#!/usr/bin/env bash

function setRedisFlag {
  set_redis_ip=${1}
  set_redis_pass=${2}
  set_key_name=${3}
  set_key_value=${4}
  set_prefix=${5}

  if [ "${set_key_name}" != "prefix" ]
  then
    set_key_name="${set_prefix}_${set_key_name}"
  fi

  resp=1
  while [ $resp -ne 0 ]
  do
    echo -e "AUTH ${set_redis_pass}\r\nSET ${set_key_name} ${set_key_value}\r\n" | nc -w1 ${set_redis_ip} 6379
    resp=$?
  done
}

function persistRedisFlag {
  set_redis_ip=${1}
  set_redis_pass=${2}
  set_key_name=${3}
  set_prefix=${4}

  if [ "${set_key_name}" != "prefix" ]
  then
    set_key_name="${set_prefix}_${set_key_name}"
  fi

  resp=1
  while [ $resp -ne 0 ]
  do
    echo -e "AUTH ${set_redis_pass}\r\nPERSIST ${set_key_name}\r\n" | nc -w1 ${set_redis_ip} 6379
    resp=$?
  done
}

# Setup parameters
prefix=${1}
redis_ip=${2}
redis_pass=${3}

setRedisFlag ${redis_ip} ${redis_pass} prefix ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} prefix

# Save blank IP address of the AD server in redis and persist it
ad_ip='NOWT'

setRedisFlag ${redis_ip} ${redis_pass} ad_ip ${ad_ip} ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} ad_ip ${prefix}

setRedisFlag ${redis_ip} ${redis_pass} sql_ready "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} sql_ready ${prefix}
setRedisFlag ${redis_ip} ${redis_pass} dynsql_started "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} dynsql_started ${prefix}

setRedisFlag ${redis_ip} ${redis_pass} allinone_ready "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_ready ${prefix}
setRedisFlag ${redis_ip} ${redis_pass} allinone_started "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_started ${prefix}
setRedisFlag ${redis_ip} ${redis_pass} allinone_365_started "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_365_started ${prefix}
setRedisFlag ${redis_ip} ${redis_pass} allinone_365_done "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_365_done ${prefix}

setRedisFlag ${redis_ip} ${redis_pass} allinone_ssrs_start "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_ssrs_start ${prefix}
setRedisFlag ${redis_ip} ${redis_pass} allinone_ssrs_done "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} allinone_ssrs_done ${prefix}

# set flag to mark an unexpected machine restart
setRedisFlag ${redis_ip} ${redis_pass} machine_restart "false" ${prefix}
persistRedisFlag ${redis_ip} ${redis_pass} machine_restart ${prefix}
