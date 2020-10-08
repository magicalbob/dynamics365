# Class: profile::dynamics
# =================
#
# Install Dynamics 2016, then upgrade to 365.
# Works out from hieradata whether machine is Front End, Back End or Admin server.
#
# Parameters
# ----------
#
# None.
#
# Variables
# ----------
#
# See below.
#
# Examples
# --------
#
# @example
#    include joindomain
#
class profile::dynamics(
  $ad_suffix = lookup('ad_suffix'),
  $ad_domain = lookup('ad_domain'),
  $sql_server = lookup('sql_server'),
  $admin_pass = lookup('admin_password'),
  $fe_server = lookup('fe_server'),
  $be_server = lookup('be_server'),
  $adm_server = lookup('adm_server'),
  $ssrs_server = lookup('ssrs_server'),
  $dynamics_user = lookup('service_users')['app']['username'],
  $dynamics_pass = lookup('service_users')['app']['password'],
  $sandbox_user = lookup('service_users')['sandbox']['username'],
  $sandbox_pass = lookup('service_users')['sandbox']['password'],
  $async_user  = lookup('service_users')['async']['username'],
  $async_pass  = lookup('service_users')['async']['password'],
  $vss_user     = lookup('service_users')['vss']['username'],
  $vss_pass     = lookup('service_users')['vss']['password'],
  $monitor_user = lookup('service_users')['monitor']['username'],
  $monitor_pass = lookup('service_users')['monitor']['password'],
  $download_url = lookup('download_url'),
  $dynamics_iso = lookup('dynamics_iso'),
  $kb4046795_exe = lookup('kb4046795_exe'),
  $quiet_install = lookup('quiet_install')
)
{
  $dc_string=join(['DC=',$domain.split('[.]').join(',DC=')])
  $ou_string = join(['OU=ServiceAccounts,',$dc_string])
  $use_domain = "${ad_domain}${ad_suffix}"

  file { 'config for dynamics node':
    ensure  => present,
    path    => 'c:\scripts\dynamics_config.xml',
    content => epp('profile/dynamics_config.epp',{
      crm_license_key => lookup('crm_license_key'),
      preferred_dc    => $ad_domain,
      sql_server      => $sql_server,
      fe_server       => $fe_server,
      be_server       => $be_server,
      adm_server      => $adm_server,
      ou_display      => 'CRMDev',
      ou_name         => 'CRMDev',
      ou_value        => $ou_string,
      reporting_url   => "http://${ssrs_server}/reportserver",
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
