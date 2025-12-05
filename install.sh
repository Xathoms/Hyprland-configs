#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    HYPRLAND ATOM ONE DARK INSTALLER                          ║
# ║                      Per Arch Linux - Programmatori                          ║
# ║                         Con supporto NVIDIA RTX                              ║
# ║                                                                              ║
# ║  Questo script può essere rieseguito per aggiornare le configurazioni        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${CYAN}→${NC} $1"; }

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              CHECK ROOT                                       │
# └──────────────────────────────────────────────────────────────────────────────┘
if [ "$EUID" -eq 0 ]; then
    print_error "Non eseguire questo script come root!"
    exit 1
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CONFIGURAZIONE INIZIALE                              │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione iniziale"

echo -e "${YELLOW}Stai installando su un laptop o desktop?${NC}"
echo "1) Laptop (con batteria)"
echo "2) Desktop (senza batteria)"
read -p "Scelta [1/2]: " -n 1 -r DEVICE_TYPE
echo

IS_LAPTOP=false
if [[ $DEVICE_TYPE == "1" ]]; then
    IS_LAPTOP=true
    print_info "Configurazione per Laptop (batteria abilitata)"
else
    print_info "Configurazione per Desktop (senza batteria)"
fi

echo -e "${YELLOW}Quale layout tastiera vuoi usare?${NC}"
echo "1) Italiano (it)"
echo "2) US International (us,intl)"
read -p "Scelta [1/2]: " -n 1 -r KB_CHOICE
echo

KB_LAYOUT="it"
if [[ $KB_CHOICE == "2" ]]; then
    KB_LAYOUT="us"
    KB_VARIANT=",intl"
    print_info "Layout tastiera: US International"
else
    KB_VARIANT=""
    print_info "Layout tastiera: Italiano"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              INSTALL YAY                                      │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Verifica AUR Helper (yay)"

if ! command -v yay &> /dev/null; then
    print_warning "yay non trovato, installazione in corso..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay
    print_success "yay installato"
else
    print_success "yay già installato"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              NVIDIA DRIVERS                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Driver NVIDIA"

read -p "Hai una scheda NVIDIA e vuoi installare i driver? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    NVIDIA_PACKAGES=(
        nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
        libva-nvidia-driver linux-headers egl-wayland
    )

    print_info "Installazione driver NVIDIA proprietari..."
    sudo pacman -S --needed --noconfirm "${NVIDIA_PACKAGES[@]}"

    # Configura moduli kernel per NVIDIA
    print_info "Configurazione moduli kernel NVIDIA..."
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_UsePageAttributeTable=1
EOF

    # Aggiungi moduli a mkinitcpio se non presenti
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        print_info "Aggiunta moduli NVIDIA a mkinitcpio..."
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
    fi

    # Abilita servizi NVIDIA
    sudo systemctl enable nvidia-suspend.service 2>/dev/null || true
    sudo systemctl enable nvidia-hibernate.service 2>/dev/null || true
    sudo systemctl enable nvidia-resume.service 2>/dev/null || true

    print_success "Driver NVIDIA configurati"
else
    print_warning "Driver NVIDIA saltati"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              PACCHETTI CORE                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione pacchetti core Hyprland"

# Pacchetti dai repository ufficiali (pacman)
PACMAN_PACKAGES=(
    # Hyprland & Core
    hyprland hyprlock hypridle xdg-desktop-portal-hyprland
    
    # Wallpaper (swww)
    swww
    
    # Bar & Launcher
    waybar rofi-wayland
    
    # Terminal
    kitty
    
    # Notifications
    swaync libnotify
    
    # File Manager & Archive
    thunar thunar-archive-plugin thunar-volman gvfs
    file-roller p7zip unrar unzip zip
    
    # Audio
    pipewire pipewire-audio pipewire-pulse wireplumber pavucontrol playerctl
    
    # Network & Bluetooth
    networkmanager nm-connection-editor bluez bluez-utils blueman
    
    # Screenshot & Clipboard
    flameshot grim slurp wl-clipboard cliphist
    
    # Authentication
    polkit-kde-agent gnome-keyring
    
    # Brightness
    brightnessctl
    
    # Qt/GTK Theming
    qt5-wayland qt6-wayland qt6ct nwg-look
    
    # Fonts
    ttf-cascadia-code-nerd ttf-font-awesome noto-fonts noto-fonts-emoji
    ttf-jetbrains-mono-nerd ttf-iosevka-nerd
    
    # Icons & Themes
    papirus-icon-theme
    
    # Utilities
    swayidle fastfetch jq btop
)

