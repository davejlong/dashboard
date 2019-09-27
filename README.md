# Cage Data Dashboard


## Installation - Part 1

Get the 2 .ps1 scripts and put them somewhere on your computer

## Installation - Part 2 (optional part)

*(only if you don't have Powershell > 5.1)*

Open an elevated Powershell terminal

```
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
```
Install Powershell and close/reopen Powershell Terminal

*(only if you don't have Nuget / PowerShellGet installed)*

Open an elevated Powershell terminal

```
Install-PackageProvider Nuget –Force
Install-Module –Name PowerShellGet –Force
```
Close the Powershell terminal

## Installation - Part 3

Open an elevated Powershell terminal

```
Install-Module UniversalDashboard.Community
```

Accept everything

## Starting

```
cd To_The_Path_Where_you_put_your_files.ps1
.\Start-Dashboard.ps1 -AteraAPIKey "[YOUR API KEY FROM ATERA]"
```
PS: Atera API key can be found in: https://app.atera.com/Admin#/admin/api

Then open your browser and go to http://127.0.0.1:10001
