#!/usr/bin/env bash

# make sure we are in right dir
BASE_PATH=$(dirname $0)
cd ${BASE_PATH}/../terraform-azure

if [ "$OS" == "Windows_NT" ]
then
  PROVIDER_EXT=".exe"
  PATH=$PATH:/c/tools/ruby27/bin:"/c/Program Files/Oracle/VirtualBox"
else
  PROVIDER_EXT=""
fi

# Terraform initialise
terraform init

# Get redis details from puppet hiera
redis_name=$(grep redis_ip ../puppet/hieradata/common.yaml |cut -d: -f2)
redis_ip=$(nslookup -querytype=A ${redis_name} 2> /dev/null | grep ^Address:|tail -n1|cut -d: -f2)
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

export TF_VAR_admin_user=$(grep admin_username ../puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')
export TF_VAR_admin_pass=$(grep admin_password ../puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')

LOCK=$(date +"%s")
resp=1
while [ $resp -ne 0 ]
do
  echo -e "AUTH ${redis_pass}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${redis_ip} 6379
  resp=$?
done

# Bring up the cluster
terraform apply --auto-approve
