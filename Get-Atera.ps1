[CmdletBinding()]
param (
    [Parameter()]
    [string] $Endpoint,
    [Parameter()]
    [string] $Method="GET",
    [Parameter()]
    [string] $ApiKey
)

function New-AteraRequest($Uri, $Method, $Headers, $ResultSet=@()) {
    $Result = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
    $ResultSet = $ResultSet + $Result.items
    if($Result.page -lt $Result.totalPages) {
        Write-Host "Getting page $($Result.page) of $($Result.totalPages) from $($Endpoint)"
        New-AteraRequest -Uri $Result.nextLink -Method $Method -Headers $Headers -ResultSet $ResultSet
    } else { return $ResultSet }
}

$ApiUrl = "https://app.atera.com/api/v3"
$Uri = "$($ApiUrl)$($Endpoint)?itemsInPage=50"

$Headers = @{'X-API-KEY' = "$($ApiKey)"}

return (New-AteraRequest -Uri $Uri -Method $Method -Headers $Headers)
