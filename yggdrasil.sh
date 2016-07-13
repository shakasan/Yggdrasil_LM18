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

# run a shell command and display a message between [ ] depending on the ret_code
function runCmd () {
  typeset cmd="$1"
  typeset ret_code

  eval $cmd" &>> ~/log.txt"
  ret_code=$?

  if [ $ret_code == 0 ]; then
    printf "[ ""$VERT""OK"$NORMAL" ] "
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] "
  fi
}

# display a simple message
function smsg () {
    printf "$*\n"
}

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
  runCmd "sudo apt-get update"
  smsg "apt-get update"

  runCmd "sudo apt-get -y upgrade"
  smsg "apt-get -y upgrade"

  runCmd "sudo apt-get -y dist-upgrade"
  smsg "apt-get -y dist-upgrade"
}

# check if running on the right OS ^^
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

# log file is reset eveytime the script is run
echo > ~/log.txt

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

msg "Ajout des dépôts"

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

msg "Ajout Repository OwnCloud"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_16.04/Release.key
sudo apt-key add - < Release.key
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"

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

msg "Installing base apps and tools"

runCmd "sudo apt-get install -y cifs-utils"; smsg "Installing cifs-utils"
runCmd "sudo apt-get install -y xterm"; smsg "Installing xterm"
runCmd "sudo apt-get install -y curl"; smsg "Installing curl"
runCmd "sudo apt-get install -y mc"; smsg "Installing mc"
runCmd "sudo apt-get install -y bmon"; smsg "Installing bmon"
runCmd "sudo apt-get install -y htop"; smsg "Installing htop"
runCmd "sudo apt-get install -y screen"; smsg "Installing screen"
runCmd "sudo apt-get install -y dconf-cli"; smsg "Installing dconf-cli"
runCmd "sudo apt-get install -y dconf-editor"; smsg "Installing dconf-editor"
runCmd "sudo apt-get install -y lnav"; smsg "Installing lnav"
runCmd "sudo apt-get install -y exfat-fuse"; smsg "Installing exfat-fuse"
runCmd "sudo apt-get install -y exfat-utils"; smsg "Installing exfat-utils"
runCmd "sudo apt-get install -y iftop"; smsg "Installing iftop"
runCmd "sudo apt-get install -y iptraf"; smsg "Installing iptraf"
runCmd "sudo apt-get install -y mpg123"; smsg "Installing mpg123"
runCmd "sudo apt-get install -y debconf-utils"; smsg "Installing debconf-utils"
runCmd "sudo apt-get install -y idle3-tools"; smsg "Installing idle3-tools"

pressKey
;;

Multimedia) #-------------------------------------------------------------------
clear

msg "Installing Multimedia apps and tools"
# to add if available : fontmatrix qgifer arista

runCmd "sudo apt-get install -y spotify-client"; smsg "Installing spotify-client"
runCmd "sudo apt-get install -y slowmovideo"; smsg "Installing slowmovideo"
runCmd "sudo apt-get install -y sayonara"; smsg "Installing sayonara"
runCmd "sudo apt-get install -y qmmp qmmp-plugin-projectm"; smsg "Installing qmmp qmmp-plugin-projectm"
runCmd "sudo apt-get install -y shotcut"; smsg "Installing shotcut"
runCmd "sudo apt-get install -y audacious"; smsg "Installing audacious"
runCmd "sudo apt-get install -y dia"; smsg "Installing dia"
runCmd "sudo apt-get install -y mpv"; smsg "Installing mpv"
runCmd "sudo apt-get install -y picard"; smsg "Installing picard"
runCmd "sudo apt-get install -y inkscape"; smsg "Installing inkscape"
runCmd "sudo apt-get install -y aegisub aegisub-l10n"; smsg "Installing aegisub aegisub-l10n"
runCmd "sudo apt-get install -y mypaint mypaint-data-extras"; smsg "Installing mypaint mypaint-data-extras"
runCmd "sudo apt-get install -y audacity"; smsg "Installing audacity"
runCmd "sudo apt-get install -y blender"; smsg "Installing blender"
runCmd "sudo apt-get install -y kodi"; smsg "Installing kodi"
runCmd "sudo apt-get install -y digikam"; smsg "Installing digikam"
runCmd "sudo apt-get install -y synfigstudio"; smsg "Installing synfigstudio"
runCmd "sudo apt-get install -y mkvtoolnix-gui"; smsg "Installing mkvtoolnix-gui"
runCmd "sudo apt-get install -y rawtherapee"; smsg "Installing rawtherapee"
runCmd "sudo apt-get install -y hugin"; smsg "Installing hugin"
runCmd "sudo apt-get install -y asunder"; smsg "Installing asunder"
runCmd "sudo apt-get install -y milkytracker"; smsg "Installing milkytracker"
runCmd "sudo apt-get install -y pitivi"; smsg "Installing pitivi"
runCmd "sudo apt-get install -y openshot"; smsg "Installing openshot"
runCmd "sudo apt-get install -y smplayer smplayer-themes smplayer-l10n"; smsg "Installing smplayer smplayer-themes smplayer-l10n"
runCmd "sudo apt-get install -y selene"; smsg "Installing selene"
runCmd "sudo apt-get install -y gnome-mplayer"; smsg "Installing gnome-mplayer"
runCmd "sudo apt-get install -y handbrake"; smsg "Installing handbrake"
runCmd "sudo apt-get install -y avidemux2.6-qt avidemux2.6-plugins-qt"; smsg "Installing avidemux2.6-qt avidemux2.6-plugins-qt"
runCmd "sudo apt-get install -y mjpegtools"; smsg "Installing mjpegtools"
runCmd "sudo apt-get install -y twolame"; smsg "Installing twolame"
runCmd "sudo apt-get install -y lame"; smsg "Installing lame"
runCmd "sudo apt-get install -y banshee banshee-extension-soundmenu"; smsg "Installing banshee banshee-extension-soundmenu"
runCmd "sudo apt-get install -y gpicview"; smsg "Installing gpicview"
runCmd "sudo apt-get install -y vlc"; smsg "Installing vlc"
runCmd "sudo apt-get install -y shotwell"; smsg "Installing shotwell"
runCmd "sudo apt-get install -y darktable"; smsg "Installing darktable"
runCmd "sudo apt-get install -y ffmpeg"; smsg "Installing ffmpeg"
runCmd "sudo apt-get install -y flacon"; smsg "Installing flacon"
runCmd "sudo apt-get install -y scribus"; smsg "Installing scribus"
runCmd "sudo apt-get install -y birdfont"; smsg "Installing birdfont"
runCmd "sudo apt-get install -y moc"; smsg "Installing moc"

