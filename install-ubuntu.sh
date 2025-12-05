#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    HYPRLAND ATOM ONE DARK INSTALLER                          ║
# ║                        Per Ubuntu 24.04 LTS                                  ║
# ║                         Con supporto NVIDIA                                  ║
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
# │                              CHECK UBUNTU                                     │
# └──────────────────────────────────────────────────────────────────────────────┘
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    print_warning "Questo script è pensato per Ubuntu 24.04 LTS"
    read -p "Vuoi continuare comunque? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
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
# │                              AGGIORNA SISTEMA                                 │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Aggiornamento sistema"

sudo apt update && sudo apt upgrade -y
print_success "Sistema aggiornato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA FLATPAK                                     │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Flatpak"

print_info "Installazione Flatpak..."
sudo apt install -y flatpak

# Aggiungi Flathub
print_info "Aggiungendo repository Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

print_success "Flatpak configurato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          AGGIUNGI REPOSITORY                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione repository"

# Universe repository (necessario per molti pacchetti)
sudo add-apt-repository -y universe

sudo apt update
print_success "Repository configurati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              NVIDIA DRIVERS                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Driver NVIDIA"

read -p "Hai una scheda NVIDIA e vuoi installare i driver? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Rilevamento driver NVIDIA consigliato..."
    
    # Usa ubuntu-drivers per rilevare il driver migliore
    sudo apt install -y ubuntu-drivers-common
    
    # Mostra i driver disponibili
    ubuntu-drivers devices
    
    # Installa automaticamente il driver consigliato
    print_info "Installazione driver NVIDIA consigliato..."
    sudo ubuntu-drivers install
    
    # Configura per Wayland
    sudo bash -c 'echo "options nvidia_drm modeset=1 fbdev=1" > /etc/modprobe.d/nvidia.conf'
    
    # Installa supporto EGL Wayland
    sudo apt install -y libnvidia-egl-wayland1
    
    sudo update-initramfs -u
    
    print_success "Driver NVIDIA installati"
else
    print_warning "Driver NVIDIA saltati"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              PACCHETTI CORE                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione pacchetti core"

# Dipendenze build essenziali
sudo apt install -y build-essential cmake meson ninja-build pkg-config \
    libwayland-dev wayland-protocols libinput-dev \
    libxkbcommon-dev libgbm-dev libdrm-dev libseat-dev hwdata

# Pacchetti base
CORE_PACKAGES=(
    # Terminal & Shell
    kitty zsh
    
    # File Manager & Archive
    thunar thunar-archive-plugin thunar-volman gvfs
    file-roller p7zip-full unrar-free unzip zip
    
    # Audio
    pipewire pipewire-audio-client-libraries wireplumber pavucontrol playerctl
    
    # Network & Bluetooth
    network-manager bluez blueman
    
    # Screenshot & Clipboard
    flameshot grim slurp wl-clipboard
    
    # Notifications
    libnotify-bin
    
    # Authentication
    policykit-1-gnome gnome-keyring
    
    # Brightness
    brightnessctl
    
    # Qt/GTK (nomi corretti per Ubuntu 24.04)
    qtwayland5 qt6-wayland adwaita-qt
    
    # Fonts
    fonts-noto fonts-noto-color-emoji fonts-font-awesome
    
    # Icons
    papirus-icon-theme
    
    # Utilities
    jq curl wget git btop
    
    # Wayland essentials
    xwayland
)

sudo apt install -y "${CORE_PACKAGES[@]}" || print_warning "Alcuni pacchetti potrebbero non essere disponibili"
print_success "Pacchetti core installati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA FASTFETCH                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione Fastfetch"

if ! command -v fastfetch &>/dev/null; then
    print_info "Scaricando Fastfetch..."
    FASTFETCH_VERSION=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo /tmp/fastfetch.deb "https://github.com/fastfetch-cli/fastfetch/releases/download/${FASTFETCH_VERSION}/fastfetch-linux-amd64.deb"
    sudo dpkg -i /tmp/fastfetch.deb || sudo apt install -f -y
    rm /tmp/fastfetch.deb
fi
print_success "Fastfetch installato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA HYPRLAND                                    │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione Hyprland"

