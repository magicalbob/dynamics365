# Class: role::allinone
# =================
#
# Complete Dynamics on one machine.
# 
# Parameters
# ----------
#
# None.
# 
# Variables
# ----------
#
# None.
#
# Examples
# --------
#
# @example
#    include role::allinone
#
class role::allinone {
  class { 'base':
  }
  -> class { 'vcredist':
  }
  -> class { 'profile::allinone':
  }
  -> exec { 'set ssrs start flag in redis':
    command => 'powershell -command "c:\scripts\flagmanset.ps1 -Name allinone_ssrs_start -Value true"',
    timeout => 0,
    path    => $::path
  }
  -> class { 'profile::ssrs':
    ad_domain  => 'allinone',
    sql_server => 'allinone',
    fe_server  => ''
  }
  -> exec { 'set ssrs done flag in redis':
    command => 'powershell -command "c:\scripts\flagmanset.ps1 -Name allinone_ssrs_done -Value true"',
    timeout => 0,
    path    => $::path
  }
  -> class { 'removepuppet':
  }
}
