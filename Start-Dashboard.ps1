[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $AteraAPIKey
)

Import-Module UniversalDashboard.Community

$env:Path += ";$PSScriptRoot"

$HourlySchedule = New-UDEndpointSchedule -Every 1 -Hour
$AgentEndpoint = New-UDEndpoint -Schedule $HourlySchedule -Endpoint {
    $Agents = Get-Atera -Endpoint "/agents" -ApiKey $AteraAPIKey
    $Cache:AgentCount = $Agents.Count
    $Cache:AgentServerCount = 0
    $Cache:AgentDCCount = 0
    $Cache:AgentWorkstationCount = 0
    $Agents | ForEach-Object {
        switch ($_.OSType) {
            "Server" { $Cache:AgentServerCount += 1; break; }
            "Domain Controller" {
                $Cache:AgentServerCount += 1
                $Cache:AgentDCCount += 1
                break
            }
            "Mac" { $Cache:AgentWorkstationCount += 1; break; }
            "Work Station" { $Cache:AgentWorkstationCount += 1; break;}
        }
        $_.OSType -eq "Server"
    }
}
$AlertEndpoint = New-UDEndpoint -Schedule $HourlySchedule -Endpoint {
    $Cache:WarningAlertCount = 0
    $Cache:CriticalAlertCount = 0

    $Alerts = Get-Atera -Endpoint "/alerts" -ApiKey $AteraAPIKey
    $OpenAlerts = @()
    $Alerts | ForEach-Object {
        if ($_.Archived -eq $false) {
            $OpenAlerts += $_
            switch($_.Severity) {
                "Warning" { $Cache:WarningAlertCount += 1; break; }
                "Critical" { $Cache:CriticalAlertCount += 1; break; }
            }
        }
    }
    $Cache:AlertCount = $OpenAlerts.Count
}

$TicketEndpoint = New-UDEndpoint -Schedule $HourlySchedule -Endpoint {
    $Cache:TicketCounts = @{
        "Open" = 0;
        "OpenedLast30Days" = 0;
        "ClosedLast30Days" = 0;
    }
    $Cache:OpenTickets = @()

    $Tickets = Get-Atera -Endpoint "/tickets" -ApiKey $AteraAPIKey
    $30DaysAgo = (Get-Date).AddDays(-30)
    $Tickets | ForEach-Object {
        # Is the ticket open
        if ($_.TicketStatus -in @("Open", "Pending")) {
            $Cache:OpenTickets += $_
        }
    }
}

$Dashboard = New-UDDashboard -Title "Cage Data Dashboard" -Content {
    New-UDLayout -Columns 4 -Content {
        New-UdMonitor -Title "Monitored Agents" -Type Line -DataPointHistory 20 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:AgentCount | Out-UDMonitorData
        } -AutoRefresh -RefreshInterval 5
        New-UDCounter -Title "Servers" -Icon "Server" -Endpoint {
            $Cache:AgentServerCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Monitored DCs" -Icon "Server" -Endpoint {
            $Cache:AgentDCCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Monitored Workstations" -Icon "Desktop" -Endpoint {
            $Cache:AgentWorkstationCount
        } -AutoRefresh -RefreshInterval 1
        
        New-UdMonitor -Title "Open Alerts" -Type Line -DataPointHistory 20 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:AlertCount | Out-UDMonitorData
        } -AutoRefresh -RefreshInterval 5
        New-UDCounter -Title "Critical Alerts" -Endpoint {
            $Cache:CriticalAlertCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Warning Alerts" -Endpoint {
            $Cache:WarningAlertCount
        } -AutoRefresh -RefreshInterval 1
    }
}

Start-UDDashboard -Dashboard $Dashboard -Port 10001 -AutoReload -Endpoint @($AgentEndpoint, $AlertEndpoint, $TicketEndpoint)