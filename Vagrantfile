# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
  config.vm.box = "precise64_kurchatov_gem"
  config.ssh.forward_agent = true

  config.vm.provider :vmware_fusion do |vmware|
     vmware.vm.vmx["memsize"] = "2048"
     vmware.vm.gui = false
     vmware.box_url = "http://files.vagrantup.com/precise64_vmware.box"
  end

end
