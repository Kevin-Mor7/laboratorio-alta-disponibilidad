param(
    [string]$OutputFile = "availability-baseline.txt"
)

if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

Write-Host "Iniciando prueba de disponibilidad..." -ForegroundColor Cyan
Write-Host "Ejecutando 200 solicitudes..." -ForegroundColor Cyan

for ($i = 1; $i -le 200; $i++) {

    $tempFile = [System.IO.Path]::GetTempFileName()

    try {
        $output = curl.exe -sS -o $tempFile -w "%{http_code} %{time_total}" http://localhost:8080/v1/products 2>$null

        $body = Get-Content -Raw -Path $tempFile -ErrorAction SilentlyContinue
        $body = $body -replace "`r?`n", ' '

        $line = "{0:D3} {1} {2}" -f $i, $output, $body

        Add-Content -Path $OutputFile -Value $line
        Write-Host $line
    }
    finally {
        Remove-Item -Force $tempFile -ErrorAction SilentlyContinue
    }
}

$lines = Get-Content $OutputFile
$total = $lines.Count

$success = ($lines | Where-Object {
    $_ -match '"status"\s*:\s*"SUCCESS"'
}).Count

$http200 = ($lines | Where-Object {
    $_ -match '^\d+\s+200\s+'
}).Count

$httpErrors = $total - $http200

$availability = 0
if ($total -gt 0) {
    $availability = [math]::Round(($http200 / $total) * 100, 2)
}

Write-Host "`n========== RESULTADOS ==========" -ForegroundColor Green
Write-Host "Respuestas SUCCESS: $success"
Write-Host "Respuestas HTTP 200: $http200"
Write-Host "Respuestas HTTP distintas de 200: $httpErrors"
Write-Host "Solicitudes totales: $total"
Write-Host "Disponibilidad observada: $availability%" -ForegroundColor Yellow
Write-Host "`nResultados guardados en: $OutputFile" -ForegroundColor Green