# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrant environment that creates a puppet master, gitlab and $agents agents
#
#
require_relative './scripts/calculate_pe.rb'

# Variables
check_update = false
iprange = '10.10.5'
masterip = iprange+'.50'
domain = 'puppetlabs.vm'
startip = 51
box = 'puppetlabs/centos-6.6-64-nocm'
agents = 0

# Calculate version of PE to download
url = return_url(box)
pe_ver ||= "latest"

Vagrant.configure(2) do |config|
  config.vm.box_check_update = check_update
  config.vm.define "master" do |master|
    master.vm.box = box
    master.vm.hostname = "master.#{domain}"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = "2"
    end
    master.vm.network "private_network", ip: masterip
    master.vm.provision "hosts" do |prov|
      prov.autoconfigure = true
    end
    master.vm.provision "shell", privileged: true, inline: <<-SHELL
      # Stop iptables
      sudo service iptables stop 2&> /dev/null && sudo chkconfig iptables off 2&> /dev/null
      if [ $? -eq 0 ]; then
        echo "IPTables stopped successfully"
      fi
      sudo /usr/local/bin/puppet --version 2&> /dev/null
      if [ $? -ne 0 ]; then
        # Download tar
        echo "Download URL: #{url}#{pe_ver}"
        echo "Downloading Puppet Enterprise, this may take a few minutes"
        sudo wget --quiet --progress=bar:force --content-disposition "#{url}#{pe_ver}"
        # Extract tar to /root
        sudo tar xzvf puppet-enterprise-*.tar* -C /root
        # Install PE from answers file
        echo "Ready to install Puppet Enterprise #{pe_ver}"
        sudo /root/puppet-enterprise-*/puppet-enterprise-installer -c /vagrant/puppetfiles/custom-pe.conf -y
        # Clean up
        #sudo rm -fr /root/puppet-enterprise-*
        sudo echo "*.#{domain}" > /etc/puppetlabs/puppet/autosign.conf
        sudo puppet agent -t
      else
        sudo /usr/local/bin/puppet agent -t
      fi
    SHELL
  end

  if agents > 0
    (1..agents).each do |i|
    ip = startip+i
    config.vm.define "agent#{i}" do |agent|
      agent.vm.box = box
      agent.vm.hostname = "agent#{i}.#{domain}"
      agent.vm.network "private_network", ip: "#{iprange}.#{ip}"
      agent.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end
      agent.vm.provision :hosts do |prov|
        prov.autoconfigure = true
      end
      agent.vm.provision "shell", inline: <<-SHELL
        # Stop iptables
        sudo service iptables stop
        sudo chkconfig iptables off
        # Install puppet
        /usr/local/bin/puppet --version 2&> /dev/null
        if [ $? -ne 0 ]; then
          curl -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
        else
          sudo /usr/local/bin/puppet agent -t
        fi
      SHELL
    end
  end

end
end
