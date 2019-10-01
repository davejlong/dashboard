$Schedule = New-UDEndpointSchedule -Every 4 -Hour
New-UDEndpoint -Schedule $Schedule -Endpoint {
  $Contracts = Get-Atera -Endpoint "/contracts" -ApiKey $AteraApiKey
  $Cache:AteraContracts = @{
    Count=0;
    Expiring30Days=0;
  }
  $30DaysFromNow = (Get-Date).AddDays(30)

  $Contracts | ForEach-Object {
    if (!$_.Active) { return }
    $Cache:AteraContracts.Count += 1;
    if ($_.EndDate -le $30DaysFromNow) {
      $Cache:AteraContracts.Expiring30Days += 1;
    }
  }
}