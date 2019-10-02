$Schedule = New-UDEndpointSchedule -Every 4 -Hour
New-UDEndpoint -Schedule $Schedule -Endpoint {
  $Pipeline = Get-AgilePipelines -AccountEmail $AgileAccountEmail -ApiKey $AgileApiKey -Domain $AgileDomain
  $Deals = Get-Agile -Endpoint "/opportunity" -AccountEmail $AgileAccountEmail -ApiKey $AgileApiKey -Domain $AgileDomain
  $Cache:AgileDealsByMilestone = [ordered]@{}
  $Cache:AgileDealsClosing = @{Amount=0; Count=0}
  $30DaysFromNow = (Get-Date).AddDays(30)
  $Epoch = [datetime]'1/1/1970'

  # Initialize milestones from our Pipeline first so we have the right order 
  $Pipeline.milestones.split(",") | ForEach-Object {
    $Cache:AgileDealsByMilestone[$_] = @{name=$_; count=0; value=0}
  }

  $Deals | ForEach-Object {
    if ($Cache:AgileDealsByMilestone[$_.milestone] -eq $null) {
      Write-Warning "Milestone $($_.milestone) doesn't exist"
    }
    $Cache:AgileDealsByMilestone[$_.milestone].count += 1
    $Cache:AgileDealsByMilestone[$_.milestone].value += $_.expected_value

    if($_.milestone -in @("Develop","Propose","Close")) {
      $CloseDate = $Epoch.AddSeconds($_.close_date)
      if ($CloseDate -gt (Get-Date) -and $CloseDate -le $30DaysFromNow) {
        $Cache:AgileDealsClosing.Amount += $_.expected_value
        $Cache:AgileDealsClosing.Count += 1
      }
    }
  }
}