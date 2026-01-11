# 🛜 Ping-Plotter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-lightgrey.svg)]()

**Finde heraus, ob dein WLAN oder dein Internetanbieter schuld ist!**

Ein einfaches PowerShell-Tool, das deine Internetverbindung protokolliert und dir hilft herauszufinden, warum dein Internet manchmal nicht funktioniert.

---

## 📋 Inhaltsverzeichnis

- [Was macht dieses Tool?](#-was-macht-dieses-tool)
- [Voraussetzungen](#️-voraussetzungen)
- [Installation](#-installation--einrichtung)
- [Nutzung](#️-script-starten)
- [Ergebnisse verstehen](#-ergebnisse-verstehen)
- [Daten analysieren](#-daten-analysieren-lassen)
- [Fehlerbehebung](#️-fehlerbehebung)
- [FAQ](#-häufige-fragen)
- [Lizenz](#-lizenz)

---

## 🔍 Was macht dieses Tool?

Das Tool prüft **jede Sekunde** zwei Dinge:

| Test | Was wird geprüft? | Ergebnis |
|------|-------------------|----------|
| 🏠 **Router-Ping** | Verbindung von deinem PC zum Router | Ist dein WLAN stabil? |
| 🌐 **Internet-Ping** | Verbindung vom Router ins Internet | Funktioniert die Leitung deines Anbieters? |

Die Ergebnisse werden automatisch in einer CSV-Datei gespeichert, die du später analysieren kannst.

### So funktioniert die Diagnose

```
Dein PC  ──────►  Router  ──────►  Internet (8.8.8.8)
           │                │
           │                └── Wenn hier Fehler: Anbieter schuld
           │
           └── Wenn hier Fehler: WLAN schuld
```

---

## 🖥️ Voraussetzungen

- ✅ Windows 10 oder Windows 11
- ✅ PowerShell (bereits vorinstalliert)
- ✅ Keine zusätzliche Installation nötig!

---

## 📥 Installation & Einrichtung

### Schritt 1: Ordner erstellen

1. Öffne den **Datei-Explorer** (`Windows-Taste` + `E`)
2. Gehe zu `C:\`
3. Erstelle einen neuen Ordner namens `Temp`:
   - Rechtsklick → **Neu** → **Ordner** → `Temp` eingeben

### Schritt 2: Script herunterladen

**Option A: Direkt herunterladen**

Lade die Datei `WLAN_Test.ps1` von diesem Repository herunter und speichere sie in `C:\Temp\`

**Option B: Manuell erstellen**

1. Öffne den **Editor** (`Windows-Taste` → "Editor" eintippen → `Enter`)
2. Kopiere das Script (siehe unten)
3. Speichere die Datei:
   - **Datei** → **Speichern unter**
   - Speicherort: `C:\Temp`
   - Dateiname: `WLAN_Test.ps1`
   - Dateityp: **Alle Dateien (\*.\*)**

---

## 📜 Das Script

<details>
<summary>📋 Klicke hier um den Code anzuzeigen</summary>

```powershell
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
```

</details>

---

## ▶️ Script starten

### Methode A: Per Rechtsklick (Empfohlen)

1. Öffne den **Datei-Explorer**
2. Gehe zu `C:\Temp`
3. **Rechtsklick** auf `WLAN_Test.ps1`
4. Wähle **Mit PowerShell ausführen**

### Methode B: Über PowerShell direkt

1. Drücke `Windows-Taste` + `X`
2. Wähle **Terminal** oder **PowerShell**
3. Führe diese Befehle aus:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
C:\Temp\WLAN_Test.ps1
```

### ⏹️ Script beenden

Drücke `STRG` + `C` im PowerShell-Fenster.

---

## 📊 Ergebnisse verstehen

### Live-Anzeige im Fenster

| Farbe | Bedeutung |
|-------|-----------|
| 🟢 **Grün** | Alles OK |
| 🔴 **Rot** | Problem erkannt |

### Die Log-Datei

Die Ergebnisse werden in `C:\Temp\WLAN_Log.csv` gespeichert:

| Spalte | Bedeutung |
|--------|-----------|
| `Timestamp` | Datum und Uhrzeit der Messung |
| `Router_Latency_ms` | Antwortzeit deines Routers (WLAN-Qualität) |
| `Internet_Latency_ms` | Antwortzeit ins Internet (Anbieter-Qualität) |
| `Status_Fazit` | Automatische Bewertung |

### Status-Bedeutungen

| Status | Was es bedeutet | Wer ist schuld? |
|--------|-----------------|-----------------|
| `OK` | Alles funktioniert | Niemand 😊 |
| `WLAN_SCHWACH` | Router antwortet langsam (>100ms) | 🏠 Dein WLAN |
| `WLAN_ABBRUCH (Lokal)` | Keine Verbindung zum Router | 🏠 Dein WLAN |
| `ISP_AUSFALL (Extern)` | Router OK, aber kein Internet | 🌐 Dein Anbieter |

---

## 🔍 Daten analysieren lassen

Nachdem du das Script eine Weile laufen gelassen hast (z.B. über Nacht), kannst du die Daten analysieren lassen.

### So gehst du vor

1. **Öffne die Log-Datei:**
   - Gehe zu `C:\Temp`
   - Doppelklick auf `WLAN_Log.csv` (öffnet sich in Excel oder Editor)

2. **Kopiere den Inhalt:**
   - Markiere alles (`STRG` + `A`)
   - Kopiere (`STRG` + `C`)

3. **Nutze den Analyse-Prompt:**

<details>
<summary>📋 Klicke hier für den kompletten Analyse-Prompt</summary>

Kopiere den folgenden Text und füge deine Daten am Ende ein:

```
Du bist ein freundlicher und geduldiger IT-Experte, der einem Laien hilft, 
Internetprobleme zu verstehen.

Ich habe ein Protokoll (CSV) erstellt, um herauszufinden, ob mein WLAN zu 
Hause schlecht ist oder ob mein Internetanbieter (ISP) Probleme macht. 
Bitte analysiere die unten angefügten Daten und gib mir eine für Laien 
verständliche Zusammenfassung.

Hier ist der Aufbau der Daten:
- Spalte "Router_Latency_ms": Das ist die Verbindung von meinem Laptop zum Router (WLAN).
- Spalte "Internet_Latency_ms": Das ist die Verbindung vom Router ins Internet.
- "TIMEOUT" bedeutet, die Verbindung war komplett weg.

Bitte befolge diese Logik bei der Analyse:
1. Wenn "Router_Latency_ms" TIMEOUT zeigt oder sehr hoch ist (>100ms), 
   dann ist mein WLAN das Problem (Signal zu schwach, Störung).
2. Wenn "Router_Latency_ms" niedrig ist (z.B. <10ms), aber "Internet_Latency_ms" 
   TIMEOUT zeigt, dann liegt das Problem beim Internetanbieter (Kabel/Leitung draußen).

Bitte erstelle mir folgende Auswertung:

1. **Zusammenfassung:** Wie stabil war die Verbindung insgesamt? Gab es viele Ausfälle?
2. **Der Schuldige:** Liegt es am WLAN oder am Anbieter? (Nenne eine Prozentzahl)
3. **Zeitpunkte:** Wann waren die schlimmsten Ausfälle?
4. **Nächste Schritte:** Was soll ich tun?

Antworte bitte einfach, ohne Fachbegriffe, aber präzise.

HIER SIND DIE DATEN:
[Füge hier den Inhalt der CSV-Datei ein]
```

</details>

---

## ⚠️ Fehlerbehebung

### "Script kann nicht ausgeführt werden"

Falls du eine rote Fehlermeldung siehst, führe **einmalig** diesen Befehl in PowerShell aus:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

Danach das Script erneut starten.

### "Zugriff verweigert" auf C:\Temp

Ändere im Script den Speicherort auf deinen Desktop:

```powershell
# Vorher:
$LogFile = "C:\Temp\WLAN_Log.csv"

# Nachher:
$LogFile = "$env:USERPROFILE\Desktop\WLAN_Log.csv"
```

---

## 💡 Tipps für gute Ergebnisse

- ⏱️ Lass das Script **mindestens 1-2 Stunden** laufen – besser über Nacht
- 🎯 Starte es, **wenn Probleme auftreten** – dann siehst du die Ausfälle
- 📍 Der Laptop sollte dort stehen, **wo du normalerweise surfst**
- 💻 Schließe den Laptop **nicht** – das unterbricht das Logging

---

## ❓ Häufige Fragen

<details>
<summary><strong>Verbraucht das Script viel Strom oder Leistung?</strong></summary>

Nein, es ist sehr ressourcenschonend. Du wirst keinen Unterschied merken.
</details>

<details>
<summary><strong>Kann ich meinen PC normal weiter benutzen?</strong></summary>

Ja! Das Script läuft im Hintergrund und stört nicht.
</details>

<details>
<summary><strong>Wie groß wird die Log-Datei?</strong></summary>

Ca. 1 MB pro Tag – also kein Problem, selbst bei längerer Nutzung.
</details>

<details>
<summary><strong>Funktioniert das auch mit LAN-Kabel?</strong></summary>

Ja! Dann testet es deine Kabelverbindung statt WLAN.
</details>

<details>
<summary><strong>Kann ich das Intervall ändern?</strong></summary>

Ja! Ändere im Script die Zeile `$IntervalSeconds = 1` auf deinen gewünschten Wert (in Sekunden).
</details>

---

## 📞 Support beim Anbieter

Falls die Analyse zeigt, dass dein **Anbieter schuld ist**, hier ein Beispieltext für den Anruf:

> *"Guten Tag, ich habe Verbindungsabbrüche dokumentiert. Mein WLAN zum Router funktioniert einwandfrei (Ping unter 10ms), aber die Verbindung ins Internet bricht regelmäßig ab. Die Ausfälle treten besonders um [UHRZEIT] auf. Können Sie bitte die Leitung prüfen?"*

---

## 🤝 Mitmachen

Fehler gefunden? Verbesserungsvorschläge?

- 🐛 [Issue erstellen](https://github.com/m0h1nd4/ping-plotter/issues)
- 🔧 Pull Request einreichen
- ⭐ Projekt mit einem Stern unterstützen!

---

## 📄 Lizenz

Dieses Projekt steht unter der **MIT-Lizenz** – du darfst es frei verwenden, verändern und weitergeben.

Siehe [LICENSE](LICENSE) für Details.

---

<p align="center">
  <strong>Erstellt für Windows 10/11 • Version 1.0</strong><br>
  <a href="https://github.com/m0h1nd4/ping-plotter">⭐ GitHub: m0h1nd4/ping-plotter</a>
</p>
