$Schedule = New-UDEndpointSchedule -Every 1 -Hour

New-UDEndpoint -Schedule $Schedule -Endpoint {
    $Cache:AteraAlerts = @{ Open=0; WarningCount=0; CriticalCount=0; Alerts=@() }
    $Cache:WarningAlertCount = 0
    $Cache:CriticalAlertCount = 0

    $Alerts = Get-Atera -Endpoint "/alerts" -ApiKey $AteraAPIKey
    $Alerts | ForEach-Object {
        if ($_.Archived -eq $false) {
            $Cache:AteraAlerts.Alerts += $_
            $Cache:AteraAlerts.Open += 1
            switch($_.Severity) {
                "Warning" { $Cache:AteraAlerts.WarningCount +=1; break; }
                "Critical" { $Cache:AteraAlerts.CriticalCount += 1; break; }
            }
        }
    }
}