#!/usr/bin/env bash

# This scripts builds a production site 
#    1) builds the production version using ```hugo build```
#    2) Updates variables in ./site with actual values
# or push updates to a running server via SSH

###################
# Title
cat <<EOF
---------------------------------------------------------------------
   _____                            ____        _ _     _           
  / ____|                          |  _ \      (_) |   | |          
 | |     ___  _   _ _ __ ___  ___  | |_) |_   _ _| | __| | ___ _ __ 
 | |    / _ \| | | | '__/ __|/ _ \ |  _ <| | | | | |/ _  |/ _ \ '__|
 | |___| (_) | |_| | |  \__ \  __/ | |_) | |_| | | | (_| |  __/ |   
  \_____\___/ \__,_|_|  |___/\___| |____/ \__,_|_|_|\__,_|\___|_|  
---------------------------------------------------------------------
EOF

###################
# Variables

### Colors
red='\033[1;31m'
none='\033[0m'
cyan='\033[0;36m'
white='\033[0;37m'
green='\033[0;32m'

### Hugo bin
bin=""
if [ "$(uname)" == "Darwin" ]; then
    bin="./bin/hugo/hugo_0.59.1_macOS-64bit/hugo"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    bin="./bin/hugo/hugo_0.59.1_Linux-64bit/hugo"
else
    echo -e "${red}[!] Cannot determine OS. Exiting..."
fi 

### Parameters and Variables
basicUsername=$2
basicPassword=$3
sshuser=$4
sshkey=$5
wikihostname=$6

wikiport=22
wikirootpath=/opt
wikipath=/opt/site 

localsource=./public # Hugo output directory
targetsource=./site  # Expected directory name hosted on target web server

###################
# Functions

# Check for error
function error_check () {
  if [ $? -eq 0 ]
  then
    echo -e "${white}[*] Command Executed Successfully${green}"
  else
    echo -e "${red}[!] Command Failed to Execute. Script Exiting. Review Output to Resolve${green}" >&2
    read -p "    Press [Enter] continue or [CTRL-C] to exit..."
  fi
}

# Usage
function usage {
   cat << EOF
Usage: 

    update_wiki.sh build

Build - Builds site locally to test for errors
    update_wiki.sh build

Push - Build and pushes site to running server
    ./update_wiki.sh push <basic auth username> <basic auth password> <ssh user> <ssh key> <wiki hostname or IP>

    ./update_wiki.sh push student 'DetectionP@ssw0rd!!' adminuser ../atd_student_range/terraform/keys/sshkey 10.10.10.10

EOF
   exit 1
}

# Regular Clean
function cleanFiles {
 echo -e "${white}[*] Cleaning up OSX created files (Icon,.DS_Store)...${green}"
 find ./ -name Icon? -exec rm {} \;
 find ./ -name .DS_Store -exec rm {} \;
}

###################
function printvariables {
# Print values of variables

    echo -e "${white}Variables"
    echo -e "${white}---------"
    echo -e "${white}Hugo Binary: $bin"
    echo -e "${white}basicUsername: $basicUsername"
    echo -e "${white}basicPassword: $basicPassword"
    echo -e "${white}wikihostname: $wikihostname"
    echo -e "${white}wikiport: $wikiport"
    echo -e "${white}wikiparentpath: $wikiparentpath"
    echo -e "${white}sshkey: $sshkey"
    echo -e "${white}---------"
    echo -e "${white}"
}

###################
function build {
# Build Wiki
    echo -e "${white}[*] Building Wiki...${green}"
    cleanFiles
    $bin
    for map in $(find ./content -name 'map.html') 
        do  
            index = (dirname $map) + (index.html)
            final_index = sed -i s/public/content/g $index
            map_html='cat $map'
            sed -i "s/$map_html1/MAP GOES HERE/g" "$final_index"
        done 
    echo -e "${white}Done...${green}"
}

###################
function push {
# Push site to production

    printvariables;
    echo -e "${white}Preparing to sync content to $wikihostname...${green}"

    build
    error_check

    echo -e "${white}[*] Moving HUGO output to $targetsource ...${green}"
    rm -rf $targetsource
    mv $localsource $targetsource

    # Grant directory permissions
    echo -e "${white}[*] Grant directory permissions...${green}"
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname -t sudo chmod -R 0777 $wikipath
    error_check
    # Sync content
    echo -e "${white}[*] Sync content...${green}"
	rsync -ravz --verbose --delete --stats --human-readable --progress -e "ssh -o StrictHostKeyChecking=no -i $sshkey" $targetsource $sshuser@$wikihostname:$wikirootpath

    # Restart nginx
    echo -e "${white}[*] Restarting nginx...${green}"
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo service nginx restart
    error_check
    # Reset directory permissions
    echo -e "${white}[*] Reset directory permissions${green}"
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo chmod -R 0755 $wikipath
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo chown -R www-data $wikipath
    error_check
}

###################
#  Let's Encrypt Certbot
function certbot {
    # Add let's encrypt certificate to Wiki
    
    echo -e "${white}[*] Certbot running...${green}"
    
    # Update server_name
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo sed -i "s/server_name.*/server_name\ $wikihostname\;/g" /etc/nginx/sites-enabled/default

    # Get Cert
    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo certbot --agree-tos --non-interactive --rsa-key-size 4096 --nginx -d $wikihostname --email noreply@$wikihostname 

    ssh -o StrictHostKeyChecking=no -i $sshkey $sshuser@$wikihostname sudo service nginx restart 

}


###################
# Main

if [ $# -lt 1 ]; then
   usage;
elif [ "$1" == "certbot" ]; then
    if [ $# -lt 6 ]; then
        usage;
    else
        certbot;
    fi
elif [ "$1" == "build" ]; then
    build;
elif [ "$1" == "push" ]; then
    if [ $# -lt 6 ]; then
        usage;
    else
        push;
    fi
else
    echo -e "${red}[!] Bad parameter. Fix and try again";
fi
