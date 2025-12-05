#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                         MONITOR CONFIGURATION HELPER                          ║
# ║                     Auto-rileva e configura monitor                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"
BACKUP_DIR="$HOME/backup-old-dotfiles/monitor-configs"

# Colori
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════╗${NC}\n"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }

# Verifica che Hyprland sia in esecuzione
if ! command -v hyprctl &> /dev/null || [ -z "$WAYLAND_DISPLAY" ]; then
    print_error "Hyprland non è in esecuzione!"
    echo "Esegui questo script dopo aver avviato Hyprland."
    exit 1
fi

print_header "Configurazione Monitor Hyprland"

# Ottieni lista monitor
echo -e "${YELLOW}Monitor rilevati:${NC}\n"
hyprctl monitors | grep -E "Monitor|ID|resolution|refreshRate" | sed 's/^/  /'
echo ""

# Rileva monitor principale
MONITORS=$(hyprctl monitors -j)
NUM_MONITORS=$(echo "$MONITORS" | jq '. | length')

if [ "$NUM_MONITORS" -eq 0 ]; then
    print_error "Nessun monitor rilevato!"
    exit 1
fi

print_info "Trovati $NUM_MONITORS monitor"
echo ""

# Menu di scelta
echo -e "${YELLOW}Cosa vuoi fare?${NC}"
echo "1) Auto-configura monitor principale (consigliato)"
echo "2) Configura manualmente tutti i monitor"
echo "3) Ripristina a 'preferred' (auto-detect di Hyprland)"
echo "4) Mostra configurazione attuale"
echo "5) Esci"
echo ""
read -p "Scelta [1-5]: " -n 1 -r CHOICE
echo ""

case $CHOICE in
    1)
        print_info "Auto-configurazione monitor principale..."
        MONITOR_INFO=$(echo "$MONITORS" | jq -r '.[0] | "monitor=\(.name),\(.width)x\(.height)@\(.refreshRate),\(.x)x\(.y),1"')
        
        # Backup centralizzato
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/hyprland.conf.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_warning "Backup salvato: $BACKUP_FILE"
        
        # Sostituisci configurazione monitor
        sed -i "/^monitor=/c\\$MONITOR_INFO" "$CONFIG_FILE"
        
        print_success "Monitor configurato: $MONITOR_INFO"
        print_info "Ricarica Hyprland con: hyprctl reload"
        ;;
        
    2)
        print_info "Configurazione manuale..."
        echo ""
        
        # Backup centralizzato
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/hyprland.conf.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_warning "Backup salvato: $BACKUP_FILE"
        
        # Rimuovi tutte le configurazioni monitor esistenti
        sed -i '/^monitor=/d' "$CONFIG_FILE"
        
        # Aggiungi configurazione per ogni monitor
        for ((i=0; i<$NUM_MONITORS; i++)); do
            MONITOR_NAME=$(echo "$MONITORS" | jq -r ".[$i].name")
            MONITOR_WIDTH=$(echo "$MONITORS" | jq -r ".[$i].width")
            MONITOR_HEIGHT=$(echo "$MONITORS" | jq -r ".[$i].height")
            MONITOR_REFRESH=$(echo "$MONITORS" | jq -r ".[$i].refreshRate")
            MONITOR_X=$(echo "$MONITORS" | jq -r ".[$i].x")
            MONITOR_Y=$(echo "$MONITORS" | jq -r ".[$i].y")
            
            MONITOR_CONFIG="monitor=$MONITOR_NAME,${MONITOR_WIDTH}x${MONITOR_HEIGHT}@${MONITOR_REFRESH},${MONITOR_X}x${MONITOR_Y},1"
            
            # Aggiungi dopo la riga del MONITOR SETUP
            sed -i "/# │                              MONITOR SETUP/a\\$MONITOR_CONFIG" "$CONFIG_FILE"
            
            print_success "Configurato: $MONITOR_NAME (${MONITOR_WIDTH}x${MONITOR_HEIGHT}@${MONITOR_REFRESH}Hz)"
        done
        
        echo ""
        print_info "Ricarica Hyprland con: hyprctl reload"
        ;;
        
    3)
        print_info "Ripristino a 'preferred'..."
        
        # Backup centralizzato
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/hyprland.conf.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_warning "Backup salvato: $BACKUP_FILE"
        
        # Ripristina a preferred
        sed -i '/^monitor=/c\monitor=,preferred,auto,1' "$CONFIG_FILE"
        
        print_success "Configurazione ripristinata a 'preferred' (auto-detect)"
        print_info "Ricarica Hyprland con: hyprctl reload"
        ;;
        
    4)
        print_info "Configurazione attuale in $CONFIG_FILE:"
        echo ""
        grep "^monitor=" "$CONFIG_FILE" | sed 's/^/  /'
        echo ""
        ;;
        
    5)
        print_info "Uscita..."
        exit 0
        ;;
        
    *)
        print_error "Scelta non valida!"
        exit 1
        ;;
esac

echo ""
print_info "Backup salvati in: $BACKUP_DIR"