# DarkDot theme for Moc
runCmd "echo 'alias mocp=\"mocp -T darkdot_theme\"' | tee -a /home/$myHomedir/.bashrc"
smsg "Configuring DarkDot theme for Mocp"

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

msg "Installation eBook apps and tools"

runCmd "sudo apt-get install -y fbreader"; smsg "Installing fbreader"

cd /tmp

#msg "Installation de Calibre"
#sudo -v && wget --no-check-certificate -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
runCmd "sudo -v && wget -q --no-check-certificate -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c \"import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()\""
smsg "Installing calibre"

pressKey
;;

Internet) #---------------------------------------------------------------------
clear

msg "Installing Internet apps and tools"

echo "opera-stable opera-stable/add-deb-source boolean false" | sudo debconf-set-selections

# to add when available :  skype-wrapper tribler qtox birdie (pushbullet)
runCmd "sudo apt-get install -y owncloud-client"; smsg "Installing owncloud-client"
runCmd "sudo apt-get install -y syncthing-gtk syncthing"; smsg "Installing syncthing-gtk syncthing"
runCmd "sudo apt-get install -y insync"; smsg "Installing insync"
runCmd "sudo apt-get install -y quiterss"; smsg "Installing quiterss"
runCmd "sudo apt-get install -y frogr"; smsg "Installing frogr"
runCmd "sudo apt-get install -y opera-stable"; smsg "Installing opera-stable"
runCmd "sudo apt-get install -y google-chrome-stable"; smsg "Installing google-chrome-stable"
runCmd "sudo apt-get install -y xchat-gnome xchat-gnome-indicator"; smsg "Installing xchat-gnome xchat-gnome-indicator"
runCmd "sudo apt-get install -y chromium-browser chromium-browser-l10n"; smsg "Installing chromium-browser chromium-browser-l10n"
runCmd "sudo apt-get install -y dropbox"; smsg "Installing dropbox"
runCmd "sudo apt-get install -y qupzilla"; smsg "Installing qupzilla"
runCmd "sudo apt-get install -y filezilla"; smsg "Installing filezilla"
runCmd "sudo apt-get install -y hexchat"; smsg "Installing hexchat"
runCmd "sudo apt-get install -y mumble"; smsg "Installing mumble"
runCmd "sudo apt-get install -y skype"; smsg "Installing skype"
runCmd "sudo apt-get install -y imagedownloader"; smsg "Installing imagedownloader"
runCmd "sudo apt-get install -y california"; smsg "Installing california"
runCmd "sudo apt-get install -y midori"; smsg "Installing midori"
runCmd "sudo apt-get install -y geary"; smsg "Installing geary"
runCmd "sudo apt-get install -y whatsie"; smsg "Installing whatsie"
runCmd "sudo apt-get install -y ring-gnome"; smsg "Installing ring-gnome"

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

msg "Installing misc. utility apps and tools"

