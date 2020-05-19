#!/usr/bin/env python

import os
import winrm

try:
  s=winrm.Session(os.environ["ad_ip"],auth=("administrator",os.environ["admin_password"]))
except:
  pass

ad_out=""

try:
  ad_out=str(s.run_cmd("powershell -command (Get-ADComputer -Filter *).Name").std_out).replace("\\r\\n",", ")
except:
  pass

print(ad_out.replace("\r\n",", "))
