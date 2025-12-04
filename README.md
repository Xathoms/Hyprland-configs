# Hyprland Config - Atom One Dark Pro

Una configurazione moderna e pulita per Hyprland, ottimizzata per sviluppatori con NVIDIA RTX.

## 🎨 Palette Colori

| Colore | Hex | Uso |
|--------|-----|-----|
| Background | `#282c34` | Sfondo principale |
| Foreground | `#abb2bf` | Testo principale |
| Red | `#e06c75` | Errori, notifiche critiche |
| Green | `#98c379` | Successo, volume |
| Yellow | `#e5c07b` | Warning, batteria in carica |
| Blue | `#61afef` | Accento principale, bordi attivi |
| Magenta | `#c678dd` | Accento secondario |
| Cyan | `#56b6c2` | Network, info |

## 🖥️ Hardware Supportato

- **GPU**: NVIDIA RTX 4070 Super (driver proprietari configurati automaticamente)
- **Wayland**: Ottimizzato con variabili d'ambiente NVIDIA
- **Suspend/Resume**: Servizi NVIDIA abilitati automaticamente

## 📁 Struttura

```
hyprland-config/
├── hypr/
│   ├── hyprland.conf    # Configurazione principale + NVIDIA
│   ├── hyprpaper.conf   # Wallpaper
│   └── hyprlock.conf    # Lock screen
├── scripts/
│   └── keybindings.sh   # Helper keybindings (SUPER+H)
├── waybar/
│   ├── config.jsonc     # Moduli e layout
│   └── style.css        # Stile
├── rofi/
│   └── config.rasi      # App launcher
├── kitty/
│   └── kitty.conf       # Terminale
├── swaync/
│   ├── config.json      # Centro notifiche
│   └── style.css        # Stile
├── zsh/
│   ├── .zshrc           # Configurazione Zsh + Oh-My-Zsh
│   └── .p10k.zsh        # Tema Powerlevel10k
├── install.sh           # Script installazione
└── README.md
```

## ⌨️ Keybindings

> **Premi `SUPER + H` per vedere tutti i keybindings in qualsiasi momento!**

### Applicazioni
| Combo | Azione |
|-------|--------|
| `SUPER + H` | **📖 Mostra tutti i keybindings** |
| `SUPER + Return` | Terminale (Kitty) |
| `SUPER + Space` | App Launcher (Rofi) |
| `SUPER + B` | Browser (Brave) |
| `SUPER + C` | VS Code |
| `SUPER + E` | File Manager (Thunar) |
| `SUPER + V` | Clipboard History |
| `SUPER + N` | Centro Notifiche (SwayNC) |

### Gestione Finestre
| Combo | Azione |
|-------|--------|
| `SUPER + Q` | Chiudi finestra |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + F` | Fullscreen (mantieni gaps) |
| `SUPER + T` | Toggle floating |
| `SUPER + P` | Pseudo-tile |
| `SUPER + J` | Toggle split |
| `SUPER + G` | Toggle gruppo |
| `SUPER + Tab` | Cambia finestra nel gruppo |

### Navigazione
| Combo | Azione |
|-------|--------|
| `SUPER + ←/→/↑/↓` | Muovi focus |
| `SUPER + SHIFT + ←/→/↑/↓` | Sposta finestra |
| `SUPER + CTRL + ←/→/↑/↓` | Ridimensiona |

### Workspace
| Combo | Azione |
|-------|--------|
| `SUPER + 1-9, 0` | Vai al workspace |
| `SUPER + SHIFT + 1-9, 0` | Sposta finestra |
| `SUPER + Mouse Scroll` | Naviga workspace |
| `SUPER + S` | Toggle Scratchpad |
| `SUPER + SHIFT + S` | Sposta in Scratchpad |

### Screenshots
| Combo | Azione |
|-------|--------|
| `Print` | Copia area selezionata |
| `SHIFT + Print` | Salva area |
| `SUPER + Print` | Copia schermo intero |
| `SUPER + SHIFT + Print` | Salva schermo intero |

### Sistema
| Combo | Azione |
|-------|--------|
| `SUPER + SHIFT + X` | Blocca schermo |
| `SUPER + SHIFT + Q` | Esci da Hyprland |

## 🚀 Installazione

```bash
# Estrai l'archivio
unzip hyprland-atom-one-dark.zip
cd hyprland-config

