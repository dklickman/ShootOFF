#! /bin/bash
# Script last edit: 20170223 by Dave K 

# Check if user is root
if [[ $EUID -ne 0 ]]; then
	printf "\n********** ERROR *********"
    printf "\nThis script needs be run as root!\n\n"
	exit 1
fi

# Directory / vars for ShootOFF Storage and tmp Storage
function createStorageVarsUsers() { 
	SHOOTOFF=~/.ShootOFF
	tmpSHOOTOFF=/tmp/ShootOFFnukeWhenDone
	pixmapsSite=/usr/share/pixmaps
	USER=$SUDO_USER
	HOME=$HOME
	mkdir $SHOOTOFF
	mkdir $tmpSHOOTOFF
	#update for future releases!
	shootOffVersion=4.0

}

function prompt1() {
	printf "\nThe begining of this installer will add the Oracle's Java SDK\n"
	printf "to your system via PPA. "
	printf "You will need to agree to the Java \nLicense Agreement in order"
	printf " to use this software!\n\n"
	read -p "Press CTRL-C to cancle out of the installer OR Press Enter to continue"
}

function prompt2() {
	printf "\n\n\n**************************************************\n"
	printf "\nShootOFF has been installed on this system!\n" 
	printf "\nIf you would like to use the software, please launch with the desktop icon\n"
	printf "or simply type ShootOFF into the terminal\n" 
	printf "\nMAKE SURE YOUR WEBCAM IS PLUGGED IN :)\n" 
	printf "\nIf you enjoy the project, please consider donating to Project Appleseed\n"
	printf "at www.appleseedinfo.org\n\n"
	printf "**************************************************\n\n\n" 
}
	
function installJava() {
	sudo add-apt-repository ppa:webupd8team/java -y 
	sudo apt-get update
	sudo apt-get -y install oracle-java8-installer 
	# during the install java8 is set as the default 
	echo "Done" 
}

function downloadShootOff() {
	echo "Downloading ShootOFF..."
	wget -c https://github.com/phrack/ShootOFF/releases/download/v$shootOffVersion-FINAL/shootoff-$shootOffVersion-final.zip -P $tmpSHOOTOFF
	echo "Done"
}
 
function extractShootOff() {
	echo "Extracting ShootOFF..."
	sudo unzip $tmpSHOOTOFF/shootoff-$shootOffVersion-final.zip -d $SHOOTOFF
	echo "Done"
}

## TODO come back to clean this function for getting the LD_PRELOAD 
function addLaunchScript() {
	echo "Adding ShootOFF launcher to /usr/local/bin..."
	
	## black magic redirect using EOL 
	cat > $tmpSHOOTOFF/ShootOFF.sh <<EOL
		#! /bin/bash
		export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libv4l/v4l1compat.so;
		cd ~/.ShootOFF;
		java -jar ShootOFF.jar;
EOL
	sudo cp $tmpSHOOTOFF/ShootOFF.sh /usr/local/bin
	echo "Done"
}


#### DESKTOP ICON CREATION #### 

function promptDesktopIcon() {
	printf "\n\n\n"
	read -p "Would you like to add a desktop icon (y/n)? " userChoice
	case $userChoice in

	        [yY] | [yY][Ee][Ss] )
	                addDesktopIcon
	                ;;

	        [nN] | [n|N][O|o] )
	                echo "Desktop Shortcut declined";
	                ;;
	        *) echo "Invalid input!, Please make a valid selection(y/n)!"
					promptDesktopIcon;
	            ;;
	esac
}

function addDesktopIcon() {
	extractDesktopIcon
	moveDesktopIconImage
	createDesktopFile 
}	


function extractDesktopIcon() {
	sudo jar xf $SHOOTOFF/ShootOFF.jar images/icon_64x64.png
	sudo mv images/icon_64x64.png $tmpSHOOTOFF
	sudo rmdir $SHOOTOFF/images
}

function moveDesktopIconImage() { 
		sudo cp $tmpSHOOTOFF/icon_64x64.png $pixmapsSite
		sudo mv $pixmapsSite/icon_64x64.png $pixmapsSite/ShootOFFicon.png
}

function createDesktopFile() {
	cat > $tmpSHOOTOFF/ShootOFF.desktop <<EOL
		[Desktop Entry]
		Version=3.10
		Name=ShootOFF
		Comment=Launch ShootOFF script from /usr/local/bin 
		Exec=ShootOFF.sh
		Icon=ShootOFFicon
		Terminal=false
		Type=Application
		Categories=Application
EOL
	cp $tmpSHOOTOFF/ShootOFF.desktop $HOME/Desktop
	# have to add +x here in case user does not select add Desktop Shortcut
	sudo chmod +x $HOME/Desktop/ShootOFF.desktop 
	echo "Done" 
}


#### END DESKTOP ICON CREATION #### 



## I'm leaving this verbose because I'm assuming there will be changes 
function updatePermissions() {
	echo "Updating File Permissions..."
	sudo chmod 644 $SHOOTOFF/shootoff.properties
	sudo chmod 644 $SHOOTOFF/ShootOFF-diagnostics.jar
	sudo chmod +x $SHOOTOFF/ShootOFF.jar 
	sudo chmod +x /usr/local/bin/ShootOFF.sh
	sudo chown -R $USER:$USER $SHOOTOFF 
	echo "Done"
}

function cleanUpFiles() {
	printf "\nCleaning up file system and deleting old files...\n"
	sudo rm -rv $tmpSHOOTOFF
	echo "Done"
}

###### Sequential execution of script ######
createStorageVarsUsers
prompt1
installJava
downloadShootOff
extractShootOff
addLaunchScript
promptDesktopIcon
updatePermissions
#cleanUpFiles  still leaving blank until testing is complete 
prompt2

