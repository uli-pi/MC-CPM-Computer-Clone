# Monitor Eprom Dateien für SYS-80s:



Mon80V1.bin - Monitor für SYS-80s mit CF-Boot und "onboard" RS-232 Schnittstelle auf Adresse 20Hex

Der Monitor ist 4KB groß und passt auch in ein 2732 Eprom.

Der Monitor wird akuell gerade überarbeitet und dokumentiert (Mon80V2). Im ersten Schritt ändert sich nur der Quelltext und der Monitor bleibt binärkompatibel.
Im zweiten Schritt sollen dann unnötige Sprünge und nicht mehr benötigte Routinen entfernt werden. Über IF/ENDIF sollen dann verschiedene Konfigurationen erstellt werden können. Zum Beispiel für unterschiedliche Schnittstellenkonfigurationen.

Mon80V1 ist die Original-Version des Monitors

Mon80V2 ist binaer identisch, aber der Quelltext wurde stark überarbeitet und kommentiert.
Mon80V2 wird die Basis für einen zukünftig überarbeiteten Monitor sein.
