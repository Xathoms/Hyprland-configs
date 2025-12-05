#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                         KEYBINDINGS HELPER                                    ║
# ║                          usando Rofi                                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

ROFI_THEME="$HOME/.config/rofi/launchers/type-2/style-2.rasi"

# Keybindings list
keybindings="━━━━━━━━━━ APPLICAZIONI ━━━━━━━━━━
Super + Return          Terminale (Kitty)
Super + D               App Launcher (Rofi)
Super + E               File Manager (Thunar)
Super + B               Browser (Brave)
Super + C               VS Code
Super + V               Clipboard History
Super + N               Centro Notifiche
Super + H               Questa guida

━━━━━━━━━━ GESTIONE FINESTRE ━━━━━━━━━━
Super + Q               Chiudi finestra
Super + Shift + Q       Esci da Hyprland
Super + F               Fullscreen
Super + Shift + F       Fake Fullscreen
Super + T               Toggle Float
Super + P               Pseudo tiling
Super + J               Toggle Split
Super + K               Scambia finestra con l'ultima
Super + G               Toggle Group
Super + Tab             Cambia finestra nel gruppo

━━━━━━━━━━ FOCUS & MOVIMENTO ━━━━━━━━━━
Super + ←↑↓→            Sposta focus
Super + Shift + ←↑↓→    Sposta finestra
Super + Ctrl + ←↑↓→     Ridimensiona finestra
Super + Mouse L         Trascina finestra
Super + Mouse R         Ridimensiona con mouse

━━━━━━━━━━ WORKSPACES ━━━━━━━━━━
Super + 1-0             Vai a workspace 1-10
Super + Shift + 1-0     Sposta a workspace 1-10
Super + S               Scratchpad (toggle)
Super + Shift + S       Sposta a scratchpad
Super + Scroll          Cambia workspace

━━━━━━━━━━ SCREENSHOT ━━━━━━━━━━
Print                   Screenshot area (selezione)
Shift + Print           Screenshot intero schermo
Super + Print           Screenshot ritardato (2s)

━━━━━━━━━━ WALLPAPER ━━━━━━━━━━
Super + W               Selettore Wallpaper

━━━━━━━━━━ SESSIONE ━━━━━━━━━━
Super + Shift + X       Blocca schermo (Hyprlock)

━━━━━━━━━━ MEDIA & HARDWARE ━━━━━━━━━━
XF86AudioRaiseVolume    Volume +5%
XF86AudioLowerVolume    Volume -5%
XF86AudioMute           Mute toggle
XF86AudioPlay           Play/Pause
XF86AudioNext           Traccia successiva
XF86AudioPrev           Traccia precedente
XF86MonBrightnessUp     Luminosità +5%
XF86MonBrightnessDown   Luminosità -5%"

# Mostra con rofi
echo "$keybindings" | rofi -dmenu -i -p "  Keybindings" -theme "${ROFI_THEME}" \
    -theme-str 'listview { columns: 1; lines: 25; }' \
    -theme-str 'window { width: 550px; }' \
    -theme-str 'element { padding: 6px 12px; }' \
    -theme-str 'element-text { font: "CaskaydiaCove Nerd Font Mono 10"; }'
