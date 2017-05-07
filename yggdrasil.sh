#!/bin/bash
#------------------------------------------------------------------------------#
# Yggdrasil                                                                    #
#    author : Francois B. (Makotosan/Shakasan)                                 #
#    licence : GPLv3                                                           #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Script's cons. and vars.                                                     #
#------------------------------------------------------------------------------#

version="0.2.2"

# myHomedir is used in full paths to the homedir
myHomedir=$(whoami)

# script base dir
scriptDir=$(pwd)

# logfile
logFile="/home/"$myHomedir"/yggdrasil.log"

# date and time
cTime=$(date +%H:%M)
cDate=$(date +%d-%m-%Y)

UNDERLINE=$(tput sgr 0 1)
BOLD=$(tput bold)
ROUGE=$(tput setaf 1)
VERT=$(tput setaf 2)
JAUNE=$(tput setaf 3)
BLEU=$(tput setaf 4)
MAUVE=$(tput setaf 5)
CYAN=$(tput setaf 6)
BLANC=$(tput setaf 7)
NORMAL=$(tput sgr0)
INV=$(tput smso)
BOLDROUGE=${BOLD}${ROUGE}
BOLDVERT=${BOLD}${VERT}
BOLDJAUNE=${BOLD}${JAUNE}
BOLDBLEU=${BOLD}${BLEU}
BOLDMAUVE=${BOLD}${MAUVE}
BOLDCYAN=${BOLD}${CYAN}
BOLDBLANC=${BOLD}${BLANC}

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
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] "
  else
    printf "[ ""$BOLDROUGE""!!"$NORMAL" ] "
  fi
}

# run a shell command and display a message between [ ] depending on the ret_code
function runCmd () {
  typeset cmd="$1"
  typeset ret_code

  eval $cmd" &>> $logFile"
  ret_code=$?

  if [ $ret_code == 0 ]; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] "
  else
    printf "[ ""$BOLDROUGE""!!"$NORMAL" ] "
  fi
}

# display a simple message
function smsgn () {
    printf "$*\n"
}

# display a simple message
function smsg () {
    printf "$*"
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

#
# system update
function updateSystem () {
  msg "System update"

  runCmd "sudo apt-get update"
  smsgn "apt-get update"

  runCmd "sudo apt-get -y upgrade"
  smsgn "apt-get -y upgrade"

  runCmd "sudo apt-get -y dist-upgrade"
  smsgn "apt-get -y dist-upgrade"
}

# check if running on the right OS ^^
function osCheck () {
  printf "$BOLDJAUNE""OS requirement checking\n\n""$NORMAL"
  OS=`lsb_release -d | gawk -F':' '{print $2}' | gawk -F'\t' '{print $2}'`

  if [[ $OS == *"Linux Mint 18"* ]]; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] Linux Mint 18.x\n"
  else
    printf "[ ""$BOLDROUGE""!!"$NORMAL" ] Linux Mint 18.x not found. Bye...\n"
    printf "\n"
    exit
  fi
}

# dependencies used in the script checked and installed if necessary
function depCheck () {
  printf "$BOLDJAUNE""Script dependencies checking\n\n""$NORMAL"

  # mpg123
  if which mpg123 >/dev/null; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] mpg123 found\n"
  else
    runCmd "sudo apt-get install -y mpg123"; smsgn "mpg123 not foud...Installing..."
  fi

  # libnotify-bin (cmd : notify-send)
  if which notify-send >/dev/null; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] libnotify-bin found\n"
  else
    runCmd "sudo apt-get install -y libnotify-bin"; smsgn "libnotify-bin not found...Installing..."
  fi

  # lsb_release
  if which lsb_release >/dev/null; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] lsb-release found\n"
  else
    runCmd "sudo apt-get install -y lsb-release"; smsgn "lsb-release not found...Installing..."
  fi

  # cifs-utils
  if which mount.cifs >/dev/null; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] cifs-utils found\n"
  else
    runCmd "sudo apt-get install -y cifs-utils"; smsgn "cifs-utils not found...Installing..."
  fi

  # dialog
  if which dialog >/dev/null; then
    printf "[ ""$BOLDVERT""OK"$NORMAL" ] dialog found\n"
  else
    runCmd "sudo apt-get install -y dialog"; smsgn "dialog not found...Installing..."
  fi
}

