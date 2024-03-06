resource "digitalocean_droplet" "worker" {
  name       = "k8s-worker${format("%d", count.index + 1)}"
  image      = "ubuntu-16-04-x64"
  region     = "fra1"
  size       = "2gb"
  ssh_keys   = [digitalocean_ssh_key.mysshkey.id]
  count      = var.number_of_workers
  depends_on = [digitalocean_droplet.master]

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    user        = "root"
    private_key = file("do_key")
  }

  provisioner remote-exec {
    script = "provision-all.bash"
  }

  provisioner file {
    source      = "join-command"
    destination = "/root/join-command"
  }

  provisioner remote-exec {
    inline = ["bash join-command"]
  }
}
