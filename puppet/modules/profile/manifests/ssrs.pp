# Class: profile::ssrs
# ===========================
#
# Installs MS SQL Server Enterprise for SQL Server Reporting Services.
# Sets up the Dynamics Srs Data Connector
#
# Parameters
# ----------
#
#  ad_domain  = The name of the Active Directory domain controller
#  ad_suffix  = The suffix added to ad_domain to form BIOS Name of AD DC
#  sql_server = The name of the SQL Server machine
#  admin_pass = Administrator password to use
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
#    include profile::crmsql
#
class profile::ssrs(
  $ad_domain  = lookup('ad_domain'),
  $ad_suffix  = lookup('ad_suffix'),
  $admin_pass = lookup('admin_password'),
  $sql_server = lookup('sql_server'),
  $fe_server  = lookup('fe_server'),
  $monitor_user = lookup('service_users')['monitor']['username'],
  $monitor_pass = lookup('service_users')['monitor']['password'],
  $quiet_install = lookup('quiet_install'),
  $download_url = lookup('download_url'),
  $dynamics_iso = lookup('dynamics_iso')
)
{
  $use_domain = "${ad_domain}${ad_suffix}"

  file { 'srs config':
    ensure  => present,
    path    => 'c:\scripts\srs-install-config.xml',
    content => epp('profile/srs-install-config.epp',{
      monitor_user => "${use_domain}\\${monitor_user}",
      monitor_pass => $monitor_pass,
      sql_server   => $sql_server
    })
  }

  -> file { 'script to install dynamics ssrs data connector':
    ensure  => present,
    path    => 'c:\scripts\install_dynamics_ssrs.ps1',
    content => epp('profile/install_dynamics_ssrs.epp',{
      sql_server    => $sql_server,
      admin_pass    => $admin_pass,
      fe_server     => $fe_server,
      quiet_install => $quiet_install,
      dynamics_iso  => $dynamics_iso,
      download_url  => $download_url
    })
  }

  -> exec { 'install dynamics ssrs data connector':
    command => 'powershell -File c:\scripts\install_dynamics_ssrs.ps1',
    timeout => 0,
    path    => $::path
  }
}
