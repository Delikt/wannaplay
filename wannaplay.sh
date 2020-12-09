#!/bin/bash

 cat << "EOF"
                                        _                                                  ___  
                                       | |                                                / _ \ 
 _ _ _ _____ ____  ____  _____    ____ | | _____ _   _    _____     ____ _____ ____  ____(_( ) )
| | | (____ |  _ \|  _ \(____ |  |  _ \| |(____ | | | |  (____ |   / _  (____ |    \| ___ | (_/ 
| | | / ___ | | | | | | / ___ |  | |_| | |/ ___ | |_| |  / ___ |  ( (_| / ___ | | | | ____| _   
 \___/\_____|_| |_|_| |_\_____|  |  __/ \_)_____|\__  |  \_____|   \___ \_____|_|_|_|_____)(_)  
  version 0.9.5                  |_|            (____/            (_____|       "by Delikt"                
EOF

# ${COLOR} colorize text ${NC}
RED="\033[0;31m" # init color var
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
ORANGE="\033[0;33m"
NC="\033[0m" # exit color var

echo                                                                                
echo -e ${YELLOW}"______________________________________________________________________________________________${NC}"
echo 
echo -e "This Script installs all the necessary libraries to play the latest DX11 (Windows) Games \non ${GREEN}Linux Mint 20+${NC} and ${GREEN}Ubuntu 19.10+${NC} Distributions and take of configurations to optimize your\nSystem for Gaming."
echo
echo
echo -e ${ORANGE}"ATTENTION:${NC} If you use an older ${GREEN}NVIDIA${NC} GPU please ensure the latest (long-life) Nvidia Driver is supported by your Card here:"
echo
echo  -e ${YELLOW}"LINK:${NC} https://www.nvidia.com/Download/index.aspx?lang=en-us"
echo
echo -e "It is strongly recommended to create a ${ORANGE}FULL BACKUP${NC} from your System before using this Script!"
echo
echo -e ${RED}"This Script comes with absolute NO Warrenty of any kind. You use it at your own Risk!\nShould this Script prove defective in any respect, YOU (not the initial Developer or any other Constributor\nassume the cost of any necessary servicing, repair or correction!"${NC}                                                                             
echo -e ${YELLOW}"______________________________________________________________________________________________${NC}"
echo 
echo "You want to go further? (Y/n)"

while true;
do
 read input
 
 case $input in
     [yY][eE][sS]|[yY])
 echo
 echo "Yes, lets do this..."
 break
 ;;
     [nN][oO]|[nN])
 echo "No - Aborted!"
 exit
        ;;
     *)
 echo "Invalid input... Try again or press [Ctrl+C] to abort!"
 ;;
 esac
done

#we need sudo privileges
if ! [ $(id -u) = 0 ]; then
   echo -e ${RED}"Error: This script need to be run with sudo privileges!"${NC} >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

echo 


###########
#functions#
###########

#confirm GPU - choose manualy
options=("Intel-AMD" "Nvidia" "Quit")

gpu_confirm() {
        
    read input
        case $input in
            [yY][eE][sS]|[yY])
        echo
        ;;
            [nN][oO]|[nN])
        echo
        echo "Sad, but you can choose one of the following GPU vendors manually [input the Number, then press Enter]:"
        echo -e "${RED}Notice: The Intel and AMD Open Source Driver are the same Package called Mesa!"${NC}
        echo
            
        select vendor in "${options[@]}"
        do
            case $vendor in
                "Intel-AMD")
                    break
                    ;;
                "Nvidia")
                    break
                    ;;
                "Quit")
                    echo
                    echo "Quit (Aborted)"
                    exit
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done
                ;;
            *)
        echo "Invalid input  - Aborted!"
        exit
        ;;
            *)
        esac  

}



#identify GPU vendor by vendor ID
#FIXME: Change code to recognize two and more GPU's (e.g. integrated GPU is active but not in use) and let select the main GPU as option


