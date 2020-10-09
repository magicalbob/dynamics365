node /^allinone.*$/ {
  include role::allinone
}

node /^dynfe.*$/ {
  include role::dynfe
}

node /^dynbe.*$/ {
  include role::dynbe
}

node /^dynadm.*$/ {
  include role::dynadm
}

node /^dynadir.*$/ {
  include role::dynadir
}

node /^dynsql.*$/ {
  include role::dynsql
}

node default {
  include role::base
}
