**Die „neue“ OUT-80 Karte (Rev. 2.1)**

… Ist nach wie vor voll MC-Computer kompatibel.

Die Karte ist fest auf die MC-Computer Seriell I/O Basis adr 0F0hex eingestellt. Die Adressbelegung entspricht der MC-Computer Terminologie und steht auf der Karte. Die Karte liegt mehrfach im I/O Adressraum, so auch wieder bei 1F0hex usw. Da hat man sich wenig Mühe gemacht und eine volle Dekodierung hätte auch den Rahmen gesprengt.

Die RS 232 Schnittstellen sind als DTE geschaltet wie es sich für einen Computer gehört. Das bedeutet zum PC braucht man ein gedrehtes Kabel (Nullmodem Kabel) weil auch der PC als DTE konfiguriert ist. SIO A ist der Terminal Port (TTY), SIO B war damals als Punch Kanal definiert.

An den Sub D9 Steckern sind die Signale DCD und DTR nicht aufgelegt, da die häufig nicht gebraucht werden. Wer die Signale dennoch benötigen sollte kann das auf dem kleinen Lötrasterfeld verwirklichen und einen weiteren RS232 Treiber einbauen.

Wenn man ein Kabel nur mit 3 Leitungen (RX/TX/GND) verwendet muss man die CTS/RTS Jumper auf der Platine stecken oder in der Kabelbuchse Brücken. Die Software fragt das ab. Man kann natürlich auch die Initialisierung im ROM Ändern.

Es gibt jetzt 2 LED auf der Platine. Sie sind an die Chip Select Anschlüsse der SIO und PIO angeschlossen und leuchten wenn diese selektiert werden (da waren noch 2 Gatter frei die ich dafür benutzt habe). Bitte hier 3mA LED verwenden damit die Gatter nicht so belastet werden.

Nicht wundern das die SIO LED leuchtet wenn der MC-Computer gestartet ist, es wird ja ständig der Port angesprochen um zu sehen ob ein Zeichen da ist. Bei Disk Operationen z.B. geht sie schon mal aus weil ja die SIO dann pausiert. Sieht man auch schön wenn man sich eine Datei mit „TYPE“ anschaut.

Folgendes zu den SIO Chip‘s:

Getestet habe ich mit original Z80-SIO-0 und Zilog Z84C4006. Da der MC-Monitor ROM die SIO mit komplettem Handshake initialisiert, muss man bei der Z80-SIO-0 die auf der Platine vorgesehenen Jumper auf DCD/DTR stecken. Sonst geht keine Eingabe.

Die PIO (Z80-PIO) war als Parallele Centronics Drucker Schnittstelle gedacht. Da gab es ein kleines Programm um diese zu initialisieren. Man kann die Pio natürlich für jede andere Art von Steuerungen verwenden. Sie kann auch weggelassen werden, das hat keinen Einfluss auf die Seriellen Port’s.