# Esegui lo script di installazione
./install.sh
```

Lo script:
1. Installa `yay` se non presente
2. Installa tutti i pacchetti necessari (Rofi, Brave, SwayNC, etc.)
3. Opzionalmente installa strumenti di sviluppo
4. Copia le configurazioni in `~/.config/`
5. Abilita i servizi necessari

## 🖼️ Wallpaper & Banner

### Wallpaper
Aggiungi il tuo wallpaper in:
```
~/Pictures/Wallpapers/wallpaper.png
```

### Banner Rofi (opzionale)
Puoi aggiungere un banner personalizzato per Rofi:
```
~/.config/rofi/images/banner.png
```
Dimensioni consigliate: 550x80px

### Risorse consigliate
- [Unsplash](https://unsplash.com) - cerca "dark minimal wallpaper"
- [Wallhaven](https://wallhaven.cc) - filtra per colore #282c34

## 🔧 Personalizzazione

### Aggiungere monitor
In `hypr/hyprland.conf`:
```conf
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1
```

### Cambiare layout tastiera
```conf
input {
    kb_layout = it,us
    kb_options = grp:alt_shift_toggle
}
```

### Regolare gaps e bordi
```conf
general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
}
```

## 📦 Pacchetti Installati

### Core
- `hyprland` - Window manager
- `waybar` - Barra di stato
- `rofi-wayland` - App launcher
- `kitty` - Terminale
- `swaync` - Centro notifiche
- `brave-bin` - Browser
- `thunar` - File manager

### Shell
- `zsh` - Shell
- `oh-my-zsh` - Framework Zsh
- `powerlevel10k` - Tema prompt
- `zsh-autosuggestions` - Suggerimenti automatici
- `zsh-syntax-highlighting` - Syntax highlighting

### NVIDIA
- `nvidia-dkms` - Driver proprietari
- `nvidia-utils` - Utilities
- `libva-nvidia-driver` - VA-API
- `egl-wayland` - Supporto Wayland

### Sviluppo (opzionale)
- `visual-studio-code-bin`
- `neovim`
- `docker` + `docker-compose`
- `lazygit`
- `btop`, `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide`

## 🐚 Alias Zsh Utili

### Sistema
| Alias | Comando |
|-------|---------|
| `update` | `yay -Syu` |
| `cleanup` | `yay -Sc && yay -Yc` |
| `gpu` | `nvidia-smi` |
| `gpuwatch` | `watch -n 1 nvidia-smi` |

### Git
| Alias | Comando |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit -m` |
| `gp` | `git push` |
| `lg` | `lazygit` |

### Docker
| Alias | Comando |
|-------|---------|
| `dps` | `docker ps` |
| `dc` | `docker-compose` |
| `dcu` | `docker-compose up -d` |
| `dcd` | `docker-compose down` |

### Modern CLI
| Alias | Sostituzione |
|-------|--------------|
| `ls` | `eza --icons` |
| `cat` | `bat` |
| `find` | `fd` |
| `grep` | `ripgrep` |
| `cd` | `zoxide` |

## 🐛 Troubleshooting

### Waybar non si avvia
```bash
killall waybar
waybar &
```

### SwayNC non mostra notifiche
```bash
killall swaync
swaync &
```

### Font icons non visibili
```bash
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome
fc-cache -fv
```

### Rofi non si apre
```bash
# Verifica che sia installata la versione wayland
yay -S rofi-wayland
```

### Blur non funziona
Verifica che la GPU supporti la composizione. In caso di problemi:
```conf
decoration {
    blur {
        enabled = false
    }
}
```

---

Made with 💙 for developers
