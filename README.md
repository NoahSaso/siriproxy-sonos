siriproxy-sonos
===============

Plugin for SiriProxy that lets you control your sonos system. Setup for plugin and webserver below.

Setup
=====

1. Clone this repository into your plugins folder ("git clone https://github.com/noahsaso/siriproxy-sonos.git") and then copy the contents of config-info.yml into your config.yml under plugins like normal. Remove any rooms that you aren't using.

2. Install a webserver on the local machine. (Linux)

	1. In terminal, run "sudo apt-get install apache2 php5 libapache2-mod-php5".
	1a. If you are getting an error when trying to start apache2, run "mkdir /run/lock", then run "sudo service apache2 restart".
	2. Now run "sudo nano /etc/apache2/mods-enabled/dir.conf". Add a space after "DirectoryIndex" and put "index.php".

3. Make sure you are inside siriproxy-sonos (which is inside your plugins folder). In terminal, run "mv web /var/www/sonos".

4. Get the IP Adresses of your sonos systems and put them in the webserver files.

	1. In terminal, run "sudo nano /var/www/index.php".
	2. You should see a line that starts with "$zones = array".
	3. Edit that line so it has the same names as the config file for this plugin, and the corresponding IP addresses for each zone.
	4. If you aren't using all 6 zones (which you probably won't), then just leave the other ones alone.

5. All Done!