vendor=$(lshw -numeric -C display -quiet  | grep -ow "10DE" | tail -n +2) #Nvidia = 10DE

if [ -z "$vendor" ]; then
    
    vendor=$(lshw -numeric -C display -quiet  | grep -ow "1002" | tail -n +2) #AMD = 1002 
fi

if [ -z "$vendor" ]; then

    vendor=$(lshw -numeric -C display -quiet  | grep -ow "8086" | tail -n +2) #Intel = 8086
fi

if [ $vendor == "8086" ]; then

    echo "It look like you are using a Intel GPU!"
    vendor="Intel-AMD"
    echo "Is this correct? [Y/n]"
    echo
    gpu_confirm

elif [ $vendor == "10DE" ]; then

    echo "It look like you are using a Nvidia GPU!"
    vendor="Nvidia"
    echo "Is this correct? [Y/n]"
    echo
    gpu_confirm

elif [ $vendor == "1002" ]; then

    echo "It look like you are using a AMD GPU!"
    vendor="Intel-AMD"
    echo "Is this correct? [Y/n]"
    echo
    gpu_confirm

elif [ -z $vendor ]; then

    echo -e ${RED}"Error: Can't recognize your GPU"${NC}
    echo -e "Choose the Graphic Card Vendor manually:"
    echo "Input the Number - then press Enter! - Otherwise press [Ctrl+C] to Abort"
    echo

        select vendor in "${options[@]}"
        do
            case $vendor in
                "Intel-AMD")
                    break
                    ;;
                "Nvidia")
                    break
                    ;;
                "Quit")
                    echo
                    echo "Quit (Aborted)"
                    exit
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done
fi

##################################################
#AMDGPU - Kisak PPA incl. LLVM for Ubuntu 19.10+ #
##################################################

GPUfunc() {

if [ $vendor == "Intel-AMD" ]; then

    echo -e ${GREEN}"TASK: Installing Mesa Driver (Kisak PPA)"${NC}
    sleep 3

    #Install Vulkan
    echo -e ${GREEN}"TASK: Install Vulkan API"${NC}
    apt install mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y

    #Add Driver PPA & Install
    echo -e ${GREEN}"TASK: Adding display driver PPA & Install display driver package"${NC}
    add-apt-repository ppa:kisak/kisak-mesa -y
    apt update -y && apt upgrade -y

elif [ $vendor == "Nvidia" ]; then

    #Add Driver PPA & Install
    #FIXME: autocheck GPU if the latest driver compatible - else give option to install legacy driver?
    echo -e ${GREEN}"TASK: Adding display driver PPA & Install latest display driver package"${NC}
    add-apt-repository ppa:graphics-drivers/ppa -y
    apt update -y

    #get latest nvidia driver version
    Ndriver=$(apt-cache search nvidia-driver* | grep "nvidia-driver"  | cut -c -17 | tail -1) 
    NdriverV=${Ndriver:14}

    #Install the driver
    apt install nvidia-driver-$NdriverV libnvidia-gl-$NdriverV libnvidia-gl-$NdriverV:i386 -y

    #uninstall standard open source nouveau driver 
    echo -e ${GREEN}"TASK: Remove Open Source Driver (nouveau) - this can take view seconds..."${NC}
    echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    update-initramfs -u


fi

}

#Install additional Libraries for better compatibility with Origin, Battle.net, Uplay etc.

    additionallibs() {

        echo -e ${GREEN}"TASK: Install additional libraries for better compatibility with Origin, Battle.net, Uplay etc."${NC}
        apt-get install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 -y

    }


#Install Winehq-staging

    instwine() {

        echo -e ${GREEN}"TASK: Install WineHQ-staging"${NC}
        wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
        add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $UbCodename main" -y 
        apt update -y
        apt install winehq-staging winetricks -y

    }

#Install 32-bit Games Support

    32bitgames() {

        echo -e ${GREEN}"TASK: Install 32-bit Game support"${NC}
        dpkg --add-architecture i386
        apt update -y

    }


