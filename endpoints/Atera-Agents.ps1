$Schedule = New-UDEndpointSchedule -Every 1 -Hour

New-UDEndpoint -Schedule $Schedule -Endpoint {
    Write-Warning "Atera API Key: $AteraApiKey"
    $Agents = Get-Atera -Endpoint "/agents" -ApiKey $AteraAPIKey
    $Cache:AteraAgents = @{
        ServerCount=0;
        DCCount=0;
        WorkstationCount=0;
        Count=0
    }
    Write-Host "Got $($Agents.count) Agents"
    $Agents | ForEach-Object {
        switch ($_.OSType) {
            "Server" { $Cache:AteraAgents.ServerCount += 1; break; }
            "Domain Controller" {
                $Cache:AteraAgents.ServerCount += 1
                $Cache:AteraAgents.DCCount += 1
                break
            }
            "Mac" { $Cache:AteraAgents.WorkstationCount += 1; break; }
            "Work Station" { $Cache:AteraAgents.WorkstationCount += 1; break;}
        }
    }
}