# Class: profile::neworg
# ===========================
#
# Installs python3 and pyautogui. Runs script to create new Dynamics org.
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
#    include profile::neworg
#
class profile::neworg(
  $default_org = lookup('default_org')
)
{
  $choco_packages = [ 'python3' ]

  package { $choco_packages:
    ensure   => 'installed',
    provider => chocolatey
  }

  -> exec { 'pip install pyautogui':
    command => 'cmd.exe /c c:\python38\scripts\pip install pyautogui',
    path    => $::path,
  }

  -> exec { 'pip install pywin32':
    command => 'cmd.exe /c c:\python38\scripts\pip install pywin32',
    path    => $::path,
  }

  -> file { 'script to install new org':
    ensure  => present,
    path    => 'c:\scripts\neworg.py',
    content => epp('profile/neworg.epp',{
    })
  }

  -> exec { 'run neworg script':
    command => "cmd.exe /c c:\\python38\\python c:\\scripts\\neworg.py ${default_org}",
    path    => $::path,
    timeout => 0
  }
}
