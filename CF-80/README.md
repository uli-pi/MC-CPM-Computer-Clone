# CF-80 Karte - CP/M Install Anleitung für eine CF Speicherkarte

Die Karte wurde für das MC-Computer ECB Bus System entwickelt und verwendet nur 8 Bit des angeschlossenen 16Bit Mediums. Das halbiert schon einmal vorweg die nutzbare Kapazität. Es sollte ein Datenträger mit mindestens 128MB verwendet werden.
Es kann auch eine ATA  oder eine SSD Festplatte verwendet werden.
 
Anschluss eines Laufwerks:

Diese Karte funktioniert mit den meisten IDE/CF/SSD-Laufwerken. Die Kapazität des Laufwerks sollte 128 Megabyte oder mehr betragen, wenn Sie CP/M installieren möchten. Dies ist nicht erforderlich, um genügend Speicherplatz zu haben – denn ein vollwertiges CP/M-System belegt unter 1 MB an Speicherplatz –, sondern vielmehr weil die von mir verwendeten Treiber vereinfachten Code verwenden, der den Speicherplatz nicht sehr effizient nutzt. Es kommt eine vereinfachte Arithmetik zum Einsatz, um die CP/M-Sektoren auf die LBA-Sektoren der Festplatte abzubilden. Dabei bleibt ein erheblicher Teil des Speicherplatzes ungenutzt.  Es kann aber jeder einen Treiber selbst für das System schreiben um den Speicherplatz auszunutzen. 
Viele kleine Solid-State-Flash-Module benötigen keinen separaten Stromanschluss; stattdessen können Sie die +5V-Spannung (bei geringer Stromaufnahme) direkt über Pin 20 des Laufwerksanschlusses beziehen. Bei der vorliegenden Karte liegt dieser auf +5V und die SSD bzw. CF Karten benötigen daher keine externe Spannungsversorgung.

Die Adressen sind auf der Karte zwischen 010h bis 078h einstellbar, es werden 8 Adressen benutzt.
Für das SYS-80 System liegt die Basis Adresse auf 018Hex.

Adressen IDE Port CF-80 Karte

	IDEDATA	EQU 0x8h			;IDE Daten Register
	SECCND	EQU 0xah			;Sector Count Register
	LBA7	EQU 0xbh			;LBA Bits 0-7
	LBA15	EQU 0xch			;LBA Bits 8-15
	LBA23	EQU 0xdh			;LBA Bits 16-23
	IDEHEAD	EQU 0xeh			;IDE Drive Head Register
	IDESTAT	EQU 0xfh			;IDE Command/Status Register
