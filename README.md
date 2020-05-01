# My Office Dashboard

This is the dashboard I use in my home office for displaying an overview of my day.

## Install

To install run the following set of commands as a normal user (DO NOT USE AN ELEVATED POWERSHELL PROMPT)

```
Set-ExecutionPolicy Unrestricted -Force
Invoke-WebRequest -Uri https://github.com/davejlong/dashboard/archive/master.zip -OutFile $env:HOME/dashboard.zip
Expand-Archive -Path $env:HOME/dashboard.zip -DestinationPath $env:HOME
Set-Location $env:HOME/dashboard-master
& ./Install.ps1
```

After that, open Start-Dashboard.ps1 and change the email address on line 4
