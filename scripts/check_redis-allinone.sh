#!/usr/bin/env bash

redis_name=$(grep redis_ip puppet/hieradata/common.yaml |cut -d: -f2)
redis_ip=$(nslookup -querytype=A ${redis_name} 2> /dev/null | grep ^Address:|tail -n1|cut -d: -f2)
redis_pass=$(grep redis_pass puppet/hieradata/common.yaml |cut -d: -f2)

prefix=$(echo -e  "AUTH ${redis_pass}\r\nGET prefix\r\n" | nc ${redis_ip} 6379|tail -n1|grep -o [0-9][0-9]*|tr -d "[:cntrl:]")

export ad_ip=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_ad_ip\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

allinone_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

sql_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_sql_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

allinone_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
allinone_365_start=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_365_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
allinone_365_done=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_365_done\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
allinone_ssrs_start=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ssrs_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
allinone_ssrs_done=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_allinone_ssrs_done\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

echo "          Prefix is: ${prefix}."
echo "           AD IP is: ${ad_ip}."
echo "   Allinone Started: ${allinone_started}."
echo "          SQL Ready: ${sql_ready}."
echo "     Allinone Ready: ${allinone_ready}."
echo " Allinone 365 Start: ${allinone_365_start}."
echo "  Allinone 365 Done: ${allinone_365_done}."
echo "Allinone SSRS Start: ${allinone_ssrs_start}."
echo " Allinone SSRS Done: ${allinone_ssrs_done}."
