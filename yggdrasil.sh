#!/bin/bash
#------------------------------------------------------------------------------#
# Yggdrasil                                                                    #
#    author : Francois B. (Makotosan/Shakasan)                                 #
#    licence : GPLv3                                                           #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Script's cons. and vars.                                                     #
#------------------------------------------------------------------------------#

version="0.2.1"

# myHomedir is used in full paths to the homedir
myHomedir=$(whoami)

# script base dir
scriptDir=$(pwd)

# logfile
logFile="/home/"$myHomedir"/yggdrasil.log"

# date and time
cTime=$(date +%H:%M)
cDate=$(date +%d-%m-%Y)

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

# display a message between [ ] depending of the ret_code
function retCode () {
  typeset ret_code="$1"

  if [ $ret_code == 0 ]; then
    printf "[ ""$VERT""OK"$NORMAL" ] "
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] "
  fi
}

# run a shell command and display a message between [ ] depending on the ret_code
function runCmd () {
  typeset cmd="$1"
  typeset ret_code

  eval $cmd" &>> $logFile"
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
  read -p "Press <Enter> key to continue ..."
  printf "$NORMAL"
}

# system update
function updateSystem () {

  msg "System update"

  runCmd "sudo apt-get update"
  smsg "apt-get update"

  runCmd "sudo apt-get -y upgrade"
  smsg "apt-get -y upgrade"

  runCmd "sudo apt-get -y dist-upgrade"
  smsg "apt-get -y dist-upgrade"
}

# check if running on the right OS ^^
function osCheck () {
  printf "$JAUNE""OS requirement checking\n\n""$NORMAL"
  OS=`lsb_release -d | gawk -F':' '{print $2}' | gawk -F'\t' '{print $2}'`

  if [[ $OS == *"Linux Mint 18"* ]]; then
    printf "[ ""$VERT""OK"$NORMAL" ] Linux Mint 18.x\n"
  else
    printf "[ ""$ROUGE""!!"$NORMAL" ] Linux Mint 18.x not found. Bye...\n"
    printf "\n"
    exit
  fi
}

# dependencies used in the script checked and installed if necessary
function depCheck () {
  printf "$JAUNE""Script dependencies checking\n\n""$NORMAL"

  # mpg123
  if which mpg123 >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] mpg123 found\n"
  else
    runCmd "sudo apt-get install -y mpg123"; smsg "Installing mpg123"
  fi

  # libnotify-bin (cmd : notify-send)
  if which notify-send >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] libnotify-bin found\n"
  else
    runCmd "sudo apt-get install -y libnotify-bin"; smsg "Installing libnotify-bin"
  fi

  # lsb_release
  if which lsb_release >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] lsb-release found\n"
  else
    runCmd "sudo apt-get install -y lsb-release"; smsg "Installing lsb-release"
  fi

  # cifs-utils
  if which mount.cifs >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] cifs-utils found\n"
  else
    runCmd "sudo apt-get install -y cifs-utils"; smsg "Installing cifs-utils"
  fi

  # dialog
  if which dialog >/dev/null; then
    printf "[ ""$VERT""OK"$NORMAL" ] dialog found\n"
  else
    runCmd "sudo apt-get install -y dialog"; smsg "Installing dialog"
  fi
}

