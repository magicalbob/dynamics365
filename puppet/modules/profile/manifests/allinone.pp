# Class: profile::allinone
# =================
#
# Stand up the Active Directory. Installs Windows Feature and the Forest, then restarts.
# After restart, add AD Organizational Unit, add system and user groups, accounts etc.
# Then install SQL Server, and Dynamics (full stack)
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
#    include profile::allinone
#
class profile::allinone(
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
  $ad_domain   = 'allinone'
  $sql_server  = 'allinone'
  $sql_svc_pass = lookup('service_users')['sqlsvc']['password']
  $download_url = lookup('download_url')
  $sql_iso = lookup('sql_iso')
  $ssm_exe = lookup('ssm_exe')

  $admin_pass = lookup('admin_password')
  $fe_server = ''
  $be_server = ''
  $adm_server = ''
  $ssrs_server = ''
  $dynamics_user = lookup('service_users')['app']['username']
  $dynamics_pass = lookup('service_users')['app']['password']
  $sandbox_user = lookup('service_users')['sandbox']['username']
  $sandbox_pass = lookup('service_users')['sandbox']['password']
  $async_user  = lookup('service_users')['async']['username']
  $async_pass  = lookup('service_users')['async']['password']
  $vss_user     = lookup('service_users')['vss']['username']
  $vss_pass     = lookup('service_users')['vss']['password']
  $monitor_user = lookup('service_users')['monitor']['username']
  $monitor_pass = lookup('service_users')['monitor']['password']
  $dynamics_iso = lookup('dynamics_iso')
  $kb4046795_exe = lookup('kb4046795_exe')
  $quiet_install = lookup('quiet_install')

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

    file { 'script to install sql server':
      ensure  => present,
      path    => 'c:\scripts\install_sql_server.ps1',
      content => epp('profile/install_sql_server.epp',{
        ad_domain    => $ad_domain,
        ad_suffix    => $ad_suffix,
        sql_svc_pass => $sql_svc_pass,
        download_url => $download_url,
        sql_iso      => $sql_iso,
        ssm_exe      => $ssm_exe
      })
    }
  
    -> exec { 'install sql server':
      command => 'powershell -File c:\scripts\install_sql_server.ps1',
      timeout => 0,
      path    => $::path
    }
  
    -> file { 'script to add sql admin user':
      ensure  => present,
      path    => 'c:\scripts\addsqladminuser.ps1',
      content => epp('profile/addsqladminuser.epp',{
        sql_server => $sql_server,
        admin_pass => $admin_pass
      })
    }
  
    -> exec { 'add sql admin user':
      command => 'powershell -File c:\Scripts\addsqladminuser.ps1',
      path    => $::path
    }
  
    -> file { 'script to add sql user':
      ensure  => present,
      path    => 'c:\scripts\addsqluser.ps1',
      content => epp('profile/addsqluser.epp',{
        sql_server => $sql_server,
        ad_domain  => $ad_domain,
        ad_suffix  => $ad_suffix
      })
    }
  
    $service_users.each | $db_user | {
      $username    = $db_user[1]['username']
      $password    = $db_user[1]['password']
      $database    = $db_user[1]['database']
  
      exec { "add sql user ${username}":
        command => "powershell -File c:\\Scripts\\addsqluser.ps1 -Username \"${username}\" -Password \"${password}\" -Database \"${database}\"",
        path    => $::path
      }
    }

    $use_domain = "${ad_domain}${ad_suffix}"
  
    file { 'config for dynamics node':
      ensure  => present,
      path    => 'c:\scripts\dynamics_config.xml',
      content => epp('profile/dynamics_config.epp',{
        crm_license_key => lookup('crm_license_key'),
        preferred_dc    => $ad_domain,
        sql_server      => $sql_server,
        fe_server       => '',
        be_server       => '',
        adm_server      => '',
        ou_display      => 'CRMDev',
        ou_name         => 'CRMDev',
        ou_value        => $ou_string,
        reporting_url   => "http://127.0.0.1/reportserver",
        dynamics_port   => '5555',
        dynamics_user   => "${use_domain}\\${dynamics_user}",
        dynamics_pass   => $dynamics_pass,
        sandbox_user    => "${use_domain}\\${sandbox_user}",
        sandbox_pass    => $sandbox_pass,
        deploy_user     => "${use_domain}\\administrator",
        deploy_pass     =>  $admin_pass,
        async_user      => "${use_domain}\\${async_user}",
        async_pass      => $async_pass,
        vss_user        => "${use_domain}\\${vss_user}",
        vss_pass        => $vss_pass,
        monitor_user    => "${use_domain}\\${monitor_user}",
        monitor_pass    => $monitor_pass
      })
    }
  
    -> file { 'script to install dynamics':
      ensure  => present,
      path    => 'c:\scripts\install_dynamics.ps1',
      content => epp('profile/install_dynamics_multi.epp',{
        config_file   => 'c:\scripts\dynamics_config.xml',
        sql_server    => $sql_server,
        admin_pass    => $admin_pass,
        fe_server     => $fe_server,
        be_server     => $be_server,
        adm_server    => $adm_server,
        download_url  => $download_url,
        dynamics_iso  => $dynamics_iso,
        kb4046795_exe => $kb4046795_exe,
        quiet_install => $quiet_install
      })
    }
  
    -> exec { 'add DYNAPP to local performance log users':
      command => "powershell -Command \"Add-LocalGroupMember -Group 'Performance Log Users' -Member ${dynamics_user}\"",
      returns => [0, 1],
      timeout => 0,
      path    => $::path
    }
  
    -> exec { 'add DYNASYNC to local performance log users':
      command => "powershell -Command \"Add-LocalGroupMember -Group 'Performance Log Users' -Member DYNAsync\"",
      returns => [0, 1],
      timeout => 0,
      path    => $::path
    }
  
    -> exec { 'install dynamics':
      command => 'powershell -File c:\scripts\install_dynamics.ps1',
      timeout => 0,
      path    => $::path
    }
  }
}
