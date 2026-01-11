# --- KONFIGURATION ---
$ExternalTarget = "8.8.8.8"   # Oder Ihre eigene Server-IP hier eintragen
$LogFile = "C:\Temp\WLAN_Log.csv"
$IntervalSeconds = 1
# ---------------------

# Gateway (Router) IP automatisch ermitteln
$Gateway = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' -and $_.NextHop -ne '0.0.0.0' } | Select-Object -First 1).NextHop

Write-Host "Starte Logging..."
Write-Host "Router IP: $Gateway"
Write-Host "Internet IP: $ExternalTarget"
Write-Host "Speichere in: $LogFile"
Write-Host "Druecken Sie STRG+C zum Beenden."

# CSV Header schreiben, falls Datei nicht existiert
if (-not (Test-Path $LogFile)) {
    "Timestamp;Router_Latency_ms;Internet_Latency_ms;Status_Fazit" | Out-File $LogFile -Encoding utf8
}

while ($true) {
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Ping Router (WLAN Test)
    $PingRouter = Test-Connection -ComputerName $Gateway -Count 1 -ErrorAction SilentlyContinue
    $LatRouter = if ($PingRouter) { $PingRouter.ResponseTime } else { "TIMEOUT" }

    # Ping Internet (ISP Test)
    $PingInet = Test-Connection -ComputerName $ExternalTarget -Count 1 -ErrorAction SilentlyContinue
    $LatInet = if ($PingInet) { $PingInet.ResponseTime } else { "TIMEOUT" }

    # Einfache Diagnose für das Log
    $Fazit = "OK"
    if ($LatRouter -eq "TIMEOUT") { 
        $Fazit = "WLAN_ABBRUCH (Lokal)" 
    } elseif ($LatInet -eq "TIMEOUT") { 
        $Fazit = "ISP_AUSFALL (Extern)" 
    } elseif ([int]$LatRouter > 100) {
        $Fazit = "WLAN_SCHWACH"
    }

    # Ausgabe auf Konsole (Live-View)
    Write-Host "$Time | Router: $LatRouter ms | Internet: $LatInet ms | -> $Fazit" -ForegroundColor $(if($Fazit -eq "OK"){'Green'}else{'Red'})

    # Schreiben in CSV
    "$Time;$LatRouter;$LatInet;$Fazit" | Out-File $LogFile -Append -Encoding utf8
    
    Start-Sleep -Seconds $IntervalSeconds
}