addPPA () {
  msg "Adding PPA and repositories"

  runCmd "sudo dpkg --add-architecture i386"; smsg "Adding Arch i386"

  runCmd "sudo apt-get install -y apt-transport-https"; smsg "Adding apt-transport-https package"

  sudo sh -c "echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections" &>> $logFile && retCode $? && smsg "Accepting Oracle Java SE 7"
  sudo sh -c "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections" &>> $logFile && retCode $? && smsg "Accepting Oracle Java SE 8"

  sudo sh -c "echo sience-config science-config/group select '$myHomedir ($myHomedir)' | sudo debconf-set-selections" &>> $logFile && retCode $? && smsg "Science-config package pre-config"

  runCmd "sudo add-apt-repository -y ppa:noobslab/themes"; smsg "Adding ppa:noobslab/themes PPA (themes)" # themes from noobslab
  runCmd "sudo add-apt-repository -y ppa:noobslab/icons"; smsg "Adding ppa:noobslab/icons PPA (icons)" # icons from noobslab
  runCmd "sudo add-apt-repository -y ppa:numix/ppa"; smsg "Adding ppa:numix/ppa PPA (themes)" # theme Numix
  runCmd "sudo add-apt-repository -y ppa:ravefinity-project/ppa"; smsg "Adding ppa:ravefinity-project/ppa PPA" # Themes
  runCmd "sudo add-apt-repository -y ppa:teejee2008/ppa"; smsg "Adding ppa:teejee2008/ppa PPA (Aptik, Conky-Manager)" # Aptik - Conky-Manage
  runCmd "sudo add-apt-repository -y ppa:yktooo/ppa"; smsg "Adding ppa:yktooo/ppa PPA (indicator-sound-switcher)" # indicator-sound-switcher
  runCmd "sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager"; smsg "Adding ppa:webupd8team/y-ppa-manager PPA (y-ppa-manager)" # y-ppa-manager
  runCmd "sudo add-apt-repository -y ppa:webupd8team/atom"; smsg "Adding ppa:webupd8team/atom PPA (Atom IDE)" # IDE
  runCmd "sudo add-apt-repository -y ppa:videolan/stable-daily"; smsg "Adding ppa:videolan/stable-daily PPA (vlc)" # video player
  runCmd "sudo add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make"; smsg "Adding ppa:ubuntu-desktop/ubuntu-make PPA (umake)" # ubuntu-make
  runCmd "sudo add-apt-repository -y ppa:nowrep/qupzilla"; smsg "Adding ppa:nowrep/qupzilla PPA (qupzilla)" # web browser
  runCmd "sudo add-apt-repository -y ppa:atareao/atareao"; smsg "Adding ppa:atareao/atareao PPA (pushbullet-indicator, imagedownloader, gqrcode, cpu-g)" # pushbullet-indicator, imagedownloader, gqrcode, cpu-g
  runCmd "sudo add-apt-repository -y ppa:costales/anoise"; smsg "Adding ppa:costales/anoise PPA (anoise)" # ambiance sounds
  runCmd "sudo add-apt-repository -y ppa:fossfreedom/rhythmbox-plugins"; smsg "Adding ppa:fossfreedom/rhythmbox-plugins PPA (Rhythmbox plugins)" # Rhythmbox plugins
  runCmd "sudo add-apt-repository -y ppa:nilarimogard/webupd8"; smsg "Adding ppa:nilarimogard/webupd8 PPA (Audacious, Grive2, Pidgin-indicator)" # Audacious, Grive2, Pidgin-indicator
  runCmd "sudo add-apt-repository -y ppa:oibaf/graphics-drivers"; smsg "Adding ppa:oibaf/graphics-drivers PPA (free graphics-drivers + mesa)" # free graphics-drivers + mesa
  runCmd "sudo add-apt-repository -y ppa:team-xbmc/ppa"; smsg "Adding ppa:team-xbmc/ppa PPA (Kodi)" # Kodi
  runCmd "sudo add-apt-repository -y ppa:webupd8team/java"; smsg "Adding ppa:webupd8team/java PPA (Oracle Java SE 7/8)" # Oracle Java SE 7/8
  runCmd "sudo add-apt-repository -y ppa:hugin/hugin-builds"; smsg "Adding ppa:hugin/hugin-builds PPA (Hugin)" # image editor
  runCmd "sudo add-apt-repository -y ppa:mumble/release"; smsg "Adding ppa:mumble/release PPA (Mumble)" # Mumble
  runCmd "sudo add-apt-repository -y ppa:atareao/utext"; smsg "Adding ppa:atareao/utext PPA (utext)" # Markdown editor
  runCmd "sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer"; smsg "Adding ppa:danielrichter2007/grub-customizer PPA (grub-customizer)" # grub-customizer
  runCmd "sudo add-apt-repository -y ppa:lucioc/sayonara"; smsg "Adding ppa:lucioc/sayonara PPA (Sayonara)" # audio player
  runCmd "sudo add-apt-repository -y ppa:haraldhv/shotcut"; smsg "Adding ppa:haraldhv/shotcut PPA (Shotcut)" # video editor
  runCmd "sudo add-apt-repository -y ppa:flacon/ppa"; smsg "Adding ppa:flacon/ppa PPA (Flacon)" # audio extraction
  runCmd "sudo add-apt-repository -y ppa:jaap.karssenberg/zim"; smsg "Adding ppa:jaap.karssenberg/zim PPA (Zim)" # local wiki
  runCmd "sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release"; smsg "Adding ppa:pmjdebruijn/darktable-release PPA (Darktable)" # raw editor
  runCmd "sudo add-apt-repository -y ppa:js-reynaud/kicad-4"; smsg "Adding ppa:js-reynaud/kicad-4 PPA (Kicad 4)" # CAD
  runCmd "sudo add-apt-repository -y ppa:stebbins/handbrake-releases"; smsg "Adding ppa:stebbins/handbrake-releases PPA (Handbrake)" # video transcoder
  runCmd "sudo add-apt-repository -y ppa:webupd8team/brackets"; smsg "Adding ppa:webupd8team/brackets PPA (Adobe Brackets)" # IDE
  runCmd "sudo add-apt-repository -y ppa:graphics-drivers/ppa"; smsg "Adding ppa:graphics-drivers/ppa PPA (Nvidia Graphics Drivers)" # non-free nvidia drivers
  runCmd "sudo add-apt-repository -y ppa:djcj/hybrid"; smsg "Adding ppa:djcj/hybrid PPA (FFMpeg, MKVToolnix)" # FFMpeg, MKVToolnix
  runCmd "sudo add-apt-repository -y ppa:diodon-team/stable"; smsg "Adding ppa:diodon-team/stable PPA (Diodon)" # clipboard manager
  runCmd "sudo add-apt-repository -y ppa:notepadqq-team/notepadqq"; smsg "Adding ppa:notepadqq-team/notepadqq PPA (Notepadqq)" # notepad++ clone
  runCmd "sudo add-apt-repository -y ppa:mariospr/frogr"; smsg "Adding ppa:mariospr/frogr PPA (Frogr)" # flickr manager
  runCmd "sudo add-apt-repository -y ppa:saiarcot895/myppa"; smsg "Adding ppa:saiarcot895/myppa PPA (apt-fast)" # apt-fast tools
  runCmd "sudo add-apt-repository -y ppa:ubuntuhandbook1/slowmovideo"; smsg "Adding ppa:ubuntuhandbook1/slowmovideo PPA (Slowmovideo)" # slow motion video editor
  runCmd "sudo add-apt-repository -y ppa:transmissionbt/ppa"; smsg "Adding ppa:transmissionbt/ppa PPA (Transmission-BT)" # bittorrent client
  runCmd "sudo add-apt-repository -y ppa:geary-team/releases"; smsg "Adding ppa:geary-team/releases PPA (Geary)" # email client
  runCmd "sudo add-apt-repository -y ppa:varlesh-l/papirus-pack"; smsg "Adding ppa:varlesh-l/papirus-pack PPA (themes)" # themes
  #sudo add-apt-repository -y ppa:mc3man/trusty-media # multimedia apps # no longer maintained ?
  #sudo add-apt-repository -y ppa:whatsapp-purple/ppa # WhatsApp plugin for Pidgin/libpurple # update ?

  wget -qO- http://deb.opera.com/archive.key | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding Opera repository key"
  echo "deb http://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera.list && retCode $? && smsg "Adding Opera repository"

  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding Chrome repository key"
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list && retCode $? && smsg "Adding Chrome repository"

  wget -qO - https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding InSync repository key"
  echo "deb http://apt.insynchq.com/ubuntu xenial non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list && retCode $? && smsg "Adding InSync repository"

  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &>> $logFile && retCode $? && smsg "Adding Docker repository key"
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main"  | sudo tee /etc/apt/sources.list.d/docker.list && retCode $? && smsg "Adding Docker repository"

  wget -qO - https://syncthing.net/release-key.txt | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding SyncThing repository key"
  echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list && retCode $? && smsg "Adding SyncThing repository"

  msg "Adding OwnCloud-Client repository"
  wget -qO - http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_16.04/Release.key | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding OwnCloud-Client repository key"
  echo "deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.04/ /" | sudo tee /etc/apt/sources.list.d/owncloud-client.list && retCode $? && smsg "Adding OwnCloud-Client repository"

  wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding MKVToolnix repository key"
  echo "deb http://mkvtoolnix.download/ubuntu/xenial/ ./"  | sudo tee /etc/apt/sources.list.d/mkv.list && retCode $? && smsg "Adding MKVToolnix repository"
  echo "deb-src http://mkvtoolnix.download/ubuntu/xenial/ ./ "  | sudo tee -a /etc/apt/sources.list.d/mkv.list && retCode $? && smsg "Adding MKVToolnix sources repository"

  #wget -O- https://jgeboski.github.io/obs.key | sudo apt-key add - && retCode $? && smsg "Adding purple-facebook repository key"
  #sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_14.04/ ./' > /etc/apt/sources.list.d/jgeboski.list" && retCode $? && smsg "Adding purple-facebook repository"

  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 &>> $logFile && retCode $? && smsg "Adding Spotify repository key"
  echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list && retCode $? && smsg "Adding Spotify repository"

  wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding VirtualBox repository old key"
  wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | sudo apt-key add - && retCode $? && smsg "Adding VirtualBox repository key"
  echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list && retCode $? && smsg "Adding VirtualBox repository"

  gpg --keyserver pool.sks-keyservers.net --recv-keys 1537994D && gpg --export --armor 1537994D | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding Whatsie repository key"
  echo "deb https://dl.bintray.com/aluxian/deb stable main" | sudo tee -a /etc/apt/sources.list.d/whatsie.list && retCode $? && smsg "Adding Whatsie repository"

  wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add - &>> $logFile && retCode $? && smsg "Adding Getdeb repository key"
  echo "deb http://archive.getdeb.net/ubuntu xenial-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb.list && retCode $? && smsg "Adding Getdeb repository"

  updateSystem
}

