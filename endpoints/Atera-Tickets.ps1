$Schedule = New-UDEndpointSchedule -Every 1 -Hour

New-UDEndpoint -Schedule $Schedule -Endpoint {
    $Cache:AteraTickets = @{
        "Open" = 0;
        "OpenedLast30Days" = 0;
        "ClosedLast30Days" = 0;
    }

    $Tickets = Get-Atera -Endpoint "/tickets" -ApiKey $AteraAPIKey
    $30DaysAgo = (Get-Date).AddDays(-30)
    $Tickets | ForEach-Object {
        # Is the ticket open
        if ($_.TicketStatus -in @("Open", "Pending")) {
            $Cache:AteraTickets.Open += 1;
        }
        if ($_.TicketCreatedDate -ge $30DaysAgo) { $Cache:AteraTickets.OpenedLast30Days += 1 }
        if ($_.TicketResolvedDate -ne $null -and $_.TicketResolvedDate -ge $30DaysAgo) { $Cache:AteraTickets.ClosedLast30Days += 1 }
    }
}