# NXremote

A low-latency virtual Nintendo Switch controller for iOS, designed as a companion input device for native macOS/PC game ports built with `nxnative`, decompilations, and C/SDL2 game engines.

<p align="center">
  <img src="assets/icon.png" width="130" alt="NXremote">
</p>

<p align="center">
  <a href="https://github.com/Demxxx/NXremote/releases/latest"><img src="https://img.shields.io/badge/Release-v1.0.0-blue.svg" alt="Release"></a>
  <img src="https://img.shields.io/badge/Platform-iOS%2015%2B-black.svg?logo=apple" alt="Platform">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Author-demxxx-purple.svg" alt="Author">
</p>

---

## Overview

NXremote turns your iPhone or iPad into an ultra-low latency wireless controller without requiring physical gamepads or Bluetooth pairing headaches. It communicates directly with host games over local WebSockets at 60 Hz with compact 12-byte binary input packets.

### Key Features
- **Dynamic Dual-Touch Virtual Sticks**:
  - **Left Screen Half**: Dynamic Stick L (character movement). Touch anywhere on the left side to engage.
  - **Right Screen Half**: Dynamic Stick R (camera / flashlight / aiming). Touch anywhere on the right side to look around.
  - No bulky on-screen thumbsticks obstructing your view.
- **Classic Controls**: Full-sized Nintendo D-Pad with directional arrows, ABXY action diamond, and responsive shoulder triggers (`ZL`, `L`, `R`, `ZR`).
- **Physical Shake Support**: Accelerometer-based shake detection forwarded directly to the game engine.
- **Host Status & Telemetry HUD**: Displays the active game title (e.g., *Luigi's Mansion 2*) along with live device battery percentage.
- **Robust Multi-Network Discovery**:
  - Automatically resolves host machines via Bonjour mDNS.
  - Built-in asynchronous subnet auto-scan falls back gracefully on mobile hotspots and networks where multicast traffic is restricted.
  - Manual IP entry fallback available with a tap on the status bar if needed.
- **Sideloading Ready**: Mach-O binary compiled with standard `LC_DYLD_INFO_ONLY` load commands (zero chained fixups) for seamless installation via TrollStore, AltStore, SideStore, and Feather.

---

## Layout

<p align="center">
  <img src="assets/layout.png" width="85%" alt="NXremote Controller Layout">
</p>

---

## C SDK Integration

Integrating NXremote into any `nxnative` port or C/C++ game loop requires only two source files (`switchpad_host.h` and `switchpad_host.m`) and two lines of initialization code.

The SDK hosts a lightweight WebSocket server and announces its presence over Bonjour and local HTTP endpoints.

### 1. Include Files
Copy `switchpad_host.h` and `switchpad_host.m` from the `sdk/` directory into your project.

### 2. Callback-Driven Integration (`nxnative` / Event Loop)

```c
#include "switchpad_host.h"
#include "dm_input.h" // For nxnative / dm engines

// 60 Hz input callback
static void on_mobile_input(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry) {
    uint64_t mask = (uint64_t)(buttons & 0xffff);
    if (buttons & SWITCHPAD_BTN_SHAKE) {
        mask |= (1ULL << 32); // DM_BTN_SHAKE
    }
    
    // Forward inputs directly to the engine
    dm_pad_set(mask, lx, ly, rx, ry);
}

int main(int argc, char **argv) {
    // Start listener on port 8080
    switchpad_host_start(8080, on_mobile_input);

    // Normal game loop...
    return 0;
}
```

### 3. Polling Integration (Generic C / SDL2 Engines)

If your game polls inputs frame-by-frame:

```c
#include "switchpad_host.h"

// During engine startup:
switchpad_host_start(8080, NULL);

// Inside your main loop:
uint32_t buttons = 0;
int16_t lx = 0, ly = 0, rx = 0, ry = 0;
switchpad_host_get_state(&buttons, &lx, &ly, &rx, &ry);

if (buttons & SWITCHPAD_BTN_A) {
    // Button A pressed
}
// lx, ly: Left stick axes (-32768 to 32767)
// rx, ry: Right stick axes (-32768 to 32767)
```

---

## Binary Protocol Specification

Inputs are streamed over WebSocket as 12-byte little-endian binary frames:

| Offset | Type | Description |
|:---:|:---:|:---|
| `0x00` | `uint32_t` | Button bitmask (`SWITCHPAD_BTN_*`) |
| `0x04` | `int16_t` | Left Stick X axis (`-32768` to `32767`) |
| `0x06` | `int16_t` | Left Stick Y axis (`-32768` to `32767`) |
| `0x08` | `int16_t` | Right Stick X axis (`-32768` to `32767`) |
| `0x0A` | `int16_t` | Right Stick Y axis (`-32768` to `32767`) |

---

## Installation

Pre-built IPA binaries are available directly on the [Releases](https://github.com/Demxxx/NXremote/releases) page:

1. Download **`NXremote.ipa`** from [Releases](https://github.com/Demxxx/NXremote/releases/latest).
2. Install via your preferred sideloading method:
   - **TrollStore**: Direct installation with permanent entitlement.
   - **AltStore / SideStore**: Standard sideloading with free 7-day Apple ID signing.
   - **Feather / Scarlet / ESign**: Direct on-device signing with custom certificates.

---

## Author & License

- **Author**: demxxx
- **Bundle ID**: `com.demxxx.nxremote`
- **License**: MIT License. See [LICENSE](LICENSE) for details.
