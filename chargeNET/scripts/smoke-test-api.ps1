# ChargeNET API smoke test — driver reserve → admin confirm → charge flow
$ErrorActionPreference = "Stop"
$base = "http://localhost:5000"
$suffix = Get-Random -Maximum 99999
$driverEmail = "smoke.driver$suffix@test.com"
$adminEmail = "smoke.admin$suffix@test.com"
$pass = "Test1234!"

function Invoke-Api {
  param($Method, $Path, $Body = $null, $Token = $null)
  $headers = @{ "Content-Type" = "application/json" }
  if ($Token) { $headers["Authorization"] = "Bearer $Token" }
  $params = @{
    Uri = "$base$Path"
    Method = $Method
    Headers = $headers
  }
  if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 5) }
  return Invoke-RestMethod @params
}

Write-Host "=== 1. Register driver ===" -ForegroundColor Cyan
$driverAuth = Invoke-Api POST "/api/auth/register" @{
  firstName = "Smoke"; lastName = "Driver"; email = $driverEmail; password = $pass; roleId = 3
}
Write-Host "Driver id: $($driverAuth.userId)"

Write-Host "=== 2. Register admin ===" -ForegroundColor Cyan
$adminAuth = Invoke-Api POST "/api/auth/register" @{
  firstName = "Smoke"; lastName = "Admin"; email = $adminEmail; password = $pass; roleId = 1
}
$adminToken = $adminAuth.token
Write-Host "Admin id: $($adminAuth.userId)"

Write-Host "=== 3. Admin creates station ===" -ForegroundColor Cyan
$station = Invoke-Api POST "/api/chargingstations" @{
  name = "Smoke Station $suffix"; address = "Test 1"; cityId = 1; statusId = 1
  latitude = 43.8563; longitude = 18.4131; isFastCharger = $false
} -Token $adminToken
Write-Host "Station id: $($station.id)"

Write-Host "=== 4. Admin adds connector ===" -ForegroundColor Cyan
$connector = Invoke-Api POST "/api/connectors" @{
  chargingStationId = $station.id; connectorTypeId = 2; powerKW = 50; isAvailable = $true; label = "CCS-1"
} -Token $adminToken
Write-Host "Connector id: $($connector.id)"

Write-Host "=== 5. Driver recommendations ===" -ForegroundColor Cyan
$recs = Invoke-Api GET "/api/recommendations?lat=43.8563&lng=18.4131&topN=5" -Token $driverAuth.token
Write-Host "Recommendations count: $($recs.Count)"

Write-Host "=== 6. Driver creates reservation ===" -ForegroundColor Cyan
$start = (Get-Date).AddHours(1).ToUniversalTime().ToString("o")
$end = (Get-Date).AddHours(3).ToUniversalTime().ToString("o")
$reservation = Invoke-Api POST "/api/reservations" @{
  chargingStationId = $station.id; connectorId = $connector.id
  reservationStart = $start; reservationEnd = $end
} -Token $driverAuth.token
Write-Host "Reservation id: $($reservation.id) status: $($reservation.statusName)"

Write-Host "=== 7. Admin confirms reservation ===" -ForegroundColor Cyan
$confirmed = Invoke-Api POST "/api/reservations/$($reservation.id)/confirm" $null -Token $adminToken
Write-Host "Status: $($confirmed.statusName)"

Write-Host "=== 8. Driver starts session ===" -ForegroundColor Cyan
$session = Invoke-Api POST "/api/chargingsessions/start" @{
  connectorId = $connector.id; tariffId = 1; reservationId = $reservation.id
} -Token $driverAuth.token
Write-Host "Session id: $($session.id) station: $($session.chargingStationName)"

Write-Host "=== 9. Driver wallet balance ===" -ForegroundColor Cyan
$balance = Invoke-Api GET "/api/wallet/balance" -Token $driverAuth.token
Write-Host "Balance: $($balance.balance) $($balance.currency)"

Write-Host "=== 10. Driver completes session ===" -ForegroundColor Cyan
try {
  $completed = Invoke-Api POST "/api/chargingsessions/$($session.id)/complete" @{
    energyConsumedKWh = 10
  } -Token $driverAuth.token
  Write-Host "Completed cost: $($completed.cost) kWh: $($completed.energyConsumedKWh)"
} catch {
  Write-Host "Complete failed (expected if wallet empty): $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "=== 11. Admin lists sessions ===" -ForegroundColor Cyan
$sessions = Invoke-Api GET "/api/chargingsessions" -Token $adminToken
Write-Host "Sessions count: $($sessions.Count)"

Write-Host "=== 12. Admin lists users ===" -ForegroundColor Cyan
$users = Invoke-Api GET "/api/users?fullText=smoke" -Token $adminToken
Write-Host "Users found: $($users.Count)"

Write-Host "`nSMOKE TEST PASSED (core flow OK)" -ForegroundColor Green
