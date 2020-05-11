# Class: base
# ===========================
#
# Base setup of machines in the dynamics cluster.
# Sets up FACTERLIB so custom puppet facts work.
# Sets the machine time zone to UTC.
# Creates the c:\scripts directory where scripts will be placed.
# Turns off IPv6.
# Turns of Internet Explorer 'security'.
# Turns off Windows firewalls.
# Backs up the unattend.xml, used by sysprep, if it is not backed up.
# Copies the back up of unattend.xml back, effectively reverting to original.
# Update the unattend.xml to auto logon the administrator with right password.
# Enable and start the Windows search service.
# Set up the script to run puppet and an on boot task to run it.
#
# Parameters
# ----------
#
# None.
#
# Variables
# ----------
#
# ad_domain_url: Top Level Domain of the machines
#
# Examples
# --------
#
# @example
#    include base
#
class base(
  $ad_domain_url = lookup('ad_domain_url'),
  $redis_ip = lookup('redis_ip'),
  $redis_pass = lookup('redis_pass')
)
{
  $choco_packages = [ '7zip', 'powershell-core', 'netcat' ]

  windows_env { 'set path to facter':
    ensure    => present,
    variable  => 'FACTERLIB',
    value     => 'c:\programdata\puppetlabs\code\environments\production\facter',
    mergemode => clobber
  }

  -> exec { 'Set time zone to UTC':
    command => "Powershell -Command \"Set-TimeZone -Id 'UTC'\"",
    path    => $::path,
  }

  -> package { $choco_packages:
    ensure   => 'installed',
    provider => chocolatey
  }

  # make scripts directory
  -> file { 'scripts directory':
    ensure => directory,
    path   => 'c:\scripts'
  }

  # Turn off firewalls, security groups will manage protection
  -> exec { 'turn off firewalls':
    command => 'cmd.exe /c netsh advfirewall set allprofiles state off',
    path    => $::path,
  }

  -> file { 'disable internet explorer enhanced security script':
    ensure  => present,
    path    => 'c:\scripts\disable_ieesc.ps1',
    content => epp('profile/disable_ieesc.epp',{
    })
  }

  -> registry::value { 'disable ipv6':
    key   => 'HKLM\System\CurrentControlSet\Services\Tcpip6\Parameters',
    value => 'DisabledComponents',
    type  => 'dword',
    data  => 16,
  }

  -> exec { 'run ieesc script':
    command => 'cmd.exe /c powershell -File c:\scripts\disable_ieesc.ps1',
    path    => $::path,
  }

  $admin_pass = $facts['admin_pass']

  exec { 'backup sysprep unattend file':
    command => 'cmd.exe /c copy /y c:\scripts\unattend.xml c:\scripts\unattend.xml.backup',
    unless  => 'c:\windows\system32\cmd.exe /c dir c:\scripts\unattend.xml.backup',
    path    => $::path,
  }

  -> exec { 'restore backed up sysprep unattend file':
    command => 'cmd.exe /c copy /y c:\scripts\unattend.xml.backup c:\scripts\unattend.xml',
    path    => $::path,
  }

  -> file_line { 'Input Locale':
    path               => 'c:\scripts\unattend.xml',
    line               => '      <InputLocale>en-GB</InputLocale>',
    match              => '<InputLocale>en-US</InputLocale>',
    append_on_no_match => false
  }

  -> file_line { 'System Locale':
    path               => 'c:\scripts\unattend.xml',
    line               => '      <SystemLocale>en-GB</SystemLocale>',
    match              => '<SystemLocale>en-US</SystemLocale>',
    append_on_no_match => false
  }

  -> file_line { 'User Locale':
    path               => 'c:\scripts\unattend.xml',
    line               => '      <UserLocale>en-GB</UserLocale>',
    match              => '<UserLocale>en-US</UserLocale>',
    append_on_no_match => false
  }

  -> file_line { 'user accounts':
    path               => 'c:\scripts\unattend.xml',
    line               => "      <RegisteredOwner>EC2</RegisteredOwner>
      <UserAccounts>
        <AdministratorPassword>
          <Value>${admin_pass}</Value>
          <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <AutoLogon>
        <Password>
          <Value>${admin_pass}</Value>
          <PlainText>true</PlainText>
        </Password>
        <Enabled>true</Enabled>
        <Username>administrator</Username>
      </AutoLogon>",
    match              => '<RegisteredOwner>EC2</RegisteredOwner>',
    append_on_no_match => false
  }

  # set admin user password to never expire
  -> exec { 'set admin password to never expire':
    command => 'powershell -command "Set-LocalUser -PasswordNeverExpires 1 -Name Administrator"',
    path    => $::path
  }

  # enable windows search service
  -> exec { 'set windows search service to auto':
    command => 'c:\windows\system32\cmd.exe /c powershell -Command Set-Service WSearch -StartupType Automatic',
    path    => $::path
  }

  -> exec { 'start windows search service':
    command => 'c:\windows\system32\cmd.exe /c powershell -Command Start-Service WSearch',
    path    => $::path
  }

  # disable the puppet service, apply_puppet.ps1 will run it
  -> service { 'puppet':
    ensure => 'stopped',
    enable => false
  }

  # set up puppet to run when machine starts
  -> file { 'puppet apply script':
    ensure  => present,
    path    => 'c:\scripts\apply_puppet.ps1',
    content => epp('profile/apply_puppet.epp',{
      ad_domain_url => $ad_domain_url,
      redis_ip      => $redis_ip,
      redis_pass    => $redis_pass
    })
  }

  -> file { 'script to setup apply_puppet task':
    ensure  => present,
    path    => 'c:\scripts\setup_task.ps1',
    content => epp('profile/setup_task.epp',{ user_name => 'Administrator' })
  }

  -> exec { 'schedule apply puppet':
    command => 'c:\windows\system32\cmd.exe /c powershell -File c:\scripts\setup_task.ps1',
    unless  => 'c:\windows\system32\cmd.exe /c schtasks /query /tn apply_puppet',
    path    => $::path
  }
}
