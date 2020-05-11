# Class: role::dynad
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
#    include role::dynad
#
class role::dynad {
  class { 'base':
  }
  -> class { 'vcredist':
  }
  # active directory does not join domain
  -> class { 'profile::dynad':
  }
  -> class { 'removepuppet':
  }
}
