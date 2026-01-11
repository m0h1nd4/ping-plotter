🛜 WLAN-Diagnose-Tool
Finde heraus, ob dein WLAN oder dein Internetanbieter schuld ist!
Dieses einfache Tool protokolliert deine Internetverbindung und hilft dir herauszufinden, warum dein Internet manchmal nicht funktioniert.
📋 Was macht dieses Tool?
Das Tool prüft jede Sekunde zwei Dinge:
Verbindung zum Router → Ist dein WLAN stabil?
Verbindung ins Internet → Funktioniert die Leitung deines Anbieters?
Die Ergebnisse werden in einer Datei gespeichert, die du später analysieren kannst.
🖥️ Voraussetzungen
Windows 10 oder Windows 11
Keine Installation nötig – PowerShell ist bereits auf deinem PC!
📥 Installation & Einrichtung
Schritt 1: Ordner erstellen
Öffne den Datei-Explorer (Windows-Taste + E)
Gehe zu C:\
Erstelle einen neuen Ordner namens Temp (falls nicht vorhanden)
Rechtsklick → Neu → Ordner → Temp eingeben
Schritt 2: Script speichern
Öffne den Editor (Windows-Taste drücken, "Editor" eintippen, Enter)
Kopiere das gesamte Script (siehe unten) in den Editor
Speichere die Datei:
Datei → Speichern unter
Speicherort: C:\Temp
Dateiname: WLAN_Test.ps1
Dateityp: Alle Dateien (*.*)
Klicke auf Speichern
📜 Das Script
Kopiere diesen Code vollständig:
# --- KONFIGURATION ---
$ExternalTarget = "8.8.8.8"   # Google DNS Server (zuverlässig erreichbar)
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
▶️ Script starten
Methode A: Per Rechtsklick (Empfohlen)
Öffne den Datei-Explorer
Gehe zu C:\Temp
Rechtsklick auf WLAN_Test.ps1
Wähle Mit PowerShell ausführen
Methode B: Über PowerShell direkt
Drücke Windows-Taste + X
Wähle Terminal oder PowerShell
Tippe folgenden Befehl und drücke Enter:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
C:\Temp\WLAN_Test.ps1
⚠️ Fehlerbehebung
"Script kann nicht ausgeführt werden"
Falls du eine rote Fehlermeldung siehst, führe einmalig diesen Befehl in PowerShell aus:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
Danach das Script erneut starten.
"Zugriff verweigert" auf C:\Temp
Erstelle den Ordner stattdessen auf deinem Desktop:
Ändere im Script die Zeile:
$LogFile = "C:\Temp\WLAN_Log.csv"
zu:
$LogFile = "$env:USERPROFILE\Desktop\WLAN_Log.csv"
⏹️ Script beenden
Drücke STRG + C im PowerShell-Fenster, um das Logging zu stoppen.
📊 Ergebnisse verstehen
Live-Anzeige im Fenster
Farbe
Bedeutung
🟢 Grün
Alles OK
🔴 Rot
Problem erkannt
Die Log-Datei (CSV)
Die Ergebnisse werden in C:\Temp\WLAN_Log.csv gespeichert.
Spalte
Bedeutung
Timestamp
Datum und Uhrzeit der Messung
Router_Latency_ms
Antwortzeit deines Routers (WLAN-Qualität)
Internet_Latency_ms
Antwortzeit ins Internet (Anbieter-Qualität)
Status_Fazit
Automatische Bewertung
Status-Bedeutungen
Status
Was es bedeutet
Wer ist schuld?
OK
Alles funktioniert
Niemand 😊
WLAN_SCHWACH
Router antwortet langsam (>100ms)
Dein WLAN
WLAN_ABBRUCH (Lokal)
Keine Verbindung zum Router
Dein WLAN
ISP_AUSFALL (Extern)
Router OK, aber kein Internet
Dein Anbieter
🔍 Daten analysieren lassen
Nachdem du das Script eine Weile laufen gelassen hast (z.B. über Nacht oder während der Problemzeiten), kannst du die Daten von einer KI analysieren lassen.
So gehst du vor:
Öffne die Log-Datei:
Gehe zu C:\Temp
Doppelklick auf WLAN_Log.csv (öffnet sich in Excel oder Editor)
Kopiere den Inhalt:
Markiere alles (STRG + A)
Kopiere (STRG + C)
Nutze diesen Analyse-Prompt:
Kopiere den folgenden Text und füge deine Daten am Ende ein:
Du bist ein freundlicher und geduldiger IT-Experte, der einem Laien hilft, Internetprobleme zu verstehen.

