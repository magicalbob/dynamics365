# Class: removepuppet
# =================
#
# Removes the scheduled task that runs puppet on startup.
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
#    include removepuppet
#
class removepuppet(
)
{
  exec { 'remove apply puppet task':
    command => 'powershell -command remove-item -force -path c:\programdata\microsoft\windows\startm~1\programs\startup\apply_puppet.cmd',
    path    => $::path,
  }
}