installBase () {
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
}

installMultimedia () {
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
}

installMultimediaExt () {
  msg "Installing Multimedia apps and tools"

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
}

installEbook () {
  msg "Installation eBook apps and tools"

  runCmd "sudo apt-get install -y fbreader"; smsg "Installing fbreader"

  cd /tmp

  runCmd "sudo -v && wget -q --no-check-certificate -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c \"import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()\""
  smsg "Installing calibre"
}

installInternet () {
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
  runCmd "sudo apt-get install -y corebird"; smsg "Installing corebird"
}

installInternetExt () {
  msg "Installing Internet apps and tools"

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
}

installMiscUtilities () {
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
}

installWine () {
  msg "Installing Wine"

  runCmd "sudo add-apt-repository -y ppa:ubuntu-wine/ppa"; smsg "Adding Wine PPA"
  updateSystem
  runCmd "sudo apt-get install -y wine1.8"; smsg "Installing wine1.8"
  runCmd "sudo apt-get install -y winetricks"; smsg "Installing winetricks"
  runCmd "sudo apt-get install -y playonlinux"; smsg "Installing playonlinux"
}

installWineDRI3 () {
  msg "Installing WineDRI3"

  runCmd "sudo add-apt-repository -y ppa:commendsarnex/winedri3"; smsg "Adding WineDRI3 PPA"
  updateSystem
  runCmd "sudo apt-get install -y wine1.9"; smsg "Installing wine1.9"
  runCmd "sudo apt-get install -y winetricks"; smsg "Installing winetricks"
  runCmd "sudo apt-get install -y playonlinux"; smsg "Installing playonlinux"
}

