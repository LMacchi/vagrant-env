## Personal Vagrant environment to configure one PE master and x agents.

Fill the following variables in Vagrantfile:

* check_update: Vagrant checks for new versions of the box image. False to disable. True is the default.
* iprange: What subnet your boxes are going to be in
* masterip: IP for the master. I go with $iprange+'.50'
* domain: Boxes get named as master.#{domain} and agentx.#{domain}.
* startip: The starting IP for the agents.
* box: Shortname of the Vagrant box to use. Notice both master and agents use the same box.
* arch: Architecture of the boxes to select the right puppet installer. Ex: 'el-6-x86_64'
* puppetver: Puppet Enterprise version. Ex: '2015.3.3'
* agents: How many agents to create.

