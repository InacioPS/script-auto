#!/bin/bash
set -e  # Encerra o script em caso de erro

# Verifica se está rodando como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root (use sudo)." 
    exit 1
fi

# Função para instalar o AppImageSup
instalar_appimagesup() {
    curl -L https://raw.githubusercontent.com/Diegopam/AppImageSup/main/app -o /usr/local/bin/app
    chmod +x /usr/local/bin/app
}

# Função para instalar universal
instalar_universal() {
    sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
}

# Lista de pacotes oficiais do repositório
PACOTES=(
    git
    wget
    curl
    htop
    fastfetch
    discord
    btop
    nvtop
    flatpak
    noisetorch
    pavucontrol
    firefox
    spotify
    cosmic-store
)

# Lista de pacotes AppImage
APPIMAGE=(
    Vscodium
    Telegram
    Appimage-Store
    Obsstudio
    Onlyoffice
)

# Lista de pacotes do AUR
AUR_PACOTES=(
    google-chrome
)

# Verifica a base da distro
ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
ID_LIKE=$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]]; then
    echo "Sistema baseado em Ubuntu"

    echo "Atualizando o sistema..."
    apt update && apt upgrade -y

    for pacote in "${PACOTES[@]}"; do
        apt install -y "$pacote"
        echo "Pacote instalado: $pacote"
    done

    # Flatpak - adiciona Flathub
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Discord via Flatpak (não está no repositório oficial)
    flatpak install -y flathub com.discordapp.Discord

    instalar_appimagesup

    if ! command -v app &>/dev/null; then
        echo "Erro: o comando 'app' não foi encontrado após tentativa de instalação."
        exit 1
    fi

    for pacote in "${APPIMAGE[@]}"; do
        app install "$pacote"
        echo "Pacote AppImage instalado: $pacote"
    done

    instalar_universal
    
    mkdir .icons && cd .icons && git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git

elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
    echo "Sistema baseado em Arch Linux"

    echo "Atualizando o sistema..."
    pacman -Syu --noconfirm

    if ! command -v yay &>/dev/null; then
        echo "yay não encontrado. Instalando yay..."
       pacman -S yay --noconfirm
    fi

    for pacote in "${PACOTES[@]}"; do
        pacman -S --noconfirm "$pacote"
        echo "Pacote instalado: $pacote"
    done

    instalar_appimagesup

    if ! command -v app &>/dev/null; then
        echo "Erro: o comando 'app' não foi encontrado após tentativa de instalação."
        exit 1
    fi

    for pacote in "${APPIMAGE[@]}"; do
        app install "$pacote"
        echo "Pacote AppImage instalado: $pacote"
    done

    instalar_universal

elif [[ "$ID" == "fedora" || "$ID_LIKE" == *"fedora"* ]]; then
    echo "Sistema Fedora"

    echo "Atualizando o sistema..."
    dnf upgrade -y

    for pacote in "${PACOTES[@]}"; do
        dnf install -y "$pacote"
        echo "Pacote instalado: $pacote"
    done

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub com.discordapp.Discord

    instalar_appimagesup

    if ! command -v app &>/dev/null; then
        echo "Erro: o comando 'app' não foi encontrado após tentativa de instalação."
        exit 1
    fi

    for pacote in "${APPIMAGE[@]}"; do
        app install "$pacote"
        echo "Pacote AppImage instalado: $pacote"
    done

    instalar_universal

elif [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
    echo "Sistema Debian"

    echo "Atualizando o sistema..."
    apt update && apt upgrade -y

    for pacote in "${PACOTES[@]}"; do
        apt install -y "$pacote"
        echo "Pacote instalado: $pacote"
    done

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub com.discordapp.Discord

    instalar_appimagesup

    if ! command -v app &>/dev/null; then
        echo "Erro: o comando 'app' não foi encontrado após tentativa de instalação."
        exit 1
    fi

    for pacote in "${APPIMAGE[@]}"; do
        app install "$pacote"
        echo "Pacote AppImage instalado: $pacote"
    done

     instalar_universal

else
    echo "Distribuição desconhecida. Abortando."
    exit 1
fi