function addPPA () {
  msg "Adding PPA and repositories"

  runCmd "sudo dpkg --add-architecture i386"; smsgn "Adding Arch i386"

  runCmd "sudo apt-get install -y apt-transport-https"; smsgn "Intalling apt-transport-https"

  sudo sh -c "echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections" &>> $logFile && retCode $? && smsgn "Accepting Oracle Java SE 7"
  sudo sh -c "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections" &>> $logFile && retCode $? && smsgn "Accepting Oracle Java SE 8"

  sudo sh -c "echo sience-config science-config/group select '$myHomedir ($myHomedir)' | sudo debconf-set-selections" &>> $logFile && retCode $? && smsgn "Pre-configuring Science-config package"

  runCmd "sudo add-apt-repository -y ppa:noobslab/themes"; smsgn "Adding ppa:noobslab/themes PPA (themes)" # themes from noobslab
  runCmd "sudo add-apt-repository -y ppa:noobslab/icons"; smsgn "Adding ppa:noobslab/icons PPA (icons)" # icons from noobslab
  runCmd "sudo add-apt-repository -y ppa:numix/ppa"; smsgn "Adding ppa:numix/ppa PPA (themes)" # theme Numix
  runCmd "sudo add-apt-repository -y ppa:ravefinity-project/ppa"; smsgn "Adding ppa:ravefinity-project/ppa PPA" # Themes
  runCmd "sudo add-apt-repository -y ppa:teejee2008/ppa"; smsgn "Adding ppa:teejee2008/ppa PPA (Aptik, Conky-Manager)" # Aptik - Conky-Manage
  runCmd "sudo add-apt-repository -y ppa:yktooo/ppa"; smsgn "Adding ppa:yktooo/ppa PPA (indicator-sound-switcher)" # indicator-sound-switcher
  runCmd "sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager"; smsgn "Adding ppa:webupd8team/y-ppa-manager PPA (y-ppa-manager)" # y-ppa-manager
  runCmd "sudo add-apt-repository -y ppa:webupd8team/atom"; smsgn "Adding ppa:webupd8team/atom PPA (Atom IDE)" # IDE
  runCmd "sudo add-apt-repository -y ppa:videolan/stable-daily"; smsgn "Adding ppa:videolan/stable-daily PPA (vlc)" # video player
  runCmd "sudo add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make"; smsgn "Adding ppa:ubuntu-desktop/ubuntu-make PPA (umake)" # ubuntu-make
  runCmd "sudo add-apt-repository -y ppa:nowrep/qupzilla"; smsgn "Adding ppa:nowrep/qupzilla PPA (qupzilla)" # web browser
  runCmd "sudo add-apt-repository -y ppa:atareao/atareao"; smsgn "Adding ppa:atareao/atareao PPA (pushbullet-indicator, imagedownloader, gqrcode, cpu-g)" # pushbullet-indicator, imagedownloader, gqrcode, cpu-g
  runCmd "sudo add-apt-repository -y ppa:fossfreedom/rhythmbox-plugins"; smsgn "Adding ppa:fossfreedom/rhythmbox-plugins PPA (Rhythmbox plugins)" # Rhythmbox plugins
  runCmd "sudo add-apt-repository -y ppa:fossfreedom/rhythmbox"; smsgn "Adding ppa:fossfreedom/rhythmbox PPA (Rhythmbox)" # Rhythmbox
  runCmd "sudo add-apt-repository -y ppa:nilarimogard/webupd8"; smsgn "Adding ppa:nilarimogard/webupd8 PPA (Audacious, Grive2, Pidgin-indicator)" # Audacious, Grive2, Pidgin-indicator
  runCmd "sudo add-apt-repository -y ppa:oibaf/graphics-drivers"; smsgn "Adding ppa:oibaf/graphics-drivers PPA (free graphics-drivers + mesa)" # free graphics-drivers + mesa
  runCmd "sudo add-apt-repository -y ppa:team-xbmc/ppa"; smsgn "Adding ppa:team-xbmc/ppa PPA (Kodi)" # Kodi
  runCmd "sudo add-apt-repository -y ppa:webupd8team/java"; smsgn "Adding ppa:webupd8team/java PPA (Oracle Java SE 7/8)" # Oracle Java SE 7/8
  runCmd "sudo add-apt-repository -y ppa:hugin/hugin-builds"; smsgn "Adding ppa:hugin/hugin-builds PPA (Hugin)" # image editor
  runCmd "sudo add-apt-repository -y ppa:mumble/release"; smsgn "Adding ppa:mumble/release PPA (Mumble)" # Mumble
  runCmd "sudo add-apt-repository -y ppa:atareao/utext"; smsgn "Adding ppa:atareao/utext PPA (utext)" # Markdown editor
  runCmd "sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer"; smsgn "Adding ppa:danielrichter2007/grub-customizer PPA (grub-customizer)" # grub-customizer
  runCmd "sudo add-apt-repository -y ppa:lucioc/sayonara"; smsgn "Adding ppa:lucioc/sayonara PPA (Sayonara)" # audio player
  runCmd "sudo add-apt-repository -y ppa:haraldhv/shotcut"; smsgn "Adding ppa:haraldhv/shotcut PPA (Shotcut)" # video editor
  runCmd "sudo add-apt-repository -y ppa:flacon/ppa"; smsgn "Adding ppa:flacon/ppa PPA (Flacon)" # audio extraction
  runCmd "sudo add-apt-repository -y ppa:jaap.karssenberg/zim"; smsgn "Adding ppa:jaap.karssenberg/zim PPA (Zim)" # local wiki
  runCmd "sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release"; smsgn "Adding ppa:pmjdebruijn/darktable-release PPA (Darktable)" # raw editor
  runCmd "sudo add-apt-repository -y ppa:js-reynaud/kicad-4"; smsgn "Adding ppa:js-reynaud/kicad-4 PPA (Kicad 4)" # CAD
  runCmd "sudo add-apt-repository -y ppa:stebbins/handbrake-releases"; smsgn "Adding ppa:stebbins/handbrake-releases PPA (Handbrake)" # video transcoder
  runCmd "sudo add-apt-repository -y ppa:webupd8team/brackets"; smsgn "Adding ppa:webupd8team/brackets PPA (Adobe Brackets)" # IDE
  runCmd "sudo add-apt-repository -y ppa:graphics-drivers/ppa"; smsgn "Adding ppa:graphics-drivers/ppa PPA (Nvidia Graphics Drivers)" # non-free nvidia drivers
  runCmd "sudo add-apt-repository -y ppa:djcj/hybrid"; smsgn "Adding ppa:djcj/hybrid PPA (FFMpeg, MKVToolnix)" # FFMpeg, MKVToolnix
  runCmd "sudo add-apt-repository -y ppa:diodon-team/stable"; smsgn "Adding ppa:diodon-team/stable PPA (Diodon)" # clipboard manager
  runCmd "sudo add-apt-repository -y ppa:notepadqq-team/notepadqq"; smsgn "Adding ppa:notepadqq-team/notepadqq PPA (Notepadqq)" # notepad++ clone
  runCmd "sudo add-apt-repository -y ppa:mariospr/frogr"; smsgn "Adding ppa:mariospr/frogr PPA (Frogr)" # flickr manager
  runCmd "sudo add-apt-repository -y ppa:ubuntuhandbook1/slowmovideo"; smsgn "Adding ppa:ubuntuhandbook1/slowmovideo PPA (Slowmovideo)" # slow motion video editor
  runCmd "sudo add-apt-repository -y ppa:transmissionbt/ppa"; smsgn "Adding ppa:transmissionbt/ppa PPA (Transmission-BT)" # bittorrent client
  runCmd "sudo add-apt-repository -y ppa:geary-team/releases"; smsgn "Adding ppa:geary-team/releases PPA (Geary)" # email client
  runCmd "sudo add-apt-repository -y ppa:ubuntuhandbook1/corebird"; smsgn "Adding ppa:ubuntuhandbook1/corebird PPA" # corebird
  runCmd "sudo add-apt-repository -y ppa:tista/adapta"; smsgn "Adding ppa:tista/adapta PPA (themes)" # adapta gtk theme
  runCmd "sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder"; smsgn "Adding ppa:maarten-baert/simplescreenrecorder PPA" # simplescreenrecorder
  runCmd "sudo add-apt-repository -y ppa:dhor/myway"; smsgn "Adding ppa:dhor/myway PPA" # rawtherapee (newer version)
  runCmd "sudo add-apt-repository -y ppa:zeal-developers/ppa"; smsgn "Adding ppa:zeal-developers/ppa PPA" # Zeal (newer version)
  runCmd "sudo add-apt-repository -y ppa:nextcloud-devs/client"; smsgn "Adding ppa:nextcloud-devs/client PPA" # NextCloud client
  runCmd "sudo add-apt-repository -y ppa:deluge-team/ppa"; smsgn "Adding ppa:deluge-team/ppa PPA" # Deluge P2P client
  runCmd "sudo add-apt-repository -y ppa:kritalime/ppa"; smsgn "Adding ppa:kritalime/ppa PPA" # Krita

  msg "Adding Opera repository"
  wget -qO- http://deb.opera.com/archive.key | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding Opera repository key"
  echo "deb http://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera.list && retCode $? && smsgn "Adding Opera repository"

  msg "Adding Chrome repository"
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding Chrome repository key"
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list && retCode $? && smsgn "Adding Chrome repository"

  msg "Adding Inscync repository"
  wget -qO - https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding InSync repository key"
  echo "deb http://apt.insynchq.com/ubuntu xenial non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list && retCode $? && smsgn "Adding InSync repository"

  msg "Adding Docker repository"
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &>> $logFile && retCode $? && smsgn "Adding Docker repository key"
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main"  | sudo tee /etc/apt/sources.list.d/docker.list && retCode $? && smsgn "Adding Docker repository"

  msg "Adding Syncthing repository"
  wget -qO - https://syncthing.net/release-key.txt | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding SyncThing repository key"
  echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list && retCode $? && smsgn "Adding SyncThing repository"

  msg "Adding OwnCloud-Client repository"
  wget -qO - http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_16.04/Release.key | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding OwnCloud-Client repository key"
  echo "deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.04/ /" | sudo tee /etc/apt/sources.list.d/owncloud-client.list && retCode $? && smsgn "Adding OwnCloud-Client repository"

  msg "Adding MKVToolnix repository"
  wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding MKVToolnix repository key"
  echo "deb http://mkvtoolnix.download/ubuntu/xenial/ ./"  | sudo tee /etc/apt/sources.list.d/mkv.list && retCode $? && smsgn "Adding MKVToolnix repository"
  echo "deb-src http://mkvtoolnix.download/ubuntu/xenial/ ./ "  | sudo tee -a /etc/apt/sources.list.d/mkv.list && retCode $? && smsgn "Adding MKVToolnix sources repository"

  msg "Adding purple-facebook repository"
  wget -O- https://jgeboski.github.io/obs.key | sudo apt-key add - && retCode $? && smsgn "Adding purple-facebook repository key"
  sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_16.04/ ./' > /etc/apt/sources.list.d/jgeboski.list" && retCode $? && smsgn "Adding purple-facebook repository"

  msg "Adding Spotify repository"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 &>> $logFile && retCode $? && smsgn "Adding Spotify repository key"
  echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list && retCode $? && smsgn "Adding Spotify repository"

  msg "Adding VirtualBox repository"
  wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding VirtualBox repository old key"
  wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | sudo apt-key add - && retCode $? && smsgn "Adding VirtualBox repository key"
  echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list && retCode $? && smsgn "Adding VirtualBox repository"

  msg "Adding Getdeb repository"
  wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add - &>> $logFile && retCode $? && smsgn "Adding Getdeb repository key"
  echo "deb http://archive.getdeb.net/ubuntu xenial-getdeb apps games" | sudo tee /etc/apt/sources.list.d/getdeb.list && retCode $? && smsgn "Adding Getdeb repository"

  updateSystem
}

