// ==============================================================================
// SwitchPad Universal Host SDK (switchpad_host.m)
// Drop-in iOS/Phone Controller Server for any Game Port on macOS/Linux.
// ==============================================================================

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <pthread.h>
#include <stdatomic.h>
#include "switchpad_host.h"

static char g_game_title[64] = "NATIVE GAME";

void switchpad_host_set_game_title(const char *title) {
    if (title && title[0]) {
        strncpy(g_game_title, title, sizeof(g_game_title) - 1);
        g_game_title[sizeof(g_game_title) - 1] = '\0';
    }
}
static _Atomic int g_running = 0;
static _Atomic int g_connected = 0;
static char g_url[128] = "http://127.0.0.1:8080";
static switchpad_input_cb g_callback = NULL;

static _Atomic uint32_t g_state_buttons = 0;
static _Atomic int16_t  g_state_lx = 0;
static _Atomic int16_t  g_state_ly = 0;
static _Atomic int16_t  g_state_rx = 0;
static _Atomic int16_t  g_state_ry = 0;

static NSNetService *g_bonjour_service = nil;

const char *switchpad_host_get_url(void) {
    return g_url;
}

bool switchpad_host_is_connected(void) {
    return atomic_load(&g_connected) != 0;
}

void switchpad_host_get_state(uint32_t *out_buttons,
                              int16_t *out_lx, int16_t *out_ly,
                              int16_t *out_rx, int16_t *out_ry) {
    if (out_buttons) *out_buttons = atomic_load(&g_state_buttons);
    if (out_lx) *out_lx = atomic_load(&g_state_lx);
    if (out_ly) *out_ly = atomic_load(&g_state_ly);
    if (out_rx) *out_rx = atomic_load(&g_state_rx);
    if (out_ry) *out_ry = atomic_load(&g_state_ry);
}

static NSString *get_primary_ip(void) {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    if (getifaddrs(&interfaces) == 0) {
        struct ifaddrs *temp = interfaces;
        while (temp != NULL) {
            if (temp->ifa_addr && temp->ifa_addr->sa_family == AF_INET) {
                if (!(temp->ifa_flags & IFF_LOOPBACK) && (temp->ifa_flags & IFF_UP)) {
                    NSString *name = [NSString stringWithUTF8String:temp->ifa_name];
                    NSString *ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
                    if ([name hasPrefix:@"en"]) {
                        address = ip;
                        if ([name isEqualToString:@"en0"]) break;
                    }
                }
            }
            temp = temp->ifa_next;
        }
        freeifaddrs(interfaces);
    }
    return address;
}

static NSString *compute_ws_accept(const char *key) {
    const char *guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
    char combined[128];
    snprintf(combined, sizeof combined, "%s%s", key, guid);
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1((const unsigned char *)combined, (CC_LONG)strlen(combined), hash);
    NSData *d = [NSData dataWithBytes:hash length:sizeof(hash)];
    return [d base64EncodedStringWithOptions:0];
}

