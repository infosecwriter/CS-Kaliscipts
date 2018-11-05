#!/bin/bash
# kalitor v0.1
# Coded by: Cyber Secrets - Information Warfare Center
# Tool for Red Team ops
# Creates a user for the Tor Browser, downloads Tor, and then runs it.

	hostname="cybersecrets.org"
	# Installing Tor browser
	printf "   Testing the address through a the Tor Browser Bundle...  \n   Please be patient...\n   This may take a few minutes...\n"
	apt update
	apt install tor 
	apt install apparmor-utils
	systemctl stop tor
	aa-complain system_tor
	systemctl start tor
	
	toruser=`cat /etc/passwd | grep -i "kalitor:" | cut -d ":" -f 1`
	if [[ $toruser == "kalitor" ]]; then
		printf "   User found\n"
	else
		useradd -m kalitor -G sudo -s /bin/bash && echo -e "kalitor\nkalitor\n" | passwd kalitor
		xhost si:localuser:kalitor
	fi
	if [[ -e /home/kalitor/tor-browser_en-US/start-tor-browser.desktop ]]; then
		# Stalling while route is built to Tor2Web
		tortimex=0
		while [ $tortimex != 30 ]
		do
			sleep 1
			printf "|"
			let tortimex++
		done
		curdir=$(pwd)
		cd /home/kalitor/tor-browser_en-US/
		printf "\n"; sudo -u kalitor -H ./start-tor-browser.desktop $hostname
		cd $curdir

	else
		printf "Downloading the Tor Browser for ease of use"
		rm tor-browser-linux64-8.0.3*
		wget https://www.torproject.org/dist/torbrowser/8.0.3/tor-browser-linux64-8.0.3_en-US.tar.xz
		chown kalitor tor-browser-linux64-8.0.3_en-US.tar.xz
		curdir=$(pwd)
		sudo -u kalitor -H tar -xvJf tor-browser-linux64-8.0.3_en-US.tar.xz -C /home/kalitor/
		cd /home/kalitor/tor-browser_en-US/
		sudo -u kalitor -H ./start-tor-browser.desktop http://ipinfo.io $hostname
		cd $curdir
	fi
