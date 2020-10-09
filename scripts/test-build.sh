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

virtualenv .py > /dev/null 2>&1

. .py/bin/activate > /dev/null 2>&1

pip install pywinrm > /dev/null 2>&1

export admin_password=$(grep admin_password ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')

# read prefix for redis keys for this build
prefix=$(cat prefix)

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
display_msg9=1
display_msg10=1
display_msg11=1
display_msgAD=1
display_msgSQL=1
display_msgFE=1
display_msgBE=1
display_msgADM=1

while [ true ]
do
  export ad_ip=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_ad_ip\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  ad_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynadir_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  sql_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynsql_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  fe_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  be_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  adm_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1|tr -d "[:cntrl:]")
  if [ "${ad_started}" == "true" ] && \
     [ "${sql_started}" == "true" ] && \
     [ "${fe_started}" == "true" ] && \
     [ "${be_started}" == "true" ] && \
     [ "${adm_started}" == "true" ]
  then
    if [ ${display_lock_msg} -eq 1 ]
    then
      echo "Lock released at $(date)"
      display_lock_msg=0
      resp=1
      while [ $resp -ne 0 ]
      do
        echo -e "AUTH ${redis_pass}\r\nDEL LOCK\r\n" | nc -w1 ${redis_ip} 6379 > /dev/null 2>&1
        resp=$?
      done
    fi
  else
    LOCK=$(date +"%s")
    resp=1
    while [ $resp -ne 0 ]
    do
      echo -e "AUTH ${redis_pass}\r\nSET LOCK ${LOCK}\r\n" | nc -w1 ${redis_ip} 6379 >/dev/null 2>&1
      resp=$?
    done
  fi

  ad_machines=$($(dirname $0)/check_winrm.py)
  if [[ "$ad_machines" =~ "DYNADIR," ]]
  then
    if [ ${display_msgAD} -eq 1 ]
    then
      echo "Domain set up on DYNADIR at $(date)"
      display_msgAD=0
    fi
  fi

  if [[ "$ad_machines" =~ "DYNSQL," ]]
  then
    if [ ${display_msgSQL} -eq 1 ]
    then
      echo "Domain joined by DYNSQL at $(date)"
      display_msgSQL=0
    fi
  fi

  if [[ "$ad_machines" =~ "DYNFE," ]]
  then
    if [ ${display_msgFE} -eq 1 ]
    then
      echo "Domain joined by DYNFE at $(date)"
      display_msgFE=0
    fi
  fi

  if [[ "$ad_machines" =~ "DYNBE," ]]
  then
    if [ ${display_msgBE} -eq 1 ]
    then
      echo "Domain joined by DYNBE at $(date)"
      display_msgBE=0
    fi
  fi

  if [[ "$ad_machines" =~ "DYNADM," ]]
  then
    if [ ${display_msgADM} -eq 1 ]
    then
      echo "Domain joined by DYNADM at $(date)"
      display_msgADM=0
    fi
  fi

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
  
  dynfe_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynfe_ready} =~ 'true' ]]
  then
    MSG2="Dynamics Front End Installed at $(date)"
    if [ ${display_msg2} -eq 1 ]
    then
      echo ${MSG2}
      display_msg2=0
    fi
  else
    MSG2="Dynamics Front End Not Installed"
  fi
  if [[ ${dynfe_ready} =~ 'error' ]]
  then
    MSG2="Dynamics Front End Failed at $(date)"
    failed='true'
  fi
  
  ssrs_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_ssrs_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${ssrs_ready} =~ 'true' ]]
  then
    MSG3="Dynamics Report Server Installed at $(date)"
    if [ ${display_msg3} -eq 1 ]
    then
      echo ${MSG3}
      display_msg3=0
    fi
  else
    MSG3="Dynamics Report Server Not Installed"
  fi
  
  dynbe_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynbe_ready} =~ 'true' ]]
  then
    MSG4="Dynamics Back End Installed at $(date)"
    if [ ${display_msg4} -eq 1 ]
    then
      echo ${MSG4}
      display_msg4=0
    fi
  else
    MSG4="Dynamics Back End Not Installed"
  fi
  if [[ ${dynbe_ready} =~ 'error' ]]
  then
    MSG4="Dynamics Back End Failed at $(date)"
    failed='true'
  fi
  
  end_time="$(date -u +%s)"

  dynadm_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynadm_ready} =~ 'true' ]]
  then
    MSG5="Dynamics Admin Installed at $(date)"
    if [ ${display_msg5} -eq 1 ]
    then
      echo ${MSG5}
      display_msg5=0
    fi
  else
    MSG5="Dynamics Admin Not Installed"
  fi
  if [[ ${dynadm_ready} =~ 'error' ]]
  then
    MSG5="Dynamics Admin Failed at $(date)"
    failed='true'
  fi

  dynfe_365_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_365_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynfe_365_started} =~ 'true' ]]
  then
    MSG6="Dynamics Front End 365 Upgrade Started at $(date)"
    if [ ${display_msg6} -eq 1 ]
    then
      echo ${MSG6}
      display_msg6=0
    fi
  else
    MSG6="Dynamics Front End 365 Upgrade Not Started"
  fi

  dynfe_365_done=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_365_done\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynfe_365_done} =~ 'true' ]]
  then
    MSG7="Dynamics Front End 365 Upgrade Done at $(date)"
    if [ ${display_msg7} -eq 1 ]
    then
      echo ${MSG7}
      display_msg7=0
    fi
  else
    MSG7="Dynamics Front End 365 Upgrade Not Done"
  fi

  dynbe_365_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_365_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynbe_365_started} =~ 'true' ]]
  then
    MSG8="Dynamics Back End 365 Upgrade Started at $(date)"
    if [ ${display_msg8} -eq 1 ]
    then
      echo ${MSG8}
      display_msg8=0
    fi
  else
    MSG8="Dynamics Back End 365 Upgrade Not Started"
  fi

  dynbe_365_done=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_365_done\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynbe_365_done} =~ 'true' ]]
  then
    MSG9="Dynamics Back End 365 Upgrade Done at $(date)"
    if [ ${display_msg9} -eq 1 ]
    then
      echo ${MSG9}
      display_msg9=0
    fi
  else
    MSG9="Dynamics Back End 365 Upgrade Not Done"
  fi

  dynadm_365_started=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_365_started\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynadm_365_started} =~ 'true' ]]
  then
    MSG10="Dynamics Admin 365 Upgrade Started at $(date)"
    if [ ${display_msg10} -eq 1 ]
    then
      echo ${MSG10}
      display_msg10=0
    fi
  else
    MSG10="Dynamics Admin 365 Upgrade Not Started"
  fi

  dynadm_365_done=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_365_done\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${dynadm_365_done} =~ 'true' ]]
  then
    MSG11="Dynamics Admin 365 Upgrade Done at $(date)"
    if [ ${display_msg11} -eq 1 ]
    then
      echo ${MSG11}
      display_msg11=0
    fi
  else
    MSG11="Dynamics Admin 365 Upgrade Not Done"
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
    echo ${MSG9}
    echo ${MSG10}
    echo ${MSG11}
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
    echo ${MSG9}
    echo ${MSG10}
    echo ${MSG11}
    exit -2
  fi

  if [[ ${dynfe_365_done} =~ 'true' ]] && [[ ${dynbe_365_done} =~ 'true' ]] && [[ ${dynadm_365_done} =~ 'true' ]]
  then
    echo "Build has finished at $(date -d @${end_time})"
    exit 0
  fi

  machine_restart=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_machine_restart\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ ${machine_restart} =~ 'dyn' ]]
  then
    # print which machine restarted, clear the machine_restart flag again
    echo "Unexpected machine restart: ${machine_restart}"
    echo -e "AUTH ${redis_pass}\r\nSET ${prefix}_machine_restart false\r\n" | nc -w1 ${redis_ip} 6379 >/dev/null 2>&1
  fi
done