echo "apt-fast	apt-fast/maxdownloads	string	5" | sudo debconf-set-selections
echo "apt-fast	apt-fast/dlflag	boolean	true" | sudo debconf-set-selections
echo "apt-fast	apt-fast/aptmanager	select	apt-get" | sudo debconf-set-selections
echo "apt-fast	apt-fast/downloader	select	aria2c" | sudo debconf-set-selections

runCmd "sudo apt-get install -y qtqr"; smsg "Installing qtqr"
runCmd "sudo apt-get install -y cpu-g"; smsg "Installing cpu-g"
runCmd "sudo apt-get install -y screenfetch"; smsg "Installing screenfetch"
runCmd "sudo apt-get install -y xcalib"; smsg "Installing xcalib"
runCmd "sudo apt-get install -y conky-manager conky-all"; smsg "Installing conky-manager conky-all"
runCmd "sudo apt-get install -y plank"; smsg "Installing plank"
runCmd "sudo apt-get install -y indicator-sound-switcher"; smsg "Installing indicator-sound-switcher"
runCmd "sudo apt-get install -y y-ppa-manager"; smsg "Installing y-ppa-manager"
runCmd "sudo apt-get install -y synapse"; smsg "Installing synapse"
runCmd "sudo apt-get install -y anoise"; smsg "Installing anoise"
runCmd "sudo apt-get install -y acetoneiso"; smsg "Installing acetoneiso"
runCmd "sudo apt-get install -y guake"; smsg "Installing guake"
runCmd "sudo apt-get install -y tilda"; smsg "Installing tilda"
runCmd "sudo apt-get install -y psensor"; smsg "Installing psensor"
runCmd "sudo apt-get install -y kazam"; smsg "Installing kazam"
runCmd "sudo apt-get install -y bleachbit"; smsg "Installing bleachbit"
runCmd "sudo apt-get install -y gparted"; smsg "Installing gparted"
runCmd "sudo apt-get install -y gsmartcontrol"; smsg "Installing gsmartcontrol"
runCmd "sudo apt-get install -y terminator"; smsg "Installing terminator"
runCmd "sudo apt-get install -y aptik"; smsg "Installing aptik"
runCmd "sudo apt-get install -y gufw"; smsg "Installing gufw"
runCmd "sudo apt-get install -y numlockx"; smsg "Installing numlockx"
runCmd "sudo apt-get install -y grub-customizer"; smsg "Installing grub-customizer"
runCmd "sudo apt-get install -y chmsee"; smsg "Installing chmsee"
runCmd "sudo apt-get install -y unetbootin"; smsg "Installing unetbootin"
runCmd "sudo apt-get install -y zim"; smsg "Installing zim"
runCmd "sudo apt-get install -y diodon"; smsg "Installing diodon"
runCmd "sudo apt-get install -y pyrenamer"; smsg "Installing pyrenamer"
runCmd "sudo apt-get install -y apt-fast"; smsg "Installing apt-fast"

pressKey
;;

Wine) #-------------------------------------------------------------------------
clear

msg "Installing Wine"

runCmd "sudo add-apt-repository -y ppa:ubuntu-wine/ppa"; smsg "Adding Wine PPA"
updateSystem
runCmd "sudo apt-get install -y wine1.8"; smsg "Installing wine1.8"
runCmd "sudo apt-get install -y winetricks"; smsg "Installing winetricks"
runCmd "sudo apt-get install -y playonlinux"; smsg "Installing playonlinux"

pressKey
;;

WineG3D) #----------------------------------------------------------------------
clear

msg "Installing WineDRI3"

runCmd "sudo add-apt-repository -y ppa:commendsarnex/winedri3"; smsg "Adding WineDRI3 PPA"
updateSystem
runCmd "sudo apt-get install -y wine1.9"; smsg "Installing wine1.9"
runCmd "sudo apt-get install -y winetricks"; smsg "Installing winetricks"
runCmd "sudo apt-get install -y playonlinux"; smsg "Installing playonlinux"

pressKey
;;

WineStaging) #------------------------------------------------------------------
clear

msg "Installing Wine-Staging"

runCmd "sudo add-apt-repository -y ppa:pipelight/stable"; smsg "Adding WineStaging PPA"
updateSystem
runCmd "sudo apt-get install -y wine-staging-amd64"; smsg "Installing wine-staging-amd64"

pressKey
;;

KodiBETA) #---------------------------------------------------------------------
clear

msg "Installing Kodi BETA"

runCmd "sudo add-apt-repository -y ppa:team-xbmc/unstable"; smsg "Adding Kodi BETA PPA"
updateSystem
runCmd "sudo apt-get install -y kodi"; smsg "Installing kodi"

pressKey
;;

KodiNightly) #------------------------------------------------------------------
clear

msg "Installing Kodi Nightly"

