cmd /r c:\progra~1\puppet~1\puppet\bin\puppet.bat apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\choco.pp
if %ERRORLEVEL% EQU 0 (
   echo Success
) else (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
cmd /r c:\progra~1\puppet~1\puppet\bin\puppet.bat apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\choco-config.pp
if %ERRORLEVEL% EQU 0 (
   echo Success
) else (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
set FACTERLIB=c:\programdata\puppetlabs\code\environments\production\facter
cmd /r c:\progra~1\puppet~1\puppet\bin\puppet.bat apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\site.pp
if %ERRORLEVEL% EQU 0 (
   echo Success
) else (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
