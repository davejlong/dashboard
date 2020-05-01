if (!(Get-Module -ListAvailable -Name UniversalDashboard.Community)) {
  Install-Module UniversalDashboard.Community -Scope CurrentUser -Force
}
if (!(Get-Module -ListAvailable -Name PSAtera)) {
  Install-Module PSAtera -MinimumVersion "1.1.1" -Scope CurrentUser -Force
}

$AteraKey = Read-Host "Enter your Atera API Key"
Write-Host "Saving token to `$env:AteraAPIKey"
[System.Environment]::SetEnvironmentVariable('AteraAPIKey', $AteraKey, [System.EnvironmentVariableTarget]::User)

Write-Host "Dashboard is installed. Before starting, update Start-Dashboard.ps1:4 with your email address."
Write-Host "To start the dashboard run ./Start-Dashboard.ps1"
