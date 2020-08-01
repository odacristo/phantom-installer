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
options=("Northern" "KnowYourDeveloper" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Northern")
            break
            ;;
        "KnowYourDeveloper")
            kydc
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

function northern() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Northern...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name northern
  docker pull smai/northern_be_phantom:0.0.1
  docker run -d --restart always -v northern:/root/phantom/conf:ro --name northern-backend smai/northern_be_phantom:0.0.1
  docker pull smai/northern_fe_phantom:0.0.1
  docker run -d --restart always -p 8080:8080 -v northern:/root/phantom-hosting/conf --name northern-frontend smai/northern_fe_phantom:0.0.1
  ufw allow 8080/tcp comment "Northern GUI" >/dev/null
  echo "alias northern-conf='cd /var/lib/docker/volumes/northern/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Northern Masternode"' > ~/.muttrc
  mutt -s "Northern MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/northern/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "* 12 * * * mutt -s 'Northern MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/northern/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function kydc_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install KYDC...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name kydc
  docker pull smai/kydc_be_phantom:0.0.1
  docker run -d --restart always -v kydc:/root/phantom/conf:ro --name kydc-backend smai/kydc_be_phantom:0.0.1
  docker pull smai/kydc_fe_phantom:0.0.1
  docker run -d --restart always -p 8105:8105 -v kydc:/root/phantom-hosting/conf --name kydc-frontend smai/kydc_fe_phantom:0.0.1
  ufw allow 8105/tcp comment "KYDC GUI" >/dev/null
  echo "alias kydc-conf='cd /var/lib/docker/volumes/kydc/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="KYDC Masternode"' > ~/.muttrc
  mutt -s "KYDC MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/kydc/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "* 12 * * * mutt -s 'KYDC MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/kydc/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function information() {
  rm /root/*installer.sh >/dev/null 2>&1
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${GREEN}The Masternode installation was successfull! Good job!${NC}"
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e ""
  echo -e "${RED}Please follow the WiKi how to use it.${NC}"
  echo -e ""
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

#Northern
clear
start_inst
mail_address
northern
information
exit 0

#KYDC
clear
mail_address
kydc_inst
information
exit 0
