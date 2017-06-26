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
time sudo apt-get -y remove walinuxagent
sudo dpkg --configure -a
# install nodejs 
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install ubuntu-desktop vnc4server ntp nodejs expect gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal gnome-core

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

####################
# Setup Chrome
####################
cd /tmp
time wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
time sudo apt-get -y --force-yes install -f
time rm /tmp/google-chrome-stable_current_amd64.deb
date

######
#install testrpc & truffle
######
# install npm from official repo, as apt-get has a very old version of npm
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash –
sudo apt-get update -y && sudo apt-get upgrade -y 
# install the basics
sudo apt-get install -y build-essential python nodejs 
# upgrade npm before install tools
sudo npm install -g npm 
sudo npm install -g ethereumjs-testrpc truffle
date

######
# install visual studio using make
######
# install make
time sudo add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make
time sudo apt-get -y update
time sudo apt-get -y install ubuntu-make
# install vs code
time sudo umake ide visual-studio-code --accept-license $HOMEDIR/.local/share/umake/ide/visual-studio-code
# fix to ensure vs code start in dekstop
time sudo sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1
# add extensions (solidity and icon theme)
# time sudo $HOMEDIR/.local/share/umake/ide/visual-studio-code/code --install-extension JuanBlanco.solidity
# time sudo $HOMEDIR/.local/share/umake/ide/visual-studio-code/code --install-extension PKief.material-icon-theme
date

sudo -i -u $AZUREUSER $HOMEDIR/bin/startvnc

# end of install
echo "completed ubuntu devbox install on pid $$"
echo "Setup Complete"