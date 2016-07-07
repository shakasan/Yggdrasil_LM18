#!/bin/bash
#------------------------------------------------------------------------------#
# Yggdrasil                                                                    #
#    author : Francois B. (Makotosan/Shakasan)                                 #
#    licence : GPLv3                                                           #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Script's cons. and vars.                                                     #
#------------------------------------------------------------------------------#

version="0.2"

# myHomedir is used in full paths to the homedir
myHomedir=$(whoami)

# script base dir
scriptDir=$(pwd)

# color codes
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"
INV="\\033[39;7m"

#------------------------------------------------------------------------------#
# Temp files for Dialog                                                        #
#------------------------------------------------------------------------------#

# temp files for the answers from dialog
OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM

# menu temp
menuINPUT=/tmp/menu.sh.$$
menuOUTPUT=/tmp/output.sh.$$
trap "rm $menuOUTPUT; rm $menuINPUT; exit" SIGHUP SIGINT SIGTERM

# menuApp tmp
menuAppINPUT=/tmp/appMenu.sh.$$
menuAppOUTPUT=/tmp/appOutput.sh.$$
trap "rm $menuAppOUTPUT; rm $menuAppINPUT; exit" SIGHUP SIGINT SIGTERM

# menuDev tmp
menuDevINPUT=/tmp/devMenu.sh.$$
menuDevOUTPUT=/tmp/devOutput.sh.$$
trap "rm $menuDevOUTPUT; rm $menuDevINPUT; exit" SIGHUP SIGINT SIGTERM

# menuCustom tmp
menuCustomINPUT=/tmp/customMenu.sh.$$
menuCustomOUTPUT=/tmp/customOutput.sh.$$
trap "rm $menuCustomOUTPUT; rm $menuCustomINPUT; exit" SIGHUP SIGINT SIGTERM

# menuHW tmp
menuHWINPUT=/tmp/hwMenu.sh.$$
menuHWOUTPUT=/tmp/hwOutput.sh.$$
trap "rm $menuHWOUTPUT; rm $menuHWINPUT; exit" SIGHUP SIGINT SIGTERM

# menuConfig tmp
menuConfigINPUT=/tmp/configMenu.sh.$$
menuConfigOUTPUT=/tmp/configOutput.sh.$$
trap "rm $menuConfigOUTPUT; rm $menuConfigINPUT; exit" SIGHUP SIGINT SIGTERM

# menuSysTools tmp
menuSysToolsINPUT=/tmp/sysToolsMenu.sh.$$
menuSysToolsOUTPUT=/tmp/sysToolsOutput.sh.$$
trap "rm $menuSysToolsOUTPUT; rm $menuSysToolsINPUT; exit" SIGHUP SIGINT SIGTERM

#------------------------------------------------------------------------------#
# Script's functions                                                           #
#------------------------------------------------------------------------------#

# display a message + notification
function msg () {
  printf "\n"
  printf "$JAUNE"
  if [ "$#" -gt "0" ]; then
    printf "$*\n"
    /usr/bin/notify-send -t 7000 "$*"
  fi
  printf "$NORMAL"
}

# display a message + notification + ask to push a key to continue
function pressKey () {
  msg $*
  if which mpg123 >/dev/null; then
    mpg123 -q $scriptDir/notify.mp3 &
  fi
  printf "$INV"
  read -p "Appuyer sur une <Enter> pour continuer ..."
  printf "$NORMAL"
}

# system update
function updateSystem () {
  msg "Mise à jours : update"
  sudo apt-get update
  msg "Mise à jours : upgrade"
  sudo apt-get -y upgrade
  msg "Mise à jours : dist-upgrade"
  sudo apt-get -y dist-upgrade
}

function osCheck () {
  printf "$JAUNE""Vérification de l'OS\n\n""$NORMAL"
  OS=`lsb_release -d | gawk -F':' '{print $2}' | gawk -F'\t' '{print $2}'`

  if [[ $OS == *"Linux Mint 18"* ]]; then
    printf "[ ""$VERT""OK"$NORMAL" ] Linux Mint 18.x\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] Linux Mint 18.x non identifiée. On quitte le script...\n"
    printf "\n"
    exit
  fi
}

# dependencies used in the script checked and installed if necessary
function depCheck () {
  printf "$JAUNE""Vérification des dépendances de base\n\n""$NORMAL"

  # mpg123
  if which mpg123 >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] mpg123\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] mpg123 : installation ...\n"
    sudo apt-get install -y mpg123 >/dev/null
  fi

  # libnotify-bin (cmd : notify-send)
  if which notify-send >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] libnotify-bin\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] libnotify-bin : installation ...\n"
    sudo apt-get install -y libnotify-bin >/dev/null
  fi

  # lsb_release
  if which lsb_release >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] lsb-release\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] lsb-release : installation ...\n"
    sudo apt-get install -y lsb-release >/dev/null
  fi

  # cifs-utils
  if which mount.cifs >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] cifs-utils\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] cifs-utils : installation ...\n"
    sudo apt-get install -y cifs-utils >/dev/null
  fi

  # dialog
  if which dialog >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] dialog\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] dialog : installation ...\n"
    sudo apt-get install -y dialog >/dev/null
  fi
}

#------------------------------------------------------------------------------#
# The main part of the script                                                  #
#------------------------------------------------------------------------------#

clear

# Useless by itself, but is used to don't be annoyed later in the script
# NEVER run the script as root or with sudo !!!!
sudo echo

printf "\n"

printf "$JAUNE"
printf "          __   __              _               _ _  \n"
printf "          \ \ / /             | |             (_) | \n"
printf "           \ V /__ _  __ _  __| |_ __ __ _ ___ _| | \n"
printf "$NORMAL     _____ $JAUNE \ // _\` |/ _\` |/ _\` | '__/ _\` / __| | | \n"
printf "$NORMAL _________ $JAUNE | | (_| | (_| | (_| | | | (_| \__ \ | | $NORMAL ___________________________________\n"
printf "$JAUNE            \_/\__, |\__, |\__,_|_|  \__,_|___/_|_| $NORMAL _______________________________\n"
printf "$JAUNE                __/ | __/ |                         \n"
printf "               |___/ |___/  $ROUGE Customize Linux Mint 18 made easier\n"
printf "$NORMAL                             ver "$version" - GPLv3 - Francois B. (Makotosan/Shakasan)\n"

printf "\n"
printf "$VERT""User (userdir) :""$NORMAL"" $myHomedir\n"
printf "$VERT""OS : ""$NORMAL"
lsb_release -d | gawk -F':' '{print $2}' | gawk -F'\t' '{print $2}'
printf "$VERT""Kernel : ""$NORMAL"
uname -r
printf "$VERT""Architecture : ""$NORMAL"
uname -m
printf "$VERT""CPU :""$NORMAL"
cat /proc/cpuinfo | grep "model name" -m1 | gawk -F':' '{print $2}'

printf "$BLANC""__________________________________________________________________________________\n""$NORMAL"
printf "\n"
osCheck
printf "\n"
depCheck