installWineStaging () {
  msg "Installing Wine-Staging"

  runCmd "sudo add-apt-repository -y ppa:pipelight/stable"; smsg "Adding WineStaging PPA"
  updateSystem
  runCmd "sudo apt-get install -y wine-staging-amd64"; smsg "Installing wine-staging-amd64"
}

installKodiBETA () {
  msg "Installing Kodi BETA"

  runCmd "sudo add-apt-repository -y ppa:team-xbmc/unstable"; smsg "Adding Kodi BETA PPA"
  updateSystem
  runCmd "sudo apt-get install -y kodi"; smsg "Installing kodi"
}

installKodiNightly () {
  msg "Installing Kodi Nightly"

  runCmd "sudo add-apt-repository -y ppa:team-xbmc/xbmc-nightly"; smsg "Adding Kodi Nightly PPA"
  updateSystem
  runCmd "sudo apt-get install -y kodi"; smsg "Installing kodi"
}

installGames () {
  msg "Installing Games apps and tools"

  runCmd "sudo apt-get install -y steam"; smsg "Installing steam"
  runCmd "sudo apt-get install -y jstest-gtk"; smsg "Installing jstest-gtk"
}

installBurningTools () {
  msg "Installing CD/DVD/BD Burning apps and tools"

  runCmd "sudo apt-get install -y brasero"; smsg "Installing brasero"
  runCmd "sudo apt-get install -y k3b k3b-extrathemes"; smsg "Installing k3b k3b-extrathemes"
  runCmd "sudo apt-get install -y xfburn"; smsg "Installing xfburn"
}

installNetTools () {
  msg "Installing Network apps and tools"
  # to add when available : gtkvncviewer

  runCmd "sudo apt-get install -y whois"; smsg "Installing whois"
  runCmd "sudo apt-get install -y iptraf"; smsg "Installing iptraf"
  runCmd "sudo apt-get install -y iperf"; smsg "Installing iperf"
  runCmd "sudo apt-get install -y wireshark tshark"; smsg "Installing wireshark tshark"
  runCmd "sudo apt-get install -y zenmap"; smsg "Installing zenmap"
  runCmd "sudo apt-get install -y dsniff"; smsg "Installing dsniff"
  runCmd "sudo apt-get install -y aircrack-ng"; smsg "Installing aircrack-ng"
}

installCajaPlugins () {
  msg "Installing Caja extensions"

  runCmd "sudo apt-get install -y caja-share"; smsg "Installing caja-share"
  runCmd "sudo apt-get install -y caja-wallpaper"; smsg "Installing caja-wallpaper"
  runCmd "sudo apt-get install -y caja-sendto"; smsg "Installing caja-sendto"
  runCmd "sudo apt-get install -y caja-image-converter"; smsg "Installing caja-image-converter"

  if which insync >/dev/null; then
    runCmd "sudo apt-get install -y insync-caja"; smsg "Installing insync-caja"
  fi
}

installNautilusAndPlugins () {
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
}

installGimpPlugins () {
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
}

installRhythmBoxPlugins () {
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
}

installPidginPlugins () {
  msg "Installing Pidgin extensions"
  # to add when available : pidgin-whatsapp

  runCmd "sudo apt-get install -y telegram-purple"; smsg "Installing telegram-purple"
  runCmd "sudo apt-get install -y pidgin-skype"; smsg "Installing pidgin-skype"
  runCmd "sudo apt-get install -y purple-hangouts"; smsg "Installing purple-hangouts"
  runCmd "sudo apt-get install -y pidgin-hangouts"; smsg "Installing pidgin-hangouts"
}

installZsh () {
  msg "Installing ZSH"
  sudo apt-get install -y zsh

  msg "Installing Oh-my-Zsh"
  msh "Type exit to leave Zsh and go back to Yggdrasil script"
  cd /tmp
  rm install.sh
  wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
  chmod +x install.sh
  ./install.sh
}

installUnbound () {
  msg "Installing Unbound"
  runCmd "sudo apt-get install -y unbound"; smsg "Installing unbound"
}

