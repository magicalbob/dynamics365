#!/usr/bin/env bash

# make sure we are in right dir
BASE_PATH=$(dirname $0)
cd ${BASE_PATH}/../terraform

source ../scripts/boxname.sh

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
export TF_VAR_netdev=$(ip route|grep default|cut -d' ' -f5)

# Bring up the cluster
/usr/local/bin/terraform apply --auto-approve

LOCK=$(date +"%s")
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

dynad=$(/usr/local/bin/terraform state show virtualbox_vm.dynad[0]|grep "id.*="|cut -d\" -f2|tr -d "[:cntrl:])")
dynad_mac=$(VBoxManage showvminfo $dynad|grep MAC:|cut -d: -f3|cut -d, -f1|tr -d "[:cntrl:]")

# Set mac of dynad in redis
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_${dynad_mac:1} dynad\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

echo "Set dynad mac address ${dynad_mac:1}"

dynsql=$(/usr/local/bin/terraform state show virtualbox_vm.dynsql[0]|grep "id.*="|cut -d\" -f2)
dynsql_mac=$(VBoxManage showvminfo $dynsql|grep MAC:|cut -d: -f3|cut -d, -f1)

# Set mac of dynsql in redis
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_${dynsql_mac:1} dynsql\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

echo "Set dynsql mac address ${dynad_mac:1}"

dynfe=$(/usr/local/bin/terraform state show virtualbox_vm.dynfe[0]|grep "id.*="|cut -d\" -f2)
dynfe_mac=$(VBoxManage showvminfo $dynfe|grep MAC:|cut -d: -f3|cut -d, -f1)

# Set mac of dynfe in redis
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_${dynfe_mac:1} dynfe\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

echo "Set dynfe mac address ${dynfe_mac:1}"

dynbe=$(/usr/local/bin/terraform state show virtualbox_vm.dynbe[0]|grep "id.*="|cut -d\" -f2)
dynbe_mac=$(VBoxManage showvminfo $dynbe|grep MAC:|cut -d: -f3|cut -d, -f1)

# Set mac of dynbe in redis
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_${dynbe_mac:1} dynbe\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

echo "Set dynbe mac address ${dynbe_mac:1}"

dynadm=$(/usr/local/bin/terraform state show virtualbox_vm.dynadm[0]|grep "id.*="|cut -d\" -f2)
dynadm_mac=$(VBoxManage showvminfo $dynadm|grep MAC:|cut -d: -f3|cut -d, -f1)

# Set mac of dynadm in redis
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_${dynadm_mac:1} dynadm\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

echo "Set dynadm mac address ${dynadm_mac:1}"
