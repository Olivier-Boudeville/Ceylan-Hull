#!/bin/sh

LANConfigScript="/etc/init.d/setLANBox.sh"
GatewayConfigScript="/etc/init.d/setGatewayBox.sh"

TMP_FILE='/etc/init.d/asnwer.txt'

if [ -x /usr/bin/beep ]; then
  beep -f 1000 -n -f 2000 -n -f 1500
fi

dialog --title "Sye's configuration" --menu "Choose Debian aranor's role:" 15 55 2 "1" "Gateway (requires the ADSL modem)"  "2" "Pure LAN client" 2> $TMP_FILE


# Default: gateway 
if [ `cat $TMP_FILE` = "2" ]; then

	if [ -x "$LANConfigScript" ]; then
		$LANConfigScript
	else
		echo "No configuration script for LAN Box !"
	fi	
else
	if [ -x "$GatewayConfigScript" ]; then
		$GatewayConfigScript
	else
		echo "No configuration script for gateway Box !"
	fi		
fi

rm $TMP_FILE

echo "Net has been configured according to aranor's standards."


