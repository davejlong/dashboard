$Schedule = New-UDEndpointSchedule -Every 30 -Minute

New-UDEndpoint -Schedule $Schedule -Endpoint {
    $Feed = Invoke-RssRequest -Uri "https://hackercombat.com/feed/"
    $Cache:HackerCombat = $Feed[0]
}