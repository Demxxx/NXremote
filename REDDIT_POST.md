# Reddit Announcement Post (Ready to Post)
*Recommended Subreddits: r/macgaming, r/sideloaded, r/emulation, r/NintendoSwitchDecomps*

---

### **TITLE:**
> **[Release] NXremote: Low-latency virtual Nintendo Switch controller for iOS (.IPA) with dynamic dual sticks & C drop-in SDK for native game ports**

---

### **POST BODY:**

Hey everyone,

I wanted to share a project I've been working on: **NXremote**, an iOS companion controller app along with an ultra-lightweight C drop-in SDK designed for native game ports (like *Luigi's Mansion 2*, *Mario Kart*, and any decompilation or engine built with `nxnative`, `dm`, or C/SDL2).

### Why I built this
When playing native ports on Mac or PC, carrying a physical gamepad isn't always practical, and existing mobile remote apps often suffer from clunky UI, high input lag, or require tedious manual IP configuration every time you change Wi-Fi networks or connect over a personal hotspot.

NXremote solves this:

1. **Clean Dynamic Dual-Stick Touch Controls**:
   - Instead of static thumbsticks blocking the action, the screen is split into two clean touch zones:
     - **Left screen half**: Dynamic Stick L for character movement.
     - **Right screen half**: Dynamic Stick R for camera rotation, aiming, and flashlight.
   - Traditional Nintendo D-Pad with directional arrows, ABXY action diamond, full shoulder triggers (`ZL`/`L`/`R`/`ZR`), `+`/`-`, and physical device shake gesture support.
   - Central HUD displaying live battery percentage and connected game status.

2. **Zero-Config Multi-Network Discovery**:
   - Resolves host machines over Bonjour mDNS automatically.
   - On isolated guest Wi-Fi networks or cellular hotspots where multicast/Bonjour is blocked, NXremote automatically sweeps the local subnet in under a second and connects directly without needing manual configuration.

3. **Sub-Frame Input Latency**:
   - Streams 12-byte compact binary frames over local WebSockets at 60 Hz.

4. **2-Line C Drop-in SDK for Game Ports**:
   - If you're building a port using `nxnative` or C, the server integration takes literally two lines:
   ```c
   #include "switchpad_host.h"
   // In main():
   switchpad_host_start(8080, on_mobile_input);
   ```

5. **Ready for iOS Sideloading**:
   - Pre-compiled `.ipa` built with `LC_DYLD_INFO_ONLY` (zero chained fixup issues), tested on TrollStore, AltStore, SideStore, and Feather.

---

### Links & Downloads:
- **GitHub Repository**: https://github.com/Alexxxxxxxxx11/NXremote
- **Latest IPA Release**: https://github.com/Alexxxxxxxxx11/NXremote/releases/latest

*(Attach `assets/icon.png` and `assets/layout.png` from the repo to your Reddit post for visual preview)*

Feedback, bug reports, and PRs are welcome!

— **demxxx**
