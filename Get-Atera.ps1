[CmdletBinding()]
param (
    [Parameter()]
    [string] $Endpoint,
    [Parameter()]
    [string] $Method="GET",
    [Parameter()]
    [string] $ApiKey,
    [Parameter()]
    [int] $MaxPages=50
)

function New-AteraRequest($Uri, $Method, $Headers, $MaxPages, $ResultSet=@()) {
    $Result = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
    $ResultSet = $ResultSet + $Result.items
    if($Result.page -lt $Result.totalPages -and $Result.Page -lt $MaxPages) {
        Write-Host "Going around again (Page $($Result.page) of $($Result.totalPages))"
        New-AteraRequest -Uri $Result.nextLink -Method $Method -Headers $Headers -ResultSet $ResultSet
    } else { return $ResultSet }
}

$ApiUrl = "https://app.atera.com/api/v3"
$Uri = "$($ApiUrl)$($Endpoint)?itemsInPage=50"

$Headers = @{'X-API-KEY' = "$($ApiKey)"}

return (New-AteraRequest -Uri $Uri -Method $Method -Headers $Headers -MaxPages $MaxPages)
