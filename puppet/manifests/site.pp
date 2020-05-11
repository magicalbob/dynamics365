node /^dynfe.*$/ {
  include role::dynfe
}

node /^dynbe.*$/ {
  include role::dynbe
}

node /^dynadm.*$/ {
  include role::dynadm
}

node /^dynad.*$/ {
  include role::dynad
}

node /^dynsql.*$/ {
  include role::dynsql
}

node default {
  include role::base
}
