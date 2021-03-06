#!/bin/bash
# Copyright (c) 2018-2020 The GOSSIP developers

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BLINK='\e[5m'
NBLINK='\e[0m'
NC='\033[0m'

clear

if [[ $(lsb_release -d) == *20.04* ]]; then
  UBUNTU_VERSION=OK
  else
    echo -e "----------------------------------------------------------------------------------"
    echo -e "${RED}You are not running Ubuntu 20.04. Why? Installation is now cancelled.${NC}  "
    echo -e "----------------------------------------------------------------------------------"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo -e "------------------------------------"
  echo -e "${RED}$0 must be run as root.${NC}  "
  echo -e "------------------------------------"
  exit 1
fi

function start_inst() {
echo -e "${BLUE}"
echo -e ""
cat << 'EOF'
  _____  _                 _                    __  __           _                            _            
 |  __ \| |               | |                  |  \/  |         | |                          | |          
 | |__) | |__   __ _ _ __ | |_ ___  _ __ ___   | \  / | __ _ ___| |_ ___ _ __ _ __   ___   __| | ___  ___ 
 |  ___/| '_ \ / _` | '_ \| __/ _ \| '_ ` _ \  | |\/| |/ _` / __| __/ _ \ '__| '_ \ / _ \ / _` |/ _ \/ __|
 | |    | | | | (_| | | | | || (_) | | | | | | | |  | | (_| \__ \ ||  __/ |  | | | | (_) | (_| |  __/\__ \
 |_|    |_| |_|\__,_|_| |_|\__\___/|_| |_| |_| |_|  |_|\__,_|___/\__\___|_|  |_| |_|\___/ \__,_|\___||___/

EOF

echo -e "${NC}"
echo -e "${GREEN}Welcome to the Phantom Masternode Installation${NC}"
echo -e ""
PS3='Please enter your choice: '
options=("Galilel" "GoByte" "IQcash" "Exit")
select opt in "${options[@]}"
do
    case $opt in			
        "Galilel")
            break
            ;;
        "GoByte")
            gbx
            ;;
        "IQcash")
            iqcash
            ;;
        "Exit")
            exit 0
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
}

function mail_address() {
  echo -e "${RED}Enter your email address for backup and press Enter:${NC}"
  read -e MAIL_ADDRESS
clear
}

function galilel() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Galilel...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name gali
  docker pull smai/galilel_be_phantom:0.0.1
  docker run -d --restart always -v gali:/go/src/phantom/conf:ro --name gali-backend smai/gali_be_phantom:0.0.1
  docker pull smai/gali_fe_phantom:0.0.1
  docker run -d --restart always -p 8101:8101 -v gali:/root/phantom-hosting/conf --name gali-frontend smai/gali_fe_phantom:0.0.1
  ufw allow 8101/tcp comment "Galilel GUI" >/dev/null
  echo "alias gali-conf='cd /var/lib/docker/volumes/gali/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Galilel Masternode"' > ~/.muttrc
  mutt -s "Galilel MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/gali/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'Galilel MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/gali/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function gobyte_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install GoByte...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name gbx
  docker pull smai/gbx_be_phantom:0.0.1
  docker run -d --restart always -v gbx:/root/phantom/conf:ro --name gbx-backend smai/gbx_be_phantom:0.0.1
  docker pull smai/gbx_fe_phantom:0.0.1
  docker run -d --restart always -p 8103:8103 -v gbx:/root/phantom-hosting/conf --name gbx-frontend smai/gbx_fe_phantom:0.0.1
  ufw allow 8103/tcp comment "GoByte GUI" >/dev/null
  echo "alias gbx-conf='cd /var/lib/docker/volumes/gbx/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="GoByte Masternode"' > ~/.muttrc
  mutt -s "GoByte MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/gbx/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'GoByte MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/gbx/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function iqcash_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install IQcash...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name iq
  docker pull smai/iq_be_phantom:0.0.1
  docker run -d --restart always -v iq:/root/phantom/conf:ro --name iq-backend smai/iq_be_phantom:0.0.1
  docker pull smai/iq_fe_phantom:0.0.1
  docker run -d --restart always -p 8104:8104 -v iq:/root/phantom-hosting/conf --name iq-frontend smai/iq_fe_phantom:0.0.1
  ufw allow 8104/tcp comment "IQcash GUI" >/dev/null
  echo "alias iq-conf='cd /var/lib/docker/volumes/iq/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="IQcash Masternode"' > ~/.muttrc
  mutt -s "IQcash MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/iq/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'IQcash MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/iq/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function information() {
  rm *installer.sh* >/dev/null 2>&1
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${GREEN}The Masternode installation was successfull! Good job!${NC}"
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e ""
  echo -e "${RED}Please follow the WiKi how to use it.${NC}"
  echo -e ""
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

#GoByte
function gbx() {
clear
mail_address
gobyte_inst
information
exit 0
}

#IQcash
function iqcash() {
clear
mail_address
iqcash_inst
information
exit 0
}

#Galilel
start_inst
clear
mail_address
galilel
information
exit 0