# Pacchetti da AUR
AUR_PACKAGES=(
    brave-bin
    adw-gtk-theme
    bibata-cursor-theme
)

print_info "Installazione pacchetti dai repository ufficiali..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

print_info "Installazione pacchetti da AUR..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

print_success "Pacchetti core installati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          FONT ADDIZIONALI (Manual)                            │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione font addizionali"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Scarica font non disponibili nei repo
# GrapeNuts
if [ ! -f "$FONT_DIR/GrapeNuts-Regular.ttf" ]; then
    print_info "Scaricamento GrapeNuts..."
    curl -sL "https://github.com/nicokosi/google-fonts/raw/main/ofl/grapenuts/GrapeNuts-Regular.ttf" -o "$FONT_DIR/GrapeNuts-Regular.ttf" 2>/dev/null || \
    curl -sL "https://fonts.google.com/download?family=Grape%20Nuts" -o /tmp/grapenuts.zip && unzip -q -o /tmp/grapenuts.zip -d /tmp/grapenuts && cp /tmp/grapenuts/*.ttf "$FONT_DIR/" 2>/dev/null || true
fi

# Icomoon Feather (comunemente incluso in hyprlock themes)
if [ ! -f "$FONT_DIR/Icomoon-Feather.ttf" ]; then
    print_info "Scaricamento Icomoon-Feather..."
    curl -sL "https://github.com/MrVivekRajan/Hyprlock-Styles/raw/main/Starter-Font/Icomoon-Feather.ttf" -o "$FONT_DIR/Icomoon-Feather.ttf" 2>/dev/null || true
fi

# Aggiorna cache font
fc-cache -fv > /dev/null 2>&1
print_success "Font installati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              ZSH + OH-MY-ZSH                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Zsh + Oh-My-Zsh + Powerlevel10k"

yay -S --needed --noconfirm zsh

# Installa Oh-My-Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installazione Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Installa Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    print_info "Installazione Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Installa plugin Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

print_success "Zsh + Oh-My-Zsh + Powerlevel10k configurati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          PACCHETTI SVILUPPO                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione strumenti per sviluppatori"

DEV_PACKAGES=(
    visual-studio-code-bin git lazygit btop
    docker docker-compose python python-pip nodejs npm
    dbeaver eza bat fd ripgrep fzf zoxide
    postgresql mongodb-bin
)

read -p "Installare i pacchetti per sviluppo? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    yay -S --needed --noconfirm "${DEV_PACKAGES[@]}"
    sudo systemctl enable docker.service
    sudo usermod -aG docker "$USER"
    print_success "Pacchetti sviluppo installati"
else
    print_warning "Pacchetti sviluppo saltati"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          COPIA CONFIGURAZIONI                                 │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Copia file di configurazione"

CONFIG_DIR="$HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/backup-old-dotfiles/$(date +%Y%m%d_%H%M%S)"

# Funzione per copiare con backup centralizzato
copy_config() {
    local src="$1"
    local dest="$2"
    
    # Se esiste qualcosa in dest, fai backup e rimuovi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Crea cartella backup se non esiste
        mkdir -p "$BACKUP_DIR"
        
        # Calcola il percorso relativo per mantenere la struttura
        local relative_path="${dest#$HOME/}"
        local backup_path="$BACKUP_DIR/$relative_path"
        
        print_warning "Backup: $dest -> $backup_path"
        mkdir -p "$(dirname "$backup_path")"
        
        # Prova a spostare, se fallisce rimuovi
        if ! mv "$dest" "$backup_path" 2>/dev/null; then
            print_warning "Impossibile spostare, rimuovo: $dest"
            rm -rf "$dest"
        fi
    fi
    
    # Ora copia in base al tipo di sorgente
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -r "$src"/* "$dest"/ 2>/dev/null || true
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
    fi
}

# Funzione per creare directory rimuovendo eventuali file omonimi
safe_mkdir() {
    for dir in "$@"; do
        # Se esiste qualcosa (file, link, o directory non vuota), gestiscilo
        if [ -e "$dir" ] || [ -L "$dir" ]; then
            # Se è già una directory, non fare nulla
            if [ -d "$dir" ] && [ ! -L "$dir" ]; then
                continue
            fi
            
            # Per tutto il resto (file, link, directory-link), fai backup e rimuovi
            mkdir -p "$BACKUP_DIR"
            local relative_path="${dir#$HOME/}"
            local backup_path="$BACKUP_DIR/$relative_path"
            
            print_warning "Backup: $dir -> $backup_path"
            mkdir -p "$(dirname "$backup_path")"
            
            # Prova a spostare
            if ! mv "$dir" "$backup_path" 2>/dev/null; then
                print_warning "Impossibile spostare, rimuovo forzatamente: $dir"
                rm -rf "$dir"
            fi
        fi
        
        # Ora crea la directory (sarà sempre possibile)
        mkdir -p "$dir"
    done
}

# Hyprland
copy_config "$SCRIPT_DIR/hypr" "$CONFIG_DIR/hypr"
mkdir -p "$CONFIG_DIR/hypr/scripts"
cp "$SCRIPT_DIR/scripts/"* "$CONFIG_DIR/hypr/scripts/"
chmod +x "$CONFIG_DIR/hypr/scripts/"*

# Imposta layout tastiera
sed -i "s/kb_layout = KEYBOARD_LAYOUT_PLACEHOLDER/kb_layout = $KB_LAYOUT/" "$CONFIG_DIR/hypr/hyprland.conf"
if [ -n "$KB_VARIANT" ]; then
    sed -i "/kb_layout/a\\    kb_variant = intl" "$CONFIG_DIR/hypr/hyprland.conf"
fi
print_info "Layout tastiera: $KB_LAYOUT"

# Auto-rileva e configura monitor
print_info "Rilevamento automatico monitor..."
if command -v hyprctl &> /dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
    # Se Hyprland è già in esecuzione, rileva i monitor
    MONITOR_INFO=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | "\(.name),\(.width)x\(.height)@\(.refreshRate),\(.x)x\(.y),1"' 2>/dev/null)
    if [ -n "$MONITOR_INFO" ] && [ "$MONITOR_INFO" != "null" ]; then
        sed -i "s|monitor=,preferred,auto,1|monitor=$MONITOR_INFO|" "$CONFIG_DIR/hypr/hyprland.conf"
        print_success "Monitor configurato automaticamente: $MONITOR_INFO"
    else
        print_warning "Auto-rilevazione fallita, uso 'preferred' (configurazione automatica)"
    fi
else
    print_info "Hyprland non in esecuzione, verrà usato 'preferred' (auto)"
fi

print_success "Hyprland"

# Waybar
copy_config "$SCRIPT_DIR/waybar" "$CONFIG_DIR/waybar"

# Modifica waybar config in base al tipo di dispositivo
if [ "$IS_LAPTOP" = false ]; then
    # Desktop: rimuovi batteria, aggiungi CPU e memoria prima di custom/power
    sed -i 's/"battery", //' "$CONFIG_DIR/waybar/config.jsonc"
    sed -i 's/"custom\/power"/"cpu", "memory", "custom\/power"/' "$CONFIG_DIR/waybar/config.jsonc"
    print_info "Waybar configurato per Desktop (CPU + Memory invece di Battery)"
else
    print_info "Waybar configurato per Laptop (con Battery)"
fi
print_success "Waybar"

# Rofi (scarica da adi1090x/rofi)
if [ -d "$CONFIG_DIR/rofi/launchers" ] && [ -d "$CONFIG_DIR/rofi/powermenu" ]; then
    print_success "Rofi già configurato, skip download"
else
    print_info "Scaricando temi Rofi da adi1090x/rofi..."
    ROFI_REPO="/tmp/adi1090x-rofi"
    
    if [ -d "$ROFI_REPO" ]; then
        rm -rf "$ROFI_REPO"
    fi
    
    git clone --depth 1 https://github.com/adi1090x/rofi.git "$ROFI_REPO" 2>/dev/null
    
    if [ -d "$ROFI_REPO/files" ]; then
        mkdir -p "$CONFIG_DIR/rofi"
        
        # Copia colors, launchers, powermenu e config.rasi
        cp -r "$ROFI_REPO/files/colors" "$CONFIG_DIR/rofi/"
        cp -r "$ROFI_REPO/files/launchers" "$CONFIG_DIR/rofi/"
        cp -r "$ROFI_REPO/files/powermenu" "$CONFIG_DIR/rofi/"
        cp "$ROFI_REPO/files/config.rasi" "$CONFIG_DIR/rofi/"
        
        # Aggiorna font in tutti i launchers
        find "$CONFIG_DIR/rofi/launchers" -path "*/shared/fonts.rasi" -exec \
            sed -i 's/font:.*$/font: "CaskaydiaCove Nerd Font Propo 14";/' {} \;
        
        # Aggiorna font in tutti i powermenu
        find "$CONFIG_DIR/rofi/powermenu" -path "*/shared/fonts.rasi" -exec \
            sed -i 's/font:.*$/font: "CaskaydiaCove Nerd Font Propo 14";/' {} \;
        
        # Rendi eseguibili tutti gli script
        find "$CONFIG_DIR/rofi" -name "*.sh" -exec chmod +x {} \;
        
        # Configura launcher type-2 con style-2 e powermenu con style-2
        sed -i "s/theme='style-1'/theme='style-2'/" "$CONFIG_DIR/rofi/launchers/type-2/launcher.sh"
        sed -i "s/theme='style-1'/theme='style-2'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        # Aggiorna powermenu per Hyprland e correggi icone con Nerd Font
        sed -i 's|betterlockscreen -l|hyprlock|' "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i 's|i3lock|hyprlock|' "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        # Correggi icone powermenu con Nerd Font (CaskaydiaCove)
        # Ordine: lock, suspend, logout, reboot, shutdown, yes, no
        sed -i "s/shutdown='.*'/shutdown='󰐥'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/reboot='.*'/reboot='󰜉'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/lock='.*'/lock='󰌾'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/suspend='.*'/suspend='󰤄'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/logout='.*'/logout='󰍃'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/yes='.*'/yes='󰄬'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/no='.*'/no='󰜺'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        # Pulizia
        rm -rf "$ROFI_REPO"
        print_success "Rofi (adi1090x themes)"
    else
        print_warning "Impossibile scaricare temi Rofi"
        # Fallback: copia dalla config locale se presente
        if [ -d "$SCRIPT_DIR/rofi" ]; then
            copy_config "$SCRIPT_DIR/rofi" "$CONFIG_DIR/rofi"
            find "$CONFIG_DIR/rofi" -name "*.sh" -exec chmod +x {} \;
            print_success "Rofi (fallback locale)"
        fi
    fi