installThemes () {
  msg "Installing themes"
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
}

installIcons () {
  msg "Installing icons"
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
}

installPlankThemes () {
  msg "Installing Plank themes"

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
}

installIconsExt () {
  msg "Installing extra icons pack"
  mkdir -p /home/$myHomedir/.icons
  cp icons.tar.gz /home/$myHomedir/.icons
  cd /home/$myHomedir/.icons
  tar xzf icons.tar.gz
  rm icons.tar.gz
}

installSolaar () {
  msg "Installing Solaar"
  runCmd "sudo apt-get install -y solaar"; smsg "Installing solaar"
}

installCardReader () {
  msg "Installing CardReader and utils"
  runCmd "sudo apt-get install -y pcscd pcsc-tools"; smsg "Installing pcscd pcsc-tools"
}

installEid () {
  cd /tmp

  msg "Installing eID middleware"

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
}

installEpsonV500Photo () {
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
}

updateMicrocode () {
  msg "Mise à jours du Microcode du Processeur"
  oldMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
  intel=`cat /proc/cpuinfo | grep -i Intel | wc -l`
  if [ "$intel" -gt "0" ]; then
    sudo apt-get install -y intel-microcode
  fi
  newMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
  msg "Microcode passé de la version "$oldMicrocode" à la version "$newMicrocode
}

fixWirelessIntel6320 () {
  msg "Backup du fichier iwlwifi.conf"
  sudo cp /etc/modprobe.d/iwlwifi.conf /etc/modprobe.d/iwlwifi.conf.bak

  msg "Paramètres dans iwlwifi.conf"
  echo options iwlwifi bt_coex_active=0 swcrypto=1 11n_disable=8 | sudo tee /etc/modprobe.d/iwlwifi.conf

  msg "!!! REBOOT Nécessaire !!!"
}

installDevApps () {
  msg "Installing base Dev apps and tools"

  runCmd "sudo apt-get install -y notepadqq"; smsg "Installing notepadqq"
  runCmd "sudo apt-get install -y agave"; smsg "Installing agave"
  runCmd "sudo apt-get install -y utext"; smsg "Installing utext"
  runCmd "sudo apt-get install -y gpick"; smsg "Installing gpick"
  runCmd "sudo apt-get install -y virtualbox-5.1"; smsg "Installing virtualbox-5.1"
  runCmd "sudo apt-get install -y build-essential"; smsg "Installing build-essential"
  runCmd "sudo apt-get install -y ubuntu-make"; smsg "Installing ubuntu-make"
  runCmd "sudo apt-get install -y ghex"; smsg "Installing ghex"
  runCmd "sudo apt-get install -y glade"; smsg "Installing glade"
  runCmd "sudo apt-get install -y eric"; smsg "Installing eric"
  runCmd "sudo apt-get install -y bluefish"; smsg "Installing bluefish"
  runCmd "sudo apt-get install -y meld"; smsg "Installing meld"
  runCmd "sudo apt-get install -y bluegriffon"; smsg "Installing bluegriffon"
  runCmd "sudo apt-get install -y zeal"; smsg "Installing zeal"
}

installJava () {
  msg "Installing Java apps and tools"

  runCmd "sudo apt-get install -y oracle-java7-installer"; smsg "Installing oracle-java7-installer"
  runCmd "sudo apt-get install -y oracle-java8-installer"; smsg "Installing oracle-java8-installer"
  runCmd "sudo apt-get install -y oracle-java8-set-default"; smsg "Installing oracle-java8-set-default"
}

installJavaScript () {
  msg "Installing JavaScript apps and tools"

  runCmd "sudo apt-get install -y npm"; smsg "Installing npm"
  runCmd "sudo apt-get install -y nodejs-legacy"; smsg "Installing nodejs-legacy"
  runCmd "sudo apt-get install -y javascript-common"; smsg "Installing javascript-common"

  if which npm >/dev/null; then
    runCmd "sudo npm install remark-lint"; smsg "NPM Installing qt4-dev-tools"
    runCmd "sudo npm install jshint"; smsg "NPM Installing jshint"
    runCmd "sudo npm install jedi"; smsg "NPM Installing jedi"
  fi
}

installPHP () {
  msg "Installing PHP apps and tools"

  runCmd "sudo apt-get install -y php7.0-cli"; smsg "Installing php7.0-cli"
}

installLUA () {
  msg "Installing LUA apps and tools"

  runCmd "sudo apt-get install -y luajit"; smsg "Installing luajit"
}

installRuby () {
  msg "Installing Ruby apps and tools"

  runCmd "sudo apt-get install -y ruby-dev"; smsg "Installing ruby-dev"
}

installQT () {
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
}

installPython () {
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
}

installAndroidEnv () {
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
}

installAtom () {
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
}

installAnjuta () {
  msg "Installing Anjuta"

  runCmd "sudo apt-get install -y anjuta anjuta-extras"; smsg "Installing anjuta anjuta-extras"
}

