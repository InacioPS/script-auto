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
    btop
    nvtop
    flatpak
    fastfetch
    pavucontrol
    firefox
    fish
    qbittorrent
    obs-studio
    telegram-desktop
    discord
    steam
    7zip
    btrfs-assistant
    fzf
    gnome-calculator
    gnome-text-editor
    gparted
    gthumb
    mpv
    nautilus-python
    nautilus
    obsidian
    unzip
)

# Lista de pacotes AppImage
APPIMAGE=(
    
)

# Lista de pacotes do AUR
AUR_PACOTES=(
    spotify
    onlyoffice
    protonplus
    apple_cursor
    backintime
    dwarfs-bin
    freedownloadmanager-bin
    gearlever
    onlyoffice-bin
    typora
    visual-studio-code-bin
    ttf-jetbrains-mono
    asusctl
)

# Verifica a base da distro
ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
ID_LIKE=$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]]; then
    echo "Sistema baseado em Ubuntu"

    echo "Atualizando o sistema..."
    apt update && apt upgrade -y

    for pacote in "${PACOTES[@]}"; do
        if apt-cache show "$pacote" &>/dev/null; then
            apt install -y "$pacote"
            echo "Pacote instalado: $pacote"
        else
            echo "Pacote $pacote não encontrado nos repositórios. Pulando."
        fi
    done

    # instalando pacotes em formato flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
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
    
elif [[ "$ID" == "arch" || "$ID" == "cachyos" || "$ID_LIKE" == *"arch"* ]]; then
    echo "Sistema baseado em Arch Linux"

    echo "Atualizando o sistema..."
    pacman -Syu --noconfirm

    # Arrays para armazenar pacotes pulados
    PACOTES_PULADOS=()
    AUR_PULADOS=()

    # Instalar pacotes oficiais
    for pacote in "${PACOTES[@]}"; do
        if pacman -Si "$pacote" &>/dev/null; then
            pacman -S --noconfirm "$pacote"
            echo "Pacote instalado: $pacote"
        else
            echo "Pacote $pacote não encontrado nos repositórios. Pulando."
            PACOTES_PULADOS+=("$pacote")
        fi
    done

    # Instalar yay se não estiver instalado
    if ! command -v yay &>/dev/null; then
        echo "yay não encontrado. Instalando yay..."
        
        # Instalar dependências necessárias
        pacman -S --needed --noconfirm base-devel git
        
        # Criar usuário temporário se estiver rodando como root
        SUDO_USER=${SUDO_USER:-$(logname 2>/dev/null)}
        
        if [[ -z "$SUDO_USER" ]]; then
            echo "Erro: Não foi possível identificar o usuário não-root."
            echo "Execute o script com: sudo ./install.sh"
            exit 1
        fi
        
        # Instalar yay como usuário não-root
        sudo -u "$SUDO_USER" bash <<EOF
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin
EOF
        
        echo "yay instalado com sucesso!"
    else
        echo "yay já está instalado."
    fi

    # Instalar pacotes do AUR
    if command -v yay &>/dev/null; then
        echo "Instalando pacotes do AUR..."
        SUDO_USER=${SUDO_USER:-$(logname 2>/dev/null)}
        
        for pacote in "${AUR_PACOTES[@]}"; do
            echo "=========================================="
            echo "Tentando instalar: $pacote"
            echo "=========================================="
            
            # Verifica se o pacote já está instalado
            if pacman -Qi "$pacote" &>/dev/null; then
                echo "✓ $pacote já está instalado. Pulando..."
                continue
            fi
            
            # Tenta instalar o pacote
            if sudo -u "$SUDO_USER" yay -S --noconfirm --needed "$pacote" 2>&1; then
                echo "✓ $pacote instalado com sucesso!"
            else
                ERRO_CODE=$?
                echo "✗ Falha ao instalar $pacote (código de erro: $ERRO_CODE)"
                AUR_PULADOS+=("$pacote")
            fi
            
            echo ""
        done
    else
        echo "Erro: yay não está disponível. Pulando todos os pacotes do AUR."
        AUR_PULADOS=("${AUR_PACOTES[@]}")
    fi
        
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

    # Exibir relatório de pacotes pulados
    echo ""
    echo "=========================================="
    echo "RELATÓRIO DE INSTALAÇÃO"
    echo "=========================================="
    
    if [[ ${#PACOTES_PULADOS[@]} -gt 0 ]]; then
        echo "Pacotes oficiais que foram pulados:"
        for pacote in "${PACOTES_PULADOS[@]}"; do
            echo "  - $pacote"
        done
    else
        echo "✓ Todos os pacotes oficiais foram instalados com sucesso!"
    fi
    
    echo ""
    
    if [[ ${#AUR_PULADOS[@]} -gt 0 ]]; then
        echo "Pacotes do AUR que foram pulados:"
        for pacote in "${AUR_PULADOS[@]}"; do
            echo "  - $pacote"
        done
    else
        echo "✓ Todos os pacotes do AUR foram instalados com sucesso!"
    fi
    
    echo "=========================================="

    instalar_universal

elif [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
    echo "Sistema Debian"

    echo "Atualizando o sistema..."
    apt update && apt upgrade -y

    for pacote in "${PACOTES[@]}"; do
        if apt-cache show "$pacote" &>/dev/null; then
            apt install -y "$pacote"
            echo "Pacote instalado: $pacote"
        else
            echo "Pacote $pacote não encontrado nos repositórios. Pulando."
        fi
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
