#!/bin/bash

 cat << "EOF"
                                        _                                                  ___  
                                       | |                                                / _ \ 
 _ _ _ _____ ____  ____  _____    ____ | | _____ _   _    _____     ____ _____ ____  ____(_( ) )
| | | (____ |  _ \|  _ \(____ |  |  _ \| |(____ | | | |  (____ |   / _  (____ |    \| ___ | (_/ 
| | | / ___ | | | | | | / ___ |  | |_| | |/ ___ | |_| |  / ___ |  ( (_| / ___ | | | | ____| _   
 \___/\_____|_| |_|_| |_\_____|  |  __/ \_)_____|\__  |  \_____|   \___ \_____|_|_|_|_____)(_)  
  version 0.8                    |_|            (____/            (_____|       "by Deliri"                
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
echo "This Script takes of the following tasks:"
echo
echo "o) automatically detect your Graphic Card and install the latest recommended Driver for Intel/AMD/Nvidia GPU’s"
echo "o) install wine-staging"
echo "o) install Vulkan API libraries"
echo "o) Install 32-bit Game Support"
echo "o) install additional libraries for better compatibility with Origin, Battle.net, Uplay etc."
echo "o) automatically configure esync support"
echo "o) optional install and configure Steam and Lutris [coming soon..]"
echo "o) install ProtonGE to fix issues in some Steam Games [coming soon..]"
echo "o) optional install MangoHUD, OBS [coming later..]"
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
options=("Intel-AMD" "Nvidia" "Skip Driver Install" "Quit")

gpu_confirm() {
        
    read input
        case $input in
            [yY][eE][sS]|[yY])
        echo "Checked, $vendor Driver will be installed!"
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
                    echo "Checked, Mesa Driver for Intel and AMD GPU's will be installed!"
                    break
                    ;;
                "Nvidia")
                    echo "Checked, Nvidia Driver (latest long-life Driver) will be installed!"
                    break
                    ;;
                    "Skip Driver Install")
                    echo "Driver installation is skipped!"
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


#Install additional Libraries for better compatibility with Origin, Battle.net, Uplay etc.

    additionallibs() {

        echo -e ${GREEN}"TASK: Install additional libraries for better compatibility with Origin, Battle.net, Uplay etc."${NC}
        sudo apt-get install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 -y

    }


#Install Winehq-staging
 
    instwine() {

        echo -e ${GREEN}"TASK: Install WineHQ-staging"${NC}
        wget -nc https://dl.winehq.org/wine-builds/winehq.key
        sudo apt-key add winehq.key
        sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $UbCodename main" -y 
        sudo apt-get install --install-recommends winehq-staging -y
        rm winehq.key

    }

#Install 32-bit Games Support

    32bitgames() {

        echo -e ${GREEN}"TASK: Install 32-bit Game support"${NC}
        sudo dpkg --add-architecture i386
        sudo apt update -y

    }

############################
#gather system information #
############################

#get OS Release Codename
UbCodename=$(cat /etc/os-release | grep  "UBUNTU_CODENAME" | cut -b17-) 


#get Systemdversion
systemdversion=$(sudo /bin/systemd --version | grep "systemd" | cut -b9-11)

#identify GPU vendor by vendor ID
#ToDo: Change code to recognize two and more GPU's (e.g. integrated GPU is active but not in use) and let select the main GPU as option
vendor=$(sudo lshw -numeric -C display -quiet  | grep -ow "10DE" | tail -n +2) #Nvidia = 10DE

if [ -z "$vendor" ]; then
    
    vendor=$(sudo lshw -numeric -C display -quiet  | grep -ow "1002" | tail -n +2) #AMD = 1002 
fi

if [ -z "$vendor" ]; then

    vendor=$(sudo lshw -numeric -C display -quiet  | grep -ow "8086" | tail -n +2) #Intel = 8086
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
    echo -e "Choose the Graphic Card Vendor manually and install the Driver. You can skip the Driver Installation and perform all other Tasks!"
    echo "Input the Number - then press Enter! - Otherwise press [Ctrl+C] to Abort"
    echo

        select vendor in "${options[@]}"
        do
            case $vendor in
                "Intel-AMD")
                    echo "Checked, Mesa Driver for Intel and AMD GPU's will be installed!"
                    break
                    ;;
                "Nvidia")
                    echo "Checked, Nvidia Driver will be installed!"
                    break
                    ;;
                    "Skip Driver Install")
                    echo "Driver installation is skipped!"
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


#Update & Upgrade System
echo 
echo -e ${GREEN}"TASK: Upgrading your System..."${NC}
sleep 3
sudo rm /var/lib/dpkg/lock & sudo rm /var/lib/apt/lists/lock #avoid an error i had while testing.. not 100% sure this is safe
sudo apt update -y && sudo apt upgrade -y

##################################################
#AMDGPU - Kisak PPA incl. LLVM for Ubuntu 19.10+ #
##################################################

if [ $vendor == "Intel-AMD" ]; then

    echo -e ${GREEN}"TASK: Installing Mesa Driver (Kisak PPA), 32-bit Games support, Winehq-staging and Vulkan API.."${NC}
    sleep 3

    #Install 32-bit Games support
        32bitgames

    #Install Vulkan
    echo -e ${GREEN}"TASK: Install Vulkan API"${NC}
    sudo apt install mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y

    #Add Driver PPA & Install
    echo -e ${GREEN}"TASK: Adding display driver PPA & Install display driver package"${NC}
    sudo add-apt-repository ppa:kisak/kisak-mesa -y
    sudo apt update -y && sudo apt upgrade -y

    #Install additional Libraries for better compatibility with Origin, Battle.net, Uplay etc.
        additionallibs

    #Install Winehq-staging
        instwine

elif [ $vendor == "Nvidia" ]; then

    #Install 32-bit Games support
        32bitgames

    #Install winehq-staging
        instwine

    #Install Vulkan
    echo -e ${GREEN}"TASK: Install Vulkan API"${NC}
    sudo apt install libvulkan1 libvulkan1:i386 -y

    #Add Driver PPA & Install
    #ToDo: autocheck GPU if the latest driver compatible - else give option to install legacy driver?
    echo -e ${GREEN}"TASK: Adding display driver PPA & Install latest display driver package"${NC}
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update -y

    #get latest nvidia driver version
    Ndriver=$(apt-cache search nvidia-driver* | grep "nvidia-driver"  | cut -c -17 | tail -1) 
    NdriverV=${Ndriver:14}

    #Install the driver
    sudo apt install nvidia-driver-$NdriverV libnvidia-gl-$NdriverV libnvidia-gl-$NdriverV:i386 -y

    #uninstall standard open source nouveau driver 
    echo -e ${GREEN}"TASK: Remove Open Source Driver (nouveau) - this can take view seconds..."${NC}
    sudo echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    sudo echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    sudo update-initramfs -u

    #Install additional libraries for better compatibility with Origin, Battle.net, Uplay etc.
        additionallibs

else

    #Skip Driver installation
    
    #Install 32-bit Game Support
        32bitgames

    #Install winehq-staging
        instwine

    #Install Vulkan
    echo -e ${GREEN}"TASK: Install Vulkan API"${NC}
    sudo apt install libvulkan1 libvulkan1:i386 -y

    #Install additional libraries for better compatibility with Origin, Battle.net, Uplay etc.
        additionallibs

fi

#Configure Esync 

    echo -e ${GREEN}"TASK: Configure Esync - checking existing DefaultLimitNOFILE Entrys..."${NC}

#check if entry exist

systemconf=$(cat /etc/systemd/system.conf | grep "^[^#;]" | grep "DefaultLimitNOFILE=" | cut -b20-)
userconf=$(cat /etc/systemd/user.conf | grep "^[^#;]" | grep "DefaultLimitNOFILE=" | cut -b20-)
limitconf=$(cat /etc/security/limits.conf | grep "^[^#;]" | grep "$real_user hard nofile")

#inject DefaultLimitNOFILE conf entry for Esync support

    echo -e ${GREEN}"TASK: Writing DefaultLimitNOFILE Entrys..."${NC}

    if [ -z "$systemdversion" ]; then

        if [ -z "$limitconf" ]; then

            sudo echo "$real_user hard nofile 1048576" >> /etc/security/limits.conf
            echo "No systemd version detected! Using initd configuration instead and write DefaultLimitNOFILE in /etc/security/limits.conf ...Done"

        else
            
            sudo sed "s/$real_user hard nofile .*/$real_user hard nofile 1048576/g" -i /etc/security/limits.conf
            echo "No systemd version detected! Using initd configuration instead and overwrite existing '$real_user hard nofile' entry in /etc/security/limits.conf ...Done"
        
        fi

    else

        if [ -z "$systemconf" ]; then

                sudo echo "DefaultLimitNOFILE=1048576" >> /etc/systemd/system.conf
                echo "Write DefaultLimitNOFILE in /etc/systemd/system.conf ...Done"

            else

                sudo sed "s/DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g" -i /etc/systemd/system.conf
                echo "Overwrite DefaultLimitNOFILE entry in /etc/systemd/system.conf ...Done"
        fi  
            
            if [ -z "$userconf" ]; then

                sudo echo "DefaultLimitNOFILE=1048576" >> /etc/systemd/user.conf
                echo "Write DefaultLimitNOFILE in /etc/systemd/user.conf ...Done"

            else

                sudo sed "s/DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g" -i /etc/systemd/user.conf
                echo "Overwrite existing DefaultLimitNOFILE in /etc/systemd/user.conf ...Done"

            fi
    fi

echo -e "${YELLOW}______________________________________________________________________________________________${NC}"
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
sudo reboot now
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