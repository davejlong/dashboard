Import-Module ".\dashboard.psm1" -Force

# Change to your email address to filter "My Tickets" and "Open Tickets"
Set-TechnicianEmail -Email 'dlong@cagedata.com'

Get-UDDashboard | Stop-UDDashboard

Start-UDDashboard -Dashboard (New-Dashboard) -Endpoint (Get-Endpoints) -Port 10001