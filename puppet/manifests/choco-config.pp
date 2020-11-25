node default {

  class { 'chocolatey':
    choco_install_timeout_seconds => 14400
  }
  exec { 'cmd.exe /c c:\ProgramData\chocolatey\bin\choco.exe config set commandExecutionTimeoutSeconds 14400':
    path => $::path
  }

}
