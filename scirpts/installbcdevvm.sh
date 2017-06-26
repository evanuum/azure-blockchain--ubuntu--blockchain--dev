# install npm from official repo, as apt-get has a very old version of npm
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash –
sudo apt-get update -y && sudo apt-get upgrade -y 
# install the basics
sudo apt-get install -y build-essential python nodejs 
# upgrade npm before install tools
sudo npm install -g npm 
sudo npm install -g ethereumjs-testrpc truffle