# Class: profile::dynadir
# =======================
#
# Stand up the Active Directory. Installs Windows Feature and the Forest, then restarts.
# After restart, add AD Organizational Unit, add system and user groups, accounts etc.
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
#    include profile::dynadir
#
class profile::dynadir(
)
{
  $ad_suffix = lookup('ad_suffix')
  $safemodeadminpass = lookup('safemodeadminpass')
  $crm_system_group = lookup('crm_system_group')
  $crm_user_group = lookup('crm_user_group')
  $dc_string=join(['DC=',$domain.split('[.]').join(',DC=')])
  $ou_string=join(['OU=ServiceAccounts,',$dc_string])
  $user_string=join(['CN=Users,',$dc_string])
  $new_user=join([$hostname.upcase(),$ad_suffix,'\Administrator'])

  if $facts['identity']['user'] != $new_user {
    exec { 'Install Windows Features':
      command => 'powershell -Command Install-WindowsFeature -Name AD-Domain-Services,DNS,Web-Server,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-Mgmt-Console,Web-Mgmt-Compat,Windows-Identity-Foundation -IncludeManagementTools -Restart',
      timeout => 0,
      path    => $::path
    }
  
    -> file { 'Script to create new forest':
      ensure  => present,
      path    => 'c:\scripts\newforest.ps1',
      content => epp('profile/newforest.epp', {
        safemodeadminpass => $safemodeadminpass,
        ad_suffix         => $ad_suffix
      })
    }
  
    -> exec { 'Install New Forest':
      command => 'powershell -File c:\scripts\newforest.ps1',
      timeout => 0,
      path    => $::path
    }

    -> exec { 'Wait for restart':
      command => 'powershell -Command Start-Sleep -Seconds 180',
      timeout => 0,
      path    => $::path
    }

    -> exec { 'Post forest restart':
      command => 'powershell -Command Restart-Computer -Force',
      timeout => 0,
      path    => $::path
    }
  } else {
    $service_users=lookup('service_users')
    $dynamics_app = $service_users['app']['username']
    $dynamics_async = $service_users['async']['username']
    $dynamics_svcapp = $service_users['svcapp']['username']
    $dynamics_vss = $service_users['vss']['username']
    $dynamics_monitor = $service_users['monitor']['username']
    $dynamics_sandbox = $service_users['sandbox']['username']

    exec { 'Wait before New AD Organizational Unit':
      command => 'powershell -Command Start-Sleep -Seconds 120',
      unless  => "powershell -Command Get-ADOrganizationalUnit '${ou_string}'",
      timeout => 0,
      path    => $::path
    }

    -> exec { 'Add New AD Organizational Unit':
      command => "powershell -Command New-ADOrganizationalUnit -Name 'ServiceAccounts' -ProtectedFromAccidentalDeletion:\$true",
      unless  => "powershell -Command Get-ADOrganizationalUnit '${ou_string}'",
      timeout => 0,
      path    => $::path
    }

    -> exec { "Add ${crm_system_group} Group":
      command => "powershell -Command New-ADGroup -Name \"${crm_system_group}\" -GroupScope Global",
      returns => [0, 1],
      timeout => 0,
      path    => $::path
    }

    -> exec { "Add ${crm_user_group} Group":
      command => "powershell -Command New-ADGroup -Name \"${crm_user_group}\" -GroupScope Global",
      returns => [0, 1],
      timeout => 0,
      path    => $::path
    }

    -> file { 'Script to add service user':
      ensure  => present,
      path    => 'c:\scripts\AddServiceUser.ps1',
      content => epp('profile/addserviceuser.epp',{
        dc_string => $dc_string
      })
    }

    -> file { 'Script to setup service users':
      ensure  => present,
      path    => 'c:\scripts\SetupServiceUsers.ps1',
      content => epp('profile/setupserviceusers.epp',{
        dc_string        => $dc_string,
        ad_suffix        => $ad_suffix,
        dynamics_app     => $dynamics_app,
        dynamics_async   => $dynamics_async,
        dynamics_svcapp  => $dynamics_svcapp,
        dynamics_vss     => $dynamics_vss,
        dynamics_monitor => $dynamics_monitor,
        dynamics_sandbox => $dynamics_sandbox
      })
    }

    -> file { 'Script to logon as a service':
      ensure  => present,
      path    => 'c:\scripts\AddAccountToLogonAsService.ps1',
      content => epp('profile/addaccounttologonasservice.epp',{
        dc_string => $dc_string
      })
    }

    $service_users.each | $user | {
      $username    = $user[1]['username']
      $password    = $user[1]['password']
      $firstname   = $user[1]['firstname']
      $lastname    = $user[1]['lastname']
      $crmgroup    = $user[1]['crmgroup']

      exec { "add service user ${username}":
        command => "powershell -File c:\\Scripts\\AddServiceUser.ps1 -Username \"${username}\" -Password \"${password}\" -Firstname \"${firstname}\" -Lastname \"${lastname}\" -OU \"${ou_string}\" -Domain \"${domain}\"",
        path    => $::path
      }

      if ($crmgroup == true) {
        exec { "add crm system user ${username} to ${crm_system_group} group":
          command => "powershell -Command Add-ADGroupMember -Identity 'CN=${crm_system_group},CN=Users,${dc_string}' -Members ${username}",
          path    => $::path
        }
      }
    }

    exec { 'Exec service user setup':
      command => 'powershell -File c:\scripts\SetupServiceUsers.ps1',
      timeout => 0,
      path    => $::path
    }

    # add a some test users
    range(1,10).each | $auto_user | {
      $username    = "user${auto_user}.test"
      $password    = 'password123~'
      $firstname   = "user${auto_user}"
      $lastname    = 'test'

      exec { "add auto test user ${username}":
        command => "powershell -File c:\\Scripts\\AddServiceUser.ps1 -Username \"${username}\" -Password \"${password}\" -Firstname \"${firstname}\" -Lastname \"${lastname}\" -OU \"${user_string}\" -Domain \"${domain}\"",
        path    => $::path
      }

      -> exec { "add auto test user ${username} to ${crm_user_group} group":
        command => "powershell -Command Add-ADGroupMember -Identity 'CN=${crm_user_group},CN=Users,${dc_string}' -Members ${username}",
        path    => $::path
      }
    }
  }
}