fi

# Kitty
copy_config "$SCRIPT_DIR/kitty" "$CONFIG_DIR/kitty"
print_success "Kitty"

# SwayNC
copy_config "$SCRIPT_DIR/swaync" "$CONFIG_DIR/swaync"
print_success "SwayNC"

# Fastfetch
copy_config "$SCRIPT_DIR/fastfetch" "$CONFIG_DIR/fastfetch"
print_success "Fastfetch"

# Zsh - con backup centralizzato
if [ -f "$HOME/.zshrc" ]; then
    mkdir -p "$BACKUP_DIR"
    print_warning "Backup: $HOME/.zshrc -> $BACKUP_DIR/.zshrc"
    mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
fi
if [ -f "$HOME/.p10k.zsh" ]; then
    mkdir -p "$BACKUP_DIR"
    print_warning "Backup: $HOME/.p10k.zsh -> $BACKUP_DIR/.p10k.zsh"
    mv "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh"
fi
cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
print_success "Zsh"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CREA CARTELLE                                        │
# └──────────────────────────────────────────────────────────────────────────────┘
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"
print_success "Cartelle create"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          SCARICA WALLPAPER ONEDARK                            │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Download wallpaper One Dark"

# Verifica se ci sono già wallpaper
WALLPAPER_COUNT=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | wc -l)

