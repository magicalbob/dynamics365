# Class: joindomain
# =================
#
# Joins an AD domain.
#
# Parameters
# ----------
#
# None.
#
# Variables
# ----------
#
# ad_domain: the hostname of the AD server
# ad_domain_url: Top Level Domain of all the machines
# ad_suffix: text added to the end of the hostname, e.g. DEV, cos of, er, Widows
#
# Examples
# --------
#
# @example
#    include joindomain
#
class joindomain(
  $ad_domain = lookup('ad_domain'),
  $ad_suffix = lookup('ad_suffix'),
  $ad_domain_url = lookup('ad_domain_url'),
  $reboot_timeout = lookup('reboot_timeout')
)
{
  $dc_string=join(['DC=',$domain.split('[.]').join(',DC=')])
  $ou_string=join(['OU=ServiceAccounts,',$dc_string])
  $admin_pass = $facts['admin_pass']

  # allow getting and setting of flags using redis
  class { 'flagman': }

  if ( $facts['addomain'] == "${ad_domain}${ad_suffix}" ) {
    notice("Machine ${hostname} is already part of domain ${ad_domain}${ad_suffix}")
  } else {
    file { 'script to set dns/wins server':
      ensure  => present,
      path    => 'c:\scripts\setwinsnet.ps1',
      content => epp('joindomain/setwinsnet.epp',{
      })
    }
  
    -> file { 'script to join domain':
      ensure  => present,
      path    => 'c:\scripts\joindomain.ps1',
      content => epp('joindomain/joindomain.epp',{
        admin_pass     => $admin_pass,
        ad_domain_url  => $ad_domain_url,
        ad_domain      => $ad_domain,
        ou_string      => $ou_string,
        reboot_timeout => $reboot_timeout
      })
    }
  
    -> exec { 'set dns/wins server':
      command  => 'powershell -File c:\scripts\setwinsnet.ps1',
      timeout  => 0,
      path     => $::path,
      returns  => [0, 1],
      provider => powershell
    }
  
    -> exec { 'join domain':
      command  => 'powershell -File c:\scripts\joindomain.ps1',
      timeout  => 0,
      path     => $::path,
      returns  => [0, 1],
      provider => powershell
    }
  
    -> exec { 'enable psremoting':
      command  => 'Enable-PSRemoting -Force',
      timeout  => 0,
      path     => $::path,
      returns  => [0, 1],
      provider => powershell
    }
  
    -> exec { 'trust all machines for psremoting':
      command  => 'Set-Item wsman:\localhost\client\trustedhosts * -Force',
      timeout  => 0,
      path     => $::path,
      returns  => [0, 1],
      provider => powershell
    }

    -> exec { 'set default domain to log in as':
      command => "c:\\windows\\system32\\cmd.exe /c Reg Add \"HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\" /v DefaultDomainName /t REG_SZ /d \"${ad_domain}${ad_suffix}\" /f",
      path    => $::path
    }

    -> exec { 'restart computer now domain joined':
      command  => 'Restart-Computer -Force',
      path     => $::path,
      returns  => [0, -1],
      provider => powershell
    }

    -> exec { 'Wait for restart':
      command => 'powershell -Command Start-Sleep -Seconds 360',
      timeout => 0,
      path    => $::path
    }
  }
}
