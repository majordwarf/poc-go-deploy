Vagrant.configure("2") do |config|
  IS_KUBERNETES = ENV["PLATFORM"] == "kubernetes"
  if IS_KUBERNETES
      config.vm.box = "ilionx/ubuntu2004-minikube"
  else
      config.vm.box = "ubuntu/focal64"
  end

  config.vm.box_download_insecure = false
  config.vm.provider "virtualbox" do |v|
      v.gui = false
  end

  unless IS_KUBERNETES
    config.vm.network :forwarded_port, guest: 80, host: 8080, host_ip: "127.0.0.1", id: "http"
    config.vm.network :forwarded_port, guest: 443, host: 4430, host_ip: "127.0.0.1", id: "https"
    config.vm.network :forwarded_port, guest: 9090, host: 9090, host_ip: "127.0.0.1", id: "prometheus"
    config.vm.network :forwarded_port, guest: 3000, host: 3000, host_ip: "127.0.0.1", id: "grafana"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vv"
    ansible.playbook = "configs/ansible/playbook.yaml"
    ansible.extra_vars = {
      PLATFORM: ENV["PLATFORM"]
    }
  end
end
