# 📢 Bozza Post per Reddit (Pronto da copiare e incollare)
*Consigliato per: r/macgaming, r/sideloaded, r/emulation o r/iOSsetups*

---

### **Titolo:**
> **[RELEASE] NXremote – Virtual Controller iOS (.IPA) per porting Mac/PC e giochi nxnative con auto-discovery Bonjour e zero latenza!**

---

### **Testo del Post:**

Ciao a tutti! 

Volevo condividere **NXremote**, un'app controller per iOS e companion SDK in C open-source che ho sviluppato per giocare ai porting nativi Nintendo Switch su Mac/PC (come *Luigi's Mansion 2*, *Mario Kart World*, e qualsiasi progetto basato su `nxnative` o motori C/SDL2) usando l'iPhone come controller a bassissima latenza.

### 🌟 Cosa fa NXremote:
- 📱 **Nessuna configurazione IP**: Grazie a Bonjour / mDNS, l'iPhone trova subito il Mac sulla rete locale appena aprite il gioco. Zero menu noiosi o IP da digitare a mano.
- 🎮 **Riconosce il gioco in riproduzione**: Il display centrale in alto mostra in tempo reale il titolo in esecuzione (es. *LUIGI'S MANSION 2*) e lo stato della batteria dell'iPhone con grafica vettoriale Apple (verde con saetta quando in carica, percentuale reale).
- 🕹️ **Layout Citra Minimal Glass**:
  - **Stick analogico sinistro dedicato e visibile** per la visuale e il movimento fluido con feedback aptico e ritorno a molla.
  - **D-Pad a croce** classico posizionato in basso a sinistra.
  - Tasti azione Switch ABXY a diamante a destra.
  - Dorsali sdoppiati: [ZL] e [L] a sinistra, [R] e [ZR] a destra.
  - Tasti [-], [+] e supporto allo scuotimento fisico dell'iPhone (Shake).
- ⚡ **Latenza istantanea**: Pacchetti binari ultra-compatti da 12 byte a 60 Hz via WebSocket locale.

---

### 📦 Per gli Sviluppatori (SDK C Drop-In per `nxnative`):
Se state sviluppando un porting, una decompilazione Switch o un gioco con `nxnative`, basta includere `switchpad_host.h` e `switchpad_host.m` nel vostro progetto:

```c
#include "switchpad_host.h"
#include "dm_input.h"

static void on_controller(uint32_t buttons, int16_t lx, int16_t ly, int16_t rx, int16_t ry) {
    dm_pad_set(buttons, lx, ly, rx, ry);
}

// In main():
switchpad_host_start(8080, on_controller);
```
Fatto! Il gioco fa da solo il broadcast Bonjour del titolo e riceve i comandi dall'iPhone.

---

### 📲 Download:
- **iOS (.IPA)**: Il file `NXremote.ipa` (firmato `com.demxxx.nxremote`, compilato con `LC_DYLD_INFO_ONLY` compatibile al 100% con TrollStore, Feather, AltStore e SideStore) è disponibile nella sezione Releases della repo.
- **Android**: Per chi usa Android, il server include un WebPad HTML5 touch a zero installazione accessibile direttamente da browser (`http://<IP-MAC>:8080`).

👉 **Repository GitHub**: *(Inserisci il tuo link GitHub)*

Fatemi sapere cosa ne pensate e buon divertimento!
— **demxxx**
