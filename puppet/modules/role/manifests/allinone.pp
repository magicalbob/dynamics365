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
  -> class { 'removepuppet':
  }
}
