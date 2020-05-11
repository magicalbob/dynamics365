## 2017-12-08 - Supported Release 2.1.3

### Summary

Small release with bugs fixes.

### Bug Fixes

- Fix timeouts and zombie process creation ([MODULES-4748](https://tickets.puppetlabs.com/browse/MODULES-4748))
- Update PowerShell executable name for experimental cross-platform / PowerShell 6 support ([MODULES-6081](https://tickets.puppetlabs.com/browse/MODULES-6081))

## 2017-07-27 - Supported Release 2.1.2

### Summary

Small release with bugs fixes.

### Bug Fixes

- Fix Global Warning variable ([MODULES-5224](https://tickets.puppetlabs.com/browse/MODULES-5224))
- Move PowerShell template file to stop conflicts with DSC Module ([MODULES-5228](https://tickets.puppetlabs.com/browse/MODULES-5228))

## 2017-07-07 - Supported Release 2.1.1

### Summary

Small release with bugs fixes and experimental support for non-Windows Operating Systems (CentOS and Ubuntu).

### Features

- Added rake tasks for release automation
- Added experimental support for non-Windows Support (CentOS, Ubuntu) ([MODULES-3945](https://tickets.puppetlabs.com/browse/MODULES-3945))

### Bug Fixes

- Documentation Update ([DOC-2960](https://tickets.puppetlabs.com/browse/DOC-2960))
- Update metadata for Puppet 4 and Puppet 5 ([MODULES-4528](https://tickets.puppetlabs.com/browse/MODULES-4528), [MODULES-4822](https://tickets.puppetlabs.com/browse/MODULES-4822), [MODULES-5144](https://tickets.puppetlabs.com/browse/MODULES-5144))
- Dispose runspace on pipe close ([MODULES-4754](https://tickets.puppetlabs.com/browse/MODULES-4754))
- Removed rspec configuration for win32_console ([MODULES-4976](https://tickets.puppetlabs.com/browse/MODULES-4976))
- Provider will now respect the environment parameter ([MODULES-4138](https://tickets.puppetlabs.com/browse/MODULES-4138))
- Return available UI Output on error ([MODULES-5145](https://tickets.puppetlabs.com/browse/MODULES-5145))

## 2016-11-17 - Supported Release 2.1.0

### Summary

Small release with bugs fixes and another speed improvement.

### Bug Fixes

- Support Windows 2016/WMF 5.1 using named pipes ([MODULES-3690](https://tickets.puppetlabs.com/browse/MODULES-3690))

### Documentation updates

- Document herestring ([DOC-2960](https://tickets.puppetlabs.com/browse/DOC-2960))

## 2016-10-05 - Supported Release 2.0.3

### Summary

Small release with bugs fixes and another speed improvement.

### Bug Fixes

- Miscellaneous fixes which improve reliability
- Capture exit codes when executing external scripts ([MODULES-3399](https://tickets.puppetlabs.com/browse/MODULES-3399))
- Add ability to set current working directory ([MODULES-3565](https://tickets.puppetlabs.com/browse/MODULES-3565))
- Respect user specified timeout ([MODULES-3709](https://tickets.puppetlabs.com/browse/MODULES-3709))
- Improve handling of user code exceptions ([MODULES-3443](https://tickets.puppetlabs.com/browse/MODULES-3443))
- Output line and stacktrace of user code exception ([MODULES-3839](https://tickets.puppetlabs.com/browse/MODULES-3839))
- Improve resilience to failure of PowerShell host ([MODULES-3875](https://tickets.puppetlabs.com/browse/MODULES-3875))
- Fix race condition in threading with PowerShell host ([MODULES-3144](https://tickets.puppetlabs.com/browse/MODULES-3144))
- Modify tests to detect differences in PowerShell error text ([MODULES-3442](https://tickets.puppetlabs.com/browse/MODULES-3442))

### Documentation updates

- Document how to handle exit codes ([MODULES-3588](https://tickets.puppetlabs.com/browse/MODULES-3588))

## 2016-07-12 - Supported Release 2.0.2

### Summary

Small release with bugs fixes and another speed improvement.

### Features

- Noticable speed increase by reducing the time start a PowerShell command ([MODULES-3406](https://tickets.puppetlabs.com/browse/MODULES-3406))

### Bug Fixes

- Fixed minor bugs in tests ([MODULES-3347](https://tickets.puppetlabs.com/browse/MODULES-3347))
- Added tests for try/catch ([MODULES-2634](https://tickets.puppetlabs.com/browse/MODULES-2634))
- Fixed bug with older ruby (1.8)

## 2016-05-24 - Supported Release 2.0.1

### Bug Fixes

- Updated the powershell manager in this module in order to not conflict with the Powershell Manager in the Puppet DSC module

## 2016-05-17 - Supported Release 2.0.0

### Summary

Major release with performance improvements

Removed support for Windows Server 2003

### Features

- Major performance improvement by sharing a single powershell session instead of creating a new powershell session per command
- Security improvement as scripts are not stored on the filesystem temporarily

### Bug Fixes

- Updated test suites with later versions
- Documentation cleanup

## 2015-12-08 - Supported Release 1.0.6

### Summary

Small release for support of newer PE versions.

## 2015-07-28 - Supported Release 1.0.5

### Summary

Add metadata for Puppet 4 and PE 2015.2.0

### Bug Fixes

- Minor testing bug fixes
- Readme cleanup

## 2014-11-04 - Supported Release 1.0.4

### Summary

Fix Issues URL
Add Future Parser testing support

## 2014-08-25 - Supported Release 1.0.3

### Summary

This release updates the tests to verify that powershell continues to function on x64-native ruby.

## 2014-07-15 - Supported Release 1.0.2

### Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-07-09 - Release 1.0.1

### Summary

Fix issue with metadata and PE version requirement
