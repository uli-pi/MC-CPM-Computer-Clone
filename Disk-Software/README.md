# DISK Software für SYS-80s

Eines der größten Probleme bei einem neu gebauten System ist: Wie bekomme ich ein Boot fähiges Medium um CP/M zu starten? In diesem Verzeichnis befinden sich alle Dateien um eine Boot Diskette im NDR 80Spur Format zu erstellen. 

Das verwendete CBIOS ist Hardwareseitig für den MC-CP/M Computer programmiert.
Für Disketten brauchen Sie natürlich die Floppy Karte FLO-80 und ein entsprechendes Laufwerk.

Als Disk kann eine 3,5" oder auch 5,25" Diskette verwendet werden. Bei Verwendung von 3,5" Disketten ist das "HD-Loch" abzukleben. Das Format entspricht 80 Spuren x 1024Byte x5Sektoren, das ergibt eine Kapazität von 800KB. Oder Sie verwenden eine Compact Flash Karte. Anleitung dazu siehe CF-Karte.


Im Bios sind 2 Laufwerke (A,B) im NDR Format und 2 Laufwerke im 8" (C,D) im IBM Format definiert. 3,5" Laufwerke verhalten sich wie 8" Laufwerke. Eine 3,5" Diskette mit offenen HD Loch kann als IBM Diskette formatiert werden. 

Das Erstellen einer BOOT Diskette ist im PDF "Erstellen-Boot-Disk" beschrieben.
