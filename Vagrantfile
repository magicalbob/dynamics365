# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant build script

Vagrant.require_version ">= 2.0.0"

require 'yaml'
servers = YAML.load_file('servers.yaml')

Vagrant.configure("2") do |config|
  servers.each do |server|
    config.vm.define server["hostname"] do |machine|
      machine.vm.hostname = server["hostname"]
      machine.vm.boot_timeout = 1200

      if (server["ip"]).nil?
        machine.vm.network "private_network", type: "dhcp"
      else
        machine.vm.network "private_network", ip: server["ip"]
      end

      machine.vm.provider "virtualbox" do |vb|
        if (server["memory"] != nil)
            vb.memory = server["memory"]
        end

        if (server["cpus"] != nil)
          vb.cpus = server["cpus"]
        end

        vb.customize [ "modifyvm", :id, "--audio", "none" ]
      end

      if (server["box"] != nil)
        machine.vm.box = server["box"]
        machine.vm.box_url = server["box_url"]
      else
        puts "No box specified, using default"
        machine.vm.box = "dynamics-windows-virtualbox.box"
      end

      if (server["hostname"] == "dynred")
        puts "Use ssh as normal for redis, but run provisioner"
        machine.vm.synced_folder '.', '/vagrant', disabled: true
        machine.vm.provision "shell", inline: <<-SHELL
          yum install -y redis
          sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis.conf
          systemctl start redis
        SHELL
      else
        machine.vm.synced_folder ".", "/vagrant", SharedFoldersEnableSymlinksCreate: false
        machine.vm.synced_folder "puppet", "c:\\ProgramData\\Puppetlabs\\code\\environments\\production", SharedFoldersEnableSymlinksCreate: false
        machine.vm.communicator = "winrm"
        machine.winrm.username = "Administrator"
        machine.winrm.password = "vagrant"
        machine.winrm.basic_auth_only = true
        machine.winrm.transport = "plaintext"
        machine.winrm.retry_limit = 30
        machine.winrm.retry_delay = 10
      end
    end
  end
end
