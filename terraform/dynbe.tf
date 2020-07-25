resource "virtualbox_vm" "dynbe" {
  count  = 1
  name   = join("", ["dynbe", formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 1
  memory = "1024 mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.netdev
  }
}
