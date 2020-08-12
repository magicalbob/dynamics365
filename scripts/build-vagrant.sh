#!/usr/bin/env bash

# function to start a vagrant machine
function run_machine {
  machine_run=""

  until [ "$machine_run" == "$1" ]
  do
    vagrant up $1
    machine_run=$(vagrant status $1|grep $1.*running|cut -d\  -f1)
  done
}

# Setup prefix in redis for this build
prefix=$(date +%s)
echo ${prefix} > prefix
redis_name=$(grep redis_ip puppet/hieradata/common.yaml |cut -d: -f2)
redis_ip=$(nslookup -querytype=A ${redis_name} 2> /dev/null | grep ^Address:|tail -n1|cut -d: -f2)
redis_pass=$(grep redis_pass puppet/hieradata/common.yaml |cut -d: -f2)

./scripts/clear-flags-for-build.sh ${prefix} ${redis_ip} ${redis_pass}

# Bring up the Active Directory server
run_machine dynad

# Bring up the rest of the machines
run_machine dynsql
run_machine dynfe
run_machine dynbe
run_machine dynadm
