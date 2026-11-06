// ==============================================================================
// SwitchPad Universal Host SDK (switchpad_host.h)
// Drop-in iOS/Phone Controller Server for any Game Port on macOS/Linux.
// Works out of the box with the SwitchPad iOS app (.ipa) and Web browsers.
// ==============================================================================

#ifndef SWITCHPAD_HOST_H
#define SWITCHPAD_HOST_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Standard Nintendo Switch NpadButton bitmask
enum {
    SWITCHPAD_BTN_A      = 1u << 0,
    SWITCHPAD_BTN_B      = 1u << 1,
    SWITCHPAD_BTN_X      = 1u << 2,
    SWITCHPAD_BTN_Y      = 1u << 3,
    SWITCHPAD_BTN_LS     = 1u << 4,
    SWITCHPAD_BTN_RS     = 1u << 5,
    SWITCHPAD_BTN_L      = 1u << 6,
    SWITCHPAD_BTN_R      = 1u << 7,
    SWITCHPAD_BTN_ZL     = 1u << 8,
    SWITCHPAD_BTN_ZR     = 1u << 9,
    SWITCHPAD_BTN_PLUS   = 1u << 10,
    SWITCHPAD_BTN_MINUS  = 1u << 11,
    SWITCHPAD_BTN_LEFT   = 1u << 12,
    SWITCHPAD_BTN_UP     = 1u << 13,
    SWITCHPAD_BTN_RIGHT  = 1u << 14,
    SWITCHPAD_BTN_DOWN   = 1u << 15,
    SWITCHPAD_BTN_SHAKE  = 1u << 16,
};

// Callback triggered whenever the phone sends an input packet
typedef void (*switchpad_input_cb)(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry);

// Start the background WebSocket + HTTP controller server
// - port: port to listen on (e.g. 8080, or 0 for default 8080)
// - cb: optional callback function to receive inputs immediately
// Returns 0 on success, < 0 on error
int switchpad_host_start(int port, switchpad_input_cb cb);

// Stop the background server
void switchpad_host_stop(void);

// Set custom game title displayed in the controller HUD (defaults to "NATIVE GAME")
void switchpad_host_set_game_title(const char *title);

// Polling alternative: read the latest atomic input state at any time
void switchpad_host_get_state(uint32_t *out_buttons,
                              int16_t *out_lx, int16_t *out_ly,
                              int16_t *out_rx, int16_t *out_ry);

// Check if a phone controller is currently connected
bool switchpad_host_is_connected(void);

// Get the server URL (e.g. "http://192.168.1.123:8080")
const char *switchpad_host_get_url(void);

#ifdef __cplusplus
}
#endif

#endif // SWITCHPAD_HOST_H