jqcheck() {

#check if jq package is installed otherwise install it 

jq=$(apt list jq --installed 2>/dev/null | grep -ow "jq")

if [ -z "$jq" ]; then

    echo -e ${GREEN}"TASK: jq package is not installed but needed to install ProtonGE - install it for you"${NC}
    apt install jq -y #jq is needed for installing ProtonGE ( Command-line JSON processor )

fi

}

#Install ProtonGE Custom Build

instprotonGE() {
    #FIXME: protonGE get not listet in steam [Game Breaker]
    echo -e ${GREEN}"TASK: Installing Proton-GE Custom Build for native Steam"${NC}
    jqcheck
    rm /tmp/Proton*
    protonGElink=$(wget -q -nv -O- https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("Proton")) | .browser_download_url')
    mkdir -p /home/$real_user/.steam/root/compatibilitytools.d
    wget $protonGElink -P /tmp/
    tar xf /tmp/Proton*.tar.gz -C /home/$real_user/.steam/root/compatibilitytools.d
    chown -R $real_user:$real_user /home/$real_user/.steam
    rm /tmp/Proton*

}


#Check if build-essential is installed otherwise install it

buildessentialcheck() {

buildess=$(apt list build-essential --installed 2>/dev/null | grep -ow "build-essential")

if [ -z "$buildess" ]; then

    echo -e ${GREEN}"TASK: build-essential package is not installed but needed - Install it for you"${NC}
    apt install build-essential -y 

fi

}

#Check if git is installed otherwise install it

gitcheck() {

git=$(apt list git --installed 2>/dev/null | grep -ow "git")

if [ -z "$git" ]; then

    echo -e ${GREEN}"TASK: git package is not installed but needed - Install it for you"${NC}
    apt install git -y 

fi

}

#check if dialog package is installed otherwise install it 

dialog=$(apt list dialog --installed 2>/dev/null | grep -ow "dialog")

if [ -z "$dialog" ]; then

        echo -e ${GREEN}"TASK: dialog package is not installed - install it for you"${NC}
        apt install dialog -y

fi

#Multichoice

    cmd=(dialog --separate-output --checklist "Choose your Weapon: (use SPACE for selection and ENTER to comfirm)" 22 76 16)
        options=(1 "Install Graphic Card Driver Packages" off
                2 "Install WineHQ and Winetricks" off
                3 "Install Vulkan API" off
                4 "Install 32-bit Game support" off
                5 "Install additional Libraries for better compatibility with Origin, Battle.net, Uplay etc." off
                6 "Configure Esync support" off
                7 "Install latest ProtonGE Release" off
                8 "Install Protontricks + GUI" off
                9 "Install native Steam Gaming Plattform" off
                10 "Install Lutris Open Gaming Plattform" off
                11 "Install MangoHUD - FPS Overlay" off
                12 "Install OBS - Open Broadcast Software" off)
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        clear
        for choice in $choices
        do
            case $choice in
                1)
                    GPUinst=true
                    ;;
                2)
                    winehq=true
                    ;;
                3)
                    vulkanapi=true
                    ;;
                4)
                    bitsupp=true
                    ;;
                5)
                    additionallibinst=true
                    ;;
                6)
                    confesync=true
                    ;;
                7)	
                    instprotonGE=true
                    ;;    
                8)	
                    instprotontricks=true
                    ;;       
                9)
                    steam=true
                    ;;
                10)
                    lutris=true
                    ;;
                11)
                    mangohud=true
                    ;;
                12)
                    obs=true
                    ;;
            esac
        done

############################
#gather system information #
############################

#get OS Release Codename
UbCodename=$(cat /etc/os-release | grep  "UBUNTU_CODENAME" | cut -b17-) 


#get Systemdversion
systemdversion=$(/bin/systemd --version | grep "systemd" | cut -b9-11)

