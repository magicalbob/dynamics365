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
    command => 'c:\windows\system32\cmd.exe /c schtasks /change /disable /tn apply_puppet',
    path    => $::path
  }
}
