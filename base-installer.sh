#!/bin/bash
# Copyright (c) 2018-2020 The GOSSIP developers

NODEIP=$(curl -s4 icanhazip.com)

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
  options=("Basis-Installation" "Exit")
  select opt in "${options[@]}"
  do
      case $opt in
          "Basis-Installation")
              break
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

function install_base_system() {
  echo -e "-------------------------------------------------------------"
  echo -e "Starting the base installation...                            "
  echo -e "                                                             "
  echo -e "                                                             "
  echo -e "${RED}${BLINK}Please be patient and wait a moment!${NBLINK}  "
  echo -e "-------------------------------------------------------------"
  sysctl vm.swappiness=10 >/dev/null 2>&1
  echo -e  "vm.swappiness=10" >> /etc/sysctl.conf >/dev/null 2>&1
  sysctl vm.vfs_cache_pressure=50 >/dev/null 2>&1
  echo -e "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf >/dev/null 2>&1
  sysctl -p >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt update
  echo -e "----------------------------"
  echo -e "Installing dependencies...  "
  echo -e "----------------------------"
  DEBIAN_FRONTEND=noninteractive apt install -q -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common sendmail mailutils mutt
  clear
  echo -e "---------------------------------------"
  echo -e "Starting the Docker installation...    "
  echo -e "---------------------------------------"
  DEBIAN_FRONTEND=noninteractive curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  DEBIAN_FRONTEND=noninteractive sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  DEBIAN_FRONTEND=noninteractive apt update
  DEBIAN_FRONTEND=noninteractive apt install -q -y docker-ce docker-ce-cli containerd.io
  clear
  echo -e "---------------------------------------"
  echo -e "Staring the Portainer installation...  "
  echo -e "---------------------------------------"
  sleep 3
  docker volume create portainer_data
  sleep 2
  docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
  sleep 2
  docker run -d --name watchtower --restart=always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
  export LC_ALL="en_US.UTF-8" >/dev/null 2>&1
  export LC_CTYPE="en_US.UTF-8" >/dev/null 2>&1
  locale-gen --purge >/dev/null 2>&1
  if [ "$?" -gt "0" ];
    then
      echo -e "---------------------------------------------------------------------------------------------------"
      echo -e "${RED}Not all required packages were installed properly.${NC} Setup Docker and Portainer manually. "
      echo -e "---------------------------------------------------------------------------------------------------"
    exit 1
  fi
  clear
}

function enable_firewall() {
  echo -e "----------------------"
  echo -e "Setting up firewall..."
  echo -e "----------------------"
  ufw allow 9000/tcp comment "Portainer" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp comment "Limit SSH" >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  ufw logging on >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  echo -e "${GREEN}done...${NC}"
  clear
}

function create_aliase() {
  echo -e "----------------------"
  echo -e "Create Shortcuts...   "
  echo -e "----------------------"
  touch ~/.bash_aliases
  echo "alias fw-on='ufw enable'" >> ~/.bash_aliases
  echo "alias fw-off='ufw disable'" >> ~/.bash_aliases
  echo "alias fw-status='ufw status'" >> ~/.bash_aliases
  echo "alias portainer-on='docker start portainer'" >> ~/.bash_aliases
  echo "alias portainer-off='docker stop portainer'" >> ~/.bash_aliases
  echo "alias portainer-status='docker ps -f name=portainer'" >> ~/.bash_aliases
  source ~/.bash_aliases
  echo -e "${GREEN}done...${NC}"
  clear
}

function information() {
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${GREEN}The basis installation for Phantom Masternodes was successfull! Good job!${NC}"
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e ""
  echo -e "${RED}Please follow the guide how to setup the masternodes.${NC}"
  echo -e ""
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

##### Main #####
clear
os_checks
start_setup
install_base_system
enable_firewall
create_aliase
information
