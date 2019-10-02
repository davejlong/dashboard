function New-AgileCredentials([string]$Email, [string]$PlainTextPassword) {
  $secpasswd = ConvertTo-SecureString $PlainTextPassword -AsPlainText -Force
  return New-Object System.Management.Automation.PSCredential($email, $Secpasswd)
}
function Get-Agile {
  param (
    [Parameter()]
    [string] $Endpoint,
    [Parameter()]
    [string] $Method="GET",
    [Parameter()]
    [string] $AccountEmail,
    [Parameter()]
    [string] $ApiKey,
    [Parameter()]
    [string] $Domain
  )
  $ApiUrl = "https://$Domain.agilecrm.com/dev/api"
  $Creds = New-AgileCredentials -Email $AccountEmail -PlainTextPassword $ApiKey
  $Headers = @{"Accept"="application/json"}
  return Invoke-RestMethod -Uri "$($ApiUrl)$($Endpoint)" -Headers $Headers -Credential $Creds
}

function Get-AgilePipelines {
  param (
    [Parameter()]
    [string] $AccountEmail,
    [Parameter()]
    [string] $ApiKey,
    [Parameter()]
    [string] $Domain
  )
  $Params = $PSBoundParameters
  $Params.Endpoint = "/milestone/pipelines"
  Get-Agile @Params
}

Export-ModuleMember -Function $("Get-Agile", "Get-AgilePipelines")