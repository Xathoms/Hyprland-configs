# Font Richiesti per Hyprlock Style 1

I seguenti font sono necessari per il corretto funzionamento di Hyprlock e altri componenti:

## Font dai Repository (installati automaticamente)
- **CaskaydiaCove Nerd Font** - Font principale (ttf-cascadia-code-nerd)
- **JetBrains Mono Nerd Font** - Font alternativo (ttf-jetbrains-mono-nerd)
- **Iosevka Nerd Font** - Font per icone (ttf-iosevka-nerd)
- **Font Awesome** - Icone (ttf-font-awesome)

## Font da Scaricare Manualmente
Se l'installer non riesce a scaricarli automaticamente:

### GrapeNuts-Regular.ttf
- Scarica da: https://fonts.google.com/specimen/Grape+Nuts
- Oppure: https://github.com/nicokosi/google-fonts/raw/main/ofl/grapenuts/GrapeNuts-Regular.ttf

### Icomoon-Feather.ttf
- Scarica da: https://github.com/MrVivekRajan/Hyprlock-Styles/raw/main/Starter-Font/Icomoon-Feather.ttf

## Installazione Manuale
```bash
# Crea cartella fonts se non esiste
mkdir -p ~/.local/share/fonts

# Copia i font
cp *.ttf ~/.local/share/fonts/

# Aggiorna cache
fc-cache -fv
```

## Verifica Installazione
```bash
# Verifica che i font siano installati
fc-list | grep -i "GrapeNuts"
fc-list | grep -i "Icomoon"
fc-list | grep -i "CaskaydiaCove"
fc-list | grep -i "JetBrains"
fc-list | grep -i "Iosevka"
```
