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
options=("1x2" "Absolute" "Aias" "Bare" "Bitcoin-Incognito" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "1x2")
            onetwo
            ;;
        "Absolute")
            abs
            ;;
        "Aias")
            aias
            ;;			
        "Bare")
            break
            ;;
        "Bitcoin-Incognito")
            xbi
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

function bare() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Bare...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name bare
  docker pull smai/bare_be_phantom:0.0.1
  docker run -d --restart always -v bare:/root/phantom/conf:ro --name bare-backend smai/bare_be_phantom:0.0.1
  docker pull smai/bare_fe_phantom:0.0.1
  docker run -d --restart always -p 8084:8084 -v bare:/root/phantom-hosting/conf --name bare-frontend smai/bare_fe_phantom:0.0.1
  ufw allow 8084/tcp comment "Bare GUI" >/dev/null
  echo "alias bare-conf='cd /var/lib/docker/volumes/bare/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Bare Masternode"' > ~/.muttrc
  mutt -s "Bare MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/bare/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'Bare MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/bare/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function onetwo_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install 1x2...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name 1x2
  docker pull smai/1x2_be_phantom:0.0.1
  docker run -d --restart always -v 1x2:/root/phantom/conf:ro --name 1x2-backend smai/1x2_be_phantom:0.0.1
  docker pull smai/1x2_fe_phantom:0.0.1
  docker run -d --restart always -p 8126:8126 -v 1x2:/root/phantom-hosting/conf --name 1x2-frontend smai/1x2_fe_phantom:0.0.1
  ufw allow 8126/tcp comment "1x2 GUI" >/dev/null
  echo "alias 1x2-conf='cd /var/lib/docker/volumes/1x2/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="1x2 Masternode"' > ~/.muttrc
  mutt -s "1x2 MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/1x2/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s '1x2 MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/1x2/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function abs_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Absolute...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name abs
  docker pull smai/abs_be_phantom:0.0.1
  docker run -d --restart always -v abs:/go/src/phantom/conf:ro --name abs-backend smai/abs_be_phantom:0.0.1
  docker pull smai/abs_fe_phantom:0.0.1
  docker run -d --restart always -p 8081:8081 -v abs:/root/phantom-hosting/conf --name abs-frontend smai/abs_fe_phantom:0.0.1
  ufw allow 8081/tcp comment "Absolute GUI" >/dev/null
  echo "alias abs-conf='cd /var/lib/docker/volumes/abs/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Absolute Masternode"' > ~/.muttrc
  mutt -s "Absolute MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/abs/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'Absolute MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/abs/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function aias_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install Aias...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name aias
  docker pull smai/aias_be_phantom:0.0.1
  docker run -d --restart always -v aias:/root/phantom/conf:ro --name aias-backend smai/aias_be_phantom:0.0.1
  docker pull smai/aias_fe_phantom:0.0.1
  docker run -d --restart always -p 8082:8082 -v aias:/root/phantom-hosting/conf --name aias-frontend smai/aias_fe_phantom:0.0.1
  ufw allow 8082/tcp comment "Aias GUI" >/dev/null
  echo "alias aias-conf='cd /var/lib/docker/volumes/aias/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Aias Masternode"' > ~/.muttrc
  mutt -s "Aias MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/aias/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'Aias MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/aias/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function xbi_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install BitcoinIncognito...${NC}   "
  echo -e "-----------------------------------"
  docker volume create --name xbi
  docker pull smai/xbi_be_phantom:0.0.1
  docker run -d --restart always -v xbi:/go/src/phantom/conf:ro --name xbi-backend smai/xbi_be_phantom:0.0.1
  docker pull smai/xbi_fe_phantom:0.0.1
  docker run -d --restart always -p 8089:8089 -v xbi:/root/phantom-hosting/conf --name xbi-frontend smai/xbi_fe_phantom:0.0.1
  ufw allow 8084/tcp comment "Bitcoin Incognito GUI" >/dev/null
  echo "alias xbi-conf='cd /var/lib/docker/volumes/xbi/_data/'" >> ~/.bash_aliases
  touch ~/.muttrc
  echo 'set from="Bitcoin Incognito Masternode"' > ~/.muttrc
  mutt -s "Bitcoin Incognito MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/xbi/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "1 12 * * * mutt -s 'Bitcoin Incognito MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/xbi/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
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

#1x2
function onetwo() {
clear
mail_address
onetwo_inst
information
exit 0
}

#Absolute
function abs() {
clear
mail_address
abs_inst
information
exit 0
}

#Aias
function aias() {
clear
mail_address
aias_inst
information
exit 0
}

#Bitcoin Incognito
function xbi() {
clear
mail_address
xbi_inst
information
exit 0
}

#Bare
start_inst
clear
mail_address
bare
information
exit 0
