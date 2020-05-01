# My Office Dashboard

This is the dashboard I use in my home office for displaying an overview of my day.

## Install

To install run the following set of commands as a normal user (DO NOT USE AN ELEVATED POWERSHELL PROMPT)

```
Invoke-WebRequest -Uri https://github.com/davejlong/dashboard/archive/master.zip -OutFile $env:HOMEPATH/dashboard.zip
Expand-Archive -Path $env:HOMEPATH/dashboard.zip -DestinationPath $env:HOMEPATH
Set-Location $env:HOMEPATH/dashboard-master
& ./Install.ps1
```

After that, open Start-Dashboard.ps1 and change the email address on line 4