printf "$BLANC""__________________________________________________________________________________\n""$NORMAL"
printf "\n"

pressKey

# Apps dir created if necessary
mkdir -p /home/$myHomedir/Apps

#------------------------------------------------------------------------------#
# Main menu, using Dialog                                                      #
#------------------------------------------------------------------------------#

while true
do

# menu -------------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Menu Principal ]" \
--menu "Cet utilitaire permet d'installer et customiser votre installation fraichement installée. A utiliser avec précaution ;-)" 32 85 24 \
----------- "---Partie obligatoire------------" \
Source "Ouvrir Sotfware-Source (ajouter dépots sources et getdeb)" \
Update "Mise à jours du système" \
PPA "Ajout des PPAs requis" \
----------- "---------------------------------" \
AppInstall "Installation des Apps" \
Custom "Customisation (themes,icones,...)" \
Hardware "Installation et config du Hardware" \
DevInstall "Installation des Apps de Dev" \
SystemTweak "Configuration/Tweaking du système" \
----------- "---------------------------------" \
SystemTools "Outils divers" \
Reboot "Re-démarrer le système" \
----------- "---------------------------------" \
About "A propos de ce script ..." \
Exit "Quitter" 2>"${menuINPUT}"

menuitem=$(<"${menuINPUT}")

# menu's actions ---------------------------------------------------------------
case $menuitem in

Source) #-----------------------------------------------------------------------
clear

msg "On change les mirroirs + add Sources"
software-sources

pressKey
;;

Update) #-----------------------------------------------------------------------
clear

msg "Mise à jours du système"
updateSystem

pressKey
;;

PPA) #--------------------------------------------------------------------------
clear
msg "Ajout Arch i386"
sudo dpkg --add-architecture i386

msg "Ajout paquet apt-transport-https"
sudo apt-get install apt-transport-https

msg "Licences Java 7/8 Oracle acceptées automatiquement"
sudo sh -c "echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections"
sudo sh -c "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections"

msg "Pré-config du paquet science-config"
sudo sh -c "echo sience-config science-config/group select '$myHomedir ($myHomedir)' | sudo debconf-set-selections"

msg "Ajout des PPAs"
sudo add-apt-repository -y ppa:noobslab/themes # themes from noobslab
sudo add-apt-repository -y ppa:noobslab/icons # icones from noobslab
sudo add-apt-repository -y ppa:numix/ppa # Theme Numix
sudo add-apt-repository -y ppa:ravefinity-project/ppa # themes
sudo add-apt-repository -y ppa:teejee2008/ppa # Aptik - Conky-Manager
sudo add-apt-repository -y ppa:yktooo/ppa # indicator-sound-switcher
sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager # Y-PPA-Manager
sudo add-apt-repository -y ppa:webupd8team/atom # Atom IDE
sudo add-apt-repository -y ppa:videolan/stable-daily # VLC
sudo add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make # ubuntu-make
#sudo add-apt-repository -y ppa:skype-wrapper/ppa # skype-wrapper # no longer maintained ?
sudo add-apt-repository -y ppa:nowrep/qupzilla # Qupzilla web browser
sudo add-apt-repository -y ppa:atareao/atareao # pushbullet-indicator, imagedownloader, gqrcode, cpu-g
sudo add-apt-repository -y ppa:costales/anoise # Anoise, ambiance sounds
sudo add-apt-repository -y ppa:fossfreedom/rhythmbox-plugins # plugins pour Rhythmbox
sudo add-apt-repository -y ppa:nilarimogard/webupd8 # Audacious, grive2, pidgin-indicator, ...
sudo add-apt-repository -y ppa:oibaf/graphics-drivers # Pilotes graphique libre + MESA
sudo add-apt-repository -y ppa:team-xbmc/ppa # Kodi
sudo add-apt-repository -y ppa:webupd8team/java # oracle-java7/8
sudo add-apt-repository -y ppa:hugin/hugin-builds # Hugin image editor
sudo add-apt-repository -y ppa:mumble/release # Mumble
sudo add-apt-repository -y ppa:atareao/utext # Utext, Markdown editor
sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer # grub-customizer
#sudo add-apt-repository -y ppa:birdie-team/stable # birdie, twitter client # no longer maintained ?
sudo add-apt-repository -y ppa:lucioc/sayonara # lecteur audio
sudo add-apt-repository -y ppa:haraldhv/shotcut # Shotcut, video editor
sudo add-apt-repository -y ppa:flacon/ppa # extraction audio
#sudo add-apt-repository -y ppa:mc3man/trusty-media # multimedia apps # no longer maintained ?
sudo add-apt-repository -y ppa:jaap.karssenberg/zim # Wiki en local
sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release # darktable (newest versions)
sudo add-apt-repository -y ppa:js-reynaud/kicad-4 # Kicad 4
sudo add-apt-repository -y ppa:stebbins/handbrake-releases # handbrake
sudo add-apt-repository -y ppa:webupd8team/brackets # Brackets IDE, Adobe Open-Source IDE
sudo add-apt-repository -y ppa:graphics-drivers/ppa # drivers Nvidia proprio
sudo add-apt-repository -y ppa:djcj/hybrid # FFMpeg, MKVToolnix, ...
sudo add-apt-repository -y ppa:diodon-team/stable # Diodon clipboard
sudo add-apt-repository -y ppa:notepadqq-team/notepadqq # Notepadqq (Notepad++ clone)
sudo add-apt-repository -y ppa:mariospr/frogr # Frogr, Flickr manager
#sudo add-apt-repository -y ppa:webupd8team/tribler # Tribbler, P2P décentralisé # no longer maintained ?
#sudo add-apt-repository -y ppa:zeal-developers/ppa # Zeal, dev doc manager # no longer maintained ?
sudo add-apt-repository -y ppa:saiarcot895/myppa # apt-fast
sudo add-apt-repository -y ppa:ubuntuhandbook1/slowmovideo # SlowmoVideo
#sudo add-apt-repository -y ppa:whatsapp-purple/ppa # WhatsApp plugin for Pidgin/libpurple # update ?
sudo add-apt-repository -y ppa:transmissionbt/ppa # Transmission-BT (newest versions)
sudo add-apt-repository -y ppa:geary-team/releases # Geary (newest versions)
sudo add-apt-repository -y ppa:varlesh-l/papirus-pack # themes and icons

msg "Ajout Repository Opera"
echo "deb http://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera.list
wget -qO- http://deb.opera.com/archive.key | sudo apt-key add -

msg "Ajout Repository Google Chrome"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

msg "Ajout Repository InSync"
echo "deb http://apt.insynchq.com/ubuntu xenial non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list
wget -qO - https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key | sudo apt-key add -

msg "Ajout Repository Docker"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main"  | sudo tee /etc/apt/sources.list.d/docker.list

msg "Ajout Repository SyncThing"
wget -qO - https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list

#msg "Ajout Repository OwnCloud"
#wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_14.04/Release.key
#sudo apt-key add - < Release.key
#sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud.list"

#msg "Ajout Repository PlayOnLinux"
#wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
#sudo wget http://deb.playonlinux.com/playonlinux_trusty.list -O /etc/apt/sources.list.d/playonlinux.list

