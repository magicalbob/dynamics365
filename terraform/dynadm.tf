resource "virtualbox_vm" "dynadm" {
  count  = 1
  name   = join("", ["dynadm", formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())])
  image  = "./dynamics-windows-virtualbox.box"
  cpus   = 2
  memory = "4096 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "${var.netdev}"
  }
}
