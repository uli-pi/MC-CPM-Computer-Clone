# CF-80 Karte

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


Wie bekommt man nun CPM auf den Datenträger ?
Voraussetzung ist die MC-Computer SYS-80  Systemkarte mit Monitor Eprom  für den IDE-80 CF-Adapter.
Zum Erstellen einer CP/M bootfähigen CF-Karte bedienen wir uns des Monitor der SYS-80 Karte. Dieser beinhaltet viele Kommandos die zum Aufsetzen und testen eines Systems hilfreich sind.
Folgende Monitor Kommandos werden benötigt:
R offset	lädt ein INTEL HEX File über die Terminal Schnittstelle in das RAM
G offset	springt an die angegebene Adresse und  startet das Programm
Wir brauchen ein Terminalprogramm das Binärfiles über die Serielle Schnittstelle zur Console  senden kann. Ich benutze dazu RealTerm.
Die Speicheraufteilung des MC-Systems ist wie folgt:
	 
Daraus geht hervor wohin wir die Binärfiles laden müssen.
 
Folgende Binärfiles im INTEL HEX Format werden benötigt:
CBIOS-CF.HEX		das angepasste Bios für die CF-Karte (Adresse EA00h)
CPM22.HEX			CCP und BDOS, original von DR (Adresse D400h)
FORM-CF.HEX		Formatiert 4 Laufwerke (Adresse 8000h)
PUTSY-CF.HEX		Kopiert CP/M auf Systemspuren (Adresse 8000h)
BLOAD-CF.HEX		Bootloader (Adresse 8000h)
BOOT-CF.HEX		Schreibt Bootloader auf LBA0 (Adresse 100h)
System Starten, Monitor meldet sich mit  > Prompt.
Um das System in einen definierten Ausganszustand zu bringen leert man zuerst den  Speicher mit folgendem Monitor Befehl  f0,ef00,0  ->Enter. Damit leert man den Speicher bis zum Monitor Bereich.
Es muss der Datenträger für das CPM vorbereitet (formatiert) werden. Dazu nutzten wir das CPM Bios das auf den Datenträger soll. Es beinhaltet alle Funktionen die zum Schreiben von Sektoren im richtigen Format nötig sind.
Im Monitor eingeben rea00   Enter, der Monitor erwartet jetzt eine Datei die er auf Adresse EA00 Hex abspeichert.
Der Monitor kann nur Dateien im INTEL HEX Format empfangen!
Nun wird in Real Term mit der Send Funktion die Datei CBIOS-CF.Hex übertragen. Ist die Übertragung korrekt erfolgt meldet sich der Monitor mit FF* wieder zurück.
Nach der gleichen Methode  wird nun FORM-CF.HEX auf Adresse 8000h geladen.
Dann startet man das Formatprogramm mit g8000 -> Enter
Jetzt sollte das Formatprogramm arbeiten. Es werden 4 Laufwerke formatiert und die „Disk Aktiv“ LED auf der Karte leuchtet.
Das Programm  zeigt den Formatierungsfortschritt an. Geduld, das dauert ein paar Minuten. Das Programm springt, wenn fertig, wieder in den Monitor zurück.
Wenn der  Datenträger formatiert ist kann CP/M aufgespielt werden.
Die erste Datei ist CPM22.com, Diese kommt auf Adresse D400h. Das geht wieder  mit dem R Kommando:  rd400 -> Enter. Diese originale DR Datei enthält das CCP, BDOS und eine leere Sprungtabelle für CP/M 2.2. Datei in Real Term auswählen und übertragen.
Dann patchen wir das BIOS in das leere CP/M. Dies ist die Datei CBIOS-CF.HEX, kommt auf Adresse EA00h. Wie gehabt mit dem R Befehl.
Das komplette CP/M ist nun im Ram und muss auf den Datenträger geschrieben werden.
Dazu lädt man nun PUTSY-CF.HEX auf Adresse 8000h 
Mit einem G Befehl auf Adresse 8000h (g8000 -> Enter) wird das Programm gestartet und schreibt CP/M auf den Datenträger. Nun sollte die LED auf der CF-80 Karte kurz aufleuchten.
Im Übrigen ist CP/M jetzt betriebsbereit wir haben nur noch keinen Kalt Start (BOOT).
Geben Sie gea00 -> ein und CP/M wird sich melden.
Zum Weitermachen wieder in den Monitor mit dem Reset Knopf.
Jetzt fehlt nur noch der „Cold Boot Loader“ um CP/M bei einem Kaltstart ins Ram zu schreiben und zu starten.
Dazu wird BLOAD-CF.HEX auf Adresse 8000h geladen.
Danach wird BOOT-CF.HEX auf Adresse 100h geladen (r100 )und mit g100 gestartet.
Reset Knopf drücken. Nun wird mit dem Monitor Befehl  I  das Bootmenue aufgerufen und mit Auswahl =2 die CF Karte ausgewählt. Das CP/M sollte starten.
Wir haben ein CP/M mit 4 Laufwerken (A bis D) und keine Dateien auf dem Datenträger. Das macht keinen Spaß, wir brauchen Programme.
Dazu benutzen wir erst einmal wieder unsere Lademethode mit Monitor und RealTerm. Reset drücken, wir brauchen den Monitor.
Die Datei der Begierde ist GETPC.COM , damit lassen sich alle Dateien über XMODEM auf unser CP/M laden.
Mit r100h, GETPC.HEX ins RAM laden. 
Nun wird mit dem Monitor Befehl  I  das Bootmenue aufgerufen und mit Auswahl =2 die CF Karte ausgewählt. Das CP/M sollte starten. 
Das GETPC ist immer noch unversehrt im RAM.
Das erste Kommando in CP/M ist nun save 5 getpc.com und wir haben das Programm auf dem Datenträger. Somit lassen sich beliebige Programme auf den Datenträger überspielen was aber ziemlich mühsam wäre. Aber wir haben jetzt GETPC.
Wir wechseln das Terminal Programm und verwenden ab sofort TerraTerm. Dieses Programm hat ein integriertes XMODEM.
Auf der CP/M Seite rufen wir GETPC Filename.ext  der Datei die wir übertragen wollen auf. Dann wartet CP/M auf das File. Der Filename ist frei wählbar das Programm überträgt einfach die Datei und speichert sie unter dem gewählten Namen ab.
Auf dem PC im Programm TerraTerm sind es die Kommandos DATEI, TRANSFER, XMODEM, SEND und Datei auswählen. Wir brauchen uns über Länge und Speicherplatz nicht mehr zu kümmern. Das machen die Programme untereinander aus.
Zurückspielen von CP/M auf PC geht dann mit PCPUT.com das wir ja jetzt mit GETPC  einfach auf unseren CP/M Rechner holen können.
GETPC.com und PUTPC.com sind einfach Kopien von PCGET.com und PCPUT.com die auf die Hardware der SYS80s Karte angepasst wurden. Ich habe diese umbenannt damit man nicht mit den Varianten für das originale System mit OUT Karte durcheinander kommt. Da die Programme direkt über die Hardware kommunizieren müssen sie immer an die verwendete Hardware angepasst werden.
