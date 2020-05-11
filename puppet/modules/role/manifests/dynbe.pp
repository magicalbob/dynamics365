# Class: role::dynbe
# =================
#
# Dynamics Back End role.
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
#    include role::dynbe
#
class role::dynbe {
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
}
