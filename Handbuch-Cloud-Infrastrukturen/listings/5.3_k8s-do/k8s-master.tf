resource "digitalocean_droplet" "master" {
  name     = "k8s-master"
  image    = "ubuntu-16-04-x64"
  region   = "fra1"
  size     = "2gb"
  ssh_keys = [digitalocean_ssh_key.mysshkey.id]

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    user        = "root"
    private_key = file("do_key")
  }

  provisioner remote-exec {
    script = "provision-all.bash"
  }

  provisioner remote-exec {
    script = "provision-master.bash"
  }

  provisioner local-exec {
    command = "scp -i do_key root@${digitalocean_droplet.master.ipv4_address}:join-command join-command"
  }

  provisioner local-exec {
    command = "scp -i do_key root@${digitalocean_droplet.master.ipv4_address}:admin.conf admin.conf"
  }
}