msg "Ajout Repository MKVToolnix"
wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | sudo apt-key add -
echo "deb http://mkvtoolnix.download/ubuntu/xenial/ ./"  | sudo tee /etc/apt/sources.list.d/mkv.list
echo "deb-src http://mkvtoolnix.download/ubuntu/xenial/ ./ "  | sudo tee -a /etc/apt/sources.list.d/mkv.list

#msg "Ajout Repository Tox/Qtox"
#echo "deb https://pkg.tox.chat/debian nightly $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/tox.list
#wget -qO - https://pkg.tox.chat/debian/pkg.gpg.key | sudo apt-key add -

msg "Ajout Repository Ring"
echo "deb http://nightly.apt.ring.cx/ubuntu_16.04/ ring main" | sudo tee /etc/apt/sources.list.d/ring-nightly-man.list
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys A295D773307D25A33AE72F2F64CD5FA175348F84
sudo add-apt-repository universe

#msg "Ajout Repository purple-facebook"
#wget -O- https://jgeboski.github.io/obs.key | sudo apt-key add -
#sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_14.04/ ./' > /etc/apt/sources.list.d/jgeboski.list"

msg "Ajout Repository Spotify"
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886

msg "Ajout Repository VirtualBox"
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

msg "Ajout Repository Whatsie"
gpg --keyserver pool.sks-keyservers.net --recv-keys 1537994D
gpg --export --armor 1537994D | sudo apt-key add -
echo "deb https://dl.bintray.com/aluxian/deb stable main" | sudo tee -a /etc/apt/sources.list.d/whatsie.list

msg "Ajout Repository Getdeb"
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
echo "deb http://archive.getdeb.net/ubuntu xenial-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb.list

updateSystem
;;

AppInstall) #-------------------------------------------------------------------
#------------------------------------------------------------------------------#
# App menu, using Dialog                                                       #
#------------------------------------------------------------------------------#
while true
do
# appMenu ----------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Apps Menu ]" \
--menu "Choisissez les Apps à installer" 34 85 26 \
Base "Outils de base" \
Multimedia "Apps multimédia" \
MultimediaExt "Apps multimédia (autres/ext)" \
eBook "Apps/outils pour eBook" \
Internet "Apps internet" \
InternetExt "Apps internet (autres/ext)" \
Utilitaires "Utilitaires divers" \
Wine "Wine" \
WineG3D "Wine opti Gallium3D (PPA oibaf requis)" \
WineStaging "Wine unstable en parallèle de wine" \
KodiBETA "Kodi Beta/Unstable" \
KodiNightly "Kodi Nightly" \
Jeux "Steam, jstest-gtk" \
Graveur "Apps pour graveur CD/DVD/BD" \
NetTools "Apps/Outils réseau" \
Caja "Extensions pour Caja" \
Nautilus "Extensions pour Nautilus" \
Gimp "Extensions pour Gimp" \
RhythmBox "Extensions pour RhythmBox" \
Pidgin "Extensions pour Pidgin et libpurple" \
Unbound "Unbound, cache DNS" \
Zsh "Shell ZSH + Oh-my-Zsh" \
Back "Revenir au menu principal" 2>"${menuAppINPUT}"

menuAppItem=$(<"${menuAppINPUT}")

# appMenu's actions ------------------------------------------------------------
case $menuAppItem in

Base) #-------------------------------------------------------------------------
clear

msg "Installation des outils de base"
sudo apt-get install -y cifs-utils xterm curl mc bmon htop screen dconf-cli dconf-editor lnav exfat-fuse exfat-utils iftop iptraf mpg123 debconf-utils idle3-tools

pressKey
;;

Multimedia) #-------------------------------------------------------------------
clear
msg "Installation des Apps multimédia"
# to add if available : fontmatrix qgifer vlc-plugin-libde265 arista
sudo apt-get install -y spotify-client dvdstyler slowmovideo mpv audacious qmmp qmmp-plugin-projectm sayonara digikam inkscape blender picard dia shotcut aegisub aegisub-l10n hugin audacity asunder mypaint mypaint-data-extras synfigstudio kodi milkytracker mkvtoolnix-gui openshot pitivi smplayer smplayer-themes smplayer-l10n selene gnome-mplayer handbrake avidemux2.6-qt avidemux2.6-plugins-qt mjpegtools twolame lame banshee banshee-extension-soundmenu gpicview vlc shotwell darktable ffmpeg flacon scribus birdfont moc rawtherapee

msg "Config du Theme DarkDot pour Mocp"
sh -c "echo '\n\nalias mocp=\"mocp -T darkdot_theme\"\n' >> /home/$myHomedir/.bashrc"

pressKey
;;

MultimediaExt) #----------------------------------------------------------------
clear

msg "Installation des Apps multimédia"

cd /tmp

msg "Téléchargement de XnRetro"
wget http://download.xnview.com/XnRetro-linux.tgz

msg "Installation de XnRetro"
tar xzf XnRetro-linux.tgz
mv XnRetro /home/$myHomedir/Apps

msg "Création du raccourci pour XnRetro"
mkdir -p /home/$myHomedir/.local/share/applications
sh -c "echo '[Desktop Entry]\n\
Encoding=UTF-8\n\
Terminal=0\n\
Exec=/home/"$myHomedir"/Apps/XnRetro/xnretro.sh\n\
Icon=/home/"$myHomedir"/Apps/XnRetro/xnretro.png\n\
Type=Application\n\
Categories=Graphics;\n\
StartupNotify=true\n\
Name=XnRetro\n\
GenericName=XnRetro\n\
Name[en_US]=XnRetro.desktop\n\
Comment=' > /home/"$myHomedir"/.local/share/applications/xnretro.desktop"

update-menus

msg "Téléchargement de XnView"
wget http://download.xnview.com/XnViewMP-linux-x64.deb

msg "Installation de XnView"
sudo dpkg -i XnViewMP-linux-x64.deb
sudo apt-get install -fy

pressKey
;;

eBook) #------------------------------------------------------------------------
clear

msg "Installation des Apps/outils pour eBook"
sudo apt-get install -y fbreader

cd /tmp

msg "Installation de Calibre"
sudo -v && wget --no-check-certificate -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"

pressKey
;;

Internet) #---------------------------------------------------------------------
clear

msg "Installation des Apps internet"

echo "opera-stable opera-stable/add-deb-source boolean false" | sudo debconf-set-selections

# to add when available : owncloud-client skype-wrapper tribler qtox birdie (pushbullet)
sudo apt-get install -y whatsie ring-gnome frogr dropbox syncthing-gtk syncthing opera-stable quiterss insync google-chrome-stable midori xchat-gnome xchat-gnome-indicator chromium-browser chromium-browser-l10n geary qupzilla dropbox filezilla hexchat mumble skype imagedownloader california

pressKey
;;

InternetExt) #------------------------------------------------------------------
clear

msg "Installation des Apps internet"

cd /tmp

msg "Téléchargement de Viber"
wget http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb

