#! /bin/bash

# Check if user is root
if [[ $EUID -ne 0 ]]; then
	printf "\n********** ERROR *********"
    printf "\nThis script needs be run as root!\n\n"
	exit 1
fi

# Directory / vars for ShootOFF Storage and tmp Storeage
SHOOTOFF=~/.ShootOFF
tmpSHOOTOFF=/tmp/ShootOFFnukeWhenDone
mkdir $SHOOTOFF
mkdir $tmpSHOOTOFF
USER=$USER


<<"COMMENT2" 
# adding the additional java repository promt at the front as I assume 
# users are going to be paying the most attention during the 
# initial run of the script ie. no hanging scripts waiting on 
# user interaction.  We can automate but I think that takes the
# control away from the user and their system..?  
COMMENT2

printf "\nThe begining of this installer will add the Oracle Java SDK to your system via PPA.\n"
printf "By pressing the return key, you are accepting the Java License Agreement!\n\n"
read -p "Press CTRL-C to cancle out of the installer OR Press Enter to continue"


# We are automating the acceptance of the license here...is that acceptable / legal? 
# xdg-open http://www.oracle.com/technetwork/java/javase/terms/license/index.html

sudo add-apt-repository ppa:webupd8team/java -y 
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer 


printf "\n\nDownloading ShootOFF packages...\n"

# Download the .zip to the tmp folder TODO: need a cleaner target for the 
# URL source so I don't have to manually update the script.  As in pull and 
# sync to var each time the script is run...REGEX it off the website?
# and check with 
wget -c https://github.com/phrack/ShootOFF/releases/download/v3.10-FINAL/shootoff-3.10-final.zip -P $tmpSHOOTOFF

# add a check to ensure the file size is greater than ~110MB?  If not call wget again?
#  I don't think I don't want to maintain checksums on this
echo "ShootOFF successfully downloaded..."

echo "Unpacking ShootOFF..." 
# extract the zip to $SHOOTOFF
unzip $tmpSHOOTOFF/shootoff-3.10-final.zip -d $SHOOTOFF

# Give permission to read/write to shootoff.properties 
# Somebody tell me if 777'ing this file is no bueno please??? 
echo "Updating permissions..."

# quick fix for getting ownership back into user's domain, I think this can be fixed 
# with a sudo -u on the creation of the directory $SHOOTOFF? 
sudo chown -R $USER:$USER $SHOOTOFF 
sudo chmod 777 $SHOOTOFF/shootoff.properties
sudo chmod 777 $SHOOTOFF/ShootOFF.jar

echo "Adding ShootOFF function to .bashrc..."
#add function to bashrc to run ShootOFF from the command line 
cat > $tmpSHOOTOFF/updateBashRC.txt <<EOL
function ShootOFF() {
	export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libv4l/v4l1compat.so;
	cd ~/.ShootOFF	
	java -jar ShootOFF.jar;
}
EOL
# adding function from $tmpSHOOTOFF into user's bashrc @ 644
cat $tmpSHOOTOFF/updateBashRC.txt >> ~/.bashrc


# TODO: create this function for ubuntu support only at this time
# perhaps in the future we can add gnome, kde, xfce, and MATE
echo""
read -p  "Would you like to create a desktop shortcut (yes/no)?"
# add desktop icon 


printf "\nCleaning up file system and deleting old files...\n"
#sudo rm -rv $tmpSHOOTOFF

# reload .bashrc
source ~/.bashrc

printf "\n\n\n**************************************************\n"
printf "ShootOFF has been installed on this system!\n" 
printf "\nIf you would like to use the software please launch with the desktop icon\n"
printf "or simply type ShootOFF into the terminal\n" 
printf "MAKE SURE YOUR WEBCAM IS PLUGGED IN :)\n" 
printf "\nIf you enjoy the project, please consider donating to Project Appleseed\n"
printf "at www.appleseedinfo.org\n\n"
printf "**************************************************\n\n\n"

















