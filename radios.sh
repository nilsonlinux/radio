#!/bin/bash
#
#
# bash_radio_gr - ακούστε online ραδιόφωνο από το τερματικό
# Copyright (c)2018 Vasilis Niakas and Contributors
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License.
#
# Please read the file LICENSE and README for more information.
#
#
while true
do
terms=0
trap ' [ $terms = 1 ] || { terms=1; kill -TERM -$$; };  exit' EXIT INT HUP TERM QUIT 

if [ "$#" -eq "0" ]		    #se nenhum argumento for fornecido, ele obtém o arquivo padrão
	then
	stations="gr_stations.txt"
	else
	stations=$1
fi

player=$(command -v mpv 2>/dev/null || command -v mplayer 2>/dev/null || command -v mpg123 2>/dev/null || echo "1")

if [[ $player = 1 ]];
	then
	echo "Nenhum player compatível encontrado, players compatíveis são mplayer e mpv"
	exit
fi

info() {
tput civis      -- invisible  # Εξαφάνιση cursor
echo -ne "| Hora certa "$(date +"%T")"\n| Você está ouvindo a rádio ("$stathmos_name")\n| Pressione Q/q para sair ou R/r para retornar à lista de estações"
}
echo "---------------------------------------------------------"
echo " _   _ _ _                 _ _                  
| \ | (_) |___  ___  _ __ | (_)_ __  _   ___  __
|  \| | | / __|/ _ \| '_ \| | | '_ \| | | \ \/ /
| |\  | | \__ \ (_) | | | | | | | | | |_| |>  < 
|_| \_|_|_|___/\___/|_| |_|_|_|_| |_|\__,_/_/\_\ "
echo "---------------------------------------------------------"
echo "https://github.com/billniakas/bash_radio_gr"

while true 
do
echo "---------------------------------------------------------"
num=0 

while IFS='' read -r line || [[ -n "$line" ]]; do
    num=$(( $num + 1 ))
    echo "["$num"]" $line | cut -d "," -f1
done < $stations
echo "---------------------------------------------------------"
read -rp "Selecionar a estação (Q/q para sair): " input

if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
	echo "Sair ..."
	tput cnorm   -- normal  # Εμφάνιση cursor
	exit 0
fi

if [ $input -gt 0 -a $input -le $num ]; #verifique se a entrada está dentro do alcance da lista de estações
	then
	stathmos_name=$(cat $stations | head -n$(( $input )) | tail -n1 | cut -d "," -f1)
	stathmos_url=$(cat $stations | head -n$(( $input )) | tail -n1 | cut -d "," -f2)
	break
	else
	echo "Digite a numeração referênte a rádio que deseja ouvir."
	sleep 2
	clear
fi
done

$player $stathmos_url &> /dev/null &
while true

do 
	   clear 
	   info
	   sleep 0
	   read -n1 -t1 input          #Por menos espera de leitura
	   if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   		then
		clear
		echo "Sair ..."
		tput cnorm   -- normal  # Mostrar cursor
           	exit 0
           fi

	   if [[ $input = "r" ]] || [[ $input = "R" ]]
		then
		killall -9 $player &> /dev/null
		clear
		echo "Retornar à lista de estações"
		tput cnorm   -- normal  # Mostrar cursor
		sleep 2
		clear
		break


		
	   fi
done

done