msg "Installation de Viber"
sudo dpkg -i viber.deb
sudo apt-get install -fy

msg "Téléchargement de MegaSync"
wget https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync-xUbuntu_16.04_amd64.deb

msg "Installation de MegaSync"
sudo dpkg -i megasync-xUbuntu_16.04_amd64.deb
sudo apt-get install -fy

msg "Téléchargement de Telegram Desktop"
wget -O tsetup.tar.xz https://tdesktop.com/linux

msg "Installation de Telegram Desktop"
tar xvJf tsetup.tar.xz
mv Telegram /home/$myHomedir/Apps
sh -c "/home/"$myHomedir"/Apps/Telegram/Telegram &" && sleep 10 && pkill Telegram

msg "Téléchargement de Wickr"
wget -O wickr.deb https://dls.wickr.com/Downloads/wickr-me_2.6.0_amd64.deb

msg "Installation de Wickr"
sudo dpkg -i wickr.deb
sudo apt-get install -fy

msg "Téléchargement de Gyazo"
wget https://packagecloud.io/install/repositories/gyazo/gyazo-for-linux/script.deb.sh

msg "Installation de Gyazo"
sudo os=ubuntu dist=xenial ./script.deb.sh
sudo apt-get install -y gya

msg "Téléchargement de Franz"
mkdir -p Franz
cd Franz
wget -O franz.tgz https://github.com/imprecision/franz-app/releases/download/3.1.0/Franz-linux-x64-3.1.0.tgz

msg "Installation de Franz"
tar xzf franz.tgz
cd ..
mv Franz /home/$myHomedir/Apps

msg "Création du raccourci pour Franz"
mkdir -p /home/$myHomedir/.local/share/applications
sh -c "echo '[Desktop Entry]\n\
Encoding=UTF-8\n\
Terminal=0\n\
Exec=/home/"$myHomedir"/Apps/Franz/Franz\n\
Icon=/home/"$myHomedir".icons/franz.png\n\
Type=Application\n\
Categories=Network;InstantMessaging;\n\
StartupNotify=true\n\
Name=Franz\n\
GenericName=Franz\n\
Name[en_US]=Franz.desktop\n\
Comment=' > /home/"$myHomedir"/.local/share/applications/Franz.desktop"

pressKey
;;

Utilitaires) #------------------------------------------------------------------
clear

msg "Installation d'Apps et Utilitaires divers"
echo "apt-fast	apt-fast/maxdownloads	string	5" | sudo debconf-set-selections
echo "apt-fast	apt-fast/dlflag	boolean	true" | sudo debconf-set-selections
echo "apt-fast	apt-fast/aptmanager	select	apt-get" | sudo debconf-set-selections
echo "apt-fast	apt-fast/downloader	select	aria2c" | sudo debconf-set-selections
sudo apt-get install -y qtqr cpu-g screenfetch xcalib conky-manager conky-all plank indicator-sound-switcher y-ppa-manager synapse anoise acetoneiso guake tilda psensor kazam bleachbit gparted gsmartcontrol terminator aptik gufw numlockx grub-customizer chmsee unetbootin zim diodon pyrenamer apt-fast

pressKey
;;

Wine) #-------------------------------------------------------------------------
clear

msg "Ajout du PPA de Wine"
sudo add-apt-repository -y ppa:ubuntu-wine/ppa

msg "Mise à jours du système"
updateSystem

msg "Installation de Wine"
sudo apt-get -y install wine1.8 winetricks playonlinux

pressKey
;;

WineG3D) #----------------------------------------------------------------------
clear

msg "Ajout du PPA de Wine - commendsarnex/winedri3"
sudo add-apt-repository -y ppa:commendsarnex/winedri3

msg "Mise à jours du système"
updateSystem

msg "Installation de Wine"
sudo apt-get -y install wine1.9 winetricks playonlinux

pressKey
;;

WineStaging) #------------------------------------------------------------------
clear

msg "Ajout du PPA de Wine-Staging"
sudo add-apt-repository -y ppa:pipelight/stable

msg "Mise à jours du système"
updateSystem

msg "Installation de Wine-Staging"
sudo apt-get -y install wine-staging-amd64

pressKey
;;

KodiBETA) #---------------------------------------------------------------------
clear

msg "Ajout du PPA de Kodi BETA"
sudo add-apt-repository -y ppa:team-xbmc/unstable

msg "Mise à jours du système"
updateSystem

msg "Installation de Kodi s/n"
sudo apt-get install -y kodi

pressKey
;;

KodiNightly) #------------------------------------------------------------------
clear

msg "Ajout du PPA de Kodi Nightly"
sudo add-apt-repository -y ppa:team-xbmc/xbmc-nightly

msg "Mise à jours du système"
updateSystem

msg "Installation de Kodi s/n"
sudo apt-get install -y kodi

pressKey
;;

Jeux) #-------------------------------------------------------------------------
clear

msg "Installation de Steam, jstest-gtk"
sudo apt-get install -y steam jstest-gtk

pressKey
;;

Graveur) #----------------------------------------------------------------------
clear

msg "Installation des Apps pour graveurs CD/DVD/BD..."
sudo apt-get install -y brasero k3b k3b-extrathemes xfburn

pressKey
;;

NetTools) #---------------------------------------------------------------------
clear

msg "Installation des outils réseau"
# to add when available : gtkvncviewer
sudo apt-get install -y whois iptraf iperf wireshark tshark zenmap dsniff aircrack-ng

pressKey
;;

Caja) #-------------------------------------------------------------------------
clear

msg "Installation des extensions pour Caja"
sudo apt-get install -y caja-share caja-wallpaper caja-sendto caja-image-converter

if which insync >/dev/null; then
  msg "Installation Addon InSync pour Caja"
	sudo apt-get install -y insync-caja
fi

pressKey
;;

Nautilus) #---------------------------------------------------------------------
clear

msg "Installation des extensions pour Nautilus"
sudo apt-get install -y nautilus file-roller nautilus-emblems nautilus-image-manipulator nautilus-image-converter nautilus-compare nautilus-actions nautilus-sendto nautilus-share nautilus-wipe nautilus-script-audio-convert nautilus-filename-repairer nautilus-gtkhash nautilus-ideviceinfo ooo-thumbnailer nautilus-dropbox nautilus-script-manager nautilus-columns nautilus-flickr-uploader nautilus-pushbullet

if which insync >/dev/null; then
  msg "Installation Addon InSync pour Nautilus"
	sudo apt-get install -y insync-nautilus
fi

pressKey
;;

Gimp) #-------------------------------------------------------------------------
clear

msg "Installation des extensions pour Gimp"
sudo apt-get install -y gtkam-gimp gimp-gluas pandora gimp-data-extras gimp-lensfun gimp-gmic gimp-ufraw gimp-texturize gimp-plugin-registry

pressKey
;;

RhythmBox) #--------------------------------------------------------------------
clear

