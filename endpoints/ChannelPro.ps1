$Schedule = New-UDEndpointSchedule -Every 30 -Minute
New-UDEndpoint -Schedule $Schedule -Endpoint {
  $Feed = Invoke-RSSRequest -Uri "https://channelpronetwork.com/rss.xml"
  Clear-UDElement -Id "channelpro-news"
  $Feed[0..3] | ForEach-Object {
    Wait-Debugger
    Add-UDElement -ParentId "channelpro-news" -Broadcast -Content {
      New-UDElement -Tag 'li' -Content {
        New-UDLink -Text $_.Title -Url $_.Link
      }
    }
  }
}