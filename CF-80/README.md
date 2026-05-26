# CF-80 Karte 

<img width="1280" height="785" alt="CF-Card" src="https://github.com/user-attachments/assets/354090ca-34f4-4ea9-8e36-fa82cbd1fe2e" />

Die Karte wurde für das MC-Computer ECB Bus System entwickelt und verwendet nur 8 Bit des angeschlossenen 16Bit Mediums. Das halbiert schon einmal vorweg die nutzbare Kapazität. Es sollte ein Datenträger mit mindestens 128MB verwendet werden.
Es kann auch eine ATA  oder eine SSD Festplatte verwendet werden.
 
Anschluss eines Laufwerks:

Diese Karte funktioniert mit den meisten IDE/CF/SSD-Laufwerken. Die Kapazität des Laufwerks sollte 128 Megabyte oder mehr betragen, wenn Sie CP/M installieren möchten. Dies ist nicht erforderlich, um genügend Speicherplatz zu haben – denn ein vollwertiges CP/M-System belegt unter 1 MB an Speicherplatz –, sondern vielmehr weil die von mir verwendeten Treiber vereinfachten Code verwenden, der den Speicherplatz nicht sehr effizient nutzt. Es kommt eine vereinfachte Arithmetik zum Einsatz, um die CP/M-Sektoren auf die LBA-Sektoren der Festplatte abzubilden. Dabei bleibt ein erheblicher Teil des Speicherplatzes ungenutzt.  Es kann aber jeder einen Treiber selbst für das System schreiben um den Speicherplatz auszunutzen. 
Viele kleine Solid-State-Flash-Module benötigen keinen separaten Stromanschluss; stattdessen können Sie die +5V-Spannung (bei geringer Stromaufnahme) direkt über Pin 20 des Laufwerksanschlusses beziehen. Bei der vorliegenden Karte liegt dieser auf +5V und die SSD bzw. CF Karten benötigen daher keine externe Spannungsversorgung.

Die Adressen sind auf der Karte zwischen 010h bis 078h einstellbar, es werden 8 Adressen benutzt.
Für das SYS-80 System liegt die Basis Adresse auf 018Hex.
