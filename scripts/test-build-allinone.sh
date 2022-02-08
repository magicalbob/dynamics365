#!/usr/bin/env bash

shopt -s nocasematch

if [ "$OS" == "Windows_NT" ]
then
  PATH=$PATH:/c/Python38
fi

start_time="$(date -u +%s)"
echo "Start time of build test is $(date -d @$start_time)"

redis_name=$(grep redis_ip puppet/hieradata/common.yaml |cut -d: -f2)
redis_ip=$(nslookup -querytype=A ${redis_name} 2> /dev/null | grep ^Address:|tail -n1|cut -d: -f2)
redis_pass=$(grep redis_pass puppet/hieradata/common.yaml |cut -d: -f2)

export admin_password=$(grep admin_password ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')

# read prefix for redis keys for this build
prefix=$(echo -e  "AUTH ${redis_pass}\r\nGET prefix\r\n" | nc ${redis_ip} 6379|tail -n1|grep -o [0-9][0-9]*|tr -d "[:cntrl:]")

failed='false'

display_lock_msg=1
display_msg1=1
display_msg2=1
display_msg3=1
display_msg4=1
display_msg5=1
display_msg6=1
display_msg7=1
display_msg8=1

while [ true ]
do
  end_time="$(date -u +%s)"

  export ad_ip=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_ad_ip\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  if [[ ${ad_ip} =~ '192' ]]
  then
    MSG2="AD IP set at $(date)"
    if [ ${display_msg2} -eq 1 ]
    then
      echo ${MSG2}
      display_msg2=0
    fi
  else
    MSG2="AD IP not set"
  fi
  sql_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynsql_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  allinone_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")

  sql_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_sql_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${sql_ready} =~ 'true' ]]
  then
    MSG1="SQL Server Installed at $(date)"
    if [ ${display_msg1} -eq 1 ]
    then
      echo ${MSG1}
      display_msg1=0
    fi
  else
    MSG1="SQL Server Not Installed"
  fi
  
  allinone_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_started} =~ 'true' ]]
  then
    MSG3="Dynamics AllInOne Started Install at $(date)"
    if [ ${display_msg3} -eq 1 ]
    then
      echo ${MSG3}
      display_msg3=0
    fi
  else
    MSG3="Dynamics AllInOne Not Started"
  fi
  if [[ ${allinone_started} =~ 'error' ]]
  then
    MSG3="Dynamics AllInOne Install Failed at $(date)"
    failed='true'
  fi

  allinone_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_ready} =~ 'true' ]]
  then
    MSG4="Dynamics AllInOne Installed at $(date)"
    if [ ${display_msg4} -eq 1 ]
    then
      echo ${MSG4}
      display_msg4=0
    fi
  else
    MSG4="Dynamics AllInOne Not Installed"
  fi
  if [[ ${allinone_ready} =~ 'error' ]]
  then
    MSG4="Dynamics AllInOne Failed at $(date)"
    failed='true'
  fi

  allinone_365_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_365_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_365_started} =~ 'true' ]]
  then
    MSG5="Dynamics AllInOne 365 Upgrade Started at $(date)"
    if [ ${display_msg5} -eq 1 ]
    then
      echo ${MSG5}
      display_msg5=0
    fi
  else
    MSG5="Dynamics AllInOne 365 Upgrade Not Started"
  fi

  allinone_365_done=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_365_done\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_365_done} =~ 'true' ]]
  then
    MSG6="Dynamics AllInOne 365 Upgrade Done at $(date)"
    if [ ${display_msg6} -eq 1 ]
    then
      echo ${MSG6}
      display_msg6=0
    fi
  else
    MSG6="Dynamics AllInOne 365 Upgrade Not Done"
  fi

  allinone_ssrs_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ssrs_start\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_ssrs_started} =~ 'true' ]]
  then
    MSG7="Dynamics AllInOne SSRS Install Started at $(date)"
    if [ ${display_msg7} -eq 1 ]
    then
      echo ${MSG7}
      display_msg7=0
    fi
  else
    MSG7="Dynamics AllInOne SSRS Install Start Not Done"
  fi

  allinone_ssrs_done=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ssrs_done\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${allinone_ssrs_done} =~ 'true' ]]
  then
    MSG8="Dynamics AllInOne SSRS Install Done at $(date)"
    if [ ${display_msg8} -eq 1 ]
    then
      echo ${MSG8}
      echo "Build has finished at $(date -d @${end_time})"
      exit 0
    fi
  else
    MSG8="Dynamics AllInOne SSRS Install Not Done"
  fi
 
  elapsed="$((${end_time}-${start_time}))"
  if [ ${elapsed} -gt 15400 ]
  then
    echo "Build has timed out at $(date -d @${end_time})"
    echo ${MSG1}
    echo ${MSG2}
    echo ${MSG3}
    echo ${MSG4}
    echo ${MSG5}
    echo ${MSG6}
    echo ${MSG7}
    echo ${MSG8}
    exit -1
  fi

  if [[ ${failed} =~ 'true' ]]
  then
    echo "Build has failed at $(date -d @${end_time})"
    echo ${MSG1}
    echo ${MSG2}
    echo ${MSG3}
    echo ${MSG4}
    echo ${MSG5}
    echo ${MSG6}
    echo ${MSG7}
    echo ${MSG8}
    exit -2
  fi

  machine_restart=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_machine_restart\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${machine_restart} =~ 'dyn' ]]
  then
    # print which machine restarted, clear the machine_restart flag again
    echo "Unexpected machine restart: ${machine_restart}"
    echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_machine_restart false\r\n" | nc -w1 ${redis_ip} 6379 >/dev/null 2>&1
  fi
done
