Expand-Archive c:\windows\temp\puppet.zip c:\ProgramData\PuppetLabs\code\environments\production

set FACTERLIB=c:\programdata\puppetlabs\code\environments\production\facter

& "c:\program files\puppet labs\puppet\bin\puppet" apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\choco.pp
$resp=$LASTEXITCODE
if ($resp -eq 0) {
   echo Success
} else {
   echo Failure Reason Given is $resp
   exit $resp
}

& "c:\program files\puppet labs\puppet\bin\puppet" apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\choco-config.pp
$resp=$LASTEXITCODE
if ($resp -eq 0) {
   echo Success
} else {
   echo Failure Reason Given is $resp
   exit $resp
}

& "c:\program files\puppet labs\puppet\bin\puppet" apply c:\ProgramData\PuppetLabs\code\environments\production\manifests\site.pp
$resp=$LASTEXITCODE
if ($resp -eq 0) {
   echo Success
} else {
   echo Failure Reason Given is $resp
   exit $resp
}

if (Test-Path c:\programdata\amazon\ec2-windows\launch\sysprep\unattend.xml) {
    c:\windows\system32\sysprep\sysprep /generalize /quiet /oobe /shutdown /unattend:c:\scripts\unattend.xml
}
