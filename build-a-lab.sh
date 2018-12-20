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
	printf "\e[92m  Build-a-Lab with KVM or VirtualBox...\n"
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
	printf "  Download Metasploitable2                                   = 50\n"
	printf "  Convert VM file type                                       = 90\n"
	printf "  Compress VM file                                           = 91\n"
	printf "  Remove KVM/VirtualBox                                      = 98\n"
	printf "  Exit                                                       = 99\n"
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

		50) 	
			FILE="temp/metasploitable-linux-2.0.0.zip"
			FOLDER="Metasploitable2-Linux"
			VMNAME="Metasploitable"
			if [ ! -f $FILE ]; then
			   	mkdir temp; wget -P temp https://download.vulnhub.com/metasploitable/metasploitable-linux-2.0.0.zip
				unzip -d temp $FILE
			else
			   	echo "File $FILE exist."
			fi
			read -p $'  Set up for ONLY KVM (1) or VirtualBox (2): \e[37;1m' vmoption
			case $vmoption in
			1|01)	pwd; makekvm temp/$FOLDER $VMNAME && virt-manager ;;
			2|02)	makevb && virtualbox ;;
			*)
			;;
			esac ;;
		90) 	read -p $'  File type to convert to "qcow2, vmdk, vdi, raw":' vmtype; 
			read -p $'  File to convert from: ' vmif;
			read -p $'  Output file name:' vmof;
			qemu-img convert -c -O $vmtype $vmif $vmof; read 'Press enter to continue.'; 
			startmenu ;; 
		91) 	read -p $'  File type to compress "qcow2, vmdk, vdi, raw": ' vmtype; 
			read -p $'  File to convert from: ' vmif;
			qemu-img convert -c -O $vmtype $vmif $vmif-1 && rm $vmif && mv $vmif-1 $vmif; read 'Press enter to continue.'; 
			startmenu ;; 

		98) 	read -p $'  Remove KVM (1) or VirtualBox (2): ' vmremove
			case $vmremove in
			1|01)	sudo apt purge qemu-kvm libvirt-clients qemu-utils libvirt-daemon-system virt-manager && startmenu ;;
			2|02)	sudo apt purge virtualbox virtualbox-ext-pack && startmenu ;;
			*)
			startmenu ;; 
			esac ;;

  		*)
		printf "\e[1;93m [!] Invalid option!\e[0m\n"
		clear
		startmenu
		;;
	esac
}

makekvm() {
pwd
	mkdir ~/VMs
	VFILE="~/VMs/Metasploitable.qcow2"
	if [ ! -f $VFILE ]; then
		printf "Building KMV qcow2 disk\n"
		pwd
		ls $1/
	   	qemu-img convert -c -O qcow2 $1/$2.vmdk ~/VMs/$2.qcow2 
	else
	   	echo "File $VFILE exist."
	fi
	virt-install --name=Metasploitable2-Linux --vcpus=1 --memory=1024 --disk ~/VMs/Metasploitable.qcow2,size=8 --os-type linux --os-variant generic --network bridge=virbr0 --graphics spice,listen=127.0.0.1 --console pty,target_type=serial --import 
# virt-install --name=Metasploitable2-Linux --vcpus=1 --memory=512 --disk ~/VMs/Metasploitable.qcow2,size=8 --os-type linux --os-variant generic --network bridge=virbr0 --graphics spice,listen=127.0.0.1 --console pty,target_type=serial --virt-type=qemu --import
}

makevb() {
	mkdir ~/VirtualBox\ VMs/Metasploitable2-Linux
	printf "Building VirtualBox disk\n"
	cp temp/$1/$2.vmdk ~/VirtualBox\ VMs/$1
	cd ~/VirtualBox\ VMs
	VBoxManage createvm --name Metasploitable2-Linux --ostype Linux --register
	VBoxManage modifyvm Metasploitable2-Linux --memory 512
	modifyvm Metasploitable2-Linux --vtxvpid off
	VBoxManage storagectl Metasploitable2-Linux --name "IDE Controller" --add ide --controller PIIX4
	VBoxManage storageattach Metasploitable2-Linux --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium Metasploitable2-Linux/Metasploitable.vmdk
	VBoxManage startvm Metasploitable2-Linux

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
	printf "  \e[101m\e[1;77m:: VirtualBox does not play well with KVM.                   ::\e[0m\n"
	printf "  \e[101m\e[1;77m:: Pick KVM or VirtualBox or run VirtualBox first...         ::\e[0m\n"
	printf "\n"
}

banner
startmenu
