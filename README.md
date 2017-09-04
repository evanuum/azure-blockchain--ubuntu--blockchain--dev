# Ubuntu Blockchain Development VM

ARM Template to provision a Ubuntu VM complete with Visual Studio Code (incl. VSTS integration), Truffle, TestRPC, Parity for Ethereum blockchain development.
For authentication to VSTS a personal access token can be used. Set up of such a token is described below.

<a href="https://portal.azure.com/#create/microsoft.template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fevanuum%2Fazure-blockchain--ubuntu--blockchain--dev%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/evanuum/azure-blockchain--ubuntu--blockchain--dev/master/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
<p>The solitdity, VSTS and material icon extension need to be installed manually for easy blockchain development.
<img src='/images/VScode.PNG' />
The install sh script is executed in the background and therefore it will take some time for it to finish even though Azure informs you the ARM template deployment has completed. Execute the "tail /var/log/initial-install.log" on a ssh shell to see what the status is. If you see the statement "Setup Complete" as the last statement in the log file the install has finished completely.</p>
<H2>SSH tunnel for VNC</H2>
Setup a SSH tunnel to connect to the environment with VNC:
<img src='/images/puttyconf.PNG' />
<h2>Personal access token VSTS</h2>
<p>Open VSTS (VSO) and create a personal token</p>
Use the procedure as described here: https://www.visualstudio.com/en-us/docs/setup-admin/team-services/use-personal-access-tokens-to-authenticate. Use it when connecting to VSTS using the TEE Command Line Client. The TEE Command Line Client can be executed using the tf command. The Team Foundation version control commands reference can be found here: https://www.visualstudio.com/en-us/docs/tfvc/use-team-foundation-version-control-commands. A Quick Start on how to work with VS Code and VSTS integration can be found here: https://github.com/Microsoft/vsts-vscode/blob/master/TFVC_README.md#quick-start.