function installBase () {
  msg "Installing base apps and tools"

  runCmd "sudo apt-get install -y cifs-utils"; smsgn "Installing cifs-utils"
  runCmd "sudo apt-get install -y xterm"; smsgn "Installing xterm"
  runCmd "sudo apt-get install -y curl"; smsgn "Installing curl"
  runCmd "sudo apt-get install -y mc"; smsgn "Installing mc"
  runCmd "sudo apt-get install -y bmon"; smsgn "Installing bmon"
  runCmd "sudo apt-get install -y htop"; smsgn "Installing htop"
  runCmd "sudo apt-get install -y screen"; smsgn "Installing screen"
  runCmd "sudo apt-get install -y dconf-cli"; smsgn "Installing dconf-cli"
  runCmd "sudo apt-get install -y dconf-editor"; smsgn "Installing dconf-editor"
  runCmd "sudo apt-get install -y lnav"; smsgn "Installing lnav"
  runCmd "sudo apt-get install -y exfat-fuse"; smsgn "Installing exfat-fuse"
  runCmd "sudo apt-get install -y exfat-utils"; smsgn "Installing exfat-utils"
  runCmd "sudo apt-get install -y iftop"; smsgn "Installing iftop"
  runCmd "sudo apt-get install -y iptraf"; smsgn "Installing iptraf"
  runCmd "sudo apt-get install -y mpg123"; smsgn "Installing mpg123"
  runCmd "sudo apt-get install -y debconf-utils"; smsgn "Installing debconf-utils"
  runCmd "sudo apt-get install -y idle3-tools"; smsgn "Installing idle3-tools"
  runCmd "sudo apt-get install -y snapd"; smsgn "Installing snapd"
}

function installMultimedia () {
  msg "Installing Multimedia apps and tools"

  runCmd "sudo apt-get install -y spotify-client"; smsgn "Installing spotify-client"
  runCmd "sudo apt-get install -y slowmovideo"; smsgn "Installing slowmovideo"
  runCmd "sudo apt-get install -y sayonara"; smsgn "Installing sayonara"
  runCmd "sudo apt-get install -y qmmp qmmp-plugin-projectm"; smsgn "Installing qmmp qmmp-plugin-projectm"
  runCmd "sudo apt-get install -y shotcut"; smsgn "Installing shotcut"
  runCmd "sudo apt-get install -y audacious"; smsgn "Installing audacious"
  runCmd "sudo apt-get install -y dia"; smsgn "Installing dia"
  runCmd "sudo apt-get install -y mpv"; smsgn "Installing mpv"
  runCmd "sudo apt-get install -y picard"; smsgn "Installing picard"
  runCmd "sudo apt-get install -y inkscape"; smsgn "Installing inkscape"
  runCmd "sudo apt-get install -y aegisub aegisub-l10n"; smsgn "Installing aegisub aegisub-l10n"
  runCmd "sudo apt-get install -y mypaint mypaint-data-extras"; smsgn "Installing mypaint mypaint-data-extras"
  runCmd "sudo apt-get install -y audacity"; smsgn "Installing audacity"
  runCmd "sudo apt-get install -y blender"; smsgn "Installing blender"
  runCmd "sudo apt-get install -y kodi"; smsgn "Installing kodi"
  runCmd "sudo apt-get install -y digikam"; smsgn "Installing digikam"
  runCmd "sudo apt-get install -y synfigstudio"; smsgn "Installing synfigstudio"
  runCmd "sudo apt-get install -y mkvtoolnix-gui"; smsgn "Installing mkvtoolnix-gui"
  runCmd "sudo apt-get install -y rawtherapee"; smsgn "Installing rawtherapee"
  runCmd "sudo apt-get install -y hugin"; smsgn "Installing hugin"
  runCmd "sudo apt-get install -y asunder"; smsgn "Installing asunder"
  runCmd "sudo apt-get install -y milkytracker"; smsgn "Installing milkytracker"
  runCmd "sudo apt-get install -y pitivi"; smsgn "Installing pitivi"
  runCmd "sudo apt-get install -y openshot"; smsgn "Installing openshot"
  runCmd "sudo apt-get install -y smplayer smplayer-themes smplayer-l10n"; smsgn "Installing smplayer smplayer-themes smplayer-l10n"
  runCmd "sudo apt-get install -y selene"; smsgn "Installing selene"
  runCmd "sudo apt-get install -y gnome-mplayer"; smsgn "Installing gnome-mplayer"
  runCmd "sudo apt-get install -y handbrake"; smsgn "Installing handbrake"
  runCmd "sudo apt-get install -y avidemux2.6-qt avidemux2.6-plugins-qt"; smsgn "Installing avidemux2.6-qt avidemux2.6-plugins-qt"
  runCmd "sudo apt-get install -y mjpegtools"; smsgn "Installing mjpegtools"
  runCmd "sudo apt-get install -y twolame"; smsgn "Installing twolame"
  runCmd "sudo apt-get install -y lame"; smsgn "Installing lame"
  runCmd "sudo apt-get install -y banshee banshee-extension-soundmenu"; smsgn "Installing banshee banshee-extension-soundmenu"
  runCmd "sudo apt-get install -y gpicview"; smsgn "Installing gpicview"
  runCmd "sudo apt-get install -y vlc"; smsgn "Installing vlc"
  runCmd "sudo apt-get install -y shotwell"; smsgn "Installing shotwell"
  runCmd "sudo apt-get install -y darktable"; smsgn "Installing darktable"
  runCmd "sudo apt-get install -y ffmpeg"; smsgn "Installing ffmpeg"
  runCmd "sudo apt-get install -y flacon"; smsgn "Installing flacon"
  runCmd "sudo apt-get install -y scribus"; smsgn "Installing scribus"
  runCmd "sudo apt-get install -y birdfont"; smsgn "Installing birdfont"
  runCmd "sudo apt-get install -y moc"; smsgn "Installing moc"
  runCmd "sudo apt-get install -y webp"; smsgn "Installing webp"
  runCmd "sudo apt-get install -y simplescreenrecorder simplescreenrecorder-lib simplescreenrecorder-lib:i386"; smsgn "Installing simplescreenrecorder simplescreenrecorder-lib simplescreenrecorder-lib:i386"
  runCmd "sudo apt-get install -y cuetools shntool flac"; smsgn "Installing cuetools shntool flac"
  runCmd "sudo apt-get install -y entangle"; smsgn "Installing entangle"
  runCmd "sudo apt-get install -y krita"; smsgn "Installing krita"
  runCmd "sudo apt-get install -y soundconverter"; smsgn "Installing soundconverter"

  # nightly theme for Moc
  runCmd "echo 'alias mocp=\"mocp -T nightly_theme\"' | tee -a /home/$myHomedir/.bashrc"
  smsgn "Configuring nightly theme for Mocp"
}

