# ARM Blockchain Dev VM

ARM Template to provision a Ubuntu VM complete with Visual Studio Code, Truffle and TestRPC for Ethereum blockchain development. The solitdity and material icon extension are instaaled as well for easy blcokchain development.
<img src='~/images/VScode.PNG' />
The install sh script is executed in the background and therefore it will take some time for it to finish even though Azure informs you the ARM template deployment has completed. Execute the "tail /var/log/initial-install.log" on a ssh shell to see what the status is. If you see the statement "Setup Complete" as the last statement in the log file the install has finished completely.

<a href="https://portal.azure.com/#create/microsoft.template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fevanuum%2Fazure-blockchain--ubuntu--blockchain--dev%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/evanuum/azure-blockchain--ubuntu--blockchain--dev/master/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>