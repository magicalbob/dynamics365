# Class: flagman
# ===========================
#
# Installs netcat to allow GET/SET of redis key values.
# Installs a script to get and a script to set the key values.
#
# Parameters
# ----------
#
# None.
#
# Variables
# ----------
#
# hieradata `redis_ip` points to redis server
#
# Examples
# --------
#
# @example
#    include flagman
#
class flagman (
  $redis_ip = lookup('redis_ip'),
  $redis_pass = lookup('redis_pass')
)
{
  file { 'script to set a flag':
    ensure  => present,
    path    => 'c:\scripts\flagmanset.ps1',
    content => epp('flagman/flagmanset.epp',{
      redis_ip   => $redis_ip,
      redis_pass => $redis_pass
    })
  }

  -> file { 'script to get a flag':
    ensure  => present,
    path    => 'c:\scripts\flagmanget.ps1',
    content => epp('flagman/flagmanget.epp',{
      redis_ip   => $redis_ip,
      redis_pass => $redis_pass
    })
  }
}
