# Class: role::dynadir
# =================
#
# Active Directory server role.
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
#    include role::dynadir
#
class role::dynadir {
  class { 'base':
  }
  -> class { 'vcredist':
  }
  # active directory does not join domain
  -> class { 'profile::dynadir':
  }
  -> class { 'removepuppet':
  }
}
