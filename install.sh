#!/bin/bash
# follow me on github https://github.com/criptixo

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
	echo "Do not execute as root!"
	exit 1
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"

clear

TERM_WIDTH=$(tput cols)

MESSAGE="Welcome to my Arch-Hyprland Installer"
PAD_LENGTH=$(( ($TERM_WIDTH - ${#MESSAGE}) / 2 ))

# Set the color to green
GREN='\033[0;32m'
NC='\033[0m' # No Color

# Display the message with thicker width and green color
printf "${GREN}+$(printf '%*s' "$((TERM_WIDTH-1))" '' | tr ' ' -)+${NC}\n"
printf "${GREN}|%*s${MESSAGE}%*s|${NC}\n" $PAD_LENGTH "" $PAD_LENGTH ""
printf "${GREN}+$(printf '%*s' "$((TERM_WIDTH-1))" '' | tr ' ' -)+${NC}\n"

sleep 2

# Warning message
printf "${ORANGE}$(tput smso)PLEASE ONLY INSTALL ON A NEW SYSTEM$(tput rmso)\n"
printf "\n"
printf "\n"

# Print VM warning message
printf "\n${NOTE} If you are installing on a VM ensure that 3D acceleration is enabled.\n"
sleep 2
printf "\n"
printf "\n"


read -n1 -rep "${CAT} Shall we proceed with installation (y/n) " PROCEED
    echo
if [[ $PROCEED =~ ^[Yy]$ ]]; then
    printf "\n%s  Starting...\n" "${OK}"
else
    printf "\n%s  NO changes made to your system. Goodbye.!!!\n" "${NOTE}"
    exit
fi

clear

printf "\n%s - Installing yay...\n" "${NOTE}"
git clone https://aur.archlinux.org/yay-bin.git || { printf "%s - Failed to clone yay from AUR\n" "${ERROR}"; exit 1; }
cd yay-bin || { printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"; exit 1; }
makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install yay from AUR\n" "${ERROR}"; exit 1; }
cd ..

clear

printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
yay -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

clear

# Set the script to exit on error
set -e

# Function for installing packages
install_package() {
    # checking if package is already installed
    if yay -Q "$1" &>> /dev/null ; then
        echo -e "${OK} $1 is already installed. skipping..."
    else
        # package not installed
        echo -e "${NOTE} installing $1 ..."
        yay -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
        # making sure package installed
        if yay -Q "$1" &>> /dev/null ; then
            echo -e "\e[1A\e[K${OK} $1 was installed."
        else
            # something is missing, exitting to review log
            echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log . You may need to install manually! Sorry I have tried :("
            exit 1
        fi
    fi
}

# Function to print error messages
print_error() {
    printf " %s%s\n" "${ERROR}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "${OK}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Exit immediately if a command exits with a non-zero status.
set -e 


for HYP in hyprland; do
    install_package "$HYP" 2>&1 | tee -a $LOG
done

clear 

for PKG in xdg-desktop-portal-hyprland base-devel librewolf-bin osu-lazer-bin nicotine+ cantata gimp piper armcord-bin transmission-gtk obs-studio waybar-hyprland-cava-git foot swaybg thunar wofi dunst grim slurp wl-clipboard polkit-gnome nwg-look nvim pipewire qt5-wayland qt6-wayland pipewire-pulse pipewire-alsa pipewire-jack pavucontrol playerctl qt5ct qt6ct ffmpeg mpv mp pamixer brightnessctl xdg-user-dirs viewnior htop neofetch network-manager-applet cava; do
    install_package "$PKG" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG install had failed, please check the install.log"
        exit 1
    fi
done

clear

for FONT in ttf-hack-nerd otf-font-awesome ttf-font-awesome; do
    install_package  "$FONT" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $FONT install had failed, please check the install.log"
        exit 1
    fi
done

echo 
print_success "All necessary packages installed successfully."

clear

printf "${NOTE} Installing Theme packages...\n"
  for THEME in catppuccin-gtk-theme-mocha; do
    install_package "$THEME" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $THEME install had failed, please check the install.log"
        exit 1
      fi
done

clear

systemctl enable --user pipewire.service
systemctl start --user pipewire.service
systemctl enable --user pipewire-pulse.service
systemctl start --user pipewire-pulse.service

printf "${NOTE} Installing Bluetooth Packages...\n"
  for BLUE in bluez bluez-utils blueman; do
    install_package "$BLUE" 2>&1 | tee -a "$LOG"
         if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $BLUE install had failed, please check the install.log"
        exit 1
        fi
    done

  printf " Activating Bluetooth Services...\n"
  sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$LOG"
fi

clear

print "${NOTE} Installing greetd...\n"
  for GREETD in greetd; do
    install_package "$GREETD" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then 
        echo -e "\e[1A\e[K${EROOR} - $GREETD install had failed, please check the intall.log"
        fi
done


sudo sed 's/\/bin\/sh/Hyprland'/etc/greetd/config.toml 
sudo printf '[initial_sessin] \n command= "Hyprland > /dev/null" \n user = "criptixo"' > /etc/greetd/config.toml 
printf 'enabling greetd'
sudo systemctl enable greetd.service

clear

printf "\n"

### Copy Config Files ###
set -e 

printf "Copying config files...\n"
mkdir -p ~/.config
cp -r config/hypr ~/.config/ || { echo "Error: Failed to copy hypr config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/foot ~/.config/ || { echo "Error: Failed to copy foot config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/wlogout ~/.config/ || { echo "Error: Failed to copy wlogout config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/waybar ~/.config/ || { echo "Error: Failed to copy waybar config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/dunst ~/.config/ || { echo "Error: Failed to copy dunst config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/mpd ~/.config/ || { echo "Error: Failed to copy mpd config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/wofi ~/.config/ || { echo "Error: Failed to copy wofi config files."; exit 1; } 2>&1 | tee -a "$LOG"
cp -r config/cava ~/.config/ || { echo "Error: Failed to copy cava config files."; exit 1; } 2>&1 | tee -a "$LOG"
rm -rf .bashrc && cp misc/.bashrc .bashrc 2>&1 | tee -a "$LOG"   
printf "Setting executables...\n"
chmod +x ~/.config/hypr/screenshot.sh/* 2>&1 | tee -a "$LOG"
chmod +x ~/.config/waybar/weather.sh/* 2>&1 | tee -a "$LOG"
chmod +x ~/.config/waybar/mediaplayer.py/* 2>&1 | tee -a "$LOG"

clear

printf "\n${OK} Installation Finished.\n"
sleep 3
sudo systemctl start greetd.service 2>&1 | tee -a "$LOG"
