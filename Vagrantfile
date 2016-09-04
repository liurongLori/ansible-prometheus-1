# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.network :private_network, ip: "192.168.33.99"
  config.vm.network :forwarded_port, guest: 22, host: 2299

  config.vm.define 'ubuntu1404-amd64' do |instance|

    instance.vm.box = 'williamyeh/ubuntu-trusty64-docker'

    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "test_vagrant.yml"
      ansible.verbose = 'vv'
      ansible.sudo = true
    end
  end
end
