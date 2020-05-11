# Class: vcredist
# ===========================
#
# Installs Visual C runtime
# Installs a script to install it and runs the script
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
#    include vcredist
#
class vcredist (
)
{
  file { 'script to install vcredist':
    ensure  => present,
    path    => 'c:/scripts/vcredist.ps1',
    content => epp('vcredist/vcredist.epp')
  }

  -> exec { 'execute script to install vcredist':
    command => 'powershell -File c:/scripts/vcredist.ps1',
    timeout => 0,
    path    => $::path
  }
}