#Update System
echo 
echo -e ${GREEN}"TASK: Updating your System..."${NC}
sleep 3
rm /var/lib/dpkg/lock & rm /var/lib/apt/lists/lock #avoid an error i had while testing.. not 100% sure this is safe
apt update -y #&& apt upgrade -y


    #Install GPU Driver
    if [ $GPUinst == "true" ]; then
        GPUfunc
    fi
  
    #Install additional libraries for better compatibility with Origin, Battle.net, Uplay etc. 
    if [ $additionallibinst == "true" ]; then
        additionallibs
    fi
  
    #Install 32-bit Game Support
    if [ $bitsupp == "true" ]; then
        32bitgames
    fi
  

    #Install winehq-staging
    if [ $winehq == "true" ]; then
        instwine
    fi


    #Install Vulkan
    

        if [ $vulkanapi == "true" ]; then
        echo -e ${GREEN}"TASK: Install Vulkan API"${NC}
            if [ $vendor == "Nvidia" ]; then
                apt install libvulkan1 libvulkan1:i386 -y

            else
                apt install mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y
            fi
        
        fi
 
#Configure Esync 
if [ $confesync == "true" ]; then

    echo -e ${GREEN}"TASK: Configure Esync - checking existing DefaultLimitNOFILE Entrys..."${NC}

#check if entry exist

systemconf=$(cat /etc/systemd/system.conf | grep "^[^#;]" | grep "DefaultLimitNOFILE=" | cut -b20-)
userconf=$(cat /etc/systemd/user.conf | grep "^[^#;]" | grep "DefaultLimitNOFILE=" | cut -b20-)
limitconf=$(cat /etc/security/limits.conf | grep "^[^#;]" | grep "$real_user hard nofile")

#inject DefaultLimitNOFILE conf entry for Esync support

    echo -e ${GREEN}"TASK: Writing DefaultLimitNOFILE Entrys..."${NC}

    if [ -z "$systemdversion" ]; then

        if [ -z "$limitconf" ]; then

            echo "$real_user hard nofile 1048576" >> /etc/security/limits.conf
            echo "No systemd version detected! Using initd configuration instead and write DefaultLimitNOFILE in /etc/security/limits.conf ...Done"

        else
            
            sed "s/$real_user hard nofile .*/$real_user hard nofile 1048576/g" -i /etc/security/limits.conf
            echo "No systemd version detected! Using initd configuration instead and overwrite existing '$real_user hard nofile' entry in /etc/security/limits.conf ...Done"
        
        fi

    else

        if [ -z "$systemconf" ]; then

                echo "DefaultLimitNOFILE=1048576" >> /etc/systemd/system.conf
                echo "Write DefaultLimitNOFILE in /etc/systemd/system.conf ...Done"

            else

                sed "s/DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g" -i /etc/systemd/system.conf
                echo "Overwrite DefaultLimitNOFILE entry in /etc/systemd/system.conf ...Done"
        fi  
            
            if [ -z "$userconf" ]; then

                echo "DefaultLimitNOFILE=1048576" >> /etc/systemd/user.conf
                echo "Write DefaultLimitNOFILE in /etc/systemd/user.conf ...Done"

            else

                sed "s/DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g" -i /etc/systemd/user.conf
                echo "Overwrite existing DefaultLimitNOFILE in /etc/systemd/user.conf ...Done"

            fi
    fi

fi

if [ $steam == "true" ]; then

    echo -e ${GREEN}"TASK: Installing native version of Steam Gaming Plattform"${NC}
    apt install steam -y
    #instprotonGE
       
fi

if [ $instprotonGE == "true" ]; then

    echo -e ${GREEN}"TASK: <Installing latest ProtonGE Release"${NC}
    jqcheck
    instprotonGE
       
fi

if [ $instprotontricks == "true" ]; then

echo -e ${GREEN}"TASK: Installing Protontricks + GUI"${NC}

xdguserdir=$(xdg-user-dir DESKTOP)

