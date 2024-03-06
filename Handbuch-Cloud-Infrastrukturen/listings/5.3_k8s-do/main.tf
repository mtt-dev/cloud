provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "mysshkey" {
  name       = "k8s-projekt"
  public_key = file("do_key.pub")
}