function installMultimediaExt () {
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

function installEbook () {
  msg "Installation eBook apps and tools"
  runCmd "sudo apt-get install -y fbreader"; smsgn "Installing fbreader"
  cd /tmp
  runCmd "sudo -v && wget -q --no-check-certificate -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c \"import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()\""
  smsgn "Installing calibre"
}

function installInternet () {
  msg "Installing Internet apps and tools"

  echo "opera-stable opera-stable/add-deb-source boolean false" | sudo debconf-set-selections

  runCmd "sudo apt-get install -y owncloud-client"; smsgn "Installing owncloud-client"
  runCmd "sudo apt-get install -y syncthing-gtk syncthing"; smsgn "Installing syncthing-gtk syncthing"
  runCmd "sudo apt-get install -y insync"; smsgn "Installing insync"
  runCmd "sudo apt-get install -y quiterss"; smsgn "Installing quiterss"
  runCmd "sudo apt-get install -y frogr"; smsgn "Installing frogr"
  runCmd "sudo apt-get install -y opera-stable"; smsgn "Installing opera-stable"
  runCmd "sudo apt-get install -y google-chrome-stable"; smsgn "Installing google-chrome-stable"
  runCmd "sudo apt-get install -y xchat-gnome xchat-gnome-indicator"; smsgn "Installing xchat-gnome xchat-gnome-indicator"
  runCmd "sudo apt-get install -y chromium-browser chromium-browser-l10n"; smsgn "Installing chromium-browser chromium-browser-l10n"
  runCmd "sudo apt-get install -y dropbox"; smsgn "Installing dropbox"
  runCmd "sudo apt-get install -y qupzilla"; smsgn "Installing qupzilla"
  runCmd "sudo apt-get install -y filezilla"; smsgn "Installing filezilla"
  runCmd "sudo apt-get install -y hexchat"; smsgn "Installing hexchat"
  runCmd "sudo apt-get install -y mumble"; smsgn "Installing mumble"
  runCmd "sudo apt-get install -y skype"; smsgn "Installing skype"
  runCmd "sudo apt-get install -y imagedownloader"; smsgn "Installing imagedownloader"
  runCmd "sudo apt-get install -y california"; smsgn "Installing california"
  runCmd "sudo apt-get install -y midori"; smsgn "Installing midori"
  runCmd "sudo apt-get install -y geary"; smsgn "Installing geary"
  runCmd "sudo apt-get install -y corebird"; smsgn "Installing corebird"
  runCmd "sudo apt-get install -y nextcloud-client nextcloud-client-caja"; smsgn "Installing NextCloud client"
  runCmd "sudo apt-get install -y deluge"; smsgn "Installing deluge"
}

function installInternetExt () {
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

  msg "Téléchargement de Gyazo"
  wget https://packagecloud.io/install/repositories/gyazo/gyazo-for-linux/script.deb.sh

  msg "Installation de Gyazo"
  chmod +x script.deb.sh
  sudo os=ubuntu dist=xenial ./script.deb.sh
  sudo apt-get install -y gyazo

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

function installMiscUtilities () {
  msg "Installing misc. utility apps and tools"

  runCmd "sudo apt-get install -y qtqr"; smsgn "Installing qtqr"
  runCmd "sudo apt-get install -y cpu-g"; smsgn "Installing cpu-g"
  runCmd "sudo apt-get install -y screenfetch"; smsgn "Installing screenfetch"
  runCmd "sudo apt-get install -y xcalib"; smsgn "Installing xcalib"
  runCmd "sudo apt-get install -y conky-manager conky-all"; smsgn "Installing conky-manager conky-all"
  runCmd "sudo apt-get install -y plank"; smsgn "Installing plank"
  runCmd "sudo apt-get install -y indicator-sound-switcher"; smsgn "Installing indicator-sound-switcher"
  runCmd "sudo apt-get install -y y-ppa-manager"; smsgn "Installing y-ppa-manager"
  runCmd "sudo apt-get install -y synapse"; smsgn "Installing synapse"
  runCmd "sudo apt-get install -y acetoneiso"; smsgn "Installing acetoneiso"
  runCmd "sudo apt-get install -y guake"; smsgn "Installing guake"
  runCmd "sudo apt-get install -y tilda"; smsgn "Installing tilda"
  runCmd "sudo apt-get install -y psensor"; smsgn "Installing psensor"
  runCmd "sudo apt-get install -y kazam"; smsgn "Installing kazam"
  runCmd "sudo apt-get install -y bleachbit"; smsgn "Installing bleachbit"
  runCmd "sudo apt-get install -y gparted"; smsgn "Installing gparted"
  runCmd "sudo apt-get install -y gsmartcontrol"; smsgn "Installing gsmartcontrol"
  runCmd "sudo apt-get install -y terminator"; smsgn "Installing terminator"
  runCmd "sudo apt-get install -y aptik"; smsgn "Installing aptik"
  runCmd "sudo apt-get install -y gufw"; smsgn "Installing gufw"
  runCmd "sudo apt-get install -y numlockx"; smsgn "Installing numlockx"
  runCmd "sudo apt-get install -y grub-customizer"; smsgn "Installing grub-customizer"
  runCmd "sudo apt-get install -y chmsee"; smsgn "Installing chmsee"
  runCmd "sudo apt-get install -y unetbootin"; smsgn "Installing unetbootin"
  runCmd "sudo apt-get install -y zim"; smsgn "Installing zim"
  runCmd "sudo apt-get install -y diodon"; smsgn "Installing diodon"
  runCmd "sudo apt-get install -y pyrenamer"; smsgn "Installing pyrenamer"
  runCmd "sudo apt-get install -y qt5ct"; smsgn "Installing qt5ct"
  runCmd "sudo apt-get install -y qt4-qtconfig"; smsgn "Installing qt4-qtconfig"
  runCmd "sudo apt-get install -y byobu"; smsgn "Installing byobu"
  runCmd "sudo apt-get install -y mupdf mupdf-tools"; smsgn "Installing mupdf mupdf-tools"
  runCmd "sudo apt-get install -y ukuu"; smsgn "Installing ukuu"
  runCmd "sudo apt-get install -y fcrackzip"; smsgn "Installing fcrackzip"
  runCmd "sudo apt-get install -y rarcrack"; smsgn "Installing rarcrack"
  runCmd "sudo apt-get install -y pdfcrack"; smsgn "Installing pdfcrack"
  runCmd "sudo apt-get install -y figlet"; smsgn "Installing figlet"
  runCmd "sudo apt-get install -y mate-sensors-applet-nvidia"; smsgn "Installing mate-sensors-applet-nvidia"
}

function installWine () {
  msg "Installing Wine"
  runCmd "sudo add-apt-repository -y ppa:wine/wine-builds"; smsgn "Adding ppa:wine/wine-builds PPA"
  updateSystem
  msg "Installing Wine"
  runCmd "sudo apt-get install -y winehq-devel"; smsgn "Installing winehq-devel"
  runCmd "sudo apt-get install -y winetricks"; smsgn "Installing winetricks"
  runCmd "sudo apt-get install -y playonlinux"; smsgn "Installing playonlinux"
}

function installKodiBETA () {
  msg "Installing Kodi BETA"
  runCmd "sudo add-apt-repository -y ppa:team-xbmc/unstable"; smsgn "Adding Kodi BETA PPA"
  updateSystem
  runCmd "sudo apt-get install -y kodi"; smsgn "Installing kodi"
}

function installKodiNightly () {
  msg "Installing Kodi Nightly"
  runCmd "sudo add-apt-repository -y ppa:team-xbmc/xbmc-nightly"; smsgn "Adding Kodi Nightly PPA"
  updateSystem
  runCmd "sudo apt-get install -y kodi"; smsgn "Installing kodi"
}

function installGames () {
  msg "Installing Games apps and tools"
  runCmd "sudo apt-get install -y steam"; smsgn "Installing steam"
  runCmd "sudo apt-get install -y jstest-gtk"; smsgn "Installing jstest-gtk"
}

function installBurningTools () {
  msg "Installing CD/DVD/BD Burning apps and tools"
  runCmd "sudo apt-get install -y brasero"; smsgn "Installing brasero"
  runCmd "sudo apt-get install -y k3b k3b-extrathemes"; smsgn "Installing k3b k3b-extrathemes"
  runCmd "sudo apt-get install -y xfburn"; smsgn "Installing xfburn"
}

function installNetTools () {
  msg "Installing Network apps and tools"

  runCmd "sudo apt-get install -y whois"; smsgn "Installing whois"
  runCmd "sudo apt-get install -y iptraf"; smsgn "Installing iptraf"
  runCmd "sudo apt-get install -y iperf"; smsgn "Installing iperf"
  runCmd "sudo apt-get install -y wireshark tshark"; smsgn "Installing wireshark tshark"
  runCmd "sudo apt-get install -y zenmap"; smsgn "Installing zenmap"
  runCmd "sudo apt-get install -y dsniff"; smsgn "Installing dsniff"
  runCmd "sudo apt-get install -y aircrack-ng"; smsgn "Installing aircrack-ng"
}

function installCajaPlugins () {
  msg "Installing Caja extensions"

  runCmd "sudo apt-get install -y caja-share"; smsgn "Installing caja-share"
  runCmd "sudo apt-get install -y caja-wallpaper"; smsgn "Installing caja-wallpaper"
  runCmd "sudo apt-get install -y caja-sendto"; smsgn "Installing caja-sendto"
  runCmd "sudo apt-get install -y caja-image-converter"; smsgn "Installing caja-image-converter"

  if which insync >/dev/null; then
    runCmd "sudo apt-get install -y insync-caja"; smsgn "Installing insync-caja"
  fi
}

function installNautilusAndPlugins () {
  msg "Installing Nautilus and extensions"

  runCmd "sudo apt-get install -y nautilus"; smsgn "Installing nautilus"
  runCmd "sudo apt-get install -y file-roller"; smsgn "Installing file-roller"
  runCmd "sudo apt-get install -y nautilus-emblems"; smsgn "Installing nautilus-emblems"
  runCmd "sudo apt-get install -y nautilus-image-manipulator"; smsgn "Installing nautilus-image-manipulator"
  runCmd "sudo apt-get install -y nautilus-image-converter"; smsgn "Installing nautilus-image-converter"
  runCmd "sudo apt-get install -y nautilus-compare"; smsgn "Installing nautilus-compare"
  runCmd "sudo apt-get install -y nautilus-actions"; smsgn "Installing nautilus-actions"
  runCmd "sudo apt-get install -y nautilus-sendto"; smsgn "Installing nautilus-sendto"
  runCmd "sudo apt-get install -y nautilus-share"; smsgn "Installing nautilus-share"
  runCmd "sudo apt-get install -y nautilus-wipe"; smsgn "Installing nautilus-wipe"
  runCmd "sudo apt-get install -y nautilus-script-audio-convert"; smsgn "Installing nautilus-script-audio-convert"
  runCmd "sudo apt-get install -y nautilus-filename-repairer"; smsgn "Installing nautilus-filename-repairer"
  runCmd "sudo apt-get install -y nautilus-gtkhash"; smsgn "Installing nautilus-gtkhash"
  runCmd "sudo apt-get install -y nautilus-ideviceinfo"; smsgn "Installing nautilus-ideviceinfo"
  runCmd "sudo apt-get install -y ooo-thumbnailer"; smsgn "Installing ooo-thumbnailer"
  runCmd "sudo apt-get install -y nautilus-dropbox"; smsgn "Installing nautilus-dropbox"
  runCmd "sudo apt-get install -y nautilus-script-manager"; smsgn "Installing nautilus-script-manager"
  runCmd "sudo apt-get install -y nautilus-columns"; smsgn "Installing nautilus-columns"
  runCmd "sudo apt-get install -y nautilus-flickr-uploader"; smsgn "Installing nautilus-flickr-uploader"

  if which insync >/dev/null; then
    runCmd "sudo apt-get install -y insync-nautilus"; smsgn "Installing insync-nautilus"
  fi
}

function installGimpPlugins () {
  msg "Installing Gimp extensions"

  runCmd "sudo apt-get install -y gtkam-gimp"; smsgn "Installing gtkam-gimp"
  runCmd "sudo apt-get install -y gimp-gluas"; smsgn "Installing gimp-gluas"
  runCmd "sudo apt-get install -y pandora"; smsgn "Installing pandora"
  runCmd "sudo apt-get install -y gimp-data-extras"; smsgn "Installing gimp-data-extras"
  runCmd "sudo apt-get install -y gimp-lensfun"; smsgn "Installing gimp-lensfun"
  runCmd "sudo apt-get install -y gimp-gmic"; smsgn "Installing gimp-gmic"
  runCmd "sudo apt-get install -y gimp-ufraw"; smsgn "Installing gimp-ufraw"
  runCmd "sudo apt-get install -y gimp-texturize"; smsgn "Installing gimp-texturize"
  runCmd "sudo apt-get install -y gimp-plugin-registry"; smsgn "Installing gimp-plugin-registry"
}

function installRhythmBoxPlugins () {
  msg "Installing RhythmBox extensions"

  runCmd "sudo apt-get install -y rhythmbox-plugin-alternative-toolbar"; smsgn "Installing rhythmbox-plugin-alternative-toolbar"
  runCmd "sudo apt-get install -y rhythmbox-plugin-artdisplay"; smsgn "Installing rhythmbox-plugin-artdisplay"
  runCmd "sudo apt-get install -y rhythmbox-plugin-cdrecorder"; smsgn "Installing rhythmbox-plugin-cdrecorder"
  runCmd "sudo apt-get install -y rhythmbox-plugin-close-on-hide"; smsgn "Installing rhythmbox-plugin-close-on-hide"
  runCmd "sudo apt-get install -y rhythmbox-plugin-countdown-playlist"; smsgn "Installing rhythmbox-plugin-countdown-playlist"
  runCmd "sudo apt-get install -y rhythmbox-plugin-coverart-browser"; smsgn "Installing rhythmbox-plugin-coverart-browser"
  runCmd "sudo apt-get install -y rhythmbox-plugin-coverart-search"; smsgn "Installing rhythmbox-plugin-coverart-search"
  runCmd "sudo apt-get install -y rhythmbox-plugin-desktopart"; smsgn "Installing rhythmbox-plugin-desktopart"
  runCmd "sudo apt-get install -y rhythmbox-plugin-equalizer"; smsgn "Installing rhythmbox-plugin-equalizer"
  runCmd "sudo apt-get install -y rhythmbox-plugin-fileorganizer"; smsgn "Installing rhythmbox-plugin-fileorganizer"
  runCmd "sudo apt-get install -y rhythmbox-plugin-fullscreen"; smsgn "Installing rhythmbox-plugin-fullscreen"
  runCmd "sudo apt-get install -y rhythmbox-plugin-hide"; smsgn "Installing rhythmbox-plugin-hide"
  runCmd "sudo apt-get install -y rhythmbox-plugin-jumptowindow"; smsgn "Installing rhythmbox-plugin-jumptowindow"
  runCmd "sudo apt-get install -y rhythmbox-plugin-llyrics"; smsgn "Installing rhythmbox-plugin-llyrics"
  runCmd "sudo apt-get install -y rhythmbox-plugin-looper"; smsgn "Installing rhythmbox-plugin-looper"
  runCmd "sudo apt-get install -y rhythmbox-plugin-opencontainingfolder"; smsgn "Installing rhythmbox-plugin-opencontainingfolder"
  runCmd "sudo apt-get install -y rhythmbox-plugin-parametriceq"; smsgn "Installing rhythmbox-plugin-parametriceq"
  runCmd "sudo apt-get install -y rhythmbox-plugin-playlist-import-export"; smsgn "Installing rhythmbox-plugin-playlist-import-export"
  runCmd "sudo apt-get install -y rhythmbox-plugin-podcast-pos"; smsgn "Installing rhythmbox-plugin-podcast-pos"
  runCmd "sudo apt-get install -y rhythmbox-plugin-randomalbumplayer"; smsgn "Installing rhythmbox-plugin-randomalbumplayer"
  runCmd "sudo apt-get install -y rhythmbox-plugin-rating-filters"; smsgn "Installing rhythmbox-plugin-rating-filters"
  runCmd "sudo apt-get install -y rhythmbox-plugin-remembertherhythm"; smsgn "Installing rhythmbox-plugin-remembertherhythm"
  runCmd "sudo apt-get install -y rhythmbox-plugin-repeat-one-song"; smsgn "Installing rhythmbox-plugin-repeat-one-song"
  runCmd "sudo apt-get install -y rhythmbox-plugin-rhythmweb"; smsgn "Installing rhythmbox-plugin-rhythmweb"
  runCmd "sudo apt-get install -y rhythmbox-plugin-screensaver"; smsgn "Installing rhythmbox-plugin-screensaver"
  runCmd "sudo apt-get install -y rhythmbox-plugin-smallwindow"; smsgn "Installing rhythmbox-plugin-smallwindow"
  runCmd "sudo apt-get install -y rhythmbox-plugin-spectrum"; smsgn "Installing rhythmbox-plugin-spectrum"
  runCmd "sudo apt-get install -y rhythmbox-plugin-suspend"; smsgn "Installing rhythmbox-plugin-suspend"
  runCmd "sudo apt-get install -y rhythmbox-plugin-tray-icon"; smsgn "Installing rhythmbox-plugin-tray-icon"
  runCmd "sudo apt-get install -y rhythmbox-plugin-visualizer"; smsgn "Installing rhythmbox-plugin-visualizer"
  runCmd "sudo apt-get install -y rhythmbox-plugin-wikipedia"; smsgn "Installing rhythmbox-plugin-wikipedia"
  runCmd "sudo apt-get install -y rhythmbox-plugins"; smsgn "Installing rhythmbox-plugins"
}

function installPidginPlugins () {
  msg "Installing Pidgin extensions"

  runCmd "sudo apt-get install -y telegram-purple"; smsgn "Installing telegram-purple"
  runCmd "sudo apt-get install -y pidgin-skype"; smsgn "Installing pidgin-skype"
  runCmd "sudo apt-get install -y purple-facebook"; smsgn "Installing purple-facebook"
  runCmd "sudo apt-get install -y purple-hangouts"; smsgn "Installing purple-hangouts"
  runCmd "sudo apt-get install -y pidgin-hangouts"; smsgn "Installing pidgin-hangouts"
  runCmd "sudo apt-get install -y pidgin-skypeweb purple-skypeweb"; smsgn "Installing pidgin-skypeweb purple-skypeweb"
}

function installNitrogen () {
  if [[ $DESKTOP_SESSION == *"mate"* ]]; then
    msg "Installing Nitrogen"
    runCmd "sudo apt-get install -y nitrogen"; smsgn "Installing nitrogen"

    msg "Disabling Desktop management from Mate in order to make Nitrogen work properly"
    gsettings set org.mate.background draw-background false
    gsettings set org.mate.background show-desktop-icons false

    msg "Adding Nitrogen --restore to Apps launched at startup"

    sh -c "echo '[Desktop Entry]\n\
    Type=Application\n\
    Exec=bash -c \"sleep 10; nitrogen --restore\"\n\
    Hidden=false\n\
    X-MATE-Autostart-enabled=true\n\
    Name[fr_BE]=Nitrogen\n\
    Name=Nitrogen\n\
    Comment[fr_BE]=\n\
    Comment=' > /home/"$myHomedir"/.config/autostart/nitrogen.desktop"
  else
    msg "Error : only Mate Desktop is currently supported"
  fi

}

function installZsh () {
  runCmd "sudo apt-get install -y zsh"; smsgn "Installing zsh"

  msg "Installing Oh-my-Zsh"
  msh "Type exit to leave Zsh and go back to Yggdrasil script"
  cd /tmp
  rm install.sh
  wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
  chmod +x install.sh
  ./install.sh
}

function installUnbound () {
  msg "Installing Unbound"
  runCmd "sudo apt-get install -y unbound"; smsgn "Installing unbound"
}

function installThemes () {
  msg "Installing themes"

  runCmd "sudo apt-get install -y ambiance-crunchy"; smsgn "Installing ambiance-crunchy"
  runCmd "sudo apt-get install -y arc-theme"; smsgn "Installing arc-theme"
  runCmd "sudo apt-get install -y ambiance-colors"; smsgn "Installing ambiance-colors"
  runCmd "sudo apt-get install -y radiance-colors"; smsgn "Installing radiance-colors"
  runCmd "sudo apt-get install -y ambiance-flat-colors"; smsgn "Installing ambiance-flat-colors"
  runCmd "sudo apt-get install -y vivacious-colors-gtk-dark"; smsgn "Installing vivacious-colors-gtk-dark"
  runCmd "sudo apt-get install -y vivacious-colors-gtk-light"; smsgn "Installing vivacious-colors-gtk-light"
  runCmd "sudo apt-get install -y yosembiance-gtk-theme"; smsgn "Installing yosembiance-gtk-theme"
  runCmd "sudo apt-get install -y ambiance-blackout-colors"; smsgn "Installing ambiance-blackout-colors"
  runCmd "sudo apt-get install -y ambiance-blackout-flat-colors"; smsgn "Installing ambiance-blackout-flat-colors"
  runCmd "sudo apt-get install -y radiance-flat-colors"; smsgn "Installing radiance-flat-colors"
  runCmd "sudo apt-get install -y vibrancy-colors"; smsgn "Installing vibrancy-colors"
  runCmd "sudo apt-get install -y vivacious-colors"; smsgn "Installing vivacious-colors"
  runCmd "sudo apt-get install -y numix-gtk-theme"; smsgn "Installing numix-gtk-theme"
  runCmd "sudo apt-get install -y adapta-gtk-theme"; smsgn "Installing adapta-gtk-theme"
}

function installIcons () {
  msg "Installing icons"

  runCmd "sudo apt-get install -y arc-icons"; smsgn "Installing arc-icons"
  runCmd "sudo apt-get install -y ultra-flat-icons"; smsgn "Installing ultra-flat-icons"
  runCmd "sudo apt-get install -y myelementary"; smsgn "Installing myelementary"
  runCmd "sudo apt-get install -y ghost-flat-icons"; smsgn "Installing ghost-flat-icons"
  runCmd "sudo apt-get install -y faenza-icon-theme"; smsgn "Installing faenza-icon-theme"
  runCmd "sudo apt-get install -y faience-icon-theme"; smsgn "Installing faience-icon-theme"
  runCmd "sudo apt-get install -y vibrantly-simple-icon-theme"; smsgn "Installing vibrantly-simple-icon-theme"
  runCmd "sudo apt-get install -y rave-x-colors-icons"; smsgn "Installing rave-x-colors-icons"
  runCmd "sudo apt-get install -y ravefinity-x-icons"; smsgn "Installing ravefinity-x-icons"
  runCmd "sudo apt-get install -y numix-icon-theme"; smsgn "Installing numix-icon-theme"
  runCmd "sudo apt-get install -y numix-icon-theme-circle"; smsgn "Installing numix-icon-theme-circle"
}

function installPlankThemes () {
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
    msg "Plank must be installed first"
  fi
}

function installIconsExt () {
  msg "Installing extra icons pack"
  mkdir -p /home/$myHomedir/.icons && cp icons.tar.gz /home/$myHomedir/.icons && cd /home/$myHomedir/.icons && tar xzf icons.tar.gz && rm icons.tar.gz retCode $? && smsgn "Installing extra icons"
}

function installSolaar () {
  msg "Installing Solaar"
  runCmd "sudo apt-get install -y solaar"; smsgn "Installing solaar"
}

function installCardReader () {
  msg "Installing CardReader and utils"
  runCmd "sudo apt-get install -y pcscd pcsc-tools"; smsgn "Installing pcscd pcsc-tools"
}

function installEid () {
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
  sudo sh -c "echo '#deb http://files.eid.belgium.be/debian selena main\n\
  deb http://files2.eid.belgium.be/debian selena main' > /etc/apt/sources.list.d/eid.list"

  updateSystem

  msg "Installation de eID : installation de eid-mw + libacr38u"
  sudo apt-get install -y eid-mw libacr38u
}

function installEpsonV500Photo () {
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

function updateMicrocode () {
  msg "Mise à jours du Microcode du Processeur"
  oldMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
  intel=`cat /proc/cpuinfo | grep -i Intel | wc -l`
  if [ "$intel" -gt "0" ]; then
    sudo apt-get install -y intel-microcode
  fi
  newMicrocode=`cat /proc/cpuinfo | grep -i --color microcode -m 1`
  msg "Microcode passé de la version "$oldMicrocode" à la version "$newMicrocode
}

function fixWirelessIntel6320 () {
  msg "Backup du fichier iwlwifi.conf"
  sudo cp /etc/modprobe.d/iwlwifi.conf /etc/modprobe.d/iwlwifi.conf.bak

  msg "Paramètres dans iwlwifi.conf"
  echo options iwlwifi bt_coex_active=0 swcrypto=1 11n_disable=8 | sudo tee /etc/modprobe.d/iwlwifi.conf

  msg "!!! REBOOT Nécessaire !!!"
}

function installLogitechC310 () {
  msg "Installing Apps needed for Logitech C310"
  runCmd "sudo apt-get install -y guvcview"; smsgn "Installing guvcview"
  runCmd "sudo apt-get install -y cheese"; smsgn "Installing cheese"
}

function installNvidia370 () {
  msg "Installing Nvidia 370 driver"
  runCmd "sudo apt-get install -y nvidia-370 nvidia-settings nvidia-opencl-icd-370"; smsgn "Installing nvidia-370 nvidia-settings nvidia-opencl-icd-370"
}

function installNvidia375 () {
  msg "Installing Nvidia 375 driver"
  runCmd "sudo apt-get install -y nvidia-375 nvidia-settings nvidia-opencl-icd-375"; smsgn "Installing nvidia-375 nvidia-settings nvidia-opencl-icd-375"
}

function installNvidia378 () {
  msg "Installing Nvidia 378 driver"
  runCmd "sudo apt-get install -y nvidia-378 nvidia-settings nvidia-opencl-icd-378 libcuda1-378"; smsgn "Installing nvidia-378 nvidia-settings nvidia-opencl-icd-378 libcuda1-378"
}

function installDevApps () {
  msg "Installing base Dev apps and tools"

  runCmd "sudo apt-get install -y notepadqq"; smsgn "Installing notepadqq"
  runCmd "sudo apt-get install -y agave"; smsgn "Installing agave"
  runCmd "sudo apt-get install -y utext"; smsgn "Installing utext"
  runCmd "sudo apt-get install -y gpick"; smsgn "Installing gpick"
  runCmd "sudo apt-get install -y virtualbox-5.1"; smsgn "Installing virtualbox-5.1"
  runCmd "sudo apt-get install -y build-essential"; smsgn "Installing build-essential"
  runCmd "sudo apt-get install -y ubuntu-make"; smsgn "Installing ubuntu-make"
  runCmd "sudo apt-get install -y ghex"; smsgn "Installing ghex"
  runCmd "sudo apt-get install -y glade"; smsgn "Installing glade"
  runCmd "sudo apt-get install -y eric"; smsgn "Installing eric"
  runCmd "sudo apt-get install -y bluefish"; smsgn "Installing bluefish"
  runCmd "sudo apt-get install -y meld"; smsgn "Installing meld"
  runCmd "sudo apt-get install -y bluegriffon"; smsgn "Installing bluegriffon"
  runCmd "sudo apt-get install -y zeal"; smsgn "Installing zeal"
  runCmd "sudo apt-get install -y shellcheck"; smsgn "Installing shellcheck"
  runCmd "sudo apt-get install -y umbrello"; smsgn "Installing umbrello"
  runCmd "sudo apt-get install -y ack-grep"; smsgn "Installing ack-grep"
}

function installJava () {
  msg "Installing Java apps and tools"
  runCmd "sudo apt-get install -y oracle-java7-installer"; smsgn "Installing oracle-java7-installer"
  runCmd "sudo apt-get install -y oracle-java8-installer"; smsgn "Installing oracle-java8-installer"
  runCmd "sudo apt-get install -y oracle-java8-set-default"; smsgn "Installing oracle-java8-set-default"
}

function installJavaScript () {
  msg "Installing JavaScript apps and tools"

  runCmd "sudo apt-get install -y npm"; smsgn "Installing npm"
  runCmd "sudo apt-get install -y nodejs-legacy"; smsgn "Installing nodejs-legacy"
  runCmd "sudo apt-get install -y javascript-common"; smsgn "Installing javascript-common"

  if which npm >/dev/null; then
    runCmd "sudo npm install remark-lint"; smsgn "NPM Installing qt4-dev-tools"
    runCmd "sudo npm install jshint"; smsgn "NPM Installing jshint"
    runCmd "sudo npm install jedi"; smsgn "NPM Installing jedi"
  fi
}

function installPHP () {
  msg "Installing PHP apps and tools"
  runCmd "sudo apt-get install -y php7.0-cli"; smsgn "Installing php7.0-cli"
  runCmd "sudo apt-get install -y php-pear"; smsgn "Installing php-pear"
}

function installLUA () {
  msg "Installing LUA apps and tools"
  runCmd "sudo apt-get install -y luajit"; smsgn "Installing luajit"
}

function installRuby () {
  msg "Installing Ruby apps and tools"
  runCmd "sudo apt-get install -y ruby-dev"; smsgn "Installing ruby-dev"
}

function installQT () {
  msg "Installing QT Dev apps and tools"

  runCmd "sudo apt-get install -y qt4-dev-tools"; smsgn "Installing qt4-dev-tools"
  runCmd "sudo apt-get install -y qt4-linguist-tools"; smsgn "Installing qt4-linguist-tools"
  runCmd "sudo apt-get install -y qt5-doc qttools5-doc"; smsgn "Installing qt5-doc qttools5-doc"
  runCmd "sudo apt-get install -y qttools5-dev-tools"; smsgn "Installing qttools5-dev-tools"
  runCmd "sudo apt-get install -y qttools5-examples"; smsgn "Installing qttools5-examples"
  runCmd "sudo apt-get install -y qttools5-doc-html"; smsgn "Installing qttools5-doc-html"

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

function installPython () {
  msg "Installing Python Dev apps and tools"

  runCmd "sudo apt-get install -y python3-dev"; smsgn "Installing python3-dev"
  runCmd "sudo apt-get install -y python3-pip"; smsgn "Installing python3-pip"
  runCmd "sudo apt-get install -y python3-pyqt5"; smsgn "Installing python3-pyqt5"

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

    msg "PIP installing : tweepy"
    sudo pip3 install tweepy

    msg "PIP installing : droopescan"
    sudo pip3 install droopescan
  fi
}

function installAndroidEnv () {
  msg="Installing Android environment"

  msg "PATH in .bashrc"
  touch /home/$myHomedir/.bashrc
  sh -c "echo '\n\nexport PATH=${PATH}:/home/'$myHomedir'/Android/Sdk/tools:/home/'$myHomedir'/Android/Sdk/platform-tools' >> /home/$myHomedir/.bashrc"

  msg "Adding UDEV rules"
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

  msg "Restarting UDEV service"
  sudo service udev restart

  msg "Creating Android SDK shortcut"
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

function installAtom () {
  msg "Installing Atom and extensions"

  runCmd "sudo apt-get install -y atom"; smsgn "Installing atom"

  if which apm >/dev/null; then
    msg "Installing Atom extensions"

    runCmd "apm install git-status"; smsgn "APM Installing git-status"
    runCmd "apm install git-time-machine"; smsgn "APM Installing git-time-machine"
    runCmd "apm install color-picker"; smsgn "APM Installing color-picker"
    runCmd "apm install file-icons"; smsgn "APM Installing file-icons"
    runCmd "apm install language-conky"; smsgn "APM Installing language-conky"
    runCmd "apm install language-lua"; smsgn "APM Installing language-lua"
    runCmd "apm install minimap"; smsgn "APM Installing minimap"
    runCmd "apm install minimap-git-diff"; smsgn "APM Installing minimap-git-diff"
    runCmd "apm install highlight-selected"; smsgn "APM Installing highlight-selected"
    runCmd "apm install minimap-highlight-selected"; smsgn "APM Installing minimap-highlight-selected"
    runCmd "apm install pigments"; smsgn "APM Installing pigments"
    runCmd "apm install minimap-pigments"; smsgn "APM Installing minimap-pigments"
    runCmd "apm install todo-show"; smsgn "APM Installing todo-show"
    runCmd "apm install linter"; smsgn "APM Installing linter"
    runCmd "apm install linter-javac"; smsgn "APM Installing linter-javac"
    runCmd "apm install linter-csslint"; smsgn "APM Installing linter-csslint"
    runCmd "apm install linter-coffeelint"; smsgn "APM Installing linter-coffeelint"
    runCmd "apm install linter-golinter"; smsgn "APM Installing linter-golinter"
    runCmd "apm install linter-htmlhint"; smsgn "APM Installing linter-htmlhint"
    runCmd "apm install linter-lua"; smsgn "APM Installing linter-lua"
    runCmd "apm install linter-markdown"; smsgn "APM Installing linter-markdown"
    runCmd "apm install linter-flake8"; smsgn "APM Installing linter-flake8"
    runCmd "apm install linter-php"; smsgn "APM Installing linter-php"
    runCmd "apm install autocomplete-java"; smsgn "APM Installing autocomplete-java"
    runCmd "apm install dash"; smsgn "APM Installing dash"
    runCmd "apm install tree-view-autoresize"; smsgn "APM Installing tree-view-autoresize"
    runCmd "apm install tree-view-git-status"; smsgn "APM Installing tree-view-git-status"
    runCmd "apm install tree-view-git-branch"; smsgn "APM Installing tree-view-git-branch"
  fi
}

function installAnjuta () {
  msg "Installing Anjuta"
  runCmd "sudo apt-get install -y anjuta anjuta-extras"; smsgn "Installing anjuta anjuta-extras"
}

function installBrackets () {
  msg "Installing Brackets"
  runCmd "sudo apt-get install -y brackets"; smsgn "Installing brackets"
}

function installCodeBlocks () {
  msg "Installing CodeBlocks"
  runCmd "sudo apt-get install -y codeblocks codeblocks-contrib"; smsgn "Installing codeblocks codeblocks-contrib"
}

function installGeany () {
  msg "Installing Geany and extensions"
  runCmd "sudo apt-get install -y geany"; smsgn "Installing geany"
  runCmd "sudo apt-get install -y geany-plugins"; smsgn "Installing geany-plugins"
  runCmd "sudo apt-get install -y geany-plugin-markdown"; smsgn "Installing geany-plugin-markdown"
}

function installEclipse () {
  if which umake >/dev/null; then
    msg "Umake installing : Eclipse"
    sudo umake ide eclipse
  fi
}

function installIdea () {
  if which umake >/dev/null; then
    msg "Umake installing : Idea"
    sudo umake ide idea
  fi
}

function installPyCharm () {
  msg "Installing PyCharm"
  runCmd "sudo apt-get install -y pycharm"; smsgn "Installing pycharm"
}

function installVisualStudioCode () {
  if which umake >/dev/null; then
    msg "Umake installing : Visual-studio-code"
    sudo umake ide visual-studio-code
  fi
}

function installAndroidStudio () {
  if which umake >/dev/null; then
    msg "Umake installing : Android-Studio"
    sudo umake android android-studio
  fi
}

function installCAD () {
  msg "Installing CAD apps and tools"
  runCmd "sudo apt-get install -y kicad kicad-locale-fr"; smsgn "Installing kicad kicad-locale-fr"
  runCmd "sudo apt-get install -y librecad"; smsgn "Installing librecad"
  runCmd "sudo apt-get install -y freecad"; smsgn "Installing freecad"
}

function installTeamViewer7 () {
  cd /tmp

  msg "Downloading Teamviewer 7"
  wget -O teamviewer7.deb http://download.teamviewer.com/download/version_7x/teamviewer_linux_x64.deb

  msg "Installing Teamviewer 7"
  sudo dpkg -i teamviewer7.deb
  sudo apt-get install -fy
}

function enableUFW () {
  msg "Enabling FireWall (UFW)"
  runCmd "sudo ufw enable"; smsgn "Enabling ufw"
}

function addNumLockXBashrc () {
  msg "NumLockX added to MDM Init Default"

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

function enableTmpRAM () {
  msg "Modif /etc/fstab pour avoir /tmp en RAM"
  sudo sh -c "echo 'tmpfs      /tmp            tmpfs        defaults,size=2g           0    0' >> /etc/fstab"
  msg "Reboot nécessaire"
}

function addScreenfetchBashrc () {
  msg "Adding screenfetch to .bashrc"
  touch /home/$myHomedir/.bashrc
  echo "screenfetch" >> /home/"$myHomedir"/.bashrc
}

function enableHistoryTS () {
  msg "Activation du TimeStamp dans History"
  echo "export HISTTIMEFORMAT='%F %T  '" >> /home/"$myHomedir"/.bashrc
}

function toolInxi () {
  inxi -F
}

function toolSpeedtestCli () {
  if which speedtest-cli >/dev/null; then
    sudo speedtest-cli
  else
    printf "Python apps and tools + speedtest-cli app are required (PIP)"
  fi
}

function toolPacketLoss () {
  ping -q -c 10 google.com
}

function toolOptimizeFirefox () {
  msg "Optimisation des bases SQLite de Firefox"
  pressKey "Veuillez fermer Firefox AVANT de procéder, celui-ci sera killé juste après"
  pkill -9 firefox
  msg "Optimisation des bases SQLite..."
  for f in ~/.mozilla/firefox/*/*.sqlite; do sqlite3 $f 'VACUUM;'; done
  msg "Fin de l'optimisation des bases SQLite..."
}

function toolAutoremove () {
  msg "Cleaning useless deb package(s)"
  runCmd "sudo apt-get -y autoremove"; smsgn "apt-get autoremove"
}

function toolClearOldKernels () {
  msg "Removing old kernels (keeping the 2 last kernels)"
  sudo purge-old-kernels --keep 2
}

function toolSoundCardsDetection () {
  sudo alsa force-reload
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

#if [ $headless == 1 ]; then
#  msg "Headless/Batch mode enabled"
#  exit
#fi

printf "\n"
printf "$BOLDJAUNE"
printf "          __   __              _               _ _  \n"
printf "          \ \ / /             | |             (_) | \n"
printf "           \ V /__ _  __ _  __| |_ __ __ _ ___ _| | \n"
printf "$BOLDBLANC     _____ $BOLDJAUNE \ // _\` |/ _\` |/ _\` | '__/ _\` / __| | | \n"
printf "$BOLDBLANC _________ $BOLDJAUNE | | (_| | (_| | (_| | | | (_| \__ \ | | $BOLDBLANC ___________________________________\n"
printf "$BOLDJAUNE            \_/\__, |\__, |\__,_|_|  \__,_|___/_|_| $BOLDBLANC _______________________________\n"
printf "$BOLDJAUNE                __/ | __/ |                         \n"
printf "               |___/ |___/  $BOLDROUGE Customize Linux Mint 18 made easier\n"
printf "$BOLDBLANC                             ver "$version" - GPLv3 - Francois B. (Makotosan/Shakasan)\n"

printf "\n"
printf "$BOLDVERT""User (userdir) :""$NORMAL"" $myHomedir\n"
printf "$BOLDVERT""OS : ""$NORMAL"
lsb_release -d | gawk -F':' '{print $2}' | gawk -F'\t' '{print $2}'
printf "$BOLDVERT""Kernel : ""$NORMAL"
uname -r
printf "$BOLDVERT""Architecture : ""$NORMAL"
uname -m
printf "$BOLDVERT""CPU :""$NORMAL"
cat /proc/cpuinfo | grep "model name" -m1 | gawk -F':' '{print $2}'

printf "$BOLDBLANC""__________________________________________________________________________________\n""$NORMAL"
printf "\n"
osCheck
printf "\n"
depCheck

printf "$BOLDBLANC""__________________________________________________________________________________\n""$NORMAL"
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
software-sources >/dev/null

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
Wine "Wine (ppa:ubuntu-wine/ppa)" \
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
Nitrogen "Multi Screens Wallpaper App" \
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

Nitrogen)
clear; installNitrogen; pressKey;;

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
--menu "Hardware : drivers & configration" 33 95 25 \
Solaar "Solaar - Logitech Unifying Manager App" \
CardReader "CardReader pcscd app" \
eID "eID middleware" \
EpsonV500Photo "Espon V500 Photo driver + iScan + Xsane" \
Microcode "CPU Microcode update (Intel)" \
WirelessIntel6320 "Intel Centrino Advanced-N 6320 config (Bluetooth/Wifi problems)" \
LogitechC310 "Logitech C310 needed apps" \
Nvidia370 "Nvidia 370 driver" \
Nvidia375 "Nvidia 375 driver" \
Nvidia378 "Nvidia 378 driver" \
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

LogitechC310)
clear; installLogitechC310; pressKey;;

Nvidia370)
clear; installNvidia370; pressKey;;

Nvidia375)
clear; installNvidia375; pressKey;;

Nvidia378)
clear; installNvidia378; pressKey;;

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
TeamViewer7 "TeamViewer 7" \
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

TeamViewer7)
clear; installTeamViewer7; pressKey;;

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
CleanOldKernels "Removing old kernels (keeping the 2 last kernels)" \
SoundCardsDetection "Sound Cards Detection (alsa force-reload)" \
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

CleanOldKernels)
clear; toolClearOldKernels; pressKey;;

SoundCardsDetection)
clear; toolSoundCardsDetection; pressKey;;

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