instprotontricks() {

sudo apt install python3-pip python3-setuptools python3-venv pipx
pipx install protontricks
pipx upgrade protontricks
touch /home/real_user/.local/share/applications/Protontricks.desktop
cat >> /home/real_user/.local/share/applications/Protontricks.desktop <<EOL
[Desktop Entry]
Name=Protontricks
Exec=protontricks --gui
Comment=
Terminal=true
Icon=steam_tray_mono
Type=Application
EOL
cp /home/real_user/.local/share/applications/Protontricks.desktop xdguserdir

}

fi


if [ $lutris == "true" ]; then

    #Install Lutris dependencies
    
    echo -e ${GREEN}"TASK: Installing Lutris Open Gaming Plattform and Dependencies"${NC}
    apt install python3-yaml python3-requests python3-pil python3-gi \
    gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 \
    gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs \
    x11-xserver-utils python3-evdev libc6-i386 lib32gcc1 libgirepository1.0-dev \
    python3-setproctitle python3-distro -y

    add-apt-repository ppa:lutris-team/lutris -y
    apt update -y
    apt install lutris -y

fi

if [ $mangohud == "true" ]; then

    #Install MangoHud

    echo -e ${GREEN}"TASK: Installing MangoHUD - FPS Overlay"${NC}
    buildessentialcheck
    gitcheck
    mkdir /home/$real_user/.mangohud
    cd /home/$real_user/.mangohud
    git clone --recurse-submodules https://github.com/flightlessmango/MangoHud.git
    chown -R $real_user:$real_user /home/$real_user/.mangohud
    cd MangoHud
    ./build.sh build
    ./build.sh package
    ./build.sh install

fi

    #Install OBS

if [ $obs == "true" ]; then

    echo -e ${GREEN}"TASK: Installing OBS Studio"${NC}
    apt install ffmpeg -y
    add-apt-repository ppa:obsproject/obs-studio -y
    apt update -y
    apt install obs-studio -y

fi

    #Cleanup apt

    apt autoremove -y
    apt clean

    #Information

    echo
    echo -e ${YELLOW}"______________________________________________________________________________________________${NC}"
    echo

if [ $mangohud == "true" ]; then

    echo -e ${GREEN}"To enable MangoHUD Overlay ingame, please visit ${NC}https://github.com/flightlessmango/MangoHud#normal-usage${GREEN} Website for instructions!"${NC}

fi
    
if [ $lutris == "true" ]; then

    echo -e ${GREEN}"To get information how Lutris work, visit ${NC}https://github.com/lutris/lutris${GREEN} and ${NC}https://github.com/lutris/lutris/wiki${GREEN} Website for instructions!"${NC}

fi

if [ $steam == "true" ]; then

echo -e ${GREEN}"If you dont know how to enable the Custom Proton Build in Steam visit${NC} https://github.com/GloriousEggroll/proton-ge-custom#enabling"

fi

echo
echo "please Reboot your System to take effect of the Changes! - Reboot now? [Y/n]"

while true;
do
 read input
 
 case $input in
     [yY][eE][sS]|[yY])
echo
echo "You are on your Mission - Good Luck ;)    (Reboot in 10 Sec...)"
echo -e ${GREEN}"10"${NC}
sleep 1
echo -e ${GREEN}"9"${NC}
sleep 1
echo -e ${GREEN}"8"${NC}
sleep 1
echo -e ${GREEN}"7"${NC}
sleep 1
echo -e ${ORANGE}"6"${NC}
sleep 1
echo -e ${ORANGE}"5"${NC}
sleep 1
echo -e ${ORANGE}"4"${NC}
sleep 1
echo -e ${RED}"3"${NC}
sleep 1
echo -e ${RED}"2"${NC}
sleep 1
echo -e ${RED}"1"${NC}
sleep 1
reboot now
break
;;
    [nN][oO]|[nN])
echo "Reboot later... for sure!"
exit
    ;;
    *)
echo "Invalid input... Try again or press [Ctrl+C] to abort!"
;;

esac

done
