# 📢 Post Ufficiale per Reddit (Pronto da copiare e incollare)
*Subreddit consigliati: r/macgaming, r/sideloaded, r/emulation, r/NintendoSwitchDecomps*

---

### **TITOLO:**
> **[RELEASE] NXremote – Virtual Nintendo Switch Controller per iOS (.IPA) per qualsiasi porting nativo Mac/PC (nxnative/C) con zero latenza e auto-discovery!**

---

### **TESTO DEL POST:**

Ciao a tutti ragazzi! 🎮

Oggi voglio condividere con voi un progetto a cui ho lavorato: **NXremote**, un companion controller virtuale per iPhone e iPad insieme al relativo SDK in C open-source per integrare il supporto mobile in **qualsiasi porting nativo Nintendo Switch** (come *Luigi's Mansion 2*, *Mario Kart World*, e qualunque progetto compilato con `nxnative`, `dm`, decompilazioni o motori C/C++/SDL2).

---

### 🖼️ Screenshot & Icona Ufficiale (Vedi allegati al post):
*(Allega al post di Reddit le due immagini incluse nella repo: `assets/icon.png` per l'icona ufficiale e `assets/layout.png` per l'interfaccia in-game!)*

1. **Icona Ufficiale**: Design minimale Joy-Con Neon Blue/Red con onde wireless.
2. **Layout In-Game (Stile Citra Minimalist)**:
   - **Doppio Stick Dinamico Invisibile**: Tocchi il vuoto a sinistra per muovere il personaggio (`lx, ly`), tocchi il vuoto a destra per orientare la **visuale / telecamera / mira Poltergust** (`rx, ry`). Zero elementi ingombranti a coprire lo schermo!
   - **D-Pad a croce Nintendo classico** ingrandito in basso a sinistra con frecce direzionali.
   - **Tasti ABXY a diamante** in vetro satinato in basso a destra.
   - **HUD Centrale dinamico**: Riconosce da solo il gioco in riproduzione (es. `LUIGI'S MANSION 2`) con indicatore di batteria stile iPhone e percentuale reale.
   - **Dorsali completi**: [ZL] e [L] a sinistra, [R] e [ZR] a destra, tasti [-] e [+], e supporto allo scuotimento fisico dell'iPhone (Shake!).

---

### 🌐 Connessione Multi-Rete (Funziona ovunque!):
Una delle cose più frustranti di molte app controller è dover digitare l'indirizzo IP a mano o vederle smettere di funzionare appena ci si sposta su un'altra rete o hotspot.
- **Bonjour / mDNS**: Trova il Mac all'istante appena lanci il gioco.
- **Subnet Auto-Scan**: Se ti colleghi a un'altra rete Wi-Fi o a un Hotspot cellulare dove Bonjour è bloccato, NXremote scansiona la subnet locale in meno di 1 secondo e trova il Mac automaticamente!
- **Zero Configurazione**: Apri il gioco sul Mac, apri l'app sull'iPhone e sei già pronto a giocare.

---

### 💻 Per Sviluppatori & Modder (SDK Drop-In per `nxnative`):
Se state sviluppando o compilando un porting con `nxnative`, bastano letteralmente **2 file** (`switchpad_host.h` e `switchpad_host.m`) e **2 righe di codice C**:

```c
#include "switchpad_host.h"
#include "dm_input.h" // Per engine nxnative / dm

// Inoltra i comandi e la visuale al gioco a 60 Hz:
static void on_phone_input(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry) {
    dm_pad_set(buttons, lx, ly, rx, ry);
}

// Nel main():
switchpad_host_start(8080, on_phone_input);
```

---

### 📲 Download iOS (.IPA):
Il file pre-compilato **`NXremote.ipa`** è scaricabile direttamente dalla sezione Releases della repository GitHub.
- Compilato con `LC_DYLD_INFO_ONLY` (zero fixup chains per la massima compatibilità).
- Pronto all'installazione immediata con **TrollStore**, **Feather**, **AltStore** e **SideStore**.
- Firmato con identificativo `com.demxxx.nxremote`.

👉 **GitHub Repository**: https://github.com/Alexxxxxxxxx11/NXremote

Fatemi sapere cosa ne pensate nei commenti!
— **demxxx**