Ich habe ein Protokoll (CSV) erstellt, um herauszufinden, ob mein WLAN zu Hause schlecht ist oder ob mein Internetanbieter (ISP) Probleme macht. Bitte analysiere die unten angefügten Daten und gib mir eine für Laien verständliche Zusammenfassung.

Hier ist der Aufbau der Daten:
- Spalte "Router_Latency_ms": Das ist die Verbindung von meinem Laptop zum Router (WLAN).
- Spalte "Internet_Latency_ms": Das ist die Verbindung vom Router ins Internet.
- "TIMEOUT" bedeutet, die Verbindung war komplett weg.

Bitte befolge diese Logik bei der Analyse:
1. Wenn "Router_Latency_ms" TIMEOUT zeigt oder sehr hoch ist (>100ms), dann ist mein WLAN das Problem (Signal zu schwach, Störung).
2. Wenn "Router_Latency_ms" niedrig ist (z.B. <10ms), aber "Internet_Latency_ms" TIMEOUT zeigt, dann liegt das Problem beim Internetanbieter (Kabel/Leitung draußen).

Bitte erstelle mir folgende Auswertung:
1. **Zusammenfassung:** Wie stabil war die Verbindung insgesamt? Gab es viele Ausfälle?
2. **Der Schuldige:** Liegt es am WLAN oder am Anbieter? (Nenne eine Prozentzahl, z.B. "Zu 90% liegt es am WLAN").
3. **Zeitpunkte:** Wann waren die schlimmsten Ausfälle?
4. **Nächste Schritte:** Was soll ich tun? (z.B. "Router umstellen" vs. "Beim Anbieter anrufen und sagen, dass das Modem die Verbindung verliert").

Antworte bitte einfach, ohne Fachbegriffe, aber präzise.

HIER SIND DIE DATEN:
[Füge hier den Inhalt der CSV-Datei ein]
💡 Tipps für gute Ergebnisse
Lass das Script mindestens 1-2 Stunden laufen – besser über Nacht
Starte es, wenn Probleme auftreten – dann siehst du die Ausfälle
Der Laptop sollte dort stehen, wo du normalerweise surfst
Schließe den Laptop nicht – das unterbricht das Logging
❓ Häufige Fragen
Verbraucht das Script viel Strom oder Leistung?
Nein, es ist sehr ressourcenschonend.
Kann ich meinen PC normal weiter benutzen?
Ja! Das Script läuft im Hintergrund.
Wie groß wird die Log-Datei?
Ca. 1 MB pro Tag – also kein Problem.
Funktioniert das auch mit LAN-Kabel?
Ja! Dann testet es deine Kabelverbindung statt WLAN.
📞 Support beim Anbieter
Falls die Analyse zeigt, dass dein Anbieter schuld ist, hier ein Beispieltext für den Anruf:
"Guten Tag, ich habe Verbindungsabbrüche dokumentiert. Mein WLAN zum Router funktioniert einwandfrei (Ping unter 10ms), aber die Verbindung ins Internet bricht regelmäßig ab. Die Ausfälle treten besonders um [UHRZEIT] auf. Können Sie bitte die Leitung prüfen?"
🌐 GitHub Repository
⭐ GitHub: m0h1nd4/ping-plotter
Fehler gefunden? Verbesserungsvorschläge? Erstelle gerne ein Issue oder einen Pull Request!
📄 Lizenz
Dieses Projekt steht unter der MIT-Lizenz – du darfst es frei verwenden, verändern und weitergeben.
Siehe LICENSE für Details.
Erstellt für Windows 11 • Version 1.0