installBrackets () {
  msg "Installing Brackets"

  runCmd "sudo apt-get install -y brackets"; smsg "Installing brackets"
}

installCodeBlocks () {
  msg "Installing CodeBlocks"

  runCmd "sudo apt-get install -y codeblocks codeblocks-contrib"; smsg "Installing codeblocks codeblocks-contrib"
}

installGeany () {
  msg "Installing Geany and extensions"

  runCmd "sudo apt-get install -y geany"; smsg "Installing geany"
  runCmd "sudo apt-get install -y geany-plugins"; smsg "Installing geany-plugins"
  runCmd "sudo apt-get install -y geany-plugin-markdown"; smsg "Installing geany-plugin-markdown"
}

installEclipse () {
  if which umake >/dev/null; then
    msg "Umake installing : Eclipse"
    sudo umake ide eclipse
  fi
}

installIdea () {
  if which umake >/dev/null; then
    msg "Umake installing : Idea"
    sudo umake ide idea
  fi
}

installPyCharm () {
  if which umake >/dev/null; then
    msg "Umake installing : PyCharm"
    sudo umake ide pycharm
  fi
}

installVisualStudioCode () {
  if which umake >/dev/null; then
    msg "Umake installing : Visual-studio-code"
    sudo umake web visual-studio-code
  fi
}

installAndroidStudio () {
  if which umake >/dev/null; then
    msg "Umake installing : Android-Studio"
    sudo umake android android-studio
  fi
}

installCAD () {
  msg "Installing CAD apps and tools"

  runCmd "sudo apt-get install -y kicad kicad-locale-fr"; smsg "Installing kicad kicad-locale-fr"
  runCmd "sudo apt-get install -y librecad"; smsg "Installing librecad"
  runCmd "sudo apt-get install -y freecad"; smsg "Installing freecad"
}

enableUFW () {
  msg "Enabling FireWall (UFW)"

  runCmd "sudo ufw enable"; smsg "Enabling ufw"
}

addNumLockXBashrc () {
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
}

enableTmpRAM () {
  msg "Modif /etc/fstab pour avoir /tmp en RAM"
  sudo sh -c "echo 'tmpfs      /tmp            tmpfs        defaults,size=2g           0    0' >> /etc/fstab"

  msg "Reboot nécessaire"
}

addScreenfetchBashrc () {
  msg "Adding screenfetch to .bashrc"
  touch /home/$myHomedir/.bashrc
  echo "screenfetch" >> /home/"$myHomedir"/.bashrc
}

enableHistoryTS () {
  msg "Activation du TimeStamp dans History"
  echo "export HISTTIMEFORMAT='%F %T  '" >> /home/"$myHomedir"/.bashrc
}

toolInxi () {
  inxi -F
}

toolSpeedtestCli () {
  if which speedtest-cli >/dev/null; then
    sudo speedtest-cli
  else
    printf "Python apps and tools + speedtest-cli app are required (PIP)"
  fi
}

toolPacketLoss () {
  ping -q -c 10 google.com
}

