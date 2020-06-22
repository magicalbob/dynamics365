# Class: role::dynadm
# =================
#
# Dynamics Admin server role.
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
#    include role::dynadm
#
class role::dynadm {
  class { 'base':
  }
  -> class { 'joindomain':
  }
  -> class { 'vcredist':
  }
  -> class { 'profile::dynamics':
  }
  -> class { 'removepuppet':
  }
  -> class { 'profile::neworg':
  }
  -> class { 'profile::dynamicsusers':
  }
}
