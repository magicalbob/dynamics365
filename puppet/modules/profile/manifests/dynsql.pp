# Class: profile::dynsql
# =================
#
# Setup SQL Server. Adds script to install it, and runs the script. Adds the admin
# user, and the other dynamics users/service accounts.
#
# Parameters
# ----------
#
# None.
#
# Variables
# ----------
#
# 
#  $ad_domain    = The hostname of the Active Directory server
#  $ad_suffix    = The suffix added to machine names for join of domain
#  $sql_server   = The address of the sql server?
#  $sql_svc_pass = The password of the SQL service user
#  $download_url = The url where sql_iso & ssm_exe can be downloaded
#  $sql_iso      = The iso used for SQL Server Install
#  $ssm_exe      = The exe used for management tool install
#
# Examples
# --------
#
# @example
#    include profile::dynsql
#
class profile::dynsql(
  $ad_domain   = lookup('ad_domain'),
  $ad_suffix   = lookup('ad_suffix'),
  $admin_user  = lookup('admin_username'),
  $admin_pass  = lookup('admin_password'),
  $sql_server  = lookup('sql_server'),
  $sql_svc_pass = lookup('service_users')['sqlsvc']['password'],
  $download_url = lookup('download_url'),
  $sql_iso = lookup('sql_iso'),
  $ssm_exe = lookup('ssm_exe')
)
{
  file { 'script to install sql server':
    ensure  => present,
    path    => 'c:\scripts\install_sql_server.ps1',
    content => epp('profile/install_sql_server.epp',{
      ad_domain    => $ad_domain,
      ad_suffix    => $ad_suffix,
      admin_user   => $admin_user,
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
      ad_domain  => $ad_domain,
      ad_suffix  => $ad_suffix,
      admin_user => $admin_user,
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

  $service_users=lookup('service_users')

  $service_users.each | $db_user | {
    $username    = $db_user[1]['username']
    $password    = $db_user[1]['password']
    $database    = $db_user[1]['database']

    exec { "add sql user ${username}":
      command => "powershell -File c:\\Scripts\\addsqluser.ps1 -Username \"${username}\" -Password \"${password}\" -Database \"${database}\"",
      path    => $::path
    }
  }
}