toolOptimizeFirefox () {
  msg "Optimisation des bases SQLite de Firefox"
  pressKey "Veuillez fermer Firefox AVANT de procéder, celui-ci sera killé juste après"
  pkill -9 firefox
  msg "Optimisation des bases SQLite..."
  for f in ~/.mozilla/firefox/*/*.sqlite; do sqlite3 $f 'VACUUM;'; done
  msg "Fin de l'optimisation des bases SQLite..."
}

toolAutoremove () {
  msg "Cleaning useless deb package(s)"
  runCmd "sudo apt-get -y autoremove"; smsg "apt-get autoremove"
}

#------------------------------------------------------------------------------#
# The main part of the script                                                  #
#------------------------------------------------------------------------------#

clear

# add a mark to the log file at every script run
echo "--[ Yggdrasil log ]--[ "$cDate" ]--[ "$cTime" ]----------------------------------------------------------------------------" >> $logFile

# Useless by itself, but is used to don't be annoyed later in the script
# NEVER run the script as root or with sudo !!!!
sudo echo

headless=1

if [ $headless == 1 ]; then
  msg "Headless/Batch mode enabled"
  exit
fi

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
--title "[ Main Menu ]" \
--menu "This tools allow you to install extra apps and customize your fresh Linux Mint setup. Use it carefully ;-)" 32 85 24 \
----------- "---Mandatory part----------------" \
Source "Open Sotfware-Source, add source repository, change mirrors" \
Update "System update" \
PPA "Add PPA and repositories " \
----------- "---------------------------------" \
AppInstall "Apps Install" \
Custom "Customize (themes,icons,...)" \
Hardware "Hardware Install/Config" \
DevInstall "Install Dev Apps" \
SystemTweak "System Config/Tweak" \
----------- "---------------------------------" \
SystemTools "Misc. tools and utilities" \
Reboot "System reboot" \
----------- "---------------------------------" \
About "About this script ..." \
Exit "Exit" 2>"${menuINPUT}"

menuitem=$(<"${menuINPUT}")

# menu's actions ---------------------------------------------------------------
case $menuitem in

Source) #-----------------------------------------------------------------------
clear

msg "Change mirrors + add Sources repository"
software-sources

pressKey
;;

Update) #-----------------------------------------------------------------------
clear

updateSystem

pressKey
;;

PPA) #--------------------------------------------------------------------------
clear

addPPA

pressKey
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
--menu "Choose apps to install" 34 85 26 \
Base "Base apps and tools" \
Multimedia "Multimedia apps and tools" \
MultimediaExt "Multimedia apps and tools (others/external)" \
eBook "eBook apps and tools" \
Internet "Internet apps and tools" \
InternetExt "Internet apps and tools (others/external)" \
MiscUtilities "Misc. utilities apps and tools" \
Wine "Wine" \
WineDRI3 "WineDRI3 (Gallium3D) (oibaf PPA required)" \
WineStaging "Unstable Wine beside Stable Wine" \
KodiBETA "Beta/Unstable Kodi" \
KodiNightly "Nightly Kodi" \
Games "Steam, jstest-gtk" \
BurningTools "CD/DVD/BD Burning Apps and tools" \
NetTools "Network apps and tools" \
Caja "Caja extensions" \
Nautilus "Nautilus + extensions" \
Gimp "Gimp extensions" \
RhythmBox "RhythmBox extensions" \
Pidgin "Pidgin/libpurple extensions" \
Unbound "Unbound (DNS cache)" \
Zsh "Shell ZSH + Oh-my-Zsh" \
Back "Back to the Main Menu" 2>"${menuAppINPUT}"

menuAppItem=$(<"${menuAppINPUT}")

# appMenu's actions ------------------------------------------------------------
case $menuAppItem in

Base)
clear; installBase; pressKey;;

Multimedia)
clear; installMultimedia; pressKey;;

MultimediaExt)
clear; installMultimediaExt; pressKey;;

eBook)
clear; installEbook; pressKey;;

Internet)
clear; installInternet; pressKey;;

InternetExt)
clear; installInternetExt; pressKey;;

MiscUtilities)
clear; installMiscUtilities; pressKey;;

Wine)
clear; installWine; pressKey;;

WineDRI3)
clear; installWineDRI3; pressKey;;

WineStaging)
clear; installWineStaging; pressKey;;

KodiBETA)
clear; installKodiBETA; pressKey;;

KodiNightly)
clear; installKodiNightly; pressKey;;

Games)
clear; installGames; pressKey;;

BurningTools)
clear; installBurningTools; pressKey;;

NetTools)
clear; installNetTools; pressKey;;

Caja)
clear; installCajaPlugins; pressKey;;

Nautilus)
clear; installNautilusAndPlugins; pressKey;;

Gimp)
clear; installGimpPlugins; pressKey;;

RhythmBox)
clear; installRhythmBoxPlugins; pressKey;;

Pidgin)
clear; installPidginPlugins; pressKey;;

Zsh)
clear; installZsh; pressKey;;

Unbound)
clear; installUnbound; pressKey;;

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
--title "[ Customization Menu ]" \
--menu "System Customization" 33 85 25 \
Themes "System themes" \
Icons "System icons" \
Plank "Plank themes" \
Icons "Extra icons pack" \
Back "Back to the Main Menu" 2>"${menuCustomINPUT}"

menuCustomItem=$(<"${menuCustomINPUT}")

# customMenu's actions ---------------------------------------------------------
case $menuCustomItem in

Themes)
clear; installThemes; pressKey;;

Icons)
clear; installIcons; pressKey;;

Plank)
clear; installPlankThemes; pressKey;;

Icons)
clear; installIconsExt; pressKey;;

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
--title "[ Hardware Menu ]" \
--menu "Hardware : drivers & configration" 32 95 24 \
Solaar "Solaar - Logitech Unifying Manager App" \
CardReader "CardReader pcscd app" \
eID "eID middleware" \
EpsonV500Photo "Espon V500 Photo driver + iScan + Xsane" \
Microcode "CPU Microcode update (Intel)" \
WirelessIntel6320 "Intel Centrino Advanced-N 6320 config (Bluetooth/Wifi problems)" \
Back "Back to the Main Menu" 2>"${menuHWINPUT}"

menuHWItem=$(<"${menuHWINPUT}")

# hwMenu's actions -------------------------------------------------------------
case $menuHWItem in

Solaar)
clear; installSolaar; pressKey;;

CardReader)
clear; installCardReader; pressKey;;

eID)
clear; installEid; pressKey;;

EpsonV500Photo)
clear; installEpsonV500Photo; pressKey;;

Microcode)
clear; updateMicrocode; pressKey;;

WirelessIntel6320)
clear; fixWirelessIntel6320; pressKey;;

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
--title "[ Dev Apps and tools Menu ]" \
--menu "Dev apps and tools to install and configure" 32 85 24 \
DevApps "Base Dev apps and tools (Required)" \
Java "Java Dev apps and tools" \
JavaScript "JavaScript Dev apps and tools" \
PHP "PHP Dev apps and tools" \
LUA "LUA Dev apps and tools" \
Ruby "Ruby Dev apps and tools" \
QT "QT Dev apps and tools" \
Python "Python Dev apps and tools" \
AndroidEnv "Android Environnement (SDK, config, ...)" \
Atom "Atom + extensions" \
Anjuta "Anjuta" \
Brackets "Brackets" \
CodeBlocks "CodeBlocks" \
Geany "Geany" \
Eclipse "Eclipse" \
Idea "Intellij IDEA (Java)" \
PyCharm "PyCharm (Python)" \
VisualStudioCode "Visual Studio Code" \
AndroidStudio "Android Studio (Android)" \
CAD "CAD Apps and tools" \
Back "Back to the Main Menu" 2>"${menuDevINPUT}"

menuDevItem=$(<"${menuDevINPUT}")

# devMenu's actions ------------------------------------------------------------
case $menuDevItem in

DevApps)
clear; installDevApps; pressKey;;

Java)
clear; installJava; pressKey;;

JavaScript)
clear; installJavaScript; pressKey;;

PHP)
clear; installPHP; pressKey;;

LUA)
clear; installLUA; pressKey;;

Ruby)
clear; installRuby; pressKey;;

QT)
clear; installQT; pressKey;;

Python)
clear; installPython; pressKey;;

AndroidEnv)
clear; installAndroidEnv; pressKey;;

Atom)
clear; installAtom; pressKey;;

Anjuta)
clear; installAnjuta; pressKey;;

Brackets)
clear; installBrackets; pressKey;;

CodeBlocks)
clear; installCodeBlocks; pressKey;;

Geany)
clear; installGeany; pressKey;;

Eclipse)
clear; installEclipse; pressKey;;

Idea)
clear; installIdea; pressKey;;

PyCharm)
clear; installPyCharm; pressKey;;

VisualStudioCode)
clear; installVisualStudioCode; pressKey;;

AndroidStudio)
clear; installAndroidStudio; pressKey;;

CAD)
clear; installCAD; pressKey;;

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
--title "[ System Configuration ]" \
--menu "System configuration" 32 95 24 \
Ufw "Enable Firewall (ufw)" \
NumLockX "NumLock Enabled at boot time" \
TmpRAM "/tmp stored in RAM" \
screenfetch "screenfetch added to .bashrc" \
historyTS "TimeStamp enabled in Shell History" \
Back "Back to the Main Menu" 2>"${menuConfigINPUT}"

menuConfigItem=$(<"${menuConfigINPUT}")

# configMenu's actions ---------------------------------------------------------
case $menuConfigItem in

Ufw)
clear; enableUFW; pressKey;;

NumLockX)
clear; addNumLockXBashrc; pressKey;;

TmpRAM)
clear; enableTmpRAM; pressKey;;

screenfetch)
clear; addScreenfetchBashrc; pressKey;;

historyTS)
clear; enableHistoryTS; pressKey;;

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
--title "[ System tools ]" \
--menu "System tools to diagnose and optimize" 32 95 24 \
inxi "System informations" \
speedtest-cli "Bandwidth test" \
packetloss "Packetloss test (ping)" \
OptimizeFirefox "Firefox SQLite databases optimization" \
Autoremove "Remove useless Deb packages" \
Back "Back to the Main Menu" 2>"${menuSysToolsINPUT}"

menuSysToolsItem=$(<"${menuSysToolsINPUT}")

# SysToolsMenu's actions -------------------------------------------------------
case $menuSysToolsItem in

inxi)
clear; toolInxi; pressKey;;

speedtest-cli)
clear; toolSpeedtestCli; pressKey;;

packetloss)
clear; toolPacketLoss; pressKey;;

OptimizeFirefox)
clear; toolOptimizeFirefox; pressKey;;

Autoremove)
clear; toolAutoremove; pressKey;;

Back) #-------------------------------------------------------------------------
break
;;

# end of SysTools menu actions choice
esac
# end of SysTools menu loop
done
;;

Reboot) #-----------------------------------------------------------------------
dialog --title "WARNING" \
--backtitle "Yggdrasil "$version \
--yesno "\nSystem reboot ?\n" 7 60
# depending of the choice ...
responseReboot=$?
case $responseReboot in
0)
sudo reboot
;;
1)
clear
msg "Canceled ..."
;;
255)
clear
msg "[ESC] pressed"
;;
esac
;;

About) #------------------------------------------------------------------------
dialog --backtitle "Yggdrasil "$version \
--title "[ About ...]" \
--msgbox '\n
Author : Francois B. (Makotosan/Shakasan)\n\n
Email : shakasan@sirenacorp.be\n\n
Website : https://sirenacorp.be/\n\n
Github : https://github.com/shakasan/Yggdrasil_LM18\n\n
Licence : GPLv3\n\n
Version : '$version'\n\n
This script has been written to makes my life easier when I have to (re)install my personal computers ;-)\n\n
This is my first major shell sccript and use of Dialog,...\n\n
Advices and remarks are welcome ^^' 25 70
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
