# 🚀 KDE Neon (Wayland) Setup

A complete, battle-tested, high-performance **KDE Plasma 6 (Wayland)** environment on **KDE Neon (Ubuntu 24.04 base)** for the **Dell G15 5530 ("TheBeast")**.

---

## 🌟 Highlights & Features

### 1. 🖥️ GRUB Bootloader — CyberGRUB 2077
- **Aesthetic**: Cyberpunk 2077 high-tech HUD aesthetic with the iconic Samurai logo.
- **Resolution**: Native `1920x1080` (`GRUB_GFXMODE=1920x1080,auto`) for razor-sharp rendering.
- **Dual-Boot**: Auto-detects and displays dedicated icons for **Windows Boot Manager** and **KDE Neon / Linux**.
- **Timeout**: Set to a responsive **5 seconds** (`GRUB_TIMEOUT=5`, `GRUB_RECORDFAIL_TIMEOUT=5`).

### 2. 🛡️ Login Screen — SDDM (Post-Apocalyptic Hacker)
- **Theme**: SDDM Astronaut Theme styled with the **Post-Apocalyptic Hacker** preset.
- **Session Switcher**: Built-in dropdown button directly under the login input to effortlessly toggle between **Plasma (Wayland)** and **Plasma (X11)**.
- **Typography**: Custom system font **Fragile Bombers Attack** installed in `/usr/local/share/fonts/`.
- **System Controls**: Power controls (Shutdown, Reboot) available directly on the greeter.

### 3. 🔒 Lock Screen (`Win + L`)
- Integrated with KDE Plasma 6's **KScreenLocker**.
- Synchronized with the high-resolution **Post-Apocalyptic Hacker** wallpaper for a seamless transition between lock and login.

### 4. ⌨️ Keyboard Backlight Always On
- **Hardware BIOS Level**: Configured via Linux Dell WMI Sysman (`dell-wmi-sysman`):
  - `KbdBacklightTimeoutAc`: `Never`
  - `KbdBacklightTimeoutBatt`: `Never`
  - `KeyboardIllumination`: `Bright`
- **Driver Timeout**: Hardware inactivity timeout set to `63h` (effectively infinite).
- **Service Persistence**: Custom systemd unit [`keyboard-backlight-always-on.service`](system/systemd/keyboard-backlight-always-on.service) re-asserts brightness level `2` on boot and resume from sleep.

### 5. 🔢 NumLock Always On (End-to-End)
- **Motherboard BIOS**: Set `NumLock=Enabled` in NVRAM so it lights up at initial hardware boot.
- **Early TTY**: Systemd service [`numlock-tty.service`](system/systemd/numlock-tty.service) and `getty@.service.d/activate-numlock.conf` activate NumLock on virtual consoles `/dev/tty1`-`/dev/tty6`.
- **Login Screen (SDDM)**: Enforced via `Numlock=on` in `/etc/sddm.conf.d/kde_settings.conf` and `/var/lib/sddm/.config/kcminputrc`.
- **Desktop Session**: Set to `NumLock=0` in user `~/.config/kcminputrc` and `/etc/xdg/kcminputrc`.

### 6. 🖱️ Cursor Theme & Unified Theming
- Unified cursor: **Breeze Dark** (`breeze_cursors`, 24px).
- Synchronized across KDE Plasma 6, KWin Wayland, XWayland, GTK 3, GTK 4, systemd user environment (`systemctl --user`), and system fallback `/usr/share/icons/default/index.theme`.
- Window manager shortcuts: Restored standard shortcuts including `Alt + F4` (Close Window) and `Win + V` (KDE Clipboard).

### 7. 💻 Kitty Terminal (Ultra-Deep Dark & High-Contrast Themes)
- **Aesthetic**: Deep dark background (`#07080c` / `#16161e`), 95% opacity with KWin glassmorphic background blur, and glowing cyber accents.
- **Theme Switcher**: Quick-switch utility `kitty-theme` included in `~/.local/bin/kitty-theme`:
  - `kitty-theme cyber-hacker`: Ultra-deep dark OLED (`#07080c`) with vibrant neon cyan, emerald, coral, and gold accents.
  - `kitty-theme tokyo-night-dark`: Midnight obsidian (`#16161e`) with the iconic Tokyo Night palette.
  - `kitty-theme catppuccin-mocha`: Deep pastel crust (`#11111b`) Mocha palette.
  - `kitty-theme vesper-black`: Pure AMOLED pitch black (`#000000`) with warm minimalist accents.

---

## 📂 Repository Structure

```
kde-neon-wayland/
├── README.md               # This documentation
├── restore.sh              # One-command full restore script
├── configs/
│   ├── dot-config/         # User ~/.config files (kcminputrc, kwinrc, kglobalshortcutsrc, etc.)
│   ├── dot-icons/          # ~/.icons cursor theme inheritance
│   └── dot-local-share-icons/ # ~/.local/share/icons cursor theme inheritance
├── system/
│   ├── grub/               # /etc/default/grub & /etc/default/grub.d/
│   ├── sddm/               # /etc/sddm.conf.d/ configurations
│   ├── systemd/            # Systemd units for Backlight & NumLock
│   └── bluetooth/          # Bluetooth power management (AutoEnable=false)
├── themes/
│   ├── grub/               # CyberGRUB-2077 complete theme files
│   └── sddm/               # sddm-astronaut-theme complete theme & fonts
└── scripts/                # Individual setup and maintenance scripts
```

---

## ⚡ Quick Restoration

To restore this entire environment on a fresh or updated installation:

```bash
cd kde-neon-wayland
sudo chmod +x restore.sh
sudo ./restore.sh
```

Then reboot your machine to enjoy the seamless CyberGRUB 2077 bootloader, Hacker SDDM login, and synchronized Plasma 6 session!
