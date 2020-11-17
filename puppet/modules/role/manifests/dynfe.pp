# Class: role::dynfe
# =================
#
# Dynamics Front End role.
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
#    include role::dynfe
#
class role::dynfe {
  class { 'base':
  }
  -> class { 'vcredist':
  }
  -> class { 'profile::dynamics':
  }
  -> class { 'removepuppet':
  }
}
