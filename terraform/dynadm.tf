resource "virtualbox_vm" "dynadm" {
  count  = 1
  name   = join("", ["dynadm", var.branch])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 1
  memory = "1024 mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.netdev
  }
}
