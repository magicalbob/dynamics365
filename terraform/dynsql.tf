resource "virtualbox_vm" "dynsql" {
  count  = 1
  name   = join("", ["dynsql", formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 2
  memory = "4096 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "${var.netdev}"
  }
}
