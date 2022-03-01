#!/bin/bash
# author : oussama ben salem.

TTY=$(tty|sed 's/\/dev\///g')
CORE=""
PORTS=""


function port_to_process() {
local cmd="sudo netstat -nlpen |grep -i 'listen\ '|awk '{ print $4 }' |grep -oP '(?<=\:)\d+' |sort -n |uniq"
for port in $(eval $cmd)
do
process_cmd="echo $(ps aux |grep $(sudo lsof -t -i tcp:$port|head -1))"
IFS=$'\n'
CORE+=($(eval ${process_cmd} 2>/dev/null))
PORTS+=( $port )
# echo $CORE
done
}

function banner() {
printf "$(tput bold)%s\t%s\t%s\t%s\t%s\t%s\t%s$(tput sgr0)\n\
---------------------------------------------------------\n" "PORT" "PID" "USER" "%CPU" "%MEM" "TTY" "PATH"
}

function parser() {
for i in $(seq 1 1 ${#CORE[@]})
do
if [[ ${CORE[i]} != "" ]];then
port=$(echo ${PORTS[i]})
user=$(echo ${CORE[i]}|awk '{ print $1 }')
pid=$(echo ${CORE[i]}|awk '{ print $2 }')
cpu=$(echo ${CORE[i]}|awk '{ print $3 }')
mem=$(echo ${CORE[i]}|awk '{ print $4 }')
tty=$(echo ${CORE[i]}|awk '{ print $7 }')
path=$(pwdx $(echo "$pid")|awk '{ print $2 }')
if [[ $(echo "$path") != "/" ]];then
	if [[ $user =~ "root" ]];then
		printf "$(tput bold)%s$(tput sgr0)\t$(tput setaf 2)%s$(tput sgr0)\t$(tput bold)$(tput setaf 1)%s$(tput sgr0)\t%s\t%s\t%s\t%s\n" \
		"$port" \
		"$pid" \
		"$user" \
		"$cpu" \
		"$mem" \
		"$tty" \
		"$path"
	else
		printf "$(tput bold)%s$(tput sgr0)\t$(tput setaf 2)%s$(tput sgr0)\t%s\t%s\t%s\t%s\t%s\n" \
		"$port" \
		"$pid" \
		"$user" \
		"$cpu" \
		"$mem" \
		"$tty" \
		"$path"
	fi
fi
fi
done
}

function main() {
	if [[ $UID -eq 0 ]]; then
		port_to_process
		banner
		parser $CORE
	else
		printf "\n$(tput bold)$(tput setaf 1)[-] %s\n$(tput sgr0)\n" "You must run with root."
	fi
}



# call main function.
main