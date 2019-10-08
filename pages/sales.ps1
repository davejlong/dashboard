New-UDPage -Name "Sales" -Icon "dollar_sign" -Content {
  $Layout = @{lg=@(
    @{i="grid-element-deals-chart"; x=0; y=0; w=6; h=6; static=$true},
    @{i="grid-element-deals-value"; x=6; y=0; w=3; h=2; maxH=2; static=$true},
    @{i="grid-element-deals-count"; x=9; y=0; w=3; h=2; maxH=2; static=$true},
    @{i="grid-element-channelpro-news-card"; x=6; y=6; w=6; h=2; static=$true}
  )}
  New-UDGridLayout -Layout ($Layout | ConvertTo-Json -Compress) -Content {
    New-UdChart -Title "Deals by Milestone" -Id "deals-chart" -Type HorizontalBar -RefreshInterval 60 -AutoRefresh -Endpoint {
      $Cache:AgileDealsByMilestone.Values | Out-UDChartData -LabelProperty name -DataProperty value -BackgroundColor @('purple', 'yellow', 'blue', 'green', 'red')
    } -Options @{
      legend=@{display=$false};
      scales=@{xAxes=@(@{minBarLength=100})}
    }
    New-UDCounter -Title "Deals value closing within 30 days" -Id "deals-value" -Format '$0,0.00' -TextAlignment center -TextSize Large -AutoRefresh -RefreshInterval 60 -Endpoint {
      $Cache:AgileDealsClosing.Amount
    }
    New-UDCounter -Title "Deals closing within 30 days" -Id "deals-count" -TextAlignment center -TextSize Large -AutoRefresh -RefreshInterval 60 -Endpoint {
      $Cache:AgileDealsClosing.Count
    }
    New-UDCard -Title "Latest from Channel Pro" -Id "channelpro-news-card" -Endpoint { 
      New-UDElement -Tag 'ul' -Id "channelpro-news"
    }
  }
}