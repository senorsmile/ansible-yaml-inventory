nodes = [
  { :hostname => 'web1', :ip => '192.168.200.11', :box => 'precise64', :forward => '2201' },
  { :hostname => 'web2', :ip => '192.168.200.12', :box => 'precise64', :forward => '2202' },
  { :hostname => 'django1', :ip => '192.168.200.13', :box => 'precise64', :forward => '2203' },
  { :hostname => 'django1', :ip => '192.168.200.14', :box => 'precise64', :forward => '2204' },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = "ubuntu/trusty64"
      nodeconfig.vm.hostname = node[:hostname] + ".box"
      nodeconfig.vm.network :private_network, ip: node[:ip]
      nodeconfig.vm.network :forwarded_port, guest: 22, host: node[:forward], id: 'ssh'

      memory = node[:ram] ? node[:ram] : 256;
      nodeconfig.vm.provider :virtualbox do |vb|
        vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "50",
          "--memory", memory.to_s,
        ]
      end
    end
  end
end
