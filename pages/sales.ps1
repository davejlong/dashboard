New-UDPage -Name "Sales" -Icon "dollar_sign" -Content {
  New-UDLayout -Columns 2 -Content {
    New-UdChart -Title "Deals by Milestone" -Type HorizontalBar -RefreshInterval 60 -AutoRefresh -Endpoint {
      $Cache:AgileDealsByMilestone.Values | Out-UDChartData -LabelProperty name -DataProperty value -BackgroundColor @('purple', 'yellow', 'blue', 'green', 'red')
    } -Options @{
      legend=@{display=$false};
      scales=@{xAxes=@(@{minBarLength=100})}
    }
    New-UDLayout -Columns 2 -Content {
      New-UDCounter -Title "Deals value closing within 30 days" -Format '$0,0.00' -TextAlignment center -TextSize Large -AutoRefresh -RefreshInterval 60 -Endpoint {
        $Cache:AgileDealsClosing.Amount
      }
      New-UDCounter -Title "Deals closing within 30 days" -TextAlignment center -TextSize Large -AutoRefresh -RefreshInterval 60 -Endpoint {
        $Cache:AgileDealsClosing.Count
      }
    }
  }
}