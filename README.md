# Wanna Play a Game (on Linux)?

The **wannaplay** Script install all necessary Libraries to play "State of the Art" Windows Games on **Linux Mint 19+** and **Ubuntu 19.10+** Distributions.

The Goal is to provide a automated Script that have the capability to play most of the latest DX11 Games like Need for Speed Heat, Battlefield V, Resident Evil 7 and 2 (Remake), Star Wars Jedi: Fallen Order, Blizzard Games, NB2K20 and many more.

For a large List of working Steam Games visit [protondb](https://www.protondb.com/).

An easy way to install many Games on Linux via Scripts, are the Lutris Gaming Plattform - visit [Lutris Homepage](https://lutris.net/).


### What it does:

- automatically detect your Graphic Card and install the latest recommended Driver for Intel/AMD/Nvidia GPU's
- install winehq-staging and winetricks
- install Vulkan API libraries
- Install 32-bit Game Support
- install additional Libraries for better compatibility with Origin, Battle.net, Uplay etc.
- automatically configure esync support
- optional install Steam and Lutris Gaming Plattform 
- install ProtonGE to fix issues in some Steam Games 
- optional install MangoHUD, OBS Studio


#### Notice:

This Script install the Mesa Driver Package (**Open-Source**) this Package contains **Intel** and **AMD** GPU Driver.

The Nvidia Driver is on the other Hand **fully proprietary**!.


### Usage:

1) Navigate to the Folder where the wannaplay.sh File is located -> Open your **Terminal** in this Directory.

2) Execute ``sudo chmod +x wannaplay.sh`` to give the Script execution rights.

3) After that execute the Script by typing: ``sudo ./wannaplay.sh``

4) Done.. follow the Script with the User input prompt and you'r should be fine so far.

![Script in Aktion gif here](img/startthescript.gif)
