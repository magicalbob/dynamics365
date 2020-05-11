resource "virtualbox_vm" "dynad" {
  count     = 1
  name      = join("",["dynad",formatdate("YYYY-MM-DD-hh-mm-ss",timestamp())])
  image     = "./dynamics-windows-virtualbox.box"
  cpus      = 2
  memory    = "4096 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "enp0s25"
  }
}
