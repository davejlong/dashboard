if (!(Get-Module -ListAvailable -Name UniversalDashboard.Community)) {
  Install-Module UniversalDashboard.Community -Scope CurrentUser -Force
}
if (!(Get-Module -ListAvailable -Name PSAtera)) {
  Install-Module PSAtera -MinimumVersion "1.1.2" -Scope CurrentUser -Force
}

$AteraKey = Read-Host "Enter your Atera API Key"
Write-Host "Saving token to `$env:AteraAPIKey"
[System.Environment]::SetEnvironmentVariable('AteraAPIKey', $AteraKey, [System.EnvironmentVariableTarget]::User)

$Email = Read-Host "Enter your email"
Write-Host "Setting email in dashboard.ps1"
$content = Get-Content $PSScriptRoot/dashboard.ps1.tmpl `
| ForEach-Object { $_ -replace "<<EMAIL>>", $Email } `
$content | Set-Content $PSScriptRoot/dashboard.ps1

Write-Host "Dashboard is installed."
Write-Host "To start the dashboard run ./dashboard.ps1"
