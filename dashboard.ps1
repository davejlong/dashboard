[CmdletBinding()]
param (
  [Parameter()]
  [string]$AteraApiKey,
  [Parameter()]
  [string]$AgileAccountEmail,
  [Parameter()]
  [string]$AgileApiKey,
  [Parameter()]
  [string]$AgileDomain
)

Import-Module UniversalDashboard.Community


# Create the initialization that we'll use for the endpoints
$Modules = Join-Path "$PSScriptRoot" -ChildPath "modules" | Get-ChildItem | ForEach-Object {
  return $_.FullName
}
$ConfigFile = Join-PAth "$PSScriptRoot" -ChildPath "config.json"
if (Test-Path $ConfigFile) {
  (Get-Content $ConfigFile | ConvertFrom-Json).Variables.psobject.Properties `
  | Where-Object MemberType -eq NoteProperty | ForEach-Object {
    Set-Variable -Name $_.Name -Value $_.Value
  }
}

$EndpointInit = New-UDEndpointInitialization -Module $Modules -Variable @("AteraApiKey", "AgileAccountEmail", "AgileApiKey", "AgileDomain")

# Load in all of the Endpoints that generate the data for the dashboard
$Endpoints = Join-Path -Path $PSScriptRoot -ChildPath "endpoints" | Get-ChildItem | ForEach-Object {
  return (. $_.FullName)
}

# Load in all of the Pages
$Pages = Join-Path -Path $PSScriptRoot -ChildPath "pages" | Get-ChildItem | ForEach-Object {
  return (. $_.FullName)
}

$Theme = Get-UDTheme -Name "DarkDefault"
$Dashboard = New-UDDashboard -Theme $Theme -EndpointInitialization $EndpointInit -Pages $Pages
Start-UDDashboard -Dashboard $Dashboard -Port 8001 -AutoReload -Endpoint $Endpoints