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

