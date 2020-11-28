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
  $ad_domain = lookup('ad_domain'),
  $ad_domain_url = lookup('ad_domain_url'),
  $redis_ip = lookup('redis_ip'),
  $redis_pass = lookup('redis_pass'),
  $admin_user = lookup('admin_username'),
  $admin_pass = lookup('admin_password'),
  $ad_suffix = lookup('ad_suffix'),
  $reboot_timeout = lookup('reboot_timeout'),
  $dc_string=join(['DC=',$ad_domain_url.split('[.]').join(',DC=')]),
  $ou_string=join(['OU=ServiceAccounts,',$dc_string])
)
{
  $choco_packages = [ '7zip', 'powershell-core', 'netcat' ]

  user { $admin_user:
    ensure => 'present',
    groups => 'administrators'
  }

  -> group { 'Remote Desktop Users':
    ensure  => 'present',
    members => $admin_user
  }

  -> exec { 'Set time zone to UTC':
    command => "Set-TimeZone -Id 'UTC'",
    path    => $::path,
    provider=> powershell,
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

  -> registry::value { 'disable uac':
    key   => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'EnableLUA',
    type  => 'dword',
    data  => 0,
  }

  -> registry::value { 'disable uac path':
    key   => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'EnableSecureUIAPaths',
    type  => 'dword',
    data  => 0,
  }

  -> registry::value { 'disable uac consent prompt behaviour':
    key   => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'ConsentPromptBehavior',
    type  => 'dword',
    data  => 0,
  }

  -> registry::value { 'disable uac consent prompt user behaviour':
    key   => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'ConsentPromptBehaviorUser',
    type  => 'dword',
    data  => 0,
  }

  -> exec { 'run ieesc script':
    command => 'cmd.exe /c powershell -File c:\scripts\disable_ieesc.ps1',
    path    => $::path,
  }

  -> exec { 'backup sysprep unattend file':
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
          <LocalAccounts>
              <LocalAccount wcm:action= \"add\" >
                  <Password>
                      <Value>${admin_pass}</Value>
                      <PlainText>true</PlainText>
                  </Password>
                  <Description>Admin user</Description>
                  <DisplayName>${admin_user}</DisplayName>
                  <Name>${admin_user}</Name>
                  <Group>Administrators</Group>
              </LocalAccount>
          </LocalAccounts>
      </UserAccounts>
      <AutoLogon>
          <Password>
              <Value>${admin_pass}</Value>
              <PlainText>true</PlainText>
          </Password>
          <Enabled>true</Enabled>
          <Username>${admin_user}</Username>
      </AutoLogon>",
    match              => '<RegisteredOwner>EC2</RegisteredOwner>',
    append_on_no_match => false
  }

  # enable windows search service
  -> exec { 'set windows search service to auto':
    command => 'Set-Service WSearch -StartupType Automatic',
    provider=> powershell,
    path    => $::path
  }

  -> exec { 'start windows search service':
    command  => 'Start-Service WSearch',
    provider => powershell,
    path     => $::path
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
      redis_pass    => $redis_pass,
      ad_domain     => $ad_domain,
      ad_suffix     => $ad_suffix,
      admin_user    => $admin_user,
      admin_pass    => $admin_pass
    })
  }

  -> file { 'script to get redis prefix':
    ensure  => present,
    path    => 'c:\scripts\get_prefix.ps1',
    content => epp('profile/get_prefix.epp',{
      redis_ip      => $redis_ip,
      redis_pass    => $redis_pass
    })
  }

  -> file { 'script to run script to run apply_puppet script':
    ensure  => present,
    path    => 'c:\programdata\microsoft\windows\startm~1\programs\startup\apply_puppet.cmd',
    content => epp('profile/cmd_apply_puppet.epp',{
    })
  }

  -> file { 'script to run apply_puppet script':
    ensure  => present,
    path    => 'c:\scripts\cmd_apply_puppet.ps1',
    content => epp('profile/cmd_apply_puppet_ps1.epp',
                   {
                     admin_user     => $admin_user,
                     admin_pass     => $admin_pass,
                     ad_domain      => $ad_domain,
                     ad_domain_url  => $ad_domain_url,
                     ad_suffix      => $ad_suffix,
                     ou_string      => $ou_string,
                     reboot_timeout => $reboot_timeout
                   })
  }

  -> file { 'script to set dns/wins server':
    ensure  => present,
    path    => 'c:\scripts\setwinsnet.ps1',
    content => epp('profile/setwinsnet.epp',{
    })
  }
}