static void *client_worker(void *arg) {
    int fd = (int)(intptr_t)arg;
    char buf[2048];
    ssize_t n = recv(fd, buf, sizeof(buf) - 1, 0);
    if (n <= 0) { close(fd); return NULL; }
    buf[n] = 0;

    if (strstr(buf, "Upgrade: websocket") || strstr(buf, "upgrade: websocket")) {
        char *key_hdr = strstr(buf, "Sec-WebSocket-Key: ");
        if (!key_hdr) key_hdr = strstr(buf, "sec-websocket-key: ");
        if (key_hdr) {
            key_hdr += 19;
            char *end = strstr(key_hdr, "\r\n");
            if (end) *end = 0;
            NSString *accept = compute_ws_accept(key_hdr);
            char resp[512];
            snprintf(resp, sizeof resp,
                     "HTTP/1.1 101 Switching Protocols\r\n"
                     "Upgrade: websocket\r\n"
                     "Connection: Upgrade\r\n"
                     "Sec-WebSocket-Accept: %s\r\n\r\n",
                     [accept UTF8String]);
            send(fd, resp, strlen(resp), 0);

            atomic_store(&g_connected, 1);
            printf("[SwitchPad] Phone controller connected! (fd %d)\n", fd);

            while (1) {
                unsigned char h[2];
                if (recv(fd, h, 2, MSG_WAITALL) != 2) break;
                int opcode = h[0] & 0x0F;
                int masked = (h[1] & 0x80) != 0;
                uint64_t len = h[1] & 0x7F;

                if (len == 126) {
                    uint16_t l16;
                    if (recv(fd, &l16, 2, MSG_WAITALL) != 2) break;
                    len = ntohs(l16);
                } else if (len == 127) {
                    uint64_t l64;
                    if (recv(fd, &l64, 8, MSG_WAITALL) != 8) break;
                    len = __builtin_bswap64(l64);
                }

                unsigned char mask[4] = {0};
                if (masked) {
                    if (recv(fd, mask, 4, MSG_WAITALL) != 4) break;
                }

                if (opcode == 8) break; // Close
                if (opcode == 9) { // Ping
                    unsigned char pong[2] = {0x8A, 0x00};
                    send(fd, pong, 2, 0);
                    continue;
                }

                if (len > 0) {
                    unsigned char *payload = malloc(len);
                    if (!payload) break;
                    if (recv(fd, payload, len, MSG_WAITALL) != (ssize_t)len) {
                        free(payload);
                        break;
                    }
                    if (masked) {
                        for (uint64_t i = 0; i < len; i++) payload[i] ^= mask[i % 4];
                    }

                    // 12-byte SwitchPad payload
                    if (len >= 12) {
                        uint32_t btn; int16_t lx, ly, rx, ry;
                        memcpy(&btn, payload + 0, 4);
                        memcpy(&lx, payload + 4, 2);
                        memcpy(&ly, payload + 6, 2);
                        memcpy(&rx, payload + 8, 2);
                        memcpy(&ry, payload + 10, 2);

                        atomic_store(&g_state_buttons, btn);
                        atomic_store(&g_state_lx, lx);
                        atomic_store(&g_state_ly, ly);
                        atomic_store(&g_state_rx, rx);
                        atomic_store(&g_state_ry, ry);

                        if (g_callback) {
                            g_callback(btn, lx, ly, rx, ry);
                        }
                    }
                    free(payload);
                }
            }

            atomic_store(&g_connected, 0);
            atomic_store(&g_state_buttons, 0);
            atomic_store(&g_state_lx, 0);
            atomic_store(&g_state_ly, 0);
            atomic_store(&g_state_rx, 0);
            atomic_store(&g_state_ry, 0);
            if (g_callback) g_callback(0, 0, 0, 0, 0);
            printf("[SwitchPad] Phone controller disconnected (fd %d)\n", fd);
        }
    } else if (strstr(buf, "GET /api/game") || strstr(buf, "GET /info")) {
        char jresp[256];
        snprintf(jresp, sizeof jresp,
                 "HTTP/1.1 200 OK\r\n"
                 "Content-Type: application/json\r\n"
                 "Access-Control-Allow-Origin: *\r\n"
                 "Connection: close\r\n\r\n"
                 "{\"game\":\"%s\"}\n",
                 g_game_title);
        send(fd, jresp, strlen(jresp), 0);
    } else {
        // Fallback HTTP response
        const char *resp = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nSwitchPad Host Active\n";
        send(fd, resp, strlen(resp), 0);
    }

    close(fd);
    return NULL;
}

static void *server_listener(void *arg) {
    (void)arg;
    int sfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sfd < 0) return NULL;

    int opt = 1;
    setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof addr);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;

    int p = g_port;
    for (; p < g_port + 10; p++) {
        addr.sin_port = htons(p);
        if (bind(sfd, (struct sockaddr *)&addr, sizeof(addr)) == 0) break;
    }
    if (p >= g_port + 10) { close(sfd); return NULL; }
    g_port = p;

    if (listen(sfd, 16) < 0) { close(sfd); return NULL; }

    NSString *ip = get_primary_ip();
    snprintf(g_url, sizeof g_url, "http://%s:%d", [ip UTF8String], g_port);
    printf("========================================================\n");
    printf("[SwitchPad] UNIVERSAL CONTROLLER SERVER STARTED!\n");
    printf("[SwitchPad] Connect SwitchPad app to: %s\n", g_url);
    printf("========================================================\n");

    // Publish Bonjour
    dispatch_async(dispatch_get_main_queue(), ^{
        g_bonjour_service = [[NSNetService alloc] initWithDomain:@"" type:@"_http._tcp." name:@"SwitchPad Controller" port:g_port];
        [g_bonjour_service publish];
    });

    while (atomic_load(&g_running)) {
        struct pollfd pfd = {.fd = sfd, .events = POLLIN};
        int pr = poll(&pfd, 1, 1000);
        if (pr <= 0) continue;

        struct sockaddr_in caddr;
        socklen_t clen = sizeof(caddr);
        int cfd = accept(sfd, (struct sockaddr *)&caddr, &clen);
        if (cfd >= 0) {
            pthread_t ct;
            pthread_create(&ct, NULL, client_worker, (void *)(intptr_t)cfd);
            pthread_detach(ct);
        }
    }

    close(sfd);
    return NULL;
}

int switchpad_host_start(int port, switchpad_input_cb cb) {
    if (atomic_load(&g_running)) return 0;
    if (port > 0) g_port = port;
    g_callback = cb;
    atomic_store(&g_running, 1);

    pthread_t st;
    pthread_create(&st, NULL, server_listener, NULL);
    pthread_detach(st);
    return 0;
}

void switchpad_host_stop(void) {
    atomic_store(&g_running, 0);
}