msg "Installation des extensions pour RhythmBox"
sudo apt-get install -y rhythmbox-plugin-alternative-toolbar rhythmbox-plugin-artdisplay rhythmbox-plugin-cdrecorder rhythmbox-plugin-close-on-hide rhythmbox-plugin-countdown-playlist rhythmbox-plugin-coverart-browser rhythmbox-plugin-coverart-search rhythmbox-plugin-desktopart rhythmbox-plugin-equalizer rhythmbox-plugin-fileorganizer rhythmbox-plugin-fullscreen rhythmbox-plugin-hide rhythmbox-plugin-jumptowindow rhythmbox-plugin-llyrics rhythmbox-plugin-looper rhythmbox-plugin-opencontainingfolder rhythmbox-plugin-parametriceq rhythmbox-plugin-playlist-import-export rhythmbox-plugin-podcast-pos rhythmbox-plugin-randomalbumplayer rhythmbox-plugin-rating-filters rhythmbox-plugin-remembertherhythm rhythmbox-plugin-repeat-one-song rhythmbox-plugin-rhythmweb rhythmbox-plugin-screensaver rhythmbox-plugin-smallwindow rhythmbox-plugin-spectrum rhythmbox-plugin-suspend rhythmbox-plugin-tray-icon rhythmbox-plugin-visualizer rhythmbox-plugin-wikipedia rhythmbox-plugins

pressKey
;;

Pidgin) #--------------------------------------------------------------------
clear

msg "Installation des extensions pour Pidgin"
# to add when available : pidgin-whatsapp
sudo apt-get install -y telegram-purple pidgin-skype purple-hangouts pidgin-hangouts

pressKey
;;

Zsh) #--------------------------------------------------------------------------
clear

msg "Installation de ZSH"
sudo apt-get install -y zsh

msg "Installation de Oh-my-Zsh"
msh "Taper exit pour sortir de Zsh et revenir vers Yggdrasil"
cd /tmp
rm install.sh
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
chmod +x install.sh
./install.sh

pressKey
;;

Unbound) #----------------------------------------------------------------------
clear

msg "Installation de Unbound"
sudo apt-get install -y unbound

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of App menu actions choice
esac
# end of App menu loop
done
;;

Custom) #-----------------------------------------------------------------------
#------------------------------------------------------------------------------#
# App menu, using Dialog                                                       #
#------------------------------------------------------------------------------#
while true
do
# customMenu -------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Custom Menu ]" \
--menu "Customisation du système" 32 85 24 \
Themes "Themes et icones" \
Plank "Themes pour Plank" \
Icons "Pack d'icones pour les Apps installées hors PPA" \
Back "Revenir au menu principal" 2>"${menuCustomINPUT}"

menuCustomItem=$(<"${menuCustomINPUT}")

# customMenu's actions ---------------------------------------------------------
case $menuCustomItem in

Themes) #-----------------------------------------------------------------------
clear

msg "Installation des thèmes"
# to add when available : ambiance-dark ambiance-dark-red mediterranean-theme polar-night-gtk hackstation-theme libra-theme zukitwo-dark-reloaded ceti-theme vertex-theme stylishdark-theme cenodark-gtk dorian-theme vimix-flat-themes delorean-dark dorian-theme-3.12 candra-gs-themes paper-gtk-theme
sudo apt-get install -y ambiance-crunchy arc-theme ambiance-colors radiance-colors ambiance-flat-colors radiance-flat-colors vivacious-colors-gtk-dark vivacious-colors-gtk-light yosembiance-gtk-theme ambiance-blackout-colors ambiance-blackout-flat-colors ambiance-colors ambiance-flat-colors radiance-flat-colors vibrancy-colors vivacious-colors numix-gtk-theme

msg "Installation des icônes"
# to add when available : elementary-icons paper-icon-theme
sudo apt-get install -y papirus-gtk-icon-theme ultra-flat-icons myelementary  ghost-flat-icons faenza-icon-theme faience-icon-theme vibrantly-simple-icon-theme rave-x-colors-icons ravefinity-x-icons numix-icon-theme numix-icon-theme-circle

pressKey
;;


Plank) #------------------------------------------------------------------------
clear

if which plank >/dev/null; then
  if (( $(ps -ef | grep -v grep | grep plank | wc -l) > 0 )); then
    sh -c "cd ~ && mkdir -p ~/.temp-plank-themer && cd ~/.temp-plank-themer && wget https://github.com/rhoconlinux/plank-themer/archive/master.zip && unzip master.zip && cd plank-themer-master/ && rm -fR ~/.config/plank/dock1/theme_index; rm -fR ~/.config/plank/dock1/themes-repo; cp -a theme_index/ ~/.config/plank/dock1 && cp -a themes-repo/ ~/.config/plank/dock1 && cd ~ && rm -R ~/.temp-plank-themer && sh ~/.config/plank/dock1/theme_index/plank-on-dock-themer.sh"
  else
    plank 2&>1 >/dev/null &
    sleep 10
    sh -c "cd ~ && mkdir -p ~/.temp-plank-themer && cd ~/.temp-plank-themer && wget https://github.com/rhoconlinux/plank-themer/archive/master.zip && unzip master.zip && cd plank-themer-master/ && rm -fR ~/.config/plank/dock1/theme_index; rm -fR ~/.config/plank/dock1/themes-repo; cp -a theme_index/ ~/.config/plank/dock1 && cp -a themes-repo/ ~/.config/plank/dock1 && cd ~ && rm -R ~/.temp-plank-themer && sh ~/.config/plank/dock1/theme_index/plank-on-dock-themer.sh"
  fi
else
  msg "Plank doit être installé en premier"
fi

pressKey
;;

Icons) #------------------------------------------------------------------------
clear

msg "Installation des icones custom"
mkdir -p /home/$myHomedir/.icons
cp icons.tar.gz /home/$myHomedir/.icons
cd /home/$myHomedir/.icons
tar xzf icons.tar.gz
rm icons.tar.gz

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of Custom menu actions choice
esac
# end of Custom menu loop
done
;;

Hardware) #---------------------------------------------------------------------
#------------------------------------------------------------------------------#
# HW menu, using Dialog                                                        #
#------------------------------------------------------------------------------#
while true
do
# hwMenu -----------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ HW Menu ]" \
--menu "Hardware : driver et configration" 32 95 24 \
CardReader "Installation de pcscd pour les CardReader" \
eID "Installation middleware eID" \
EpsonV500Photo "Installation driver Espon V500 Photo + iscan + Xsane" \
Microcode "Mise à jours du Microcode du CPU (Intel)" \
WirelessIntel6320 "Config Intel Centrino Advanced-N 6320 (problème Bluetooth)" \
Back "Revenir au menu principal" 2>"${menuHWINPUT}"

menuHWItem=$(<"${menuHWINPUT}")

# hwMenu's actions -------------------------------------------------------------
case $menuHWItem in

CardReader) #-------------------------------------------------------------------
clear

msg "Installation de CardReader and utils"
sudo apt-get install -y pcscd pcsc-tools

pressKey
;;

eID) #------------------------------------------------------------------------
clear

cd /tmp

msg "Installation de eID"

msg "Installation de eID : download du .deb"
wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" http://eid.belgium.be/sites/default/files/downloads/eid-archive_2016.2_all.deb

