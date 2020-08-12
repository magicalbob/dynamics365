#!/usr/bin/env bash

start_time="$(date -u +%s)"
echo "Start time of org test is $(date -d @$start_time)"

redis_name=$(grep redis_ip puppet/hieradata/common.yaml |cut -d: -f2)
redis_ip=$(nslookup -querytype=A ${redis_name} | grep ^Address:|tail -n1|cut -d\  -f2)
redis_pass=$(grep redis_pass puppet/hieradata/common.yaml |cut -d: -f2)

# read prefix for redis keys for this build
prefix=$(cat prefix)

while [ true ]
do
  end_time="$(date -u +%s)"

  neworg_ready=$(echo -e "AUTH ${redis_pass}\r\nGET ${prefix}_neworg_ready\r\n" | nc -w1 ${redis_ip} 6379 2>/dev/null|tail -n1)
  if [[ $neworg_ready =~ 'true' ]]
  then
    echo .
    echo "New Org has finished at $(date -d @$end_time)"
    MSG1="New Org Created"
    echo $MSG1
    exit 0
  else
    MSG1="New Org Not Created"
  fi
 
  elapsed="$(($end_time-$start_time))"
  if [ $elapsed -gt 7200 ]
  then
    echo .
    echo "Build has timed out at $(date -d @$end_time)"
    echo $MSG1
    exit -1
  fi

  echo -n .
done
