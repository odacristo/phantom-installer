#!/bin/bash
# Copyright (c) 2018-2020 The GOSSIP developers

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BLINK='\e[5m'
NBLINK='\e[0m'
NC='\033[0m'

function start_setup() {
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
  options=("Northern" "Exit")
  select opt in "${options[@]}"
  do
      case $opt in
          "Northern")
              northern
              ;;
          "Exit")
              exit 0
              ;;
          *) echo "Invalid option $REPLY";;
      esac
  done
}

function os_checks() {
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
}

function mail_address() {
  echo -e "${RED}Enter your email address for backup and press Enter:${NC}"
  read -e MAIL_ADDRESS
clear
}

function northern_inst() {
  echo -e "-----------------------------------"
  echo -e "${GREEN}Install "$MN"...${NC}   "
  echo -e "-----------------------------------"
  mn=northern
  MN=Northern
  docker volume create --name "$mn"
  docker pull smai/phantom:latest
  docker run -d --restart always -v "$mn":/root/phantom/conf:ro --name "$mn"-backend smai/phantom:latest
  docker pull smai/"$mn"_phantom:latest
  docker run -d --restart always -p 8080:8080 -v "$mn":/root/phantom-hosting/conf --name "$mn"-frontend smai/"$mn"_phantom:latest
  ufw allow 8080/tcp comment ""$MN" GUI" >/dev/null
  touch ~/.muttrc
  echo 'set from='$MAIL_ADDRESS'' > ~/.muttrc
  mutt -s "$MN MN Backup" $MAIL_ADDRESS -a /var/lib/docker/volumes/"$mn"/_data/masternode.txt < /dev/null
  crontab -l | { cat; echo "* 12 * * * mutt -s '"$MN" MN Backup' "$MAIL_ADDRESS" -a /var/lib/docker/volumes/"$mn"/_data/masternode.txt < /dev/null >/dev/null 2>&1"; } | crontab -
  echo -e "${GREEN}done...${NC}"
  clear
}

function information() {
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${GREEN}The Masternode installation was successfull! Good job!${NC}"
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e ""
  echo -e "${RED}Please follow the guide how to use it.${NC}"
  echo -e ""
  echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

function northern() {
  clear
  os_checks
  mail_address
  northern_inst
  information
  exit 0
}