msg "Installation de eID : extraction du .deb"
ar xv eid-archive_2016.2_all.deb
tar xvf data.tar.xz
cd /tmp/usr/share/eid-archive/keys

msg "Installation de eID : installation manuelle de la clé GPG"
sudo mv 6773d225.gpg /etc/apt/trusted.gpg.d/eid-archive-released-builds.gpg

msg "Installation de eID : installation du dépot"
sudo sh -c "echo 'deb http://files.eid.belgium.be/debian qiana main\n\
deb http://files2.eid.belgium.be/debian qiana main' > /etc/apt/sources.list.d/eid.list"

updateSystem

msg "Installation de eID : installation de eid-mw + libacr38u"
sudo apt-get install -y eid-mw libacr38u

pressKey
;;

EpsonV500Photo) #---------------------------------------------------------------
clear

cd /tmp

msg "Téléchargement de iScan"
wget https://download2.ebz.epson.net/iscan/plugin/gt-x770/deb/x64/iscan-gt-x770-bundle-1.0.0.x64.deb.tar.gz

msg "Installation de iScan via DPKG"
tar xzf iscan-gt-x770-bundle-1.0.0.x64.deb.tar.gz
cd /tmp/iscan-gt-x770-bundle-1.0.0.x64.deb
./install.sh

msg "Installation de Xsane"
sudo apt-get -y install xsane

msg "Ajout à Xsane du backend epkowa du Scanner Epson Perfection V500"
sudo sh -c "echo '# Epson Perfection V500\n\
usb 0x04b8 0x0130' >> /etc/sane.d/epkowa.conf"

pressKey
;;

Microcode) #--------------------------------------------------------------------
clear

msg "Mise à jours du Microcode du Processeur"
oldMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
intel=`cat /proc/cpuinfo | grep -i Intel | wc -l`
if [ "$intel" -gt "0" ]; then
  sudo apt-get install -y intel-microcode
fi
newMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
msg "Microcode passé de la version "$oldMicrocode" à la version "$newMicrocode

pressKey
;;

WirelessIntel6320) #------------------------------------------------------------
clear

msg "Backup du fichier iwlwifi.conf"
sudo cp /etc/modprobe.d/iwlwifi.conf /etc/modprobe.d/iwlwifi.conf.bak

msg "Paramètres dans iwlwifi.conf"
echo options iwlwifi bt_coex_active=0 swcrypto=1 11n_disable=8 | sudo tee /etc/modprobe.d/iwlwifi.conf

msg "!!! REBOOT Nécessaire !!!"

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of HW menu actions choice
esac
# end of HW menu loop
done
;;

DevInstall) #-------------------------------------------------------------------
#------------------------------------------------------------------------------#
# Dev menu, using Dialog                                                       #
#------------------------------------------------------------------------------#
while true
do
# devMenu ----------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Dev Menu ]" \
--menu "Choisissez les Apps de Dev à installer" 32 85 24 \
DevApps "Outils de Dev divers (Requis)" \
Java "Outils de dev Java" \
JavaScript "Outils de dev JavaScript" \
PHP "Outils de dev PHP" \
LUA "Outils de dev LUA" \
GO "Outils de dev GO" \
Ruby "Outils de dev Ruby" \
QT "Outils de dev QT" \
Python "Outils de dev Python" \
AndroidEnv "Environnement Android (SDK, config, ...)" \
Atom "IDE Atom + extensions" \
Anjuta "IDE Anjuta" \
Brackets "IDE Brackets" \
CodeBlocks "IDE CodeBlocks" \
Geany "IDE Geany" \
Eclipse "IDE Eclipse" \
Idea "IDE Intellij IDEA (Java)" \
PyCharm "IDE PyCharm (Python)" \
VisualStudioCode "IDA Visual Studio Code" \
AndroidStudio "IDE Android Studio (Android)" \
CAD "Apps de CAD" \
Back "Revenir au menu principal" 2>"${menuDevINPUT}"

menuDevItem=$(<"${menuDevINPUT}")

# devMenu's actions ------------------------------------------------------------
case $menuDevItem in

DevApps) #----------------------------------------------------------------------
clear

msg "Installation de divers outils de Dev"
sudo apt-get install -y notepadqq agave utext gpick virtualbox-5.0 build-essential ubuntu-make ghex glade eric bluefish meld bluegriffon zeal

pressKey
;;

Java) #-------------------------------------------------------------------------
clear

msg "Installation des outils Java"
sudo apt-get install -y oracle-java7-installer oracle-java8-installer oracle-java8-set-default

pressKey
;;

JavaScript) #-------------------------------------------------------------------
clear

msg "Installation des outils JavaScript"
sudo apt-get install -y npm nodejs-legacy javascript-common

if which npm >/dev/null; then
  msg "NPM install : remark-lint"
  sudo npm install remark-lint

  msg "NPM install : jshint"
  sudo npm install -g jshint

  msg "NPM install : jedi"
  sudo npm install -g jedi
fi

pressKey
;;

PHP) #--------------------------------------------------------------------------
clear

msg "Installation des outils PHP"
sudo apt-get install -y php7.0-cli

pressKey
;;

LUA) #--------------------------------------------------------------------------
clear

msg "Installation des outils LUA"
sudo apt-get install -y luajit

pressKey
;;

GO) #---------------------------------------------------------------------------
clear

msg "Installation des outils GO"
sudo apt-get install -y gccgo-go

msg "GO Lang : GO PATH dans .bashrc"
sh -c "echo '\n\nexport GOPATH=$HOME/go\nexport PATH=$PATH:$GOROOT/bin:$GOPATH/bin\n' >> /home/$myHomedir/.bashrc"

pressKey
;;

Ruby) #---------------------------------------------------------------------------
clear

msg "Installation des outils Ruby"
sudo apt-get install -y ruby-dev

pressKey
;;

QT) #---------------------------------------------------------------------------
clear

msg "Installation des outils de Dev QT"
sudo apt-get install -y qt4-dev-tools qt4-linguist-tools qt5-doc qttools5-doc qttools5-dev-tools qttools5-examples qttools5-doc-html

msg "Création du lien symbolique permettant à qtchooser de prendre qt5 par défaut"
sudo ln -s /usr/share/qtchooser/qt5-x86_64-linux-gnu.conf /usr/lib/x86_64-linux-gnu/qtchooser/default.conf

msg "Création du raccourci pour QtDesigner 5"
sudo sh -c "echo '#!/usr/bin/env xdg-open\n\
[Desktop Entry]\n\
Version=1.0\n\
Terminal=false\n\
Type=Application\n\
Name=QT Designer 5\n\
Exec=/usr/bin/designer\n\
Icon=/home/"$myHomedir"/.icons/qtdesigner.png\n\
Categories=GNOME;GTK;Development;IDE;\n\
Comment=' > /usr/share/applications/qtdesigner5.desktop"

update-menus

pressKey
;;

Python) #-----------------------------------------------------------------------
clear

msg "Installation des outils de Dev Python"
sudo apt-get install -y python3-dev python3-pip python3-pyqt5

