#!/bin/bash
test="curl ipinfo.io/ip"
$test > findme
nmap -Pn -A -T5 -sTU -p- -vvv -iL findme