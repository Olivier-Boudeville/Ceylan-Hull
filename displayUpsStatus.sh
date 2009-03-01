#!/bin/sh


UPS_NAME="myBelkin"
UPS_SERVER="aranor"


echo "Displaying state of UPS ${UPS_NAME}@${UPS_SERVER}: "
/bin/upsc ${UPS_NAME}@${UPS_SERVER}

