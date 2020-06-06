#!/usr/bin/env bash

function createMachine {
# arg 1 = machine name
# arg 2 = prefix
# arg 3 = redis_ip
# arg 4 = redis_pass
  vbox_state=""
  vbox_id=""
  vbox_mac=""
  echo "Create Machine: ${1}"

  while [ ! "$vbox_state" == "running" ]
  do
    /usr/local/bin/terraform destroy --auto-approve --target virtualbox_vm.${1}
    /usr/local/bin/terraform apply --auto-approve --target virtualbox_vm.${1}

    vbox_id=$(/usr/local/bin/terraform state show virtualbox_vm.${1}[0]|grep "id.*="|cut -d\" -f2|tr -d "[:cntrl:])")

    sleep 60

    vbox_state=$(VBoxManage showvminfo ${vbox_id}|grep ^State|grep -o running)

    # update the lock time
    LOCK=$(date +"%s")
    resp=1
    while [ $resp -ne 0 ]
    do
      echo -e "AUTH ${4}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${3} 6379
      resp=$?
    done
  done

  vbox_mac=$(VBoxManage showvminfo ${vbox_id}|grep MAC:|cut -d: -f3|cut -d, -f1|tr -d "[:cntrl:]")

  # Set mac of machine in redis
  resp=1
  while [ $resp -ne 0 ]
  do
    echo -e "AUTH ${4}\r\nSET ${2}_${vbox_mac:1} ${1}\r\n" | nc -w1 ${3} 6379
    resp=$?
  done

  echo "Set ${1} mac address ${vbox_mac:1}"
}

# make sure we are in right dir
BASE_PATH=$(dirname $0)
cd ${BASE_PATH}/../terraform

source ../scripts/boxname.sh

# check that BRANCH_NAME exists, otherwise set it to "master"
if [[ -z "$BRANCH_NAME" ]]
then
  export BRANCH_NAME=master
fi

# Download terraform provider for virtualbox
curl -LO https://dev.ellisbs.co.uk/files/software/terraform-provider-virtualbox
chmod +x ./terraform-provider-virtualbox

# Get rid of old box, in case it already exists
rm -rvf *.box ~/.terraform/virtualbox/gold/dynamics-windows-virtualbox

# Download the box image
curl -L -o ./dynamics-windows-virtualbox.box https://dev.ellisbs.co.uk/files/boxes/${box_name}-windows-virtualbox-${BRANCH_NAME}.box

# Terraform initialise
terraform init

# Get redis details from puppet hiera
redis_ip=$(grep redis_ip ../puppet/hieradata/common.yaml |cut -d: -f2)
redis_pass=$(grep redis_pass ../puppet/hieradata/common.yaml |cut -d: -f2)

# LOCK loop checking no lock more recent than X minutes ago
LOCKED=1

while [ ${LOCKED} -eq 1 ]
do
  resp=1
  while [ $resp -ne 0 ]
  do
    LOCK=$(echo -e "AUTH ${redis_pass}\r\nGET LOCK\r\n" | nc -w1 ${redis_ip} 6379|tail -n1|tr -d "[:cntrl:]")
    echo -e "AUTH ${redis_pass}\r\nGET LOCK\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null
    resp=$?
  done
  if [ "${LOCK}" == '$-1' ]
  then
    LOCKED=0
  else
    NOW=$(date +"%s")
    let DIFF=$NOW-$LOCK
    if [ $DIFF -gt 600 ]
    then
      LOCKED=0
    else
      echo "Build is locked by previous build. Last lock was ${DIFF} seconds ago. Waiting for it to finish"
      sleep 60
    fi
  fi
done

LOCK=$(date +"%s")
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

# Setup prefix in redis for this build
prefix=$(date +%s)
echo ${prefix} > prefix
echo ${prefix} > ../prefix

../scripts/clear-flags-for-build.sh ${prefix} ${redis_ip} ${redis_pass}

LOCK=$(date +"%s")
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

# Get primary network device
export TF_VAR_netdev=$(/usr/sbin/ip route|grep default|cut -d' ' -f5)

# Bring up the cluster
createMachine dynad  ${prefix} ${redis_ip} ${redis_pass}
createMachine dynsql ${prefix} ${redis_ip} ${redis_pass}
createMachine dynfe  ${prefix} ${redis_ip} ${redis_pass}
createMachine dynbe  ${prefix} ${redis_ip} ${redis_pass}
createMachine dynadm ${prefix} ${redis_ip} ${redis_pass}
