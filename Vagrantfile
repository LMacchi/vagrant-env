# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrant environment that creates a puppet master, gitlab and $agents agents
#
# Variables
$check_update = false
$iprange = '10.10.5'
$masterip = $iprange+'.50'
$domain = 'puppetlabs.vm'
$startip = 51
$box = 'puppetlabs/centos-6.6-64-nocm'
$arch = 'el-6-x86_64'
$puppetver = '2015.3.3'
$agents = 1


Vagrant.configure(2) do |config|
  config.vm.box_check_update = $check_update
  config.vm.define "master" do |master|
    master.vm.box = $box
    master.vm.hostname = "master.#$domain"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = "2"
    end
    master.vm.network "private_network", ip: $masterip
    master.vm.provision "hosts" do |prov|
      prov.autoconfigure = true
    end
    master.vm.provision "shell", privileged: true, inline: <<-SHELL
      # Stop iptables
      sudo service iptables stop
      sudo chkconfig iptables off
      sudo /usr/local/bin/puppet --version 2&> /dev/null
      if [ $? -ne 0 ]; then
        # Download tar
        sudo wget --progress=bar:force --content-disposition "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=6&arch=x86_64&ver=#$puppetver"
        # Extract tar to /root
        sudo tar xzvf puppet-enterprise-#$puppetver*-#$arch.tar* -C /root
        # Install PE from answers file
        sudo /root/puppet-enterprise-#$puppetver*-#$arch/puppet-enterprise-installer -a /vagrant/puppetfiles/answers-#$puppetver*-master.#$domain.txt
        # Clean up
        sudo rm -fr /root/puppet-enterprise-*
        sudo echo "*.#$domain" > /etc/puppetlabs/puppet/autosign.conf
      else
        sudo /usr/local/bin/puppet agent -t
      fi
    SHELL
  end
    (1..$agents).each do |i|
    ip = $startip+i
    config.vm.define "agent#{i}" do |agent|
      agent.vm.box = $box
      agent.vm.hostname = "agent#{i}.#$domain"
      agent.vm.network "private_network", ip: "#$iprange.#{ip}"
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
          curl -k https://master.#$domain:8140/packages/current/install.bash | sudo bash
        else
          sudo /usr/local/bin/puppet agent -t
        fi
      SHELL
    end
  end
end
