#!/bin/bash

# This script makes the shortcut links to pre-made html script :

SCRIPTS[0]="putTOC.sh"
LINKS[0]="toc"

SCRIPTS[1]="putBox.sh"
LINKS[1]="box"

SCRIPTS[2]="putLinkList.sh"
LINKS[2]="linked"

SCRIPTS[3]="putOrderList.sh"
LINKS[3]="ordered"

SCRIPTS[4]="putStrongList.sh"
LINKS[4]="strong"

SCRIPTS[5]="putTable.sh"
LINKS[5]="table"

SCRIPTS[6]="putDefinitionList.sh"
LINKS[6]="def"

SCRIPTS[7]="putEmphasize.sh"
LINKS[7]="em"

SCRIPTS[8]="putParagraph.sh"
LINKS[8]="para"

SCRIPTS[9]="putImage.sh"
LINKS[9]="img"

SCRIPTS[10]="putBold.sh"
LINKS[10]="bold"

SCRIPTS[11]="putCode.sh"
LINKS[11]="code"

SCRIPTS[12]="putDefinitionElement.sh"
LINKS[12]="defel"

SCRIPTS[13]="putCenter.sh"
LINKS[13]="cent"

SCRIPTS[14]="putTitle.sh"
LINKS[14]="tit"

SCRIPTS[15]="putLink.sh"
LINKS[15]="lnk"

SCRIPTS[16]="putSnip.sh"
LINKS[16]="sni"

SCRIPTS[17]="putFullDate.sh"
LINKS[17]="fuda"

SCRIPTS[18]="putNewsDate.sh"
LINKS[18]="newda"

SCRIPTS[19]="putRstImage.sh"
LINKS[19]="imgr"

SCRIPTS[20]="putRstLink.sh"
LINKS[20]="lnkr"


element_count=${#SCRIPTS[@]}
echo "element_count = $element_count"

index=0

while [ $index -lt $element_count ]; do

  # List all the elements in the array.

  echo "    Making new link ${LINKS[$index]} to ${SCRIPTS[$index]}"
  ln -s ${SCRIPTS[$index]} ${LINKS[$index]} 2>/dev/null
  
  let "index = $index + 1"
  
done
