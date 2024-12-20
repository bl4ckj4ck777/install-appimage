This is meant to be used in Ubuntu 24.04 in order to take AppImage files
and turn them into fully functional Apps that can be launched from the 
launcher menu and pinned to the dash just like normal apps. 

INSTALLATION:
In order to use this script you must:
1. Put the *.AppImage file in the same directory as the install-appimage.sh file
2. Replace the *.svg icon file with whatever icon you would like to use
	(you may skip this step if you want to use the default icon provided)
	(I recommend Inkscape to modify the icon file if you want to create
	 your own, that way it will already be the right dimensions for 
	 Ubuntu and will display correctly in the dash)
3. Run the script using sudo. This should look like:
	sudo bash install-appimage.sh
	
	You will obviously need to have a terminal open to the location of the script. 
4. Enter the information asked for by the script in the terminal. 

If all goes well, this should work without any further intervention. The 
script will set all the permissions and move all the files to the correct
locations automatically. 

To UNINSTALL:
1. (Optional) Follow step 1 of installation. This will allow the script to 
	automatically figure out the name of the application to uninstall. Otherwise 
	it will look at the .desktop files that have been installed and ask you to
	choose one. 
2. Run the uninstall script using sudo from a terminal in the correct directory:
	sudo bash uninstall-appimage.sh
3. Follow the instructions in the terminal. 
