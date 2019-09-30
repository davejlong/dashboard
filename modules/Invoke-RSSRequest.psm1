function Invoke-RSSRequest {
    param (
        [Parameter()]
        [string] $Uri
    )

    $Content = Invoke-WebRequest -Uri $Uri -UseBasicParsing
    [xml]$Feed = $Content.Content
    return $Feed.GetElementsByTagName("item")
}
Export-ModuleMember -Function "Invoke-RSSRequest"