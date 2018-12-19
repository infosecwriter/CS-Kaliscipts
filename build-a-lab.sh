#!/bin/bash
# Build-a-lab (KVM/VirtualBox) v0.1.2
# Coded by: Cyber Secrets - Information Warfare Center
# Github: https://github.com/infosecwriter
# This just sets up the environment for KVM or VirtualBox and has a few extra items

trap 'printf "\n"; stop 1; exit 1' 2
clear

trap 'printf "\n"; stop 1; exit 1' 2
clear

startmenu() {
	banner
	printf "\e[92m  Building a Lab with KVM and/or VirtualBox...\n"
	printf "  Install Libvirt/KVM                                        =  1\n"
	printf "  Run Virt-Manager                                           =  2\n"
	printf "  List KVM Virtual Machines                                  =  3\n"
	printf "  Start a headless KVM Virtual Machine                       =  4\n"
	printf "  Stop a headless KVM Virtual Machine                        =  5\n"
	printf "  Install VirtualBox                                         = 11\n"
	printf "  Run VirtualBox                                             = 12\n"
	printf "  List VirtualBox Virtual Machines                           = 13\n"
	printf "  Start a headless VirtualBox Virtual Machine                = 14\n"
	printf "  Stop a headless VirtualBox Virtual Machine                 = 15\n"
	printf "  Convert VM file type                                       = 90\n"
	printf "  Compress VM file                                           = 91\n"
	printf "  Exit and keep services running                             = 99\n"
	printf "\n"
	read -p $'  Choose an option: \e[37;1m' option
	case $option in
		99) 	stop 1;;
		1|01) 	sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove && sudo apt install qemu-kvm libvirt-clients qemu-utils libvirt-daemon-system virt-manager; startmenu ;;
		2|02) 	virt-manager; startmenu ;;
		3|03) 	virsh list --all | tee VMs.txt; read -p $'Press enter to continue.' val; startmenu ;;
		4|04) 	read -p $'Name the VM you want to start: ' val; virsh start $val && startmenu ;;
		5|05) 	read -p $'Name the VM you want to shutdown: ' val; virsh destroy $val && startmenu ;;


		11) 	sudo apt-get update
			sudo apt-get dist-upgrade -y
			sudo apt-get autoremove -y
			sudo apt-get -y install gcc make linux-headers-$(uname -r) dkms
			sudo apt-get -y install virtualbox virtualbox-ext-pack 		
			startmenu;;
		12) 	virtualbox &
			startmenu ;;
		13) 	VBoxManage list vms | tee VMs.txt; read -p $'Press enter to continue.' val; startmenu ;;
		14) 	read -p $'Name the VM you want to start: ' val; VBoxManage startvm "$val" --type headless && startmenu ;;
		15) 	read -p $'Name the VM you want to shutdown: ' val; VBoxManage controlvm "$val" poweroff --type headless && startmenu ;;

		90) 	read -p $'  File type to convert to "qcow2, vmdk, vdi, raw":' vmtype; 
			read -p $'  File to convert from: ' vmif;
			read -p $'  Output file name:' vmof;
			qemu-img convert -c -O $vmtype $vmif $vmof; read 'Press enter to continue.'; 
			startmenu ;; 
		91) 	read -p $'  File type to compress "qcow2, vmdk, vdi, raw": ' vmtype; 
			read -p $'  File to convert from: ' vmif;
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
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m Build-a-Lab with KVM or VirtualBox              \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m Tool coded by: @InfoSecWriter                   \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m https://github.com/infosecwriter/               \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\e[1;93m    .:.:.\e[0m\e[1;77m CyberSecrets.org : IntelligentHacking.com       \e[0m\e[1;93m.:.:.\e[0m\n"
	printf "\n"
	printf "  \e[101m\e[1;77m:: Disclaimer: Developers assume no liability and are not    ::\e[0m\n"
	printf "  \e[101m\e[1;77m:: responsible for any misuse or damage caused by user...    ::\e[0m\n"
	printf "\n"
}

banner
startmenu
