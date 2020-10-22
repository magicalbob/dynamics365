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
  -> class { 'profile::ssrs':
    ad_domain  => 'allinone',
    sql_server => 'allinone',
    fe_server  => ''
  }
  -> class { 'removepuppet':
  }
}
