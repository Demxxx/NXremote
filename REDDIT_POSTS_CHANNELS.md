# Reddit Community Posts (Tailored per Subreddit)

Custom posts crafted for each targeted community. Copy and paste into each subreddit, attach `assets/icon.png` and `assets/layout.png`, and post.

---

## 1. For Native Ports & Mac/PC Gaming
**Target Subreddits:** `r/macgaming`, `r/gamedev`, `r/NintendoSwitchDecomps`

### **Title:**
> **I made NXremote: an ultra-low latency virtual Switch controller for iOS (.IPA) + 2-line C SDK for native ports (nxnative/SDL2)**

### **Body:**
Hey everyone,

Whenever I wanted to play native ports on my Mac (like *Luigi’s Mansion 2* or other projects decompiled/built with `nxnative`), I found carrying an actual physical controller around inconvenient. The existing mobile controller apps were either full of ads, suffered from noticeable Bluetooth/Wi-Fi lag, or broke whenever I connected to a hotspot or guest Wi-Fi.

So I wrote **NXremote**—a dedicated iOS controller client and an ultra-lightweight C companion server:

- **Dynamic Dual-Touch Thumbsticks**: No clunky on-screen joysticks taking up half the screen. The left half of the display dynamically tracks movement (`lx, ly`), and the right half handles camera/aiming (`rx, ry`).
- **Full Switch Controls**: Complete D-pad, ABXY diamond, shoulders (`ZL`, `L`, `R`, `ZR`), and device shake detection via accelerometer.
- **Sub-frame Latency**: Sends 12-byte binary WebSocket frames at 60 Hz over the local network.
- **Zero-Config Network Auto-Discovery**: Works over Bonjour, but if you're on a mobile hotspot or isolated Wi-Fi that blocks mDNS, it automatically sweeps the local subnet in under a second and connects directly.
- **2-line C SDK for Game Ports**: If you're building or modding any game port, you just drop `switchpad_host.h`/`.m` into your tree and start the server with:
  ```c
  #include "switchpad_host.h"
  // In your init:
  switchpad_host_start(8080, on_input_callback);
  ```

It’s 100% open source under MIT. The pre-built `.ipa` is compiled with standard `LC_DYLD_INFO_ONLY` (no chained fixup issues) and works on TrollStore, AltStore, SideStore, and Feather.

- **GitHub & Code**: https://github.com/Demxxx/NXremote
- **IPA Download**: https://github.com/Demxxx/NXremote/releases/latest

Let me know if you run into any issues or want features added.

— demxxx

---

## 2. For iOS Sideloading & Mobile Tech
**Target Subreddits:** `r/sideloaded`, `r/jailbreak`, `r/AltStore`, `r/TrollStore`

### **Title:**
> **[Release] NXremote (.IPA) – Turn your iPhone into a zero-latency wireless Switch controller for PC/Mac ports**

### **Body:**
Hey /r/sideloaded,

Just released the first version of **NXremote**, an open-source virtual Nintendo Switch controller for iOS 15+. 

If you play native ports or decompilations on your computer and don't want to carry a controller around, you can install this on your phone and use it as a seamless input device over local Wi-Fi or cellular hotspot.

### Highlights:
- **Clean touch interface**: Invisible dynamic sticks—touch anywhere on the left for movement, touch anywhere on the right for camera/aim. Keeps the screen clean.
- **Low latency**: 12-byte binary WebSocket frames at 60 Hz.
- **No network headache**: Auto-discovers the game machine on your network. Even works when connected via iPhone Personal Hotspot (which normally breaks Bonjour/multicast discovery).
- **HUD telemetry**: Shows the running game title and device battery percentage right on the controller.
- **Sideloading ready**: Clean 64-bit Mach-O binary signed ad-hoc, compatible with TrollStore (permanent), AltStore, SideStore, and Feather.

The project is completely free and open-source (no ads, no tracking):
- **Download `.ipa`**: https://github.com/Demxxx/NXremote/releases/latest
- **Source Code**: https://github.com/Demxxx/NXremote

Enjoy, and let me know your thoughts!

— demxxx

---

## 3. For Emulation & Switch Communities
**Target Subreddits:** `r/emulation`, `r/SwitchHacks`, `r/SwitchPirates`, `r/SwitchHaxing`

### **Title:**
> **NXremote: Open-source virtual Switch controller app for iOS + drop-in C host SDK for game ports & homebrew**

### **Body:**
Hey guys,

Wanted to share an open-source project called **NXremote**. It's an iOS app that turns an iPhone/iPad into a responsive wireless Nintendo Switch controller, built specifically as a companion for native ports (like `nxnative`, decompilations, and standalone C/SDL2 ports).

### What makes it different from standard remote apps:
1. **Designed for gaming**: It doesn't emulate an on-screen gamepad with fixed plastic-looking analog sticks. Instead, it uses dynamic touch zones: the left screen side acts as Stick L (movement) and the right screen side acts as Stick R (camera/aiming), leaving full visibility for your fingers and HUD.
2. **True local speed**: Streams 12-byte binary packets at 60 Hz directly over local WebSockets.
3. **Multi-network fallback**: If you are playing on the go via mobile hotspot or a guest Wi-Fi network where mDNS/Bonjour discovery is blocked, the client runs an asynchronous subnet sweep in <1 second to auto-pair with your computer.
4. **Hardware gestures**: Physical iPhone shake is mapped to the Switch shake gesture (useful for Luigi's Mansion, Mario, etc.).
5. **Drop-in C SDK**: Consists of only two C files (`switchpad_host.h`/`.m`) that developers can drop into any game loop with two lines of code.

### Getting it:
The iOS `.ipa` and full source are available on GitHub:
- **Repository**: https://github.com/Demxxx/NXremote
- **Releases**: https://github.com/Demxxx/NXremote/releases/latest

Feedback and PRs are appreciated!

— demxxx
