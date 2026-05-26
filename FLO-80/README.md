# Floppy Controller FLO-80

<img width="1024" height="607" alt="FLO-80" src="https://github.com/user-attachments/assets/319e2cc6-d75c-4727-8343-2995fb4de503" />

Die Flo-80 Karte ist kompatibel zur FLO-2 Karte des MC CP/M Computers. 
Es wurde der FDC9239BT Datenseparator benutzt da die alte originale FLO-Karte erhebliche Probleme mit dem Datenseparator hatte. In der ersten FLO Karte war der Datenseparator noch diskret aufgebaut und ohne Oszilloskope war ein Abgleich nur schwer möglich. Dann gab es eine Umbauanleitung mit dem 9216 Datenseparator. Die folgenden FLO Karten verwendeten den FDC 9229 Chip.
 
Auf den FLO-80 Karten können FDC9239BT oder FDC9229BT bestückt werden, je nachdem welcher Chip erhältlich ist. Dies ist mit 2 Jumpern einstellbar.
 
Für den FDC9229BT ist zwingend der Quarzoszillator X1 erforderlich. Beim FDC9239BT kann anstelle des X1 auch der Quarz Y1 eingesetzt werden.

Es sind Pfostenstecker für 3,5" bzw.  5,25" und 8" Laufwerke vorhanden. Die Dekodierung erlaubt den direkten Anschluss von 4 Laufwerken. Modere PC Laufwerke haben meist  keinen "READY" Anschluss mehr, da der PC heute stattdessen den Disk Change Anschluss benutzt. Manche Laufwerke können mittels Jumper auf die Signale eingestellt werden. Bei dem größten Teil der Laufwerke ist dies aber nicht oder nur mit Eingriff in die Elektronik möglich. Der Floppy Controller Chip benötigt aber dieses Signal, daher kann die FLO-80 Karte Ihr eigenes Ready Signal erzeugen. Hierzu sind die Jumper DS1 bis DS4 Vorgesehen. Somit können alle Laufwerke verwendet werden.
Mittels Adapter ist es möglich 3,5" Laufwerke anzuschließen.  Man benötigt ein 1:1 Kabel. Bei einem gedrehten PC Floppy Anschlusskabel muss man den Stecker für das zweite Laufwerk von dem gedrehten Teil auf den geraden Teil umklemmen. Auf dem Adapter ist die ID für Disk 1 bis 4 (entspricht Laufwerk A bis D) per Jumper einstellbar.

3,5" Disk Laufwerke sind heute noch gut zu bekommen und lassen sich im MC-Computer nutzen.
Wird bei  3,5" Disketten das HD "Loch" zugeklebt, sind die Disketten als DD Disketten nutzbar. Diese können dann mit NDR Format formatiert und als 800KB Disketten genutzt werden. 
Es gilt weiterhin die originale Beschreibung der FLO2 Karte. 
