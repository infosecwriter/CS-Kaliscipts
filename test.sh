#!/bin/bash
# comment tag
# Basic script to show how to use functions, banners, grab information, and case statements

trap 'printf "\n"; stop 1; exit 1' 2
clear

banner() {
	clear
	printf "\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m Banner                                          \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\n"
	printf "  \e[101m\e[1;77m:: Disclaimer: Developers assume no liability and are not    ::\e[0m\n"
	printf "  \e[101m\e[1;77m:: responsible for any misuse or damage caused by user...    ::\e[0m\n"
	printf "\n"
}

startmenu() {
	printf "\e[92m  Options...\n"
	printf "  Something 1                                                =  1\n"
	printf "  Something 2                                                =  2\n"
	printf "  Update Debian base                                         =  3\n"
	printf "  Install Cyber Secrets Quick Tunnel                         =  4\n"
	printf "  Exit                                                       =  99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	case $option in
		99) 	stop 1 ;;
		1|01) 	banner
			printf "\e[92m  This is option 1...\n"
			startmenu
			;;
		2|02) 	banner; printf "\e[92m  This is option 2...\n"; startmenu ;;
		3|03) 	banner; printf "\e[92m  Updating Debian base...\n"; sudo apt update && sudo apt upgrade -y && sudo apt autoclean; startmenu ;;
		4|04) 	banner; printf "\e[92m  Installing Cyber Secrets Quick Tunnel...\n"
			sudo apt install git 
			git clone https://github.com/infosecwriter/CS-QuickTunnel.git
			cd CS-QuickTunnel
			bash CS-QuickTunnel.sh
			banner
			startmenu 
			;;
  		*)
		
		clear
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		startmenu
		;;
	esac
}

stop() {
printf "\e[1;93m [!] Exiting!\e[0m\n\n"
exit
}
banner
startmenu