runCmd "sudo add-apt-repository -y ppa:team-xbmc/xbmc-nightly"; smsg "Adding Kodi Nightly PPA"
updateSystem
runCmd "sudo apt-get install -y kodi"; smsg "Installing kodi"

pressKey
;;

Jeux) #-------------------------------------------------------------------------
clear

msg "Installing Games apps and tools"

runCmd "sudo apt-get install -y steam"; smsg "Installing steam"
runCmd "sudo apt-get install -y jstest-gtk"; smsg "Installing jstest-gtk"

pressKey
;;

Graveur) #----------------------------------------------------------------------
clear

msg "Installing CD/DVD/BR Burning apps and tools"

runCmd "sudo apt-get install -y brasero"; smsg "Installing brasero"
runCmd "sudo apt-get install -y k3b k3b-extrathemes"; smsg "Installing k3b k3b-extrathemes"
runCmd "sudo apt-get install -y xfburn"; smsg "Installing xfburn"

pressKey
;;

NetTools) #---------------------------------------------------------------------
clear

msg "Installing Network apps and tools"
# to add when available : gtkvncviewer

runCmd "sudo apt-get install -y whois"; smsg "Installing whois"
runCmd "sudo apt-get install -y iptraf"; smsg "Installing iptraf"
runCmd "sudo apt-get install -y iperf"; smsg "Installing iperf"
runCmd "sudo apt-get install -y wireshark tshark"; smsg "Installing wireshark tshark"
runCmd "sudo apt-get install -y zenmap"; smsg "Installing zenmap"
runCmd "sudo apt-get install -y dsniff"; smsg "Installing dsniff"
runCmd "sudo apt-get install -y aircrack-ng"; smsg "Installing aircrack-ng"

pressKey
;;

Caja) #-------------------------------------------------------------------------
clear

msg "Installing Caja extensions"

runCmd "sudo apt-get install -y caja-share"; smsg "Installing caja-share"
runCmd "sudo apt-get install -y caja-wallpaper"; smsg "Installing caja-wallpaper"
runCmd "sudo apt-get install -y caja-sendto"; smsg "Installing caja-sendto"
runCmd "sudo apt-get install -y caja-image-converter"; smsg "Installing caja-image-converter"

if which insync >/dev/null; then
  runCmd "sudo apt-get install -y insync-caja"; smsg "Installing insync-caja"
fi

pressKey
;;

Nautilus) #---------------------------------------------------------------------
clear

msg "Installing Nautilus and extensions"

runCmd "sudo apt-get install -y nautilus"; smsg "Installing nautilus"
runCmd "sudo apt-get install -y file-roller"; smsg "Installing file-roller"
runCmd "sudo apt-get install -y nautilus-emblems"; smsg "Installing nautilus-emblems"
runCmd "sudo apt-get install -y nautilus-image-manipulator"; smsg "Installing nautilus-image-manipulator"
runCmd "sudo apt-get install -y nautilus-image-converter"; smsg "Installing nautilus-image-converter"
runCmd "sudo apt-get install -y nautilus-compare"; smsg "Installing nautilus-compare"
runCmd "sudo apt-get install -y nautilus-actions"; smsg "Installing nautilus-actions"
runCmd "sudo apt-get install -y nautilus-sendto"; smsg "Installing nautilus-sendto"
runCmd "sudo apt-get install -y nautilus-share"; smsg "Installing nautilus-share"
runCmd "sudo apt-get install -y nautilus-wipe"; smsg "Installing nautilus-wipe"
runCmd "sudo apt-get install -y nautilus-script-audio-convert"; smsg "Installing nautilus-script-audio-convert"
runCmd "sudo apt-get install -y nautilus-filename-repairer"; smsg "Installing nautilus-filename-repairer"
runCmd "sudo apt-get install -y nautilus-gtkhash"; smsg "Installing nautilus-gtkhash"
runCmd "sudo apt-get install -y nautilus-ideviceinfo"; smsg "Installing nautilus-ideviceinfo"
runCmd "sudo apt-get install -y ooo-thumbnailer"; smsg "Installing ooo-thumbnailer"
runCmd "sudo apt-get install -y nautilus-dropbox"; smsg "Installing nautilus-dropbox"
runCmd "sudo apt-get install -y nautilus-script-manager"; smsg "Installing nautilus-script-manager"
runCmd "sudo apt-get install -y nautilus-columns"; smsg "Installing nautilus-columns"
runCmd "sudo apt-get install -y nautilus-flickr-uploader"; smsg "Installing nautilus-flickr-uploader"

if which insync >/dev/null; then
  runCmd "sudo apt-get install -y insync-nautilus"; smsg "Installing insync-nautilus"
fi

pressKey
;;

Gimp) #-------------------------------------------------------------------------
clear

msg "Installing Gimp extensions"

