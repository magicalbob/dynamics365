# Class: role::dynsql
# =================
#
# SQL Server role.
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
#    include role::dynsql
#
class role::dynsql {
  class { 'base':
  }
  -> class { 'joindomain':
  }
  -> class { 'vcredist':
  }
  -> class { 'profile::dynsql':
  }
  -> class { 'profile::ssrs':
  }
  -> class { 'removepuppet':
  }
}
