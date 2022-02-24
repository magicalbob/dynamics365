resource "virtualbox_vm" "allinone" {
  count  = 1
  name   = join("", ["allinone", var.branch])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 4
  memory = "16384 mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.netdev
  }
}
