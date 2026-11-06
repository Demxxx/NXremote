/**
 * NXremote SDK - Example Integration for nxnative / dm_input based ports
 * 
 * Works with Switch decompilations & native game ports (nxnative / C / SDL2).
 */

#include "switchpad_host.h"
#include <stdio.h>
#include <stdint.h>

// Forward declaration of your engine's input feeder (e.g. dm_pad_set or SDL_PushEvent)
// Example for nxnative / dm_input:
extern void dm_pad_set(uint64_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry);

#define DM_BTN_SHAKE (1ULL << 32)

// Callback invoked on each packet received from the mobile app (30-60 Hz, ultra-low latency UDP/WS)
static void on_mobile_controller_input(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry) {
    uint64_t full_mask = (uint64_t)(buttons & 0xffff);
    
    // Optional: map virtual SHAKE button or accelerometer shake gesture
    if (buttons & SWITCHPAD_BTN_SHAKE) {
        full_mask |= DM_BTN_SHAKE;
    }
    
    // Forward directly to the game's native input pipeline
    dm_pad_set(full_mask, lx, ly, rx, ry);
}

void init_nxremote_controller(void) {
    // 1. Starts WebSocket server on port 8080
    // 2. Publishes Bonjour / mDNS zero-conf service so iPhone discovers it automatically
    // 3. Serves /api/game with the running title name
    int port = 8080;
    switchpad_host_start(port, on_mobile_controller_input);
    printf("[NXremote] Host server listening on port %d with Bonjour discovery active.\n", port);
}
