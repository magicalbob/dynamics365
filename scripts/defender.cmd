cmd /c schtasks /CHANGE /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /RL LIMITED
cmd /c schtasks /CHANGE /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /RL LIMITED
cmd /c schtasks /CHANGE /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /RL LIMITED
cmd /c schtasks /CHANGE /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /RL LIMITED
