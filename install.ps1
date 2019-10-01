function Test-IsElevated {
  [CmdletBinding()]
  param()
  [Security.Principal.WindowsPrincipal] $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $Identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (!(Test-IsElevated)) {
  Write-Error "You must run install.ps1 in an elevated prompt"
  exit 1
}

$PowershellGet = Get-Module PowershellGet
if (!($PowershellGet -and $PowershellGet.Version -ge 2.2)) {
  Install-Module PowershellGet -Force
}

Import-Module PowerShellGet -MinimumVersion 2.2 -Force

Install-Module UniversalDashboard.Community -AcceptLicense -Force
