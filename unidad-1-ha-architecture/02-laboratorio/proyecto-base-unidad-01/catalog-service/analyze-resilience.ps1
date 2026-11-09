if (-not (Test-Path "availability-baseline.txt") -or
    -not (Test-Path "resilience-sample.txt")) {
    Write-Host "Error: faltan los archivos de resultados." -ForegroundColor Red
    exit 1
}

$baseline = @(Get-Content "availability-baseline.txt")
$resilience = @(Get-Content "resilience-sample.txt")

$total_1_1 = $baseline.Count
$success_1_1 = ($baseline | Where-Object { $_ -like '*"status":"SUCCESS"*' }).Count
$errors_1_1 = $total_1_1 - $success_1_1
$avail_1_1 = if ($total_1_1 -gt 0) { $success_1_1 / $total_1_1 } else { 0 }

$total_1_2 = $resilience.Count
$success_1_2 = ($resilience | Where-Object { $_ -like '*"status":"SUCCESS"*' }).Count
$degraded_1_2 = ($resilience | Where-Object { $_ -like '*"status":"DEGRADED_CACHE"*' }).Count
$http_errors_1_2 = $total_1_2 - $success_1_2 - $degraded_1_2
$avail_1_2 = if ($total_1_2 -gt 0) {
    ($success_1_2 + $degraded_1_2) / $total_1_2
} else { 0 }

Write-Host "`n=== LAB 1.1: LINEA BASE ===" -ForegroundColor Cyan
Write-Host "Total: $total_1_1"
Write-Host "SUCCESS: $success_1_1"
Write-Host "Errores/no SUCCESS: $errors_1_1"
Write-Host ("Disponibilidad SUCCESS: {0:P2}" -f $avail_1_1)

Write-Host "`n=== LAB 1.2: CON RESILIENCIA ===" -ForegroundColor Cyan
Write-Host "Total: $total_1_2"
Write-Host "SUCCESS: $success_1_2"
Write-Host "DEGRADED_CACHE: $degraded_1_2"
Write-Host "Otras respuestas: $http_errors_1_2"
Write-Host ("Disponibilidad SUCCESS + DEGRADED_CACHE: {0:P2}" -f $avail_1_2)

Write-Host "`n=== COMPARACION ===" -ForegroundColor Green
Write-Host ("Cambio de disponibilidad: {0:P2}" -f ($avail_1_2 - $avail_1_1))
Write-Host "Fallbacks que entregaron datos de caché: $degraded_1_2"

if ($total_1_1 -ne 200 -or $total_1_2 -ne 200) {
    Write-Host "Aviso: uno de los archivos no contiene 200 líneas. Verifica el script y los archivos." -ForegroundColor Yellow
}
if ($http_errors_1_2 -eq 0 -and $total_1_2 -gt 0) {
    Write-Host "No se detectaron respuestas distintas de SUCCESS/DEGRADED_CACHE en la muestra." -ForegroundColor Green
} else {
    Write-Host "Hay respuestas que requieren revisión; no asumas disponibilidad del 100%." -ForegroundColor Yellow
}
