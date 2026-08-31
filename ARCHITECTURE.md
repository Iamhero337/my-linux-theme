# 🏛️ System Architecture & AI Operational Blueprint

> **For Future AI Agents & Developers**:  
> This document is a complete architectural specification of the **`my-linux-theme`** desktop environment. It defines the component hierarchy, data flow, IPC mechanisms, filesystem mapping, and exact step-by-step protocols to **BACKUP**, **RESTORE**, and **EXTEND** this system without introducing regressions.

---

## 1. 🌌 High-Level System Architecture

The desktop environment is composed of loosely coupled, event-driven layers running on Wayland:

```
                      ┌────────────────────────────────────────┐
                      │          Hyprland Compositor           │
                      │  (0.56+ Wayland Tiling Window Manager) │
                      └───────────────────┬────────────────────┘
                                          │ Wayland Protocols / IPC
              ┌───────────────────────────┼───────────────────────────┐
              ▼                           ▼                           ▼
┌──────────────────────────┐ ┌──────────────────────────┐ ┌──────────────────────────┐
│   Quickshell Subsystem   │ │  Background Daemons      │ │    Theming & Stylers     │
│ - TopBar.qml             │ │ - gesture_daemon.py      │ │ - Matugen (Material You) │
│ - Main.qml (Popups)      │ │ - focus_daemon.py        │ │ - SWWW (Wallpaper daemon)│
│ - Floating.qml (Drawer)  │ │ - volume_listener.sh     │ │ - Kitty / Rofi / SwayOSD │
│ - WindowRegistry.js      │ │ - KDE Connect (kdeconnectd)│ - Cava / Waybar          │
└─────────────┬────────────┘ └────────────┬─────────────┘ └──────────────────────────┘
              │                           │
              ▼                           ▼
┌────────────────────────────────────────────────────────────────────────────────────┐
│                       Hardware & OS Integration Layer                              │
│  - PipeWire / WirePlumber / pamixer (Audio Management)                             │
│  - brightnessctl / Intel Backlight (Display Brightness)                            │
│  - libinput / /dev/input/event* (Multi-touch Gestures)                             │
│  - supergfxctl / nvidia-smi (GPU Power Switching)                                  │
│  - systemd-resolved (AdGuard DNS with DoT)                                         │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 📁 Filesystem & Component Mapping

| Repository Path | Live Target Path | Purpose & Description |
| :--- | :--- | :--- |
| `.config/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` | Root Hyprland config; sources modular subconfigs. |
| `.config/hypr/config/*.conf` | `~/.config/hypr/config/*.conf` | Modular configs (`autostart`, `env`, `keybindings`, `monitors`, `rules`, `settings`, `variables`). |
| `.config/hypr/scripts/quickshell/` | `~/.config/hypr/scripts/quickshell/` | All Quickshell QML widgets, popups, and watchers. |
| `.config/hypr/scripts/gesture_daemon.py`| `~/.config/hypr/scripts/gesture_daemon.py` | Standalone Python daemon reading `libinput` multi-touch gestures. |
| `.config/hypr/scripts/qs_manager.sh` | `~/.config/hypr/scripts/qs_manager.sh` | CLI helper to open/toggle/query Quickshell popups via IPC. |
| `.config/hypr/scripts/monitor_modes.sh`| `~/.config/hypr/scripts/monitor_modes.sh` | Dual/Single/Mirror/Extend monitor management script. |
| `.config/systemd/user/gesture-daemon.service` | `~/.config/systemd/user/gesture-daemon.service` | Systemd user unit ensuring touchpad gesture daemon resilience. |
| `.config/autostart/*.desktop` | `~/.config/autostart/` | XDG autostart desktop entries (e.g. KDE Connect). |
| `.config/kitty/` | `~/.config/kitty/` | Terminal emulator config with Matugen color auto-injection. |
| `.config/matugen/` | `~/.config/matugen/` | Dynamic Material You color scheme generator & templates. |
| `.config/rofi/` | `~/.config/rofi/` | Application runner launcher & theme definitions. |
| `.config/swayosd/` | `~/.config/swayosd/` | On-Screen Display style sheets (Volume, Brightness, CapsLock). |
| `.local/share/hypr-shortcuts/` | `~/.local/share/hypr-shortcuts/` | Interactive Python/GTK shortcut cheat sheet trainer. |

---

## 3. 🧩 Core Subsystems & Operational Mechanics

### A. Quickshell Architecture (`Shell.qml`)
- **`ShellRoot`**: Declares three primary layers:
  1. `TopBar {}`: The persistent status bar (`TopBar.qml`).
  2. `Main {}`: The lazy-loaded modal popups router (`Main.qml`).
  3. `Floating {}`: The bottom-edge quick-actions drawer (`Floating.qml`).

#### 1. Modal Popup Lifecycle & `WindowRegistry.js`
- Popups are NOT hardcoded in `Main.qml`. Instead, dimensions, positioning, and component paths are registered in [`WindowRegistry.js`](file:///home/hero/.config/hypr/scripts/quickshell/WindowRegistry.js).
- When a toggle command is executed (`qs_manager.sh toggle <name>` or `Quickshell.execDetached(...)`), `Main.qml` evaluates `WindowRegistry.get(name)`, instantiates a `Loader`, computes scaling with `Scaler.qml`, and handles smooth entry/exit animations.

#### 2. Background Watchers (`watchers/`)
- To prevent high CPU load, background monitoring uses **FIFO event streams** rather than rapid polling loops:
  - `audio_wait.sh`: Uses `pactl subscribe` piped to a FIFO. TopBar only re-queries audio when an event fires.
  - `audio_fetch.sh`: Fast JSON output formatting volume (`pamixer`), mute state, and dynamic icon.
  - `battery_wait.sh`: Watches `/sys/class/power_supply/` uevents.
  - `kb_wait.sh`: Watches Hyprland socket for active keyboard layout changes.

### B. Interactive TopBar Scroll Controls
- Located in `TopBar.qml`:
  - **Volume Pill (`volMouse`)**:
    - `onWheel`: Evaluates `wheel.angleDelta.y || wheel.angleDelta.x`.
    - Optimistically updates `barWindow.volPercent` and `volIcon` in QML instantly for 0ms visual latency.
    - Executes `wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+` or `5%-`.
    - Fires `volSyncTimer` (200ms debounce) to verify exact state against PipeWire.
  - **Battery Pill (`batMouse`)**:
    - `onWheel`: Executes `brightnessctl set 5%+` / `brightnessctl set 5%-`.

### C. Touchpad Gestures Subsystem (`gesture_daemon.py`)
- Background service managed by `gesture-daemon.service` via systemd user units.
- Subscribes directly to `libinput debug-events`:
  - **3 Fingers (Horizontal Swipe)**:
    - Left swipe $\rightarrow$ `hyprctl dispatch cyclenext` (Next Window).
    - Right swipe $\rightarrow$ `hyprctl dispatch cyclenext prev` (Previous Window).
    - Vertical movements are filtered out.
    - Debounced per physical stroke until `GESTURE_SWIPE_END`.
  - **4 Fingers (Horizontal Swipe)**:
    - Handled directly by Hyprland's native gesture engine via `gesture = 4, horizontal, workspace` in `settings.conf`.

### D. GPU Power Switcher Subsystem
- Components:
  - `GpuPopup.qml`: GUI popup displaying live VRAM gauge, GPU clock, temperature, and mode selection buttons.
  - `gpu_fetch.sh`: Queries `nvidia-smi` and active GPU profile.
  - `gpu_switch.sh`: Dispatches profile switching commands (Performance, Hybrid, APU/Integrated).

### E. Floating Quick-Actions Drawer (`Floating.qml`)
- Configured to trigger **ONLY on the bottom screen edge** (`activeEdge: "bottom"`).
- Contains 3 modular action tabs:
  - `DrawAction.qml`: Interactive whiteboard canvas using QML Canvas API.
  - `SystemUsage.qml`: Hardware telemetry graphs.
  - `Timer.qml`: Focus / Pomodoro countdown timers.

---

## 4. 🤖 SOP: Guidelines for Future AI Agents

When interacting with this repository, follow these deterministic procedures:

### 🔄 Protocol A: Full Backup (Live System ➡️ Repo)
Run the following workflow when instructed to **"backup settings"**:

```bash
REPO="$HOME/Documents/Gits/my-linux-theme"
mkdir -p "$REPO/.config" "$REPO/.local/share" "$REPO/previews"

# 1. Sync Configs
cp -r "$HOME/.config/hypr" "$REPO/.config/"
cp -r "$HOME/.config/kitty" "$REPO/.config/"
cp -r "$HOME/.config/rofi" "$REPO/.config/"
cp -r "$HOME/.config/waybar" "$REPO/.config/"
cp -r "$HOME/.config/swayosd" "$REPO/.config/"
cp -r "$HOME/.config/matugen" "$REPO/.config/"
cp -r "$HOME/.config/cava" "$REPO/.config/"

# 2. Sync Services & Autostart
mkdir -p "$REPO/.config/systemd/user" "$REPO/.config/autostart"
cp "$HOME/.config/systemd/user/gesture-daemon.service" "$REPO/.config/systemd/user/" 2>/dev/null || true
cp "$HOME/.config/autostart/org.kde.kdeconnect.daemon.desktop" "$REPO/.config/autostart/" 2>/dev/null || true

# 3. Sync Tools & Clean Cache
cp -r "$HOME/.local/share/hypr-shortcuts" "$REPO/.local/share/" 2>/dev/null || true
find "$REPO" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$REPO" -type f -name "*.pyc" -delete 2>/dev/null || true

# 4. Commit and Push
git -C "$REPO" add .
git -C "$REPO" commit -m "chore: sync configuration backup $(date +'%Y-%m-%d %H:%M')" || true
env -u GITHUB_TOKEN gh repo view Iamhero337/my-linux-theme &>/dev/null && git -C "$REPO" push origin main
```

---

### 📥 Protocol B: Safe Restore (Repo ➡️ Live System)
Run the following workflow when instructed to **"restore settings"** or deploy on a new machine:

```bash
REPO="$HOME/Documents/Gits/my-linux-theme"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 1. Backup Existing Configs
for cfg in hypr kitty rofi waybar swayosd matugen cava; do
    [ -d "$HOME/.config/$cfg" ] && mv "$HOME/.config/$cfg" "$BACKUP_DIR/"
    cp -r "$REPO/.config/$cfg" "$HOME/.config/"
done

# 2. Deploy Services & Autostart
mkdir -p "$HOME/.config/systemd/user" "$HOME/.config/autostart" "$HOME/.local/share"
cp "$REPO/.config/systemd/user/gesture-daemon.service" "$HOME/.config/systemd/user/" 2>/dev/null || true
cp "$REPO/.config/autostart/org.kde.kdeconnect.daemon.desktop" "$HOME/.config/autostart/" 2>/dev/null || true
cp -r "$REPO/.local/share/hypr-shortcuts" "$HOME/.local/share/" 2>/dev/null || true

# 3. Set Execution Permissions
chmod +x "$HOME/.config/hypr/scripts/"*.sh "$HOME/.config/hypr/scripts/"*.py 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/quickshell/volume/"*.sh "$HOME/.config/hypr/scripts/quickshell/volume/"*.py 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/quickshell/watchers/"*.sh 2>/dev/null || true

# 4. Reload Daemons
systemctl --user daemon-reload
systemctl --user enable --now gesture-daemon.service
hyprctl reload
killall quickshell 2>/dev/null || true
sleep 0.5
hyprctl dispatch exec "quickshell -p $HOME/.config/hypr/scripts/quickshell/Shell.qml"
```

---

### ➕ Protocol C: Adding a New Popup Window
To add a new popup window `Foo`:
1. Create the QML file: `~/.config/hypr/scripts/quickshell/foo/FooPopup.qml`.
2. Register it in [`WindowRegistry.js`](file:///home/hero/.config/hypr/scripts/quickshell/WindowRegistry.js):
   ```javascript
   "foo": {
       w: s(500, scale),
       h: s(400, scale),
       rx: Math.floor((mw/2) - (s(500, scale)/2)),
       ry: Math.floor((mh/2) - (s(400, scale)/2)),
       comp: "foo/FooPopup.qml"
   },
   ```
3. Add a keybinding in [`keybindings.conf`](file:///home/hero/.config/hypr/config/keybindings.conf):
   ```ini
   bind = SUPER SHIFT, X, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle foo
   ```
4. Reload Hyprland and test with `bash ~/.config/hypr/scripts/qs_manager.sh toggle foo`.

---

## ⚠️ Known Invariants & Quirks

1. **Wayland Shift + Scroll Delta Translation**:
   - Holding <kbd>Shift</kbd> while scrolling a vertical wheel causes Qt/libinput to map the delta into `angleDelta.x` instead of `angleDelta.y`. Always check both axes: `let delta = (wheel.angleDelta.y !== 0) ? wheel.angleDelta.y : wheel.angleDelta.x;`.
2. **QML Deprecation Warning**:
   - `WlrLayershell` and `PanelWindow` in Quickshell deprecate direct `height`/`width` properties in favor of `implicitHeight`/`implicitWidth`.
3. **Hyprland `layoutmsg, togglesplit`**:
   - In modern Hyprland (0.50+), the dwindle toggle dispatcher is `layoutmsg, togglesplit`, NOT `togglesplit`.
4. **AdGuard DNS Configuration**:
   - Managed via `/etc/systemd/resolved.conf.d/adguard.conf` with DNS-over-TLS (`opportunistic`) and NetworkManager `ignore-auto-dns yes`.

---

<div align="center">
  <sub>Document generated for cross-AI continuity and system preservation.</sub>
</div>
