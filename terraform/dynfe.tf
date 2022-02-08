resource "virtualbox_vm" "dynfe" {
  count  = 1
  name   = join("", ["dynfe", var.branch])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 1
  memory = "1024 mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.netdev
  }
}