runCmd "sudo apt-get install -y gtkam-gimp"; smsg "Installing gtkam-gimp"
runCmd "sudo apt-get install -y gimp-gluas"; smsg "Installing gimp-gluas"
runCmd "sudo apt-get install -y pandora"; smsg "Installing pandora"
runCmd "sudo apt-get install -y gimp-data-extras"; smsg "Installing gimp-data-extras"
runCmd "sudo apt-get install -y gimp-lensfun"; smsg "Installing gimp-lensfun"
runCmd "sudo apt-get install -y gimp-gmic"; smsg "Installing gimp-gmic"
runCmd "sudo apt-get install -y gimp-ufraw"; smsg "Installing gimp-ufraw"
runCmd "sudo apt-get install -y gimp-texturize"; smsg "Installing gimp-texturize"
runCmd "sudo apt-get install -y gimp-plugin-registry"; smsg "Installing gimp-plugin-registry"


pressKey
;;

RhythmBox) #--------------------------------------------------------------------
clear

msg "Installing RhythmBox extensions"

runCmd "sudo apt-get install -y rhythmbox-plugin-alternative-toolbar"; smsg "Installing rhythmbox-plugin-alternative-toolbar"
runCmd "sudo apt-get install -y rhythmbox-plugin-artdisplay"; smsg "Installing rhythmbox-plugin-artdisplay"
runCmd "sudo apt-get install -y rhythmbox-plugin-cdrecorder"; smsg "Installing rhythmbox-plugin-cdrecorder"
runCmd "sudo apt-get install -y rhythmbox-plugin-close-on-hide"; smsg "Installing rhythmbox-plugin-close-on-hide"
runCmd "sudo apt-get install -y rhythmbox-plugin-countdown-playlist"; smsg "Installing rhythmbox-plugin-countdown-playlist"
runCmd "sudo apt-get install -y rhythmbox-plugin-coverart-browser"; smsg "Installing rhythmbox-plugin-coverart-browser"
runCmd "sudo apt-get install -y rhythmbox-plugin-coverart-search"; smsg "Installing rhythmbox-plugin-coverart-search"
runCmd "sudo apt-get install -y rhythmbox-plugin-desktopart"; smsg "Installing rhythmbox-plugin-desktopart"
runCmd "sudo apt-get install -y rhythmbox-plugin-equalizer"; smsg "Installing rhythmbox-plugin-equalizer"
runCmd "sudo apt-get install -y rhythmbox-plugin-fileorganizer"; smsg "Installing rhythmbox-plugin-fileorganizer"
runCmd "sudo apt-get install -y rhythmbox-plugin-fullscreen"; smsg "Installing rhythmbox-plugin-fullscreen"
runCmd "sudo apt-get install -y rhythmbox-plugin-hide"; smsg "Installing rhythmbox-plugin-hide"
runCmd "sudo apt-get install -y rhythmbox-plugin-jumptowindow"; smsg "Installing rhythmbox-plugin-jumptowindow"
runCmd "sudo apt-get install -y rhythmbox-plugin-llyrics"; smsg "Installing rhythmbox-plugin-llyrics"
runCmd "sudo apt-get install -y rhythmbox-plugin-looper"; smsg "Installing rhythmbox-plugin-looper"
runCmd "sudo apt-get install -y rhythmbox-plugin-opencontainingfolder"; smsg "Installing rhythmbox-plugin-opencontainingfolder"
runCmd "sudo apt-get install -y rhythmbox-plugin-parametriceq"; smsg "Installing rhythmbox-plugin-parametriceq"
runCmd "sudo apt-get install -y rhythmbox-plugin-playlist-import-export"; smsg "Installing rhythmbox-plugin-playlist-import-export"
runCmd "sudo apt-get install -y rhythmbox-plugin-podcast-pos"; smsg "Installing rhythmbox-plugin-podcast-pos"
runCmd "sudo apt-get install -y rhythmbox-plugin-randomalbumplayer"; smsg "Installing rhythmbox-plugin-randomalbumplayer"
runCmd "sudo apt-get install -y rhythmbox-plugin-rating-filters"; smsg "Installing rhythmbox-plugin-rating-filters"
runCmd "sudo apt-get install -y rhythmbox-plugin-remembertherhythm"; smsg "Installing rhythmbox-plugin-remembertherhythm"
runCmd "sudo apt-get install -y rhythmbox-plugin-repeat-one-song"; smsg "Installing rhythmbox-plugin-repeat-one-song"
runCmd "sudo apt-get install -y rhythmbox-plugin-rhythmweb"; smsg "Installing rhythmbox-plugin-rhythmweb"
runCmd "sudo apt-get install -y rhythmbox-plugin-screensaver"; smsg "Installing rhythmbox-plugin-screensaver"
runCmd "sudo apt-get install -y rhythmbox-plugin-smallwindow"; smsg "Installing rhythmbox-plugin-smallwindow"
runCmd "sudo apt-get install -y rhythmbox-plugin-spectrum"; smsg "Installing rhythmbox-plugin-spectrum"
runCmd "sudo apt-get install -y rhythmbox-plugin-suspend"; smsg "Installing rhythmbox-plugin-suspend"
runCmd "sudo apt-get install -y rhythmbox-plugin-tray-icon"; smsg "Installing rhythmbox-plugin-tray-icon"
runCmd "sudo apt-get install -y rhythmbox-plugin-visualizer"; smsg "Installing rhythmbox-plugin-visualizer"
runCmd "sudo apt-get install -y rhythmbox-plugin-wikipedia"; smsg "Installing rhythmbox-plugin-wikipedia"
runCmd "sudo apt-get install -y rhythmbox-plugins"; smsg "Installing rhythmbox-plugins"