if which pip3 >/dev/null; then
  msg "Mise à jours de PIP"
  sudo pip3 install --upgrade pip

  msg "PIP install : setuptools"
  sudo pip3 install setuptools

  msg "PIP install : flake8"
  sudo pip3 install flake8

  msg "PIP install : MyCLI"
  sudo pip3 install mycli

  msg "PIP install : SpoofMAC"
  sudo pip3 install SpoofMAC

  msg "PIP install : speedtest-cli"
  sudo pip3 install speedtest-cli

  msg "PIP install : whatportis"
  sudo pip3 install whatportis

  msg "PIP install : py-term"
  sudo pip3 install py-term

  msg "PIP install : weppy"
  sudo pip3 install weppy

  msg "PIP install : retext"
  sudo pip3 install retext

  msg "PIP install : waybackpack"
  sudo pip3 install waybackpack

fi

pressKey
;;

AndroidEnv) #-------------------------------------------------------------------
clear

msg="Installation d'un environnement Android"

cd /tmp

msg "Création des répertoires <tools> et <Android> pour le SDK Android, et les apps via umake plus tard"
mkdir /home/$myHomedir/tools
mkdir /home/$myHomedir/tools/Android

msg "Téléchargement du SDK Android"
for a_sdk in $( wget -qO- http://developer.android.com/sdk/index.html | egrep -o "http://dl.google.com[^\"']*linux.tgz" ); do
  wget $a_sdk
done

msg "Installation du SDK Android"
tar --wildcards --no-anchored -xvzf android-sdk_*-linux.tgz
mv android-sdk-linux /home/$myHomedir/tools/Android/Sdk

msg "PATH dans .bashrc : Création fichier S/N"
touch /home/$myHomedir/.bashrc

msg "PATH dans .bashrc : Ajout dans le fichier"
sh -c "echo '\n\nexport PATH=${PATH}:/home/'$myHomedir'/tools/Android/Sdk/tools:/home/'$myHomedir'/tools/Android/Sdk/platform-tools' >> /home/$myHomedir/.bashrc"

msg "Ajout règles UDEV"
sudo sh -c "echo 'SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0502\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Acer\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0b05\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Asus\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"413c\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Dell\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0489\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Foxconn\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04c5\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Fujitsu\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04c5\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Fujitsu-Toshiba\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"091e\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Garmin-Asus\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Google-Nexus\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"201E\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Haier\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"109b\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Hisense\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0bb4\", MODE=\"0666\", OWNER=\""$myHomedir"\" # HTC\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"12d1\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Huawei\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"8087\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Intel\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"24e3\", MODE=\"0666\", OWNER=\""$myHomedir"\" # K-Touch\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2116\", MODE=\"0666\", OWNER=\""$myHomedir"\" # KT Tech\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0482\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Kyocera\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"17ef\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Lenovo\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1004\", MODE=\"0666\", OWNER=\""$myHomedir"\" # LG\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"22b8\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Motorola\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0e8d\", MODE=\"0666\", OWNER=\""$myHomedir"\" # MTK\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0409\", MODE=\"0666\", OWNER=\""$myHomedir"\" # NEC\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2080\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Nook\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0955\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Nvidia\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2257\", MODE=\"0666\", OWNER=\""$myHomedir"\" # OTGV\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"10a9\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Pantech\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1d4d\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Pegatron\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0471\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Philips\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04da\", MODE=\"0666\", OWNER=\""$myHomedir"\" # PMC-Sierra\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"05c6\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Qualcomm\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1f53\", MODE=\"0666\", OWNER=\""$myHomedir"\" # SK Telesys\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04e8\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Samsung\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04dd\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Sharp\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"054c\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Sony\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0fce\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Sony Ericsson\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0fce\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Sony Mobile Communications\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2340\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Teleepoch\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0930\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Toshiba\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"19d2\", MODE=\"0666\", OWNER=\""$myHomedir"\" # ZTE' > /etc/udev/rules.d/99-android.rules"

msg "On redémarre UDEV"
sudo service udev restart

msg "Création du raccourci pour Android SDK"
sudo sh -c "echo '#!/usr/bin/env xdg-open\n\
[Desktop Entry]\n\
Version=1.0\n\
Terminal=false\n\
Type=Application\n\
Name=Android SDK\n\
Exec=/home/"$myHomedir"/tools/Android/Sdk/tools/android\n\
Icon=/home/"$myHomedir"/.icons/android.png\n\
Categories=GNOME;GTK;Development;IDE;\n\
Comment=' > /home/"$myHomedir"/.local/share/applications/androidsdk.desktop"

update-menus

pressKey
;;

Atom) #-------------------------------------------------------------------------
clear

msg "Installation d'Atom + extensions"
sudo apt-get install -y atom

if which apm >/dev/null; then
  msg "Installation plugins Atom"
  apm install git-time-machine color-picker file-icons language-conky language-lua minimap git-status todo-show highlight-selected minimap-highlight-selected pigments minimap-pigments linter linter-javac linter-csslint linter-coffeelint linter-golinter linter-htmlhint linter-lua linter-markdown linter-flake8 linter-php autocomplete-java dash
fi

pressKey
;;

Anjuta) #-----------------------------------------------------------------------
clear

msg "Installation de Anjuta"
sudo apt-get install -y anjuta anjuta-extras

pressKey
;;

Brackets) #---------------------------------------------------------------------
clear

msg "Installation de Brackets"
sudo apt-get install -y brackets

pressKey
;;

CodeBlocks) #-------------------------------------------------------------------
clear

msg "Installation de CodeBlocks"
sudo apt-get install -y codeblocks codeblocks-contrib

pressKey
;;

Geany) #------------------------------------------------------------------------
clear

msg "Installation de Geany"
sudo apt-get install -y geany geany-plugins geany-plugin-markdown

pressKey
;;

Eclipse) #----------------------------------------------------------------------
clear

if which umake >/dev/null; then
  msg "Umake install : Eclipse"
  sudo umake ide eclipse
fi

pressKey
;;

Idea) #-------------------------------------------------------------------------
clear

if which umake >/dev/null; then
  msg "Umake install : Idea"
  sudo umake ide idea
fi
pressKey
;;

PyCharm) #----------------------------------------------------------------------
clear

if which umake >/dev/null; then
  msg "Umake install : PyCharm"
  sudo umake ide pycharm
fi

pressKey
;;

VisualStudioCode) #-------------------------------------------------------------
clear

if which umake >/dev/null; then
  msg "Umake install : Visual-studio-code"
  sudo umake web visual-studio-code
fi

pressKey
;;

AndroidStudio) #----------------------------------------------------------------
clear

if which umake >/dev/null; then
  msg "Umake install : Android-Studio"
  sudo umake android android-studio
fi

pressKey
;;

CAD) #--------------------------------------------------------------------------
clear

msg "Installation des outils de CAD"
sudo apt-get install -y freecad librecad kicad kicad-locale-fr

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of Dev menu actions choice
esac
# end of Dev menu loop
done
;;

