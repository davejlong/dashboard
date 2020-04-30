Import-Module PSAtera -Force
Set-AteraRecordLimit 500

$TechnicianEmail = ''
function Set-TechnicianEmail([string]$Email) { $script:TechnicianEmail = $Email }


function Get-Endpoints {
  $EveryFiveMinutes = New-UDEndpointSchedule -Every 5 -Minute
  $AlertEndpoint = New-UDEndpoint -Schedule $EveryFiveMinutes -Endpoint {
    $alerts = Get-AteraAlertsFiltered -Open
    $Cache:AteraAlerts = @{
      Warning = $alerts | Where-Object { $_.Severity -eq "Warning" };
      Critical = $alerts | Where-Object { $_.Severity -eq "Critical" }
    }
  }
  $TicketEndpoint = New-UDEndpoint -Schedule $EveryFiveMinutes -Endpoint {
    $tickets = Get-AteraTicketsFiltered -Open -Pending -ErrorAction SilentlyContinue
    $Cache:AteraTickets = @{
      My = $tickets | Where-Object { $_.TechnicianEmail -eq $script:TechnicianEmail };
      Unassigned = $tickets | Where-Object { !$_.TechnicianEmail };
      All = $tickets | Where-Object { $_.TechnicianEmail -eq $script:TechnicianEmail -or !$_.TechnicianEmail }
    }
  }

  $GetAlerts = New-UDEndpoint -Url "/alerts" -Endpoint {
    $Cache:AteraAlerts | ConvertTo-Json
  }
  $GetTickets = New-UDEndpoint -Url "/tickets" -Endpoint {
    $Cache:AteraTickets | ConvertTo-Json
  }

  return @($AlertEndpoint, $TicketEndpoint, $GetAlerts, $GetTickets)
}

function Get-Content {
  return {
    New-UDLayout -Columns 4 -Content {
      New-UDCounter -Title "Critical Alerts" -AutoRefresh -RefreshInterval 10 -Icon "exclamation_triangle" -TextAlignment 'Center' -TextSize 'Large' -BackgroundColor '#80FF6B63' -Endpoint {
        ([System.Array]$Cache:AteraAlerts.Critical).Count
      }
      New-UDCounter -Title "Warning Alerts" -AutoRefresh -RefreshInterval 10 -Icon "question_circle" -TextAlignment 'Center' -TextSize 'Large' -BackgroundColor "#80FFB963"  -Endpoint {
        ([System.Array]$Cache:AteraAlerts.Warning).Count
      }
      New-UDCounter -Title "My Tickets" -AutoRefresh -RefreshInterval 10 -Icon "ticket" -TextAlignment 'Center' -TextSize 'Large' -BackgroundColor "#8063A9FF" -Endpoint {
        $Cache:AteraTickets.My.Count
      }
      New-UDCounter -Title "Unassigned Tickets" -AutoRefresh -RefreshInterval 10 -Icon "ticket" -TextAlignment 'Center' -TextSize 'Large' -BackgroundColor "#8063A9FF" -Endpoint {
        $Cache:AteraTickets.Unassigned.Count
      }

      $ChartOptions = @{
        scales = @{
          yAxes = @(
            @{ ticks = @{ stepSize = 1; beginAtZeto = $true; suggestedMin = 0; suggestedMax = 10 } }
          )}
      }

      New-UDMonitor -Title "Critical Alerts" -Type Line -DataPointHistory 120 -RefreshInterval 60 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Options $ChartOptions -Endpoint {
        ([System.Array]$Cache:AteraAlerts.Critical).Count | Out-UDMonitorData
      }
      New-UDMonitor -Title "Warning Alerts" -Type Line -DataPointHistory 120 -RefreshInterval 60 -ChartBackgroundColor '#80FFB963' -ChartBorderColor '#FFFFB963' -Options $ChartOptions -Endpoint {
        ([System.Array]$Cache:AteraAlerts.Warning).Count | Out-UDMonitorData
      }
      New-UDMonitor -Title "My Tickets" -Type Line -DataPointHistory 120 -RefreshInterval 60 -ChartBackgroundColor '#8063A9FF' -ChartBorderColor '#FF63A9FF' -Options $ChartOptions -Endpoint {
        $Cache:AteraTickets.My.Count | Out-UDMonitorData
      }
      New-UDMonitor -Title "Unassigned Tickets" -Type Line -DataPointHistory 120 -RefreshInterval 60 -ChartBackgroundColor '#8063A9FF' -ChartBorderColor '#FF63A9FF' -Options $ChartOptions -Endpoint {
        $Cache:AteraTickets.Unassigned.Count | Out-UDMonitorData
      }
    }

    New-UDGrid -Title "Open Tickets" -AutoRefresh -RefreshInterval 60 -Id 'TicketGrid' -Endpoint {
      $Cache:AteraTickets.All | ForEach-Object {
        if ($_.Link) { return }
        $Link = New-UDLink -Text "Open" -Icon "ticket" -Url "https://app.atera.com/Admin#/ticket/$($_.TicketID)" -OpenInNewWindow
        $_ | Add-Member -MemberType NoteProperty -Name 'Link' -Value $Link
      }
      $Cache:AteraTickets.All | Sort-Object LastEndUserCommentTimeStamp -Descending | Select-Object LastEndUserCommentTimeStamp, TicketTitle, CustomerName, TicketType, TicketStatus, TechnicianFullName, Link | Out-UDGridData
    }
  }
}

function Get-Theme {
  return New-UDTheme -Name "CustomerDark" -Parent "Azure" -Definition @{
    # '.ud-counter .card-content .left-align' = @{
    #   'font-size' = '3rem';
    #   'text-align' = 'center';
    # };
    '.ud-counter .card-content svg' = @{
      'display' = 'block';
      'margin' = '5px auto';
      'font-size' = '1.5rem';
    }
  }
}

function New-Dashboard {
  return New-UDDashboard -Title "Dashboard" -Theme (Get-Theme) -Content (Get-Content)
}

Export-ModuleMember -Function New-Dashboard,Get-Endpoints,Set-TechnicianEmail