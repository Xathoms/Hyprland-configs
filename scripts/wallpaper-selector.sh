#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                         WALLPAPER SELECTOR                                    ║
# ║                            usando swww                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
ROFI_THEME="$HOME/.config/rofi/launchers/type-2/style-2.rasi"

# Assicurati che swww daemon sia in esecuzione
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Controlla se la cartella esiste
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Errore" "Cartella $WALLPAPER_DIR non trovata" -u critical
    exit 1
fi

# Trova tutte le immagini
images=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort)

# Controlla se ci sono immagini
if [ -z "$images" ]; then
    notify-send "Errore" "Nessuna immagine trovata in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Mostra il selettore con rofi
chosen=$(echo "$images" | while read -r img; do
    echo -en "$(basename "$img")\x00icon\x1f$img\n"
done | rofi -dmenu -i -p "󰸉 Wallpaper" -show-icons -theme "${ROFI_THEME}" \
    -theme-str 'listview { columns: 1; lines: 8; }' \
    -theme-str 'element-icon { size: 64px; }')

# Se è stato scelto un wallpaper, applicalo
if [ -n "$chosen" ]; then
    wallpaper="$WALLPAPER_DIR/$chosen"
    
    if [ -f "$wallpaper" ]; then
        # Applica con transizione
        swww img "$wallpaper" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1 \
            --transition-fps 60
        
        notify-send "Wallpaper" "Applicato: $chosen" -i "$wallpaper"
    fi
fi
