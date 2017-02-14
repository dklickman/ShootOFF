#! /bin/bash

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
	mkdir $SHOOTOFF
	mkdir $tmpSHOOTOFF
	USER=$USER
	#update for future releases!
	shootoffVersion=3.10

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
	printf "ShootOFF has been installed on this system!\n" 
	printf "\nIf you would like to use the software please launch with the desktop icon\n"
	printf "or simply type ShootOFF into the terminal\n" 
	printf "MAKE SURE YOUR WEBCAM IS PLUGGED IN :)\n" 
	printf "\nIf you enjoy the project, please consider donating to Project Appleseed\n"
	printf "at www.appleseedinfo.org\n\n"
	printf "**************************************************\n\n\n" 
}
	


function installJava() {
	sudo add-apt-repository ppa:webupd8team/java -y 
	sudo apt-get update
	sudo apt-get -y install oracle-java8-installer 
	# during the install java8 is set as the default 
}

function downloadShootOff() {
	echo "Downloading ShootOFF..."
	wget -c https://github.com/phrack/ShootOFF/releases/download/v3.10-FINAL/shootoff-$shootoffVersion-final.zip -P $tmpSHOOTOFF
	echo "Done"
}
 
function extractShootOff() {
	echo "Extracting ShootOFF"
	unzip $tmpSHOOTOFF/shootoff-$shootoffVersion-final.zip -d $SHOOTOFF
	echo "Done"
}

 

function updatePermissions() {
	echo "Updating File Permissions..."
	sudo chown -R $USER:$USER $SHOOTOFF 
	sudo chmod 666 $SHOOTOFF/shootoff.properties
	sudo chmod 666 $SHOOTOFF/ShootOFF-diagnostics.jar
	#sudo chmod $SHOOTOFF/
	sudo chmod +x $SHOOTOFF/ShootOFF.jar
	echo "Done"
}

## TODO come back to this function for getting the LD_PRELOAD set up correctly 
# for other distribution
function addTerminalLaunch() {
	echo "Adding ShootOFF function to .bashrc..."
	cat > $tmpSHOOTOFF/updateBashRC.txt <<EOL
	function ShootOFF() {
		export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libv4l/v4l1compat.so;
		cd ~/.ShootOFF	
		java -jar ShootOFF.jar;

EOL
	cat $tmpSHOOTOFF/updateBashRC.txt >> ~/.bashrc
}


function cleanUpFiles() {
	printf "\nCleaning up file system and deleting old files...\n"
	sudo rm -rv $tmpSHOOTOFF
	source ~/.bashrc
	echo "Done"
}




# TODO: Add a desktop icon launcher // I need help here
# read -p  "Would you like to create a desktop shortcut (yes/no)?"
 

###### Sequential execution of script ######
createStorageVarsUsers
prompt1
installJava
downloadShootOff
extractShootOff
updatePermissions
addTerminalLaunch
# leaving out cleanUpFiles() until testing complete cause satellite internet
# is quite a burden 
prompt2


