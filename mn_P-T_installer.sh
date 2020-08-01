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
options=("Trittium" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Trittium")
            break
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

function trittium() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Trittium...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name trtt
  docker pull smai/trtt_be_phantom:0.0.1
  docker run -d --restart always -v trtt:/root/phantom/conf:ro --name trtt-backend smai/trtt_be_phantom:0.0.1
  docker pull smai/trtt_fe_phantom:0.0.1
  docker run -d --restart always -p 8123:8123 -v trtt:/root/phantom-hosting/conf --name trtt-frontend smai/trtt_fe_phantom:0.0.1
  ufw allow 8123/tcp comment "Trittium GUI" >/dev/null
  echo "alias trtt-conf='cd /var/lib/docker/volumes/trtt/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Trittium Masternode"' > ~/.muttrc
  mutt -s "Trittium MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/trtt/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "* 12 * * * mutt -s 'Trittium MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/trtt/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function information() {
  rm *installer.sh >/dev/null 2>&1
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${GREEN}The Masternode installation was successfull! Good job!${NC}"
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e ""
  echo -e "${RED}Please follow the WiKi how to use it.${NC}"
  echo -e ""
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

#Trittium
start_inst
clear
mail_address
trittium
information
exit 0
