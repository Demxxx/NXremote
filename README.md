# NXremote 🎮
### *Ultra-Low Latency Virtual Nintendo Switch Controller for iOS & Web*
**Created by demxxx**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: iOS 15+](https://img.shields.io/badge/Platform-iOS%2015%2B-black.svg?logo=apple)](releases/)
[![Bundle ID](https://img.shields.io/badge/Bundle%20ID-com.demxxx.nxremote-purple.svg)](ios_controller/)

---

<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="NXremote Icon" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" />
</p>

**NXremote** è un controller virtuale wireless ad altissima reattività per iPhone e iPad, progettato specificamente per giochi nativi e porting Nintendo Switch (compilati con `nxnative`, `dm`, decompilazioni o motori C/C++/SDL2).

---

## ✨ Caratteristiche Principali

- ⚡ **Zero-Configuration (Bonjour / mDNS)**: L'iPhone rileva automaticamente il gioco in esecuzione sul Mac/PC locale senza dover inserire indirizzi IP o porte manualmente.
- 📺 **Riconoscimento Automatico del Gioco**: Il display centrale mostra istantaneamente il titolo in riproduzione (es. `LUIGI'S MANSION 2`, `MARIO KART WORLD`).
- 🔋 **Indicatore Batteria Stile iPhone**: Percentuale e icona batteria vettoriale dinamica (verde con saetta in ricarica, rosso sotto il 20%).
- 🕹️ **Layout Ispirato a Citra / 3DS**:
  - **Stick Sinistro Visibile (Visuale / Movimento)**: Feedback aptico istantaneo e ritorno a molla.
  - **D-Pad a croce ergonomico**: Posizionato comodamente sotto lo stick.
  - **Dorsali completi**: [ZL] [L] a sinistra, [R] [ZR] a destra.
  - **Tasti Azione ABXY**: Diamante Nintendo con trasparenza in vetro satinato.
  - **Tasti di sistema**: [-], [+] e supporto al movimento/scuotimento fisico (Shake).
- 🚀 **Compatibilità Sideloading**: File Mach-O a 64-bit con zero `fixup_chains`, pronto per l'installazione diretta con **TrollStore**, **Feather**, **AltStore** e **SideStore**.

---

## 🚀 Come implementare l'SDK in QUALSIASI gioco fatto con `nxnative`

L'integrazione richiede solo **2 file** e **2 righe di codice C**:

### 1. File necessari
Copia dalla cartella `sdk/`:
- `switchpad_host.h`
- `switchpad_host.m`

### 2. Integrazione nel codice del gioco
Nel file principale del frontend del gioco (es. `front_mac.m` o `main.m`):

```c
#include "switchpad_host.h"
#include "dm_input.h" // Se usi l'engine nxnative / dm

// Callback invocato ad ogni pacchetto ricevuto dall'iPhone (30-60 Hz)
static void on_mobile_input(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry) {
    uint64_t full_mask = (uint64_t)(buttons & 0xffff);
    if (buttons & SWITCHPAD_BTN_SHAKE) {
        full_mask |= (1ULL << 32); // DM_BTN_SHAKE
    }
    
    // Inoltra direttamente al gioco (lx/ly muove e orienta la visuale)
    dm_pad_set(full_mask, lx, ly, rx, ry);
}

// All'avvio dell'applicazione (es. in main() o game_init()):
int main(int argc, char **argv) {
    // Avvia il server WebSocket e il broadcast Bonjour del titolo di gioco
    switchpad_host_start(8080, on_mobile_input);
    
    // ... il tuo loop di gioco normale ...
}
```

### 3. Per motori generici C / C++ o SDL2 (Polling a frame)
Se il motore legge gli input in un ciclo continuo:

```c
#include "switchpad_host.h"

// All'avvio:
switchpad_host_start(8080, NULL);

// Nel Game Loop:
uint32_t buttons = 0;
int16_t lx = 0, ly = 0, rx = 0, ry = 0;
switchpad_host_get_state(&buttons, &lx, &ly, &rx, &ry);

if (buttons & SWITCHPAD_BTN_A) {
    // Tasto A premuto
}
```

---

## 📲 Installazione

### iOS (.ipa)
Scarica l'ultimo file `.ipa` dalla cartella [releases/NXremote.ipa](releases/NXremote.ipa):
- **TrollStore**: Apri il file `.ipa` e seleziona "Install".
- **Feather / Scarlet**: Firma con il tuo certificato personale o d'impresa.
- **AltStore / SideStore**: Installa via sideloading collegando l'iPhone al Mac.

### Android (.apk e WebPad)
Il server host `switchpad_host` include già un **WebPad HTML5 zero-install**:
- Apri qualsiasi browser su Android (Chrome, Firefox, Brave) collegato alla stessa rete Wi-Fi:
  `http://<IP-DEL-MAC>:8080`
- È disponibile anche il codice sorgente per il wrapper APK nativo Android.

---

## 🔒 Protocollo di Rete (12-byte Little-Endian)
- **Porta**: `8080` TCP WebSocket (`/ws`)
- **Discovery**: Servizio mDNS `_http._tcp.` con metadati del gioco
- **Pacchetto Binario (12 byte)**:
  ```c
  struct __attribute__((packed)) {
      uint32_t buttons; // Maschera bit NpadButton (A, B, X, Y, L, R, ZL, ZR, -, +, ecc.)
      int16_t  lx;      // Stick X (-32767 a +32767)
      int16_t  ly;      // Stick Y (-32767 a +32767)
      int16_t  rx;      // Right Stick X (-32767 a +32767)
      int16_t  ry;      // Right Stick Y (-32767 a +32767)
  };
  ```

---

## 👤 Credits & Autore
- **Ideato e sviluppato da**: **demxxx**
- **Firma / Bundle ID**: `com.demxxx.nxremote`
- **Licenza**: MIT License