pressKey
;;

Pidgin) #--------------------------------------------------------------------
clear

msg "Installing Pidgin extensions"
# to add when available : pidgin-whatsapp

runCmd "sudo apt-get install -y telegram-purple"; smsg "Installing telegram-purple"
runCmd "sudo apt-get install -y pidgin-skype"; smsg "Installing pidgin-skype"
runCmd "sudo apt-get install -y purple-hangouts"; smsg "Installing purple-hangouts"
runCmd "sudo apt-get install -y pidgin-hangouts"; smsg "Installing pidgin-hangouts"




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

msg "Installing Unbound"
runCmd "sudo apt-get install -y unbound"; smsg "Installing unbound"

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

runCmd "sudo apt-get install -y ambiance-crunchy"; smsg "Installing ambiance-crunchy"
runCmd "sudo apt-get install -y arc-theme"; smsg "Installing arc-theme"
runCmd "sudo apt-get install -y ambiance-colors"; smsg "Installing ambiance-colors"
runCmd "sudo apt-get install -y radiance-colors"; smsg "Installing radiance-colors"
runCmd "sudo apt-get install -y ambiance-flat-colors"; smsg "Installing ambiance-flat-colors"
runCmd "sudo apt-get install -y vivacious-colors-gtk-dark"; smsg "Installing vivacious-colors-gtk-dark"
runCmd "sudo apt-get install -y vivacious-colors-gtk-light"; smsg "Installing vivacious-colors-gtk-light"
runCmd "sudo apt-get install -y yosembiance-gtk-theme"; smsg "Installing yosembiance-gtk-theme"
runCmd "sudo apt-get install -y ambiance-blackout-colors"; smsg "Installing ambiance-blackout-colors"
runCmd "sudo apt-get install -y ambiance-blackout-flat-colors"; smsg "Installing ambiance-blackout-flat-colors"
runCmd "sudo apt-get install -y radiance-flat-colors"; smsg "Installing radiance-flat-colors"
runCmd "sudo apt-get install -y vibrancy-colors"; smsg "Installing vibrancy-colors"
runCmd "sudo apt-get install -y vivacious-colors"; smsg "Installing vivacious-colors"
runCmd "sudo apt-get install -y numix-gtk-theme"; smsg "Installing numix-gtk-theme"

msg "Installation des icônes"
# to add when available : elementary-icons paper-icon-theme

runCmd "sudo apt-get install -y arc-icons"; smsg "Installing arc-icons"
runCmd "sudo apt-get install -y papirus-gtk-icon-theme"; smsg "Installing papirus-gtk-icon-theme"
runCmd "sudo apt-get install -y ultra-flat-icons"; smsg "Installing ultra-flat-icons"
runCmd "sudo apt-get install -y myelementary"; smsg "Installing myelementary"
runCmd "sudo apt-get install -y ghost-flat-icons"; smsg "Installing ghost-flat-icons"
runCmd "sudo apt-get install -y faenza-icon-theme"; smsg "Installing faenza-icon-theme"
runCmd "sudo apt-get install -y faience-icon-theme"; smsg "Installing faience-icon-theme"
runCmd "sudo apt-get install -y vibrantly-simple-icon-theme"; smsg "Installing vibrantly-simple-icon-theme"
runCmd "sudo apt-get install -y rave-x-colors-icons"; smsg "Installing rave-x-colors-icons"
runCmd "sudo apt-get install -y ravefinity-x-icons"; smsg "Installing ravefinity-x-icons"
runCmd "sudo apt-get install -y numix-icon-theme"; smsg "Installing numix-icon-theme"
runCmd "sudo apt-get install -y numix-icon-theme-circle"; smsg "Installing numix-icon-theme-circle"

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
Solaar "Solaar - Logitech Unifying Manager App" \
CardReader "Installation de pcscd pour les CardReader" \
eID "Installation middleware eID" \
EpsonV500Photo "Installation driver Espon V500 Photo + iscan + Xsane" \
Microcode "Mise à jours du Microcode du CPU (Intel)" \
WirelessIntel6320 "Config Intel Centrino Advanced-N 6320 (problème Bluetooth)" \
Back "Revenir au menu principal" 2>"${menuHWINPUT}"

