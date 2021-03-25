# Class: profile::neworg
# ===========================
#
# Runs script to create new Dynamics org.
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
  $default_org = lookup('default_org'),
  $sql_server  = lookup('sql_server')
)
{
  file { 'script to install new org':
    ensure  => present,
    path    => 'c:\scripts\neworg.ps1',
    content => epp('profile/neworg.epp',{
      sql_server => $sql_server
    })
  }

  -> exec { 'run neworg script':
    command => "powershell -file c:\\scripts\\neworg.ps1 ${default_org}",
    path    => $::path,
    timeout => 0
  }
}
