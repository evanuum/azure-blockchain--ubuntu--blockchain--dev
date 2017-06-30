#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "Start setup"
echo "starting ubuntu blockchain devbox install on pid $$"
date

#############
# Parameters
#############

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=$2
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

# install ubuntu-desktop

###################
# Common Functions
###################

ensureAzureNetwork()
{
  # ensure the host name is resolvable
  hostResolveHealthy=1
  for i in {1..120}; do
    host $VMNAME
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      hostResolveHealthy=0
      echo "the host name resolves"
      break
    fi
    sleep 1
  done
  if [ $hostResolveHealthy -ne 0 ]
  then
    echo "host name does not resolve, aborting install"
    exit 1
  fi

  # ensure the network works
  networkHealthy=1
  for i in {1..12}; do
    wget -O/dev/null http://bing.com
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 10
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork

###################################################
# Update Ubuntu and install all necessary binaries
###################################################

time sudo apt-get -y update
# kill the waagent and uninstall, otherwise, adding the desktop will do this and kill this script
sudo pkill waagent
# sudo dpkg --configure -a
# install nodejs 
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ubuntu-desktop vnc4server ntp nodejs npm expect gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal gnome-core

#########################################
# Setup Azure User Account including VNC
#########################################
sudo -i -u $AZUREUSER mkdir $HOMEDIR/bin
sudo -i -u $AZUREUSER touch $HOMEDIR/bin/startvnc
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/bin/startvnc
sudo -i -u $AZUREUSER touch $HOMEDIR/bin/stopvnc
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/bin/stopvnc
echo "vncserver -geometry 1024x768 -depth 16" | sudo tee $HOMEDIR/bin/startvnc
echo "vncserver -kill :1" | sudo tee $HOMEDIR/bin/stopvnc
echo "export PATH=\$PATH:~/bin" | sudo tee -a $HOMEDIR/.bashrc

prog=/usr/bin/vncpasswd
mypass=$3

sudo -i -u $AZUREUSER /usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF

sudo -i -u $AZUREUSER startvnc
sudo -i -u $AZUREUSER stopvnc

echo "#!/bin/sh" | sudo tee $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "export XKL_XMODMAP_DISABLE=1" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "unset SESSION_MANAGER" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "unset DBUS_SESSION_BUS_ADDRESS" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "xsetroot -solid grey" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "vncconfig -iconic &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-panel &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-settings-daemon &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "metacity &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "nautilus &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-terminal &" | sudo tee -a $HOMEDIR/.vnc/xstartup

sudo -i -u $AZUREUSER $HOMEDIR/bin/startvnc

######
# install visual studio code
######
sudo add-apt-repository -y "deb https://packages.microsoft.com/repos/vscode stable main"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB3E94ADBE1229CF
time sudo apt update -y
time sudo apt-get -y install code
# fix to ensure vs code starts in dekstop
time sudo sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1
# add extensions (solidity, material icon theme and VSTS)
time sudo -H -u $AZUREUSER bash -c 'code --install-extension JuanBlanco.solidity'
time sudo -H -u $AZUREUSER bash -c 'code --install-extension PKief.material-icon-theme'
time sudo -H -u $AZUREUSER bash -c 'code --install-extension ms-vsts.team'
date

######
#install testrpc & truffle
######
# install the basics
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash
sudo apt-get update -y && sudo apt-get upgrade -y 
sudo apt-get install -y build-essential python nodejs

# upgrade npm before install tools
sudo npm install -g npm 
sudo npm install -g truffle@beta
sudo npm install -g ethereumjs-testrpc@beta
# install parity
time sudo -H -u $AZUREUSER bash -c 'bash <(curl https://raw.githubusercontent.com/paritytech/scripts/master/get-parity.sh -Lk)'
date

####################
# Setup Chrome
####################
cd /tmp
time wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
time sudo apt-get -f -y install
time rm /tmp/google-chrome-stable_current_amd64.deb
date

##########
# Install Team Explorer Everywhere Command Line Client (version 14.120.0.201706271643)
##########
# install JAVA
time sudo apt-get -y install default-jre
# get TEE
time wget https://github.com/Microsoft/team-explorer-everywhere/releases/download/14.120.0/TEE-CLC-14.120.0.zip
time sudo -H -u $AZUREUSER bash -c 'unzip TEE-CLC-14.120.0.zip -d $HOME/bin'
# set PATH and clean up
time sudo -H -u $AZUREUSER bash -c "echo 'PATH=\"\$PATH:\"$HOME/bin/TEE-CLC-14.120.0/\"' >> .profile"
time sudo -H -u $AZUREUSER bash -c 'tf eula -accept'
# create VSCode TF user settings
time sudo mkdir $HOMEDIR/.Configs/Code
time sudo mkdir $HOMEDIR/.Configs/Code/User
echo "{" | sudo tee $HOMEDIR/.config/Code/User/settings.json
echo "\"tfvc.location\": \"\$HOME/bin/TEE-CLC-14.120.0/tf\"" | sudo tee -a $HOMEDIR/.config/Code/User/settings.json
echo "}" | sudo tee -a $HOMEDIR/.config/Code/User/settings.json
time rm TEE-CLC-14.120.0.zip
date

# end of install
echo "completed ubuntu devbox install on pid $$"
echo "Setup Complete"