menuHWItem=$(<"${menuHWINPUT}")

# hwMenu's actions -------------------------------------------------------------
case $menuHWItem in

Solaar) #-----------------------------------------------------------------------
clear

msg "Installing Solaar"
runCmd "sudo apt-get install -y solaar"; smsg "Installing solaar"

pressKey
;;

CardReader) #-------------------------------------------------------------------
clear

msg "Installing CardReader and utils"
runCmd "sudo apt-get install -y pcscd pcsc-tools"; smsg "Installing pcscd pcsc-tools"

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

msg "Installing base Dev apps and tools"

runCmd "sudo apt-get install -y notepadqq"; smsg "Installing notepadqq"
runCmd "sudo apt-get install -y agave"; smsg "Installing agave"
runCmd "sudo apt-get install -y utext"; smsg "Installing utext"
runCmd "sudo apt-get install -y gpick"; smsg "Installing gpick"
runCmd "sudo apt-get install -y virtualbox-5.0"; smsg "Installing virtualbox-5.0"
runCmd "sudo apt-get install -y build-essential"; smsg "Installing build-essential"
runCmd "sudo apt-get install -y ubuntu-make"; smsg "Installing ubuntu-make"
runCmd "sudo apt-get install -y ghex"; smsg "Installing ghex"
runCmd "sudo apt-get install -y glade"; smsg "Installing glade"
runCmd "sudo apt-get install -y eric"; smsg "Installing eric"
runCmd "sudo apt-get install -y bluefish"; smsg "Installing bluefish"
runCmd "sudo apt-get install -y meld"; smsg "Installing meld"
runCmd "sudo apt-get install -y bluegriffon"; smsg "Installing bluegriffon"
runCmd "sudo apt-get install -y zeal"; smsg "Installing zeal"

pressKey
;;

Java) #-------------------------------------------------------------------------
clear

msg "Installing Java apps and tools"

runCmd "sudo apt-get install -y oracle-java7-installer"; smsg "Installing oracle-java7-installer"
runCmd "sudo apt-get install -y oracle-java8-installer"; smsg "Installing oracle-java8-installer"
runCmd "sudo apt-get install -y oracle-java8-set-default"; smsg "Installing oracle-java8-set-default"

pressKey
;;

JavaScript) #-------------------------------------------------------------------
clear

msg "Installing JavaScript apps and tools"

runCmd "sudo apt-get install -y npm"; smsg "Installing npm"
runCmd "sudo apt-get install -y nodejs-legacy"; smsg "Installing nodejs-legacy"
runCmd "sudo apt-get install -y javascript-common"; smsg "Installing javascript-common"


if which npm >/dev/null; then
  msg "NPM installing : remark-lint"
  sudo npm install remark-lint

  msg "NPM installing : jshint"
  sudo npm install -g jshint

  msg "NPM installing : jedi"
  sudo npm install -g jedi
fi

pressKey
;;

PHP) #--------------------------------------------------------------------------
clear

msg "Installing PHP apps and tools"

runCmd "sudo apt-get install -y php7.0-cli"; smsg "Installing php7.0-cli"

pressKey
;;

LUA) #--------------------------------------------------------------------------
clear

msg "Installing LUA apps and tools"

runCmd "sudo apt-get install -y luajit"; smsg "Installing luajit"

pressKey
;;

Ruby) #---------------------------------------------------------------------------
clear

msg "Installing Ruby apps and tools"

runCmd "sudo apt-get install -y ruby-dev"; smsg "Installing ruby-dev"

pressKey
;;

QT) #---------------------------------------------------------------------------
clear

msg "Installing QT Dev apps and tools"

runCmd "sudo apt-get install -y qt4-dev-tools"; smsg "Installing qt4-dev-tools"
runCmd "sudo apt-get install -y qt4-linguist-tools"; smsg "Installing qt4-linguist-tools"
runCmd "sudo apt-get install -y qt5-doc qttools5-doc"; smsg "Installing qt5-doc qttools5-doc"
runCmd "sudo apt-get install -y qttools5-dev-tools"; smsg "Installing qttools5-dev-tools"
runCmd "sudo apt-get install -y qttools5-examples"; smsg "Installing qttools5-examples"
runCmd "sudo apt-get install -y qttools5-doc-html"; smsg "Installing qttools5-doc-html"

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

msg "Installing Python Dev apps and tools"

runCmd "sudo apt-get install -y python3-dev"; smsg "Installing python3-dev"
runCmd "sudo apt-get install -y python3-pip"; smsg "Installing python3-pip"
runCmd "sudo apt-get install -y python3-pyqt5"; smsg "Installing python3-pyqt5"


