# DISK Software für SYS-80s

Das verwendete CBIOS ist Hardwareseitig für die SYS-80s CPU-Karte mit serieller Schnittstelle eingestellt. Für die SYS ohne serielle Schnittstelle muss ein andres Bios verwendet werden. 
In diesem Verzeichnis befinden sich alle Dateien um eine Boot Diskette im NDR 80Spur Format zu erstellen. Als Disk kann eine 3,5" oder auch 5,25" Diskette verwendet werden. Bei Verwendung von 3,5" Disketten ist das "HD-Loch" abzukleben. Das Format entspricht 80 Spuren x 1024Byte x5Sektoren, dies entspricht einer Kapazität von 800KB.
Im Bios sind 2 Laufwerke (A,B) im NDR Format und 2 Laufwerke im 8" (C,D) im IBM Format definiert. 3,5" Laufwerke verhalten sich wie 8" Laufwerke. Eine 3,5" Diskette mit offenen HD Loch kann als IBM Diskette formatiert werden. 