#!/bin/bash
# Build-a-lab (KVM) v0.1
# Coded by: Cyber Secrets - Information Warfare Center
# Github: https://github.com/infosecwriter
# This just sets up the environment for KVM and has a few extra items

trap 'printf "\n"; stop 1; exit 1' 2
clear

startmenu() {
	banner
	printf "\e[92m  Building a Lab with Libvirt and Virt-Mannager...\n"
	printf "  Install Libvirt/KVM                                        =  1\n"
	printf "  Run Virt-Manager                                           =  2\n"
	printf "  List Virtual Machines                                      =  3\n"
	printf "  Start a Virtual Machine                                    =  4\n"
	printf "  Convert VM file type                                       = 10\n"
	printf "  Compress VM file                                           = 11\n"
	printf "  Exit and keep services running                             = 99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	case $option in
		99) 	stop 1;;
		1|01) 	apt update && apt upgrade && apt install qemu-kvm libvirt-clients qemu-utils libvirt-daemon-system virt-manager; startmenu
			;;
		2|02) 	virt-manager; startmenu ;;
		3|03) 	virsh list --all | tee VMs.txt; read -p $'Press enter to continue.' val; startmenu ;;
		4|04) 	read -p $'Name the VM you want to start' val; virsh start $val && startmenu ;;


		10) 	read -p $'  File type to convert to "qcow2, vmdk, vdi, raw":' vmtype; 
			read -p $'  File to convert from:' vmif;
			read -p $'  Output file name:' vmof;
			qemu-img convert -c -O $vmtype $vmif $vmof; read 'Press enter to continue.'; 
			startmenu ;; 
		11) 	read -p $'  File type to compress "qcow2, vmdk, vdi, raw":' vmtype; 
			read -p $'  File to convert from:' vmif;
			qemu-img convert -c -O $vmtype $vmif $vmif-1 && rm $vmif && mv $vmif-1 $vmif; read 'Press enter to continue.'; 
			startmenu ;; 
  		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		clear
		startmenu
		;;
	esac
}

stop() {
# 	Cleaning up your mess
	printf "\nCleaning up\n"
}

banner() {
	clear
	printf "\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m Libvirt/KVM tool coded by: @InfoSecWriter       \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m https://github.com/infosecwriter/               \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m CyberSecrets.org : IntelligentHacking.com       \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\n"
	printf "  \e[101m\e[1;77m:: Disclaimer: Developers assume no liability and are not    ::\e[0m\n"
	printf "  \e[101m\e[1;77m:: responsible for any misuse or damage caused by user...    ::\e[0m\n"
	printf "\n"
}

banner
startmenu