if which pip3 >/dev/null; then
  msg "Upgrading PIP"
  sudo pip3 install --upgrade pip

  msg "PIP installing : setuptools"
  sudo pip3 install setuptools

  msg "PIP installing : flake8"
  sudo pip3 install flake8

  msg "PIP installing : MyCLI"
  sudo pip3 install mycli

  msg "PIP installing : SpoofMAC"
  sudo pip3 install SpoofMAC

  msg "PIP installing : speedtest-cli"
  sudo pip3 install speedtest-cli

  msg "PIP installing : whatportis"
  sudo pip3 install whatportis

  msg "PIP installing : py-term"
  sudo pip3 install py-term

  msg "PIP installing : weppy"
  sudo pip3 install weppy

  msg "PIP installing : retext"
  sudo pip3 install retext

  msg "PIP installing : waybackpack"
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

msg "Installing Atom and extensions"

runCmd "sudo apt-get install -y atom"; smsg "Installing atom"

if which apm >/dev/null; then
  msg "Installing Atom extensions"

  runCmd "apm install git-status"; smsg "APM Installing git-status"
  runCmd "apm install git-time-machine"; smsg "APM Installing git-time-machine"
  runCmd "apm install color-picker"; smsg "APM Installing color-picker"
  runCmd "apm install file-icons"; smsg "APM Installing file-icons"
  runCmd "apm install language-conky"; smsg "APM Installing language-conky"
  runCmd "apm install language-lua"; smsg "APM Installing language-lua"
  runCmd "apm install minimap"; smsg "APM Installing minimap"
  runCmd "apm install highlight-selected"; smsg "APM Installing highlight-selected"
  runCmd "apm install minimap-highlight-selected"; smsg "APM Installing minimap-highlight-selected"
  runCmd "apm install pigments"; smsg "APM Installing pigments"
  runCmd "apm install minimap-pigments"; smsg "APM Installing minimap-pigments"
  runCmd "apm install todo-show"; smsg "APM Installing todo-show"
  runCmd "apm install linter"; smsg "APM Installing linter"
  runCmd "apm install linter-javac"; smsg "APM Installing linter-javac"
  runCmd "apm install linter-csslint"; smsg "APM Installing linter-csslint"
  runCmd "apm install linter-coffeelint"; smsg "APM Installing linter-coffeelint"
  runCmd "apm install linter-golinter"; smsg "APM Installing linter-golinter"
  runCmd "apm install linter-htmlhint"; smsg "APM Installing linter-htmlhint"
  runCmd "apm install linter-lua"; smsg "APM Installing linter-lua"
  runCmd "apm install linter-markdown"; smsg "APM Installing linter-markdown"
  runCmd "apm install linter-flake8"; smsg "APM Installing linter-flake8"
  runCmd "apm install linter-php"; smsg "APM Installing linter-php"
  runCmd "apm install autocomplete-java"; smsg "APM Installing autocomplete-java"
  runCmd "apm install dash"; smsg "APM Installing dash"
fi

pressKey
;;

Anjuta) #-----------------------------------------------------------------------
clear

msg "Installing Anjuta"

runCmd "sudo apt-get install -y anjuta anjuta-extras"; smsg "Installing anjuta anjuta-extras"

pressKey
;;

Brackets) #---------------------------------------------------------------------
clear

msg "Installing Brackets"

runCmd "sudo apt-get install -y brackets"; smsg "Installing brackets"

pressKey
;;

CodeBlocks) #-------------------------------------------------------------------
clear

msg "Installing CodeBlocks"

runCmd "sudo apt-get install -y codeblocks codeblocks-contrib"; smsg "Installing codeblocks codeblocks-contrib"

pressKey
;;

Geany) #------------------------------------------------------------------------
clear

msg "Installing Geany and extensions"

runCmd "sudo apt-get install -y geany"; smsg "Installing geany"
runCmd "sudo apt-get install -y geany-plugins"; smsg "Installing geany-plugins"
runCmd "sudo apt-get install -y geany-plugin-markdown"; smsg "Installing geany-plugin-markdown"

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

msg "Installing CAD apps and tools"

runCmd "sudo apt-get install -y kicad kicad-locale-fr"; smsg "Installing kicad kicad-locale-fr"
runCmd "sudo apt-get install -y librecad"; smsg "Installing librecad"
runCmd "sudo apt-get install -y freecad"; smsg "Installing freecad"

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

Ufw) #--------------------------------------------------------------------------
clear

msg "Enabling FireWall (UFW)"

runCmd "sudo ufw enable"; smsg "Enabling ufw"

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

msg "Adding screenfetch to .bashrc"
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
  printf "Python apps and tools + speedtest-cli app are required (PIP)"
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

msg "Cleaning useless deb package(s)"
runCmd "sudo apt-get -y autoremove"; smsg "apt-get autoremove"

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
