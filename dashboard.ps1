[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $AteraAPIKey
)

Import-Module UniversalDashboard.Community

# Load in any libraries to do things like interact with APIs
Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath "lib") | ForEach-Object { . $_.FullName }

# Load in all of the Endpoints that generate the data for the dashboard
$Endpoints = Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath "endpoints") | ForEach-Object {
    . $_.FullName
}

$Theme = Get-UDTheme -Name "DarkDefault"
$Dashboard = New-UDDashboard -Theme $Theme -Content {
    New-UDLayout -Columns 4 -Content {
        New-UdMonitor -Title "Monitored Agents" -Type Line -DataPointHistory 20 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:AteraAgents.Count | Out-UDMonitorData
        } -AutoRefresh -RefreshInterval 600
        New-UDCounter -Title "Servers" -Icon "Server" -TextAlignment center -TextSize Large -Endpoint {
            $Cache:AteraAgents.ServerCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Monitored DCs" -Icon "Server" -TextAlignment center -TextSize Large -Endpoint {
            $Cache:AteraAgents.DCCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Monitored Workstations" -Icon "Desktop" -TextAlignment center -TextSize Large -Endpoint {
            $Cache:AteraAgents.WorkstationCount
        } -AutoRefresh -RefreshInterval 1
        
        New-UdMonitor -Title "Open Alerts" -Type Line -DataPointHistory 20 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:AteraAlerts.Open | Out-UDMonitorData
        } -AutoRefresh -RefreshInterval 30
        New-UDCounter -Title "Critical Alerts" -Icon "exclamation_triangle" -BackgroundColor '#ff4000' -TextAlignment center -TextSize Large -Endpoint {
            $Cache:AteraAlerts.CriticalCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCounter -Title "Warning Alerts" -Icon "exclamation_circle" -BackgroundColor '#ffbf00' -TextAlignment center -TextSize Large -Endpoint {
            $Cache:AteraAlerts.WarningCount
        } -AutoRefresh -RefreshInterval 1
        New-UDCard

        New-UdMonitor -Title "Open Tickets" -Type Line -DataPointHistory 20 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:AteraTickets.Open | Out-UDMonitorData
        } -AutoRefresh -RefreshInterval 30
        New-UdChart -Title "Opened vs Closed Tickets Last 30 Days" -Type Bar -AutoRefresh -Endpoint {
            @{Label="Opened vs Closed"; Opened=$Cache:AteraTickets.OpenedLast30Days; Closed=$Cache:AteraTickets.ClosedLast30Days } `
                | Out-UDChartData -LabelProperty "Label" -Dataset @(
                    New-UdChartDataset -DataProperty "Opened" -Label "Opened" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                    New-UdChartDataset -DataProperty "Closed" -Label "Closed" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                )
        }
    }
}

Start-UDDashboard -Dashboard $Dashboard -Port 8001 -AutoReload -Endpoint $Endpoints