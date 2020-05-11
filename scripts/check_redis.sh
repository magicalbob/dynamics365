#!/usr/bin/env bash

redis_ip=$(grep redis_ip puppet/hieradata/common.yaml |cut -d: -f2)
redis_pass=$(grep redis_pass puppet/hieradata/common.yaml |cut -d: -f2)

prefix=$(echo -e  "AUTH ${redis_pass}\r\nGET prefix\r\n" | nc ${redis_ip} 6379|tail -n1|grep -o [0-9][0-9]*|tr -d "[:cntrl:]")

ad_ip=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_ad_ip\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

ad_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynad_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

sql_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynsql_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

sql_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_sql_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

fe_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

fe_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
fe_365_start=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_365_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
fe_365_done=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynfe_365_done\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

ssrs_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_ssrs_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

be_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

be_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
be_365_start=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_365_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
be_365_done=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynbe_365_done\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

adm_started=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

adm_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
adm_365_start=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_365_started\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")
adm_365_done=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_dynadm_365_done\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

org_ready=$(echo -e  "AUTH ${redis_pass}\r\nGET ${prefix}_neworg_ready\r\n" | nc ${redis_ip} 6379 |tail -n1|tr -d "[:cntrl:]")

echo "    Prefix is: ${prefix}."
echo "     AD IP is: ${ad_ip}."
echo "   AD Started: ${ad_started}."
echo "  SQL Started: ${sql_started}."
echo "    SQL Ready: ${sql_ready}."
echo "   FE Started: ${fe_started}."
echo "     FE Ready: ${fe_ready}."
echo " FE 365 Start: ${fe_365_start}."
echo "  FE 365 Done: ${fe_365_done}."
echo "   SSRS Ready: ${ssrs_ready}."
echo "   BE Started: ${be_started}."
echo "     BE Ready: ${be_ready}."
echo " BE 365 Start: ${be_365_start}."
echo "  BE 365 Done: ${be_365_done}."
echo "  ADM Started: ${adm_started}."
echo "    ADM Ready: ${adm_ready}."
echo "ADM 365 Start: ${adm_365_start}."
echo " ADM 365 Done: ${adm_365_done}."
echo "    Org Ready: ${org_ready}."