SystemTweak) #------------------------------------------------------------------
#------------------------------------------------------------------------------#
# Config menu, using Dialog                                                    #
#------------------------------------------------------------------------------#
while true
do
# configMenu -------------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Configuration du système ]" \
--menu "Configuration du système" 32 95 24 \
Ufw "Activation du firewall ufw" \
NumLockX "Activation de NumLock dés le démarrage" \
TmpRAM "Mise en RAM de /tmp" \
screenfetch "Ajout de screenfetch à .bashrc" \
historyTS "Activation du TimeStamp dans History" \
Back "Revenir au menu principal" 2>"${menuConfigINPUT}"

menuConfigItem=$(<"${menuConfigINPUT}")

# configMenu's actions ---------------------------------------------------------
case $menuConfigItem in

#Fstrim) #-----------------------------------------------------------------------
#clear

#msg "Modif /etc/cron.weekly/fstrim pour activer le TRIM pour tout les SSD"
#sudo sed -i -e '
#s!exec fstrim-all!exec fstrim-all --no-model-check!
#' /etc/cron.weekly/fstrim

#pressKey
#;;

Ufw) #--------------------------------------------------------------------------
clear

msg "Acivatation du FireWall (UFW)"
sudo ufw enable

pressKey
;;

NumLockX) #---------------------------------------------------------------------
clear

msg "NumLockX ajouté à MDM Init Default"
if which numlockx >/dev/null; then
sudo sed -i -e '
s!exit 0!#numlockx!
' /etc/mdm/Init/Default
sudo sh -c "echo 'if [ -x /usr/bin/numlockx ]; then\n\
exec /usr/bin/numlockx on\n\
fi\n\
\n\
exit 0' >> /etc/mdm/Init/Default"
fi

pressKey
;;

TmpRAM) #-----------------------------------------------------------------------
clear

msg "Modif /etc/fstab pour avoir /tmp en RAM"
sudo sh -c "echo 'tmpfs      /tmp            tmpfs        defaults,size=2g           0    0' >> /etc/fstab"

msg "Reboot nécessaire"
pressKey
;;

screenfetch) #------------------------------------------------------------------
clear

msg "Ajout de screenfetch à .bashrc"
touch /home/$myHomedir/.bashrc
echo "screenfetch" >> /home/"$myHomedir"/.bashrc

pressKey
;;

historyTS) #--------------------------------------------------------------------
clear

msg "Activation du TimeStamp dans History"
echo "export HISTTIMEFORMAT='%F %T  '" >> /home/"$myHomedir"/.bashrc

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of Config menu actions choice
esac
# end of Config menu loop
done
;;

SystemTools) #------------------------------------------------------------------
#------------------------------------------------------------------------------#
# SysTools menu, using Dialog                                                  #
#------------------------------------------------------------------------------#
while true
do
# SysToolsMenu -----------------------------------------------------------------
dialog --clear  --help-button --backtitle "Yggdrasil "$version \
--title "[ Outils système ]" \
--menu "Configuration du système" 32 95 24 \
inxi "infos sur le système" \
speedtest-cli "test de la bande passante" \
packetloss "on vérifie s'il y a des pertes de packets (ping)" \
OptimizeFirefox "Optimisation des bases SQLite de Firefox" \
Autoremove "Suppression des paquets inutiles" \
Back "Revenir au menu principal" 2>"${menuSysToolsINPUT}"

menuSysToolsItem=$(<"${menuSysToolsINPUT}")

# SysToolsMenu's actions -------------------------------------------------------
case $menuSysToolsItem in

inxi) #-------------------------------------------------------------------------
clear

inxi -F

pressKey
;;

speedtest-cli) #----------------------------------------------------------------
clear

if which speedtest-cli >/dev/null; then
  sudo speedtest-cli
else
  printf "Outils Python + speedtest-cli via PIP requis"
fi

pressKey
;;

packetloss) #-------------------------------------------------------------------
clear

ping -q -c 10 google.com

pressKey
;;

OptimizeFirefox) #--------------------------------------------------------------
clear

msg "Optimisation des bases SQLite de Firefox"
pressKey "Veuillez fermer Firefox AVANT de procéder, celui-ci sera killé juste après"
pkill -9 firefox
msg "Optimisation des bases SQLite..."
for f in ~/.mozilla/firefox/*/*.sqlite; do sqlite3 $f 'VACUUM;'; done
msg "Fin de l'optimisation des bases SQLite..."

pressKey
;;

Autoremove) #-------------------------------------------------------------------
clear

msg "Suppression des paquets inutiles"
sudo apt-get -y autoremove

pressKey
;;

Back) #-------------------------------------------------------------------------
break
;;

# end of SysTools menu actions choice
esac
# end of SysTools menu loop
done
;;

Reboot) #-----------------------------------------------------------------------
dialog --title "ATTENTION" \
--backtitle "Yggdrasil "$version \
--yesno "\nRe-démarrage du système ?\n" 7 60
# depending of the choice ...
responseReboot=$?
case $responseReboot in
0)
sudo reboot
;;
1)
clear
msg "Annulé ..."
;;
255)
clear
msg "[ESC] pressé"
;;
esac
;;

About) #------------------------------------------------------------------------
dialog --backtitle "Yggdrasil "$version \
--title "[ A propos de ...]" \
--msgbox '\n
Auteur : Francois B. (Makotosan/Shakasan)\n\n
Email : shakasan@sirenacorp.be\n
Website : https://sirenacorp.be/\n\n
Licence : GPLv3\n\n
Version : '$version'\n\n
Ce script a été réalisé afin de me faciliter la vie lors des (re)installations de mes machines personnelles ;-)\n\n
Premier script aussi conséquent en Shell et avec Dialog,...\n\n
Les conseils sont donc les bienvenus ^^' 25 50
;;

Exit) #-------------------------------------------------------------------------
msg "Bye ...";
break
;;

# end of Main menu actions choice
esac
# end of Main menu loop
done

#------------------------------------------------------------------------------#
# clean temp files from Dialog                                                 #
#------------------------------------------------------------------------------#
rm $OUTPUT
[ -f $menuOUTPUT ] && rm $menuOUTPUT
[ -f $menuINPUT ] && rm $menuINPUT
[ -f $menuAppOUTPUT ] && rm $menuAppOUTPUT
[ -f $menuAppINPUT ] && rm $menuAppINPUT
[ -f $menuDevOUTPUT ] && rm $menuDevOUTPUT
[ -f $menuDevINPUT ] && rm $menuDevINPUT
[ -f $menuCustomOUTPUT ] && rm $menuCustomOUTPUT
[ -f $menuCustomINPUT ] && rm $menuCustomINPUT
[ -f $menuHWOUTPUT ] && rm $menuHWOUTPUT
[ -f $menuHWINPUT ] && rm $menuHWINPUT
[ -f $menuConfigOUTPUT ] && rm $menuConfigOUTPUT
[ -f $menuConfigINPUT ] && rm $menuConfigINPUT
[ -f $menuSysToolsOUTPUT ] && rm $menuSysToolsOUTPUT
[ -f $menuSysToolsINPUT ] && rm $menuSysToolsINPUT
clear