if [ "$WALLPAPER_COUNT" -gt 5 ]; then
    print_success "Wallpaper già presenti ($WALLPAPER_COUNT trovati), skip download"
else
    WALLPAPER_REPO="/tmp/onedark-wallpapers"
    
    if [ -d "$WALLPAPER_REPO" ]; then
        rm -rf "$WALLPAPER_REPO"
    fi
    
    print_info "Clonando repository wallpaper..."
    git clone --depth 1 https://github.com/Narmis-E/onedark-wallpapers.git "$WALLPAPER_REPO" 2>/dev/null
    
    if [ -d "$WALLPAPER_REPO" ]; then
        # Copia wallpaper dalle cartelle specifiche
        for folder in minimal misc os; do
            if [ -d "$WALLPAPER_REPO/$folder" ]; then
                cp "$WALLPAPER_REPO/$folder"/*.{png,jpg,jpeg,webp} "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
                print_info "Copiati wallpaper da: $folder"
            fi
        done
        
        # Pulizia
        rm -rf "$WALLPAPER_REPO"
        print_success "Wallpaper One Dark installati"
    else
        print_warning "Impossibile scaricare wallpaper (controlla la connessione)"
    fi
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CONFIGURA TEMA GTK                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione tema GTK e Cursore"

safe_mkdir "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=CaskaydiaCove Nerd Font 11
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF

cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/"

# Configura cursore di default per X11
mkdir -p "$HOME/.local/share/icons/default"
cat > "$HOME/.local/share/icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Bibata-Modern-Ice
EOF

print_success "Tema GTK e cursore Bibata configurati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          IMPOSTA ZSH COME DEFAULT                             │
# └──────────────────────────────────────────────────────────────────────────────┘
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Impostazione Zsh come shell predefinita..."
    chsh -s $(which zsh)
    print_success "Zsh impostata come shell predefinita"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          ABILITA SERVIZI                                      │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Abilitazione servizi"
sudo systemctl enable NetworkManager 2>/dev/null || true
sudo systemctl enable bluetooth 2>/dev/null || true
print_success "Servizi abilitati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CONFIGURA FLAMESHOT                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Flameshot per Wayland"

FLAMESHOT_DIR="$HOME/.config/flameshot"
mkdir -p "$FLAMESHOT_DIR"

cat > "$FLAMESHOT_DIR/flameshot.ini" << 'EOF'
[General]
useGrimAdapter=true
disabledGrimWarning=true
showStartupLaunchMessage=false
savePath=/home/$USER/Pictures/Screenshots
EOF

# Sostituisci $USER con il valore reale
sed -i "s|\$USER|$USER|g" "$FLAMESHOT_DIR/flameshot.ini"
print_success "Flameshot configurato per Wayland (Grim adapter)"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              COMPLETATO                                       │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione completata!"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}              SETUP COMPLETATO CON SUCCESSO!              ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${MAGENTA}Font:${NC} CaskaydiaCove Nerd Font (Mono per terminale, Propo per Rofi)"
echo -e "${MAGENTA}Tema GTK:${NC} adw-gtk3-dark"
echo -e "${MAGENTA}Temi Rofi:${NC} type-2/style-2 (adi1090x)"
echo ""
echo -e "${BLUE}Keybindings principali:${NC}"
echo -e "  ${YELLOW}SUPER + D${NC}             → Launcher (Rofi)"
echo -e "  ${YELLOW}SUPER + Return${NC}        → Terminale (Kitty)"
echo -e "  ${YELLOW}SUPER + W${NC}             → Selettore Wallpaper"
echo -e "  ${YELLOW}SUPER + H${NC}             → Mostra tutti i keybindings"
echo -e "  ${YELLOW}Power button (waybar)${NC} → Powermenu (Rofi)"
echo ""
echo -e "${RED}⚠️  RIAVVIA IL SISTEMA per applicare i driver NVIDIA!${NC}"
echo ""

# Mostra info backup se esistono
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    echo -e "${BLUE}📦 Backup delle vecchie configurazioni:${NC}"
    echo -e "   ${BACKUP_DIR}"
    echo ""
fi

print_warning "Logout/login per applicare la nuova shell (zsh)"
