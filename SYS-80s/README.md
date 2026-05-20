# SYS-80s CPU Karte


MC CP/M Computer kompatible CPU Karte zur originalen MC-Computer SYS-1 Karte.

Die SYS-80s Karte hat eine serielle Schnittstelle on Board und benötigt daher zum Betrieb keine  OUT-Karte wie ursprünglich im MC-CP/M Computer vorgesehen. Das Consol Terminal wird direkt an die CPU Karte angeschlossen. Die Einheit kann "Standalone" als vollwertiger Z80 Rechner betrieben werden.

Es gibt ein angepasstes Monitor Eprom (Mon80V1.bin) um diese Schnittstelle als Console zu nutzen. Die SYS-80s kann auch mit dem originalen Monitor Eprom benutzt werden dann ist die Console zur OUT Karte umgeleitet und die "on Board" Schnittstelle frei.

Es ist somit möglich die SYS-80s CPU Karte als 1:1 Ersatz für eine alte SYS-1 zu verwenden wenn diese defekt sein sollte.

Auf der SYS-80 Karte wird ein statisches 128KB RAM verwendet. Der Z80 kann aber nur 64KB adressieren so bleibt die hälfte des RAM ungenutzt. Der Chip war deutlich preiswerter als andere Lösungen daher wurde er verwendet. Vielleicht ergibt sich ja in Zukunft die Möglichkeit mit einem Hardware "banking" die zweiten 64KB nutzbar zu machen. Der EPROM Sockel erlaubt 4KB oder 8KB Eproms zu benutzen, dies ist per Jumper einstellbar.

Der CPU Takt ist mit einem 12Mhz Quarz zwischen 6Mhz und 3Mhz umschaltbar. Bei benutzung von 8" Floppy Laufwerken ist 6Mhz erforderlich. Heute gibt es genug Z80 Varianten die schnellen CPU-Takt vertragen.

Der Schnittstellen Chip (D71051C)ist eine schnelle Variante des 8251. Der Chip ist Hard und Software kompatibel. Es lässt sich deshalb auch ein 8251 einsetzen. Während der 8251 bei  Taktraten jenseits 4Mhz Probleme bereitet kann der 71051 bis über 8Mhz getaktet werden.
Die Standard Adresse der seriellen Schnittstelle für das Monitor Eprom (Mon80V1.bin) liegt bei 20H. Per Jumper einstellbar. Mit einem UART Quarz von 4,915 Mhz lässt sich die Übertragung der seriellen Schnittstelle mittels Jumper auf 19,2K Baud, 9,6K Baud und 4,8K Baud einstellen. Mit 2,4Mhz Quarz halbieren sich die Baudraten.
