# Class: profile::dynamicsusers
# =============================
#
# Create Dynamics users.
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
class profile::dynamicsusers(
  $admin_user = lookup('admin_username'),
  $admin_pass = lookup('admin_password'),
  $ad_domain = lookup('ad_domain'),
  $ad_suffix = lookup('ad_suffix'),
  $fe_server = lookup('fe_server'),
  $crm_user_group = lookup('crm_user_group'),
  $default_org = lookup('default_org'),
  $download_url = lookup('download_url')
)
{
  $dc_string=join(['DC=',$domain.split('[.]').join(',DC=')])
  $use_domain = "${ad_domain}${ad_suffix}"

  file { 'script to export crm users from ad':
    ensure  => present,
    path    => 'c:\scripts\export-users-from-ad.ps1',
    content => epp('profile/export-users-from-ad.epp',{
      dc_string      => $dc_string,
      admin_user     => $admin_user,
      admin_pass     => $admin_pass,
      ad_domain      => $ad_domain,
      crm_user_group => $crm_user_group
    })
  }

  -> file { 'script to import crm users to crm':
    ensure  => present,
    path    => 'c:\scripts\import-crm-users.ps1',
    content => epp('profile/import-crm-users.epp',{
      fe_server   => $fe_server,
      admin_user  => $admin_user,
      admin_pass  => $admin_pass,
      use_domain  => $use_domain,
      default_org => $default_org
    })
  }

  -> exec { 'execute export of crm users':
    command => 'powershell -File c:\scripts\export-users-from-ad.ps1',
    timeout => 0,
    path    => $::path
  }

  -> exec { 'execute import of crm users':
    command => 'powershell -File c:\scripts\import-crm-users.ps1',
    timeout => 0,
    path    => $::path
  }
}
