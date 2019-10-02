function Get-Atera {
  param (
    [Parameter()]
    [string] $Endpoint,
    [Parameter()]
    [string] $Method="GET",
    [Parameter()]
    [string] $ApiKey,
    [Parameter()]
    [int] $MaxPages=50
  )
  
  function New-AteraRequest($Uri, $Method, $Headers, $MaxPages, $ResultSet=@()) {
    $Result = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
    $ResultSet += $Result.items
    if($Result.page -lt $Result.totalPages -and $Result.Page -lt $MaxPages) {
      Write-Host "Getting page $($Result.page) of $($Result.totalPages) from $($Endpoint)"
      New-AteraRequest -Uri $Result.nextLink -Method $Method -Headers $Headers -ResultSet $ResultSet
    } else { return $ResultSet }
  }
  
  $ApiUrl = "https://app.atera.com/api/v3"
  $Uri = "$($ApiUrl)$($Endpoint)?itemsInPage=50"
  
  $Headers = @{'X-API-KEY' = "$($ApiKey)"}
  
  return (New-AteraRequest -Uri $Uri -Method $Method -Headers $Headers -MaxPages $MaxPages)
}

Export-ModuleMember -Function "Get-Atera"