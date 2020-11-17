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
  -> class { 'vcredist':
  }
  -> class { 'profile::dynamics':
  }
  -> class { 'removepuppet':
  }
}
