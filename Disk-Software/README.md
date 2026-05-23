# DISK Software für SYS-80s

Eines der größten Probleme bei einem neu gebauten System ist: Wie bekomme ich ein Boot fähiges Medium um CP/M zu starten? In diesem Verzeichnis befinden sich alle Dateien um eine Boot Diskette im NDR 80Spur Format zu erstellen. 

Das verwendete BIOS ist Hardwareseitig für den MC-CP/M Computer programmiert.
Für Disketten brauchen Sie natürlich eine Floppy Karte FLO-80 bzw. original FLO2 und ein entsprechendes Laufwerk. 3,5", 5,25" oder auch 8" Laufwerke sind möglich.
Bei Verwendung von 3,5" Disketten ist das "HD-Loch" abzukleben. Oder Sie verwenden eine Compact Flash Karte. Anleitung dazu siehe CF-Karte.

Im diesem Bios sind 2 Laufwerke (A,B) im NDR Format (80TRK, 5 x 1024, 800KB) und 2 Laufwerke (C,D) im 8"  im IBM Format definiert. 3,5" Laufwerke verhalten sich wie 8" Laufwerke. Eine 3,5" Diskette mit offenen HD Loch kann als IBM 8" Diskette formatiert werden. 

Für das NDR 80TRK Format können 3,5" oder auch 5,25" Laufwerke verwendet werden. Das Bios ist für beide Laufwerksarten identisch. Bei Verwendung von 3,5" Disketten ist das "HD-Loch" auf der Disk abzukleben. Bei Verwendung von 5,25" Laufwerken müssen Sie darauf achten das, das Laufwerk als Double Density (DD) konfiguriert ist. PC Laufwerke in der Standard Einstellung arbeiten im HD Modus und funktionieren mit diesem Bios nicht. Die meisten 5,25" Laufwerke kann man auf DD umstellen. Anleitungen dazu findet man im Internet. Das würde hier den Rahmen sprengen den da ist jedes Laufwerk anders.  

Das Erstellen einer BOOT Diskette ist im PDF "Erstellen-Boot-Disk" beschrieben.