print_warning "NOTA: Hyprland su Ubuntu 24.04 richiede installazione manuale"
print_info "Opzioni disponibili:"
print_info "  1. Compilazione da sorgente (consigliato)"
print_info "  2. Usa il repo: https://github.com/luispabon/sway-ubuntu"
print_info "  3. Visita: https://wiki.hyprland.org/Getting-Started/Installation/"
echo

read -p "Vuoi provare a compilare Hyprland da sorgente? (richiede ~10-15 min) [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Installa CMake 3.30+ (richiesto da Hyprland)
    print_info "Verifica versione CMake..."
    CMAKE_VERSION=$(cmake --version | grep -oP 'cmake version \K[0-9.]+' | head -1)
    CMAKE_MAJOR=$(echo "$CMAKE_VERSION" | cut -d. -f1)
    CMAKE_MINOR=$(echo "$CMAKE_VERSION" | cut -d. -f2)
    
    if [ "$CMAKE_MAJOR" -lt 3 ] || { [ "$CMAKE_MAJOR" -eq 3 ] && [ "$CMAKE_MINOR" -lt 30 ]; }; then
        print_warning "CMake $CMAKE_VERSION troppo vecchio, serve 3.30+"
        print_info "Installazione CMake 3.30+ da Kitware..."
        
        # Rimuovi CMake vecchio
        sudo apt remove -y cmake
        
        # Aggiungi repo Kitware per CMake aggiornato
        wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
        echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
        sudo apt update
        sudo apt install -y cmake
        
        NEW_CMAKE_VERSION=$(cmake --version | grep -oP 'cmake version \K[0-9.]+' | head -1)
        print_success "CMake aggiornato: $CMAKE_VERSION → $NEW_CMAKE_VERSION"
    else
        print_success "CMake $CMAKE_VERSION è già aggiornato"
    fi
    
    # Installa dipendenze per compilazione
    print_info "Installazione dipendenze build..."
    sudo apt install -y \
        meson ninja-build pkg-config \
        libtomlplusplus-dev libmagic-dev libdrm-dev \
        libgles2-mesa-dev libgbm-dev libinput-dev libxcb-composite0-dev \
        libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev \
        libxcb-xfixes0-dev libpango1.0-dev libcairo2-dev libzip-dev \
        librsvg2-dev libxcb-ewmh-dev libxcb-xkb-dev libxcb-cursor-dev \
        libxcb-util-dev libpugixml-dev libseat-dev \
        glslang-tools libvulkan-dev libvulkan-volk-dev libvkfft-dev \
        hwdata libdisplay-info-dev libliftoff-dev libxcb-dri3-dev
    
    # Hyprland
    print_info "Compilazione Hyprland..."
    if [ ! -d "/tmp/Hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/Hyprland /tmp/Hyprland
    fi
    cd /tmp/Hyprland
    make all && sudo make install
    cd -
    
    print_success "Hyprland compilato e installato"
else
    print_warning "Installazione Hyprland saltata - dovrai installarlo manualmente"
fi

# Hyprlock e Hypridle (potrebbero non essere disponibili)
print_info "Tentativo installazione Hyprlock e Hypridle..."
sudo apt install -y hyprlock hypridle 2>/dev/null || {
    print_warning "Hyprlock/Hypridle non nei repository Ubuntu"
    print_info "Potrai installarli manualmente dopo"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA COMPONENTI AGGIUNTIVI                       │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione componenti aggiuntivi"

# Waybar
print_info "Installazione Waybar..."
sudo apt install -y waybar || {
    git clone https://github.com/Alexays/Waybar /tmp/Waybar
    cd /tmp/Waybar
    meson build
    ninja -C build
    sudo ninja -C build install
    cd -
}

# Rofi Wayland
print_info "Installazione Rofi..."
sudo apt install -y rofi || {
    sudo apt install -y rofi-dev
}

# Swww (wallpaper)
print_info "Installazione swww..."
if ! command -v swww &>/dev/null; then
    # Installa da cargo se disponibile
    if command -v cargo &>/dev/null; then
        cargo install swww
    else
        sudo apt install -y cargo
        cargo install swww
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    fi
fi

# SwayNC (nome corretto pacchetto Ubuntu)
print_info "Installazione SwayNC..."
sudo apt install -y sway-notification-center || {
    print_warning "SwayNC non installato da apt, provo con Flatpak..."
}

# Cliphist
print_info "Installazione cliphist..."
if ! command -v cliphist &>/dev/null; then
    if command -v go &>/dev/null; then
        go install go.senan.xyz/cliphist@latest
    else
        sudo apt install -y golang-go
        go install go.senan.xyz/cliphist@latest
        echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
    fi
fi

print_success "Componenti aggiuntivi installati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA FONTS                                       │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione font Nerd"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# CaskaydiaCove Nerd Font
if [ ! -f "$FONT_DIR/CaskaydiaCoveNerdFont-Regular.ttf" ]; then
    print_info "Scaricando CaskaydiaCove Nerd Font..."
    curl -fLo "/tmp/CascadiaCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    unzip -o /tmp/CascadiaCode.zip -d "$FONT_DIR"
    rm /tmp/CascadiaCode.zip
fi

# JetBrains Mono Nerd Font
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    print_info "Scaricando JetBrains Mono Nerd Font..."
    curl -fLo "/tmp/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
fi

fc-cache -fv
print_success "Font Nerd installati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA BRAVE BROWSER                               │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione Brave Browser"

if ! command -v brave-browser &>/dev/null; then
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser
fi
print_success "Brave Browser installato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          INSTALLA CURSORE                                     │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione cursore Bibata"

CURSOR_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSOR_DIR"

if [ ! -d "$CURSOR_DIR/Bibata-Modern-Ice" ]; then
    print_info "Scaricando Bibata Modern Ice..."
    curl -fLo "/tmp/Bibata-Modern-Ice.tar.xz" \
        "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
    tar -xf /tmp/Bibata-Modern-Ice.tar.xz -C "$CURSOR_DIR"
    rm /tmp/Bibata-Modern-Ice.tar.xz
fi
print_success "Cursore Bibata installato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          ZSH + OH-MY-ZSH                                      │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Zsh + Oh-My-Zsh + Powerlevel10k"

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

# Cambia shell di default
chsh -s $(which zsh)

print_success "Zsh + Oh-My-Zsh + Powerlevel10k configurati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          PACCHETTI SVILUPPO                                   │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione strumenti per sviluppatori"

DEV_PACKAGES=(
    git
    docker.io docker-compose
    python3 python3-pip python3-venv
    nodejs npm
    postgresql postgresql-contrib
)

read -p "Installare i pacchetti per sviluppo? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt install -y "${DEV_PACKAGES[@]}"
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    
    # VS Code
    if ! command -v code &>/dev/null; then
        print_info "Installazione VS Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        sudo apt install -y code
    fi
    
    # MongoDB
    print_info "Installazione MongoDB..."
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | \
        sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update
    sudo apt install -y mongodb-org 2>/dev/null || print_warning "MongoDB non installato"
    
    # CLI tools
    sudo apt install -y fd-find ripgrep fzf bat eza
    
    # Lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    
    print_success "Pacchetti sviluppo installati"
else
    print_warning "Pacchetti sviluppo saltati"
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          COPIA CONFIGURAZIONI                                 │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Copia delle configurazioni"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
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

# Ubuntu usa brave-browser invece di brave
sed -i 's/exec, brave$/exec, brave-browser/' "$CONFIG_DIR/hypr/hyprland.conf"

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
    sed -i 's/"battery", //' "$CONFIG_DIR/waybar/config.jsonc"
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
        
        cp -r "$ROFI_REPO/files/colors" "$CONFIG_DIR/rofi/"
        cp -r "$ROFI_REPO/files/launchers" "$CONFIG_DIR/rofi/"
        cp -r "$ROFI_REPO/files/powermenu" "$CONFIG_DIR/rofi/"
        cp "$ROFI_REPO/files/config.rasi" "$CONFIG_DIR/rofi/"
        
        # Aggiorna font
        find "$CONFIG_DIR/rofi/launchers" -path "*/shared/fonts.rasi" -exec \
            sed -i 's/font:.*$/font: "CaskaydiaCove Nerd Font Propo 14";/' {} \;
        find "$CONFIG_DIR/rofi/powermenu" -path "*/shared/fonts.rasi" -exec \
            sed -i 's/font:.*$/font: "CaskaydiaCove Nerd Font Propo 14";/' {} \;
        
        find "$CONFIG_DIR/rofi" -name "*.sh" -exec chmod +x {} \;
        
        # Configura style
        sed -i "s/theme='style-1'/theme='style-2'/" "$CONFIG_DIR/rofi/launchers/type-2/launcher.sh"
        sed -i "s/theme='style-1'/theme='style-2'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        # Aggiorna per Hyprland
        sed -i 's|betterlockscreen -l|hyprlock|' "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i 's|i3lock|hyprlock|' "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        # Correggi icone
        sed -i "s/shutdown='.*'/shutdown='󰐥'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/reboot='.*'/reboot='󰜉'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/lock='.*'/lock='󰌾'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/suspend='.*'/suspend='󰤄'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/logout='.*'/logout='󰍃'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/yes='.*'/yes='󰄬'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        sed -i "s/no='.*'/no='󰜺'/" "$CONFIG_DIR/rofi/powermenu/type-2/powermenu.sh"
        
        rm -rf "$ROFI_REPO"
        print_success "Rofi (adi1090x themes)"
    else
        print_warning "Impossibile scaricare temi Rofi"
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
        for folder in minimal misc os; do
            if [ -d "$WALLPAPER_REPO/$folder" ]; then
                cp "$WALLPAPER_REPO/$folder"/*.{png,jpg,jpeg,webp} "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
                print_info "Copiati wallpaper da: $folder"
            fi
        done
        
        rm -rf "$WALLPAPER_REPO"
        print_success "Wallpaper One Dark installati"
    else
        print_warning "Impossibile scaricare wallpaper"
    fi
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CONFIGURA GTK                                        │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione tema GTK e Cursore"

safe_mkdir "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
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

# Cursore di default
mkdir -p "$HOME/.local/share/icons/default"
cat > "$HOME/.local/share/icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Bibata-Modern-Ice
EOF

print_success "Tema GTK e cursore configurati"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CONFIGURA FLAMESHOT                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Configurazione Flameshot per Wayland"

FLAMESHOT_DIR="$HOME/.config/flameshot"
mkdir -p "$FLAMESHOT_DIR"

cat > "$FLAMESHOT_DIR/flameshot.ini" << EOF
[General]
useGrimAdapter=true
disabledGrimWarning=true
showStartupLaunchMessage=false
savePath=$HOME/Pictures/Screenshots
EOF

print_success "Flameshot configurato per Wayland (Grim adapter)"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          CREA SESSION FILE                                    │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Creazione session file per login manager"

sudo mkdir -p /usr/share/wayland-sessions

sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

print_success "Session file creato"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              COMPLETATO                                       │
# └──────────────────────────────────────────────────────────────────────────────┘
print_header "Installazione completata!"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}              SETUP COMPLETATO CON SUCCESSO!              ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${MAGENTA}Font:${NC} CaskaydiaCove Nerd Font"
echo -e "${MAGENTA}Tema GTK:${NC} Adwaita-dark"
echo -e "${MAGENTA}Temi Rofi:${NC} type-2/style-2 (adi1090x)"
echo ""
echo -e "${BLUE}Keybindings principali:${NC}"
echo -e "  ${YELLOW}SUPER + D${NC}             → Launcher (Rofi)"
echo -e "  ${YELLOW}SUPER + Return${NC}        → Terminale (Kitty)"
echo -e "  ${YELLOW}SUPER + W${NC}             → Selettore Wallpaper"
echo -e "  ${YELLOW}SUPER + H${NC}             → Mostra tutti i keybindings"
echo -e "  ${YELLOW}Power button (waybar)${NC} → Powermenu (Rofi)"
echo ""
echo -e "${RED}⚠️  RIAVVIA IL SISTEMA per applicare tutte le modifiche!${NC}"
echo ""
echo -e "${CYAN}Al login, seleziona 'Hyprland' come sessione${NC}"
echo ""

# Mostra info backup se esistono
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    echo -e "${BLUE}📦 Backup delle vecchie configurazioni:${NC}"
    echo -e "   ${BACKUP_DIR}"
    echo ""
fi

print_warning "Logout/login per applicare la nuova shell (zsh)"
