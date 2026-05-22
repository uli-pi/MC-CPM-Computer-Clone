
	MACLIB DISKDEF	;LOAD DEFINTION FOR DISKS

;*************************************************
; Version 3.1   Version 80 Spur-Laufwerk         *
; gebootet wird vom 80 Spur-Laufwerk             *
; A,B sind die beiden 80 Spur Laufwerke          *
; C,D ist ein 8Zoll LW, C=Vorderseite,D=Ruecks.  *
; E ist RAM-Floppy                               *
; (C) 1984 Rolf-Dieter Klein     841220          *
; ************************************************
		

VERS	EQU	22	; Definitionen, allegemein
TRUE	EQU	0FFFFH
FALSE	EQU	NOT TRUE
TEST	EQU	TRUE


msize 	equ 60		; Speichergroesse, hier 60K

bias	equ (msize-20)*1024	; min=20K
ccp	equ 3400h+bias	; Start des CCP
bdos	equ ccp+806h	; dort beginnt das BDOS
bios	equ ccp+1600h	; und dort das BIOS
;
cpmb	equ ccp		; Start CP/M-Boot.
;
cpml	equ bios-cpmb	; Laenge des CP/Ms
nsects	equ cpml/128	; Anzahl der belegten Sektoren
;
;
	org bios	; Start des Bios 
;

CDISK	EQU 4			; Adresse im Speicher, letztes Laufwerk
BUFF	EQU 80H		; Bufferadresse, die voreingestellt wird.
retry	equ 5			; Fehlerversuche bei BOOT etc.

; VEKTORTABELLE der BIOS-Einspruenge

	JMP BOOT		; Kalt-Start
WBOOTE:	JMP WBOOT	; Warm-Start, bei CTRL-C
	JMP CONST		; Consol Status, Ergebnis in A
	JMP CONIN		; Consol Eingabe, nach A	
	JMP CONOUT		; Consol Ausgabe von C
	JMP LIST		; Ausgabe auf den Drucker, von C
	JMP PUNCH		; Ausgabe auf PO, C-Register
	JMP READER		; Eingabe nach RI, A-Register

	JMP HOME		; Laufwerk nur Track 0
	JMP SELDSK		; Laufwerk auswaehlen
	JMP SETTRK		; Spur auswaehlen
	JMP SETSEC		; Sektor auswaehlen
	JMP SETDMA      ; Adresse festlegen                     
	JMP READ		; Sektor lesen
	JMP WRITE		; Sektor schreiben
	JMP LISTST		; Drucker fertig ?
	JMP SECTRAN	; Sektoruebersetzung
;
offset	equ 4		; fuer Minilw.

;
DISKKAP	EQU	389	;TRUNC (5 * 1024 * (160-4)/2048) - 1 ca. 780 K

	DISKS 5		; 5 Laufwerke definiert	

	DISKDEF 0,0,39,0,2048,DISKKAP,256,256,offset

				; *** DISKDEF BEDEUTUNG DER PARAMETER***
				; 0 = NUMMER DES LAUFWERKS
				; 0 = NUMMER DES ERSTEN SEKTORS EINER SPUR
				; 39 =  NUMMER DES LETZTEN SEKTORS EINER SPUR
				; 0 = OPTIONALER VERSCHIEBUNGSFAKTOR ZUM
				;     VERSETZEN ABSPEICHERN DER SEKTOREN
				; 2048 = GROESSE EINES BLOCKS
				; DISKKAP = ZAHL DER MAX. MOEGLICHEN BLOECKE
 				; 256 = ZAHL DER DIRECTORY EINTRITTSPUNKTE
 				; 256 = ZAHL DER GEPRUEFTEN EINTRITTSPUNKTE
 				; offset = ADDITIVE KONSTANTE ZUM ANSPRECHEN DER SPUR 00

	DISKDEF 1,0	; LAUFWERK 1 WIE LAUFWERK 0 DEFINIERT

	DISKDEF 2,1,26,6,1024,243,64,64,2 ; 8 Zoll Definition

	DISKDEF 3,2	; LAUFWERK 3 WIE LAUFWERK 2 DEFINIERT

	DISKDEF 4,0,14,0,1024,180,64,64,0 ; RAM Floppy 60K,120K,180K

; ENDEF am Schluss nicht vergessen

MON80	EQU 0F01EH		; Neustart des Monitors
RMON80  EQU 0F01EH

CR	EQU 0DH		; Zeilenrücklauf
LF	EQU 0AH		; Zeilenvorschub

SIGNON:			; Meldung nach dem Kaltstart
	DB 26
	DB CR,LF,'Welcome to 60 K CP/M 2.2'
	DB CR,LF,0

CONST:			; DIESE ROUTINE LIEFERT DEN STATUS DER
	JMP 0F012H		; EINGABETASTATUR. WURDE EIN ZEICHEN
				; EINGEGEBEN, SO LIEFERT DIE ROUTINE 0FFH. 
	
CONIN:   CALL 0F003H    ; DIE ROUTINE HOLT EIN ZEICHEN VON DER
                        ; TASTATUR AB UND SETZT DAS HOECHSTE BIT
                        ; (PARITY BIT) AUF NULL
         ANI 7FH
         RET

CONOUT:  EQU 0F009H     ; ROUTINE ZUR AUSGABE EINES ZEICHENS IM
                        ; C-REGISTER AN DIE KONSOLE. DAZU SPRUNG 
                        ; IN DEN MONITOR IM EPROM

LIST     EQU 0F00FH     ; ADRESSE FUER DEN SPRUNG IN DIE AUSGABEROUTINE,
                        ; UM EIN ZEICHEN IM C-REGISTER AN DIE DRUCKER-
                        ; SCHNITTSTELLE ZU LIEFERN

PUNCH    EQU 0F00CH     ; ADRESSE FUER DEN SPRUNG IN DIE AUSGABEROUTINE,
                        ; UM EIN ZEICHEN IM C-REGISTER AN DIE STANZ-
                        ; SCHNITTSTELLE ZU LIEFERN

READER   EQU 0F006H     ; ADRESSE FUER DEN SPRUNG IN DIE EINGABEROUTINE,
                        ; UM EIN ZEICHEN VON LESER-KANAL ZU HOLEN,
                        ; UND DAS ZEICHEN IM A-REGISTER ABZULIEFERN (RI)	

BOOT:				; Kaltstart folgt hier.
	LXI SP,BUFF+80H	; Stack vorbelegen
	LXI H,SIGNON	; Meldung ausgeben
	CALL PRMSG		; mit Druckroutine
	XRA A			; Laufwerk A wird angewaehlt
	STA CDISK		;
;
; Sektorenbuffer ist leer, Monitor wird desaktiviert
;
	XRA A			; kein Schreibvorgang mehr aktuell
	STA MWRTFLG	; daher auf 0 setzen
	MVI A,0FFH		; Laufwerk ist undefiniert
	STA MDRVAKT	; nach dem Booten
	LXI H,WBOOT	; Monitoreinsprung wird
	SHLD 0F033H+1	; kurzgeschlossen
	SHLD 0F036H+1	; denn evtl. ueberschreiben
;

	JMP GOCPM	; und CP/M dann starten

WBOOT:			; Warm-Boot
	LDA MWRTFLG	; wenn noch ein alter Track zum
	ORA A			; Schreiben da, dann zurueck damit.
	JZ NOTBAC		; sonst weiter.
	CALL PUTTRK	; normalerweise ist Schreibvorgang
				; nach einem Direktoryzugriff abgeschlossen
				;
NOTBAC:	MVI A,0FFH	; alle Tracks ungueltig, bei Diskettenwechsel
	STA MDRVAKT	; wichtig. 

	LXI SP,BUFF	; Stack zuweisen
	MVI C,RETRY	; Anzahl der Versuche
	PUSH B		; und dann anfangen zu booten
WBOOT0:	LXI B,CPMB	; Boot von MINI-Diskette
	CALL SETDMA	; auf der Startadresse des CP/Ms
	MVI C,0		; Laufwerk A
	CALL SELDSK	; auswaehlen
	MVI C,0		; Track 0
	CALL SETTRK	; und den zweiten phys. Sektor, (Nr8 logisch)
	MVI C,8		; enstpricht Nr 2 bei 1024 Bytes
	CALL SETSEC	; wichtig, da andere Zaehlweise
	POP B			; und von da an n Sektoren einlesen
	MVI B,NSECTS	; aber das Bios nicht ueberschreiben
				; damit Patches leicht moeglich sind
RDSEC:	PUSH B		; Anzahl merken
	CALL READ		; LESEN ausfuehren
	JNZ BOOTERR	; Fehler: defekter Sektor
	LHLD IOD		; Zieladresse laden
	LXI D,128		; um logische Sektorgroesser erhoehen
	DAD D			; dazu addieren,
	SHLD IOD		; und dann wieder zurueckspeichern.
	LDA IOS		; Sektor laden
	CPI 39		; Mini 0..39 Sektoren a 128 Bytes
	JC RD1		; solange auf der gleichen Spur bleiben
	LDA IOT		; Dann neue Spur anwaehlen,
	INR A	  		; jedoch im Verfahren 0,2,...
	INR A			; SPUR 0, dann SPUR 2, wegen BOOT.ASM
	STA IOT		; denn 1,3,5 ist die Rueckseite des Laufwerks
	MVI A,0FFH		; 0,1,2,3.... nach Increment A=0
RD1:	INR A			; dann 0
	STA IOS		; und auch neuesn Sektor anwaehlen
	POP B			; Schleifenzaehler zuruech
	DCR B			; und immer weiter lesen
	JNZ RDSEC		; danach CP/M neu starten
GOCPM:
	LXI B,BUFF		; Buffer auf Default einstellen
	CALL SETDMA	; so wie es CP/M braucht
	MVI A,JMP		; Sprung auf den WARM-Boot im
	STA 0			; RAM ablegen.
	LXI H,WBOOTE	; Warm-Boot-Adresse
	SHLD 1		; nicht vergessen
	STA 5			; Sprung auf die BDOS-CALL-Adresse
	LXI H,BDOS		; legen und auch das Ziel
	SHLD 6		; dorthin
	STA 7*8		; RST7 definieren, default ist Monitor
	LXI H,MON80	; der aber normalerweise kurzgeschl. ist.
	SHLD 7*8+1		
	LDA CDISK		; das zuletzt verwendete Laufwerk
	MOV C,A		; laden und damit selektieren.
	JMP CPMB

BOOTERR:			; im Fehlerfalle, bei BAD-Sektor.
	POP B			; erst mal nocheinmal versuchen
	DCR C			;
	JZ BOOTER0		; bis hoffnungslos, dann Fehlermeldung
	PUSH B
	JMP WBOOT0		; TRY AGAIN

BOOTER0:			; Fehlermeldung schliesslich ausgeben
	LXI H,BOOTMSG	; und Monitor neu starten, bzw. WBOOT.
	CALL PRMSG
	JMP MON80

BOOTMSG:			; Fehlermeldung
	DB '?BOOT',0

LISTST:			; LST-Status, derzeit kurzgeschlossen
	NOP			;
	XRA A			; ggf. hier Sprung einbauen.
	RET

HOME:				; Laufwerk, Spur 0 anfahren
	MVI C,0		; aber nur anwaehlen, nicht
	JMP SETTRK	; ausfuehren

SELDSK:			; Laufwerk auswaehlen
	LXI H,0		; und pruefen ob gueltig
	MOV A,C		; wenn groesser als ndisks
	CPI NDISKS		; dann nicht ok
	RNC			; Nummer 0 bis n-1 erscheint in A
	STA DBANK		; dann zusaetzlich die
	MOV L,C		; Laufwerkstabelle ausrechnen
	MVI H,0		; dazu Nummer mit 16 multiplizieren
	DAD H	
	DAD H	
	DAD H	
	DAD H	
	LXI D,DPBASE	; und Basisadresse drauf addieren.
	DAD D
	RET
;
SETTRK:			; Spur merken
	LXI H,IOT		; dazu im Speicherzelle laden
	MOV M,C
	RET

SETSEC:			; Sektor merken
	LXI H,IOS		; dazu in Speicherzelle laden
	MOV M,C
	RET

SECTRAN:			; Sektor Umsetzung
	mov a,d		; wenn ein SKEW-Faktor verwendet wird,
        ora e		; wie z.B. bei 8 Zoll ueblich.
        jz se1		; =0, dann kein Skew verwendet,
	MVI B,0		; sonst in DE Adresse der Skew-Tabelle
	XCHG			; dazu Sektor in C addieren
	DAD B			; und Wert als neuen Sektor
	MOV A,M		; festlegen und
	STA IOS		; speichern.
	MOV L,A
	RET
se1:	mov l,c		; sonst nur einfache Wert
        mov a,c		; uebernehmen, ohne Umrechnung.
        sta ios		; auch merken
        mvi h,0		; se 0..255 max
        ret
;

SETDMA:			; Adresse fuer Floppy-Zugriff festlegen.
	MOV L,C
	MOV H,B
	SHLD IOD
	RET

PRMSG:			; Text ausgeben, fuer Fehlermeldung
 	MOV A,M		; dazu laden
	ORA A			; =0, dann ende des Textes
	RZ			; sonst ueber Console ausgeben
	PUSH H
	MOV C,A
	CALL CONOUT
	POP H
	INX H			; bis alle Buchstaben draussen
	JMP PRMSG

;READ und WRITE unter Verwendung von EXEC im Monitor
; HL=DMA ADR
; DE=TRACK/SECTOR
; B=0 RSTORE
;   1 READ
;   2 WRITE
; C=DRIVE 0...3		; bei MEXEC, EXEC
; bei FEXEC ist C bei bestimmt.

READ:				; einen Sektor lesen
	LDA DBANK		; dazu Laufwerk bestimmen
	cpi 2			; 
	jc minird		; 0,1 sind Minilaufwerke
	cpi 4		
	jc maxiread	; 8 Zoll Laufwerk
;
; RAMFLOPPY Zusatz-Routinen
;
	call adrerz	; hl=Quelladresse
        xchg		; Adressumrechnung durchfuehren
        lhld iod	; zieladresse laden
        xchg		; und de=ziel, hl=quelle, c=bank quelle
        mvi b,0		; Ziel ist Bank 0
        call rexec	; und 128 Bytes kopieren, carry=Fehler
	JNC NORERR
	MVI A,1		; Fehler da, Bank nicht vorhanden,
	RET			; wirkt wie BAD-Sektor
NORERR:	XRA A		; sonst ok.
	RET


; sektor 0..E,  track 0..5fh
; sssstttt t0000000   , adresse fuer RAM-Floppy
adrerz:			; Adresse berechnen, Quelle in HL
 	lda iot		; Track holen
 	rrc 			; und umrechnen
 	ani 0fh		; unterer Teil vom MSB
 	mov h,a
 	lda ios		; dann Sektor dazu
 	rlc
 	rlc
 	rlc
 	rlc
 	ani 0f0h
 	ora h
 	mov h,a		; damit sssstttt ok
 	lda iot
 	rrc			; txxxxxxx
 	ani 80h
 	mov l,a		; t0000000
 	lda iot		; nun noch bank bestimmen, in c und b	
 	rlc			; und dazu msb-Teil des Tracks verwenden
 	rlc			; 0mmttttt
 	rlc			; Banknummer
 	ani 03h		; 000000mm
	adi 1			; erst ab Bank 1 starten
 	mov b,a		; da BANK 0=CP/M RAM und TPA
 	mov c,a		; ok beide definiert
 	ret
  
neubank:		; umrechnen fuer 8Zoll
			; und neuen Floppy-Einsprung verwenden.
			; nach c laden
			; LW=2, dann Vorderseite LW 3
			; LW=3, dann Rueckseite LW 3
 	lda dbank	; 
	cpi 2
	jnz neu1
	mvi c,00010100b	; SD,8 ZOll, LW=3
	ret
neu1:	mvi c,10010100b
	ret		; 

maxiread:		; Lesen der 8 Zoll Floppy
SK1:	MVI B,RETRY	; Anzahl der Leseversuche
LP:	PUSH B		; dann ausfuehren
	LHLD IOD		; Zieladresse holen
	LDA IOT		; Spurnummer
	MOV D,A	
	LDA IOS		; Sektornummer
	MOV E,A
	MVI B,1		; Lese-Befehlscode
	call neubank	; vorher Laufwerkscode umrechnen
	CALL FEXEC		; und dann ausfuehren
	POP B			; Retry-Zaehler
	RZ			; kein Fehler, dann ok zurueck
	DCR B			; sonst nochmals probieren
	JNZ LP		
	MVI A,1		; BAD SEKTOR
	ORA A
	RET

;

WRITE:			; Schreiben eines Sektors
	LDA DBANK		; dazu Laufwerkscode laden
	cpi 2			; und Floppy-Typ bestimmen
	jc miniwr		; 0 und 1 sind Minilaufwerke
	cpi 4			; 2 und 3 Maxilaufwerke
	jc maxiwr		; rest ist RAM-Floppy
; RAM FLOPPY
	call adrerz	; hl=Quelladresse
        xchg		; umrechnen
        lhld iod	; ziel in BANK hl=Quelle diesmal
        mvi c,0		; Quelle ist Bank 0, b=Ziel, de=Ziel
        call rexec	; und 128 Bytes kopieren, carry=Fehler
	JNC NORERR		; OK Bank war da, sonst
	MVI A,1		; Fehler ausgeben
	RET

maxiwr:	MVI B,RETRY	; Schreiben bei 8 Zoll
LPP:	PUSH B		; Dazu Fehlerzaehler retten
	LHLD IOD		; Quelleadresse laden
	LDA IOT		; Spur
	MOV D,A
	LDA IOS		; Sektor
	MOV E,A
	MVI B,2		; Schreib-Befehlscode
	call neubank	; vorher Laufwerk umrechnen
	CALL FEXEC		; und ausfuehren
	POP B	
	RZ			; kein Fehler, dann zurueck
	DCR B			; sonst erneut versuchen
	JNZ LPP
	MVI A,1		; BAD SEKTOR
	ORA A
	RET


; Minifloppy 80 Spur, DD, DS
;
;READ und WRITE unter Verwendung von MEXEC
; HL=DMA ADR
; DE=TRACK/SECTOR
; B=0 RSTORE
;   1 READ
;   2 WRITE
; C=DRIVE 0...3  10H,11H,12H,13H  DOUBMIN 0D0H,0D1H,0D2H,0D3H
;                                          A   C    B    D
; 1K BUFFER IN MONITORGEBIET
; WIRD DADURCH TEILWEISE UEBERSCHRIEBEN
; BEI WARMBOOT MUSS BUFFER GELEERT WERDEN
; DEBLOCK WIRD AUS SICHERHEITSGRUENDEN NICHT VERWENDET
; 

BUFFER	EQU	0FC00H	; FREIES GEBIET BIS FFFF NUR MONITORBEFEHLE

CALC:				;RECHNET DBANK IN PHYS LAUFWERK UM
				;RECHNET IOS IN SEKTORBUFFERNR UM
	LDA IOS		;0..39 IST DER BEREICH
	RRC			;X000NNNN 0..15
        RRC
        RRC		;0,1,2,3,4
	ANI 00000111b	; max
	INR A			;1,2,3,4,5  STARTSEKTOR DES GEBIETS (1K)
	MOV E,A		;IN E ALS PARAMETER
	LDA DBANK       ;DRIVE 0->0  1->2
				;nur 0,1 SUI 4 ;und Track umrechnen , Laufwerk 0,1
	CPI 1			; 0,2,4,6,8 ist Vorderseite 1,3,5... Rueckseite
	JNZ CAL2
	MVI A,2
CAL2:	MOV C,A		;DRIVE PHYSIKALISCH
	LDA IOT
	RRC			; Track / 2,  = Phys Track, Carry=Rueckseite
	MOV D,A		; Track merken
	JNC CAL3
	MOV A,C
	ORI 1			; D0 -> D1,  D2 -> D3
	MOV C,A
CAL3:	MOV A,D
	ANI 7FH		; Bereich Track 0..79 real
	MOV D,A		;TRACK=D SEKTOR=E DRIVE=C
	RET
	
;
minird:	CALL CALC	; FUER VERGLEICH, Laufwerksdaten umrechnen
	LDA MDRVAKT	; und nun aktuelles Laufwerk vergleichen
	CMP C			; wenn nicht gleich, dann neu 
	JNZ RLOAD		; laden,
	LDA MTRKAKT	; sonst Spur vergleichen
	CMP D			; und 
	JNZ RLOAD
	LDA MSEKAKT	; sonst Sektor
	CMP E			; wenn gleich, dann Sektor im Speicher
	JNZ RLOAD		; und laden unnoetig
R1RD:				; OK IST SCHON IN BUFFER
	LXI H,BUFFER	; ADRESSE BERECHNEN
	LDA IOS		; 0..39   * 128 + BUFFER
	ANI 00000111b	; 0,1,2,3,4,5,6,7
	MOV D,A
	MVI E,0		; SCHIEBEN MIT Z80 BEFS
	DB 0CBH,2AH	; SRA D
	DB 0CBH,1BH	; RR E   = *256/2
	DAD D			; +BUFFER
	XCHG			; NACH DE IST ZIEL
	LHLD IOD		; DMA ADRESSE QUELLE HIER
	XCHG			; ZIEL DE
	LXI B,128		; LAENGE
	DB 0EDH,0B0H	; LDIR
	XRA A
	RET			; OK ENDE

RLOAD:			; NEUEN LADEN, GGF ALTEN ZURUECKSCHREIBEN
	LDA MWRTFLG
	ORA A
	JZ R1LOAD
	CALL PUTTRK	; ALTEN ZURUECKSCHREIBEN
	JC ERRIO
R1LOAD:	CALL CALC	; BERECHNEN
	MOV A,C
	STA MDRVAKT
	MOV A,E
	STA MSEKAKT
	MOV A,D
	STA MTRKAKT
	CALL GETTRK	; neuen Sektor lesen
	JC ERRIO		; Fehler aufgetreten
	JMP R1RD		; Ende
;

miniwr:			; Schreiben eines Sektors
	MOV A,C
	STA alloc		; Information 1=Direktory Write
	CALL CALC		; FUER VERGLEICH, Berechung ausfuehren
	LDA MDRVAKT	; und wie bei minird
	CMP C			;
	JNZ WLOAD
	LDA MTRKAKT
	CMP D
	JNZ WLOAD
	LDA MSEKAKT
	CMP E
	JNZ WLOAD		; laden unnoetig, Sektor schon da.
W1WR:				; OK IST SCHON IN BUFFER
	LXI H,BUFFER	; ADRESSE BERECHNEN
	LDA IOS		; 0..39   * 128 + BUFFER
	ANI 00000111b	; 0,1,2,3,4,5,6,7
	MOV D,A
	MVI E,0		; SCHIEBEN MIT Z80 BEFS
	DB 0CBH,2AH	; SRA D
	DB 0CBH,1BH	; RR E   = *256/2
	DAD D			; +BUFFER
	XCHG			; NACH DE IST ZIEL
	LHLD IOD		; DMA ADRESSE QUELLE HIER
	LXI B,128		; LAENGE ZIEL DE
	DB 0EDH,0B0H	; LDIR
	MVI A,1
	STA MWRTFLG	; NUN BESCHRIEBEN
	lda alloc		; =1 dann zurueck
  	cpi 1			; wenn Direktory Zugriff, dann
	jnz w2wr		; gleich zurueckschreiben.
	CALL puttrk	; 
	jc errio		; falls Fehler, dann BAD SEKTOR
w2wr:
	XRA A			; kein Fehler
	RET			; OK ENDE

WLOAD:			; NEUEN LADEN, GGF ALTEN ZURUECKSCHREIBEN
	LDA MWRTFLG	; 
	ORA A
	JZ W1LOAD
	CALL PUTTRK	; ALTEN ZURUECKSCHREIBEN
	JC ERRIO
W1LOAD:	CALL CALC	; BERECHNEN
	MOV A,C
	STA MDRVAKT
	MOV A,E
	STA MSEKAKT
	MOV A,D
	STA MTRKAKT
	CALL GETTRK
	JC ERRIO
	JMP W1WR

ERRIO:	MVI A,1	; Fehler aufgetreten
	ORA A
	RET

; BUFFERVERWALTUNG

GETTRK:			;TRKAKT,SEKAKT,DRVAKT ENTHALTEN NEUE
				;BUFFERADRESSE
	XRA A
	STA MWRTFLG	; Sektor einlesen
	LXI H,BUFFER
	LDA MSEKAKT
	MOV E,A
	LDA MDRVAKT
	ORI 11010000B	;LAUFWERK PHYS 0,1,2,3 DOUBLE DENSE
	MOV C,A
	MVI B,1		;READ, 1K direkt
	LDA MTRKAKT
	MOV D,A
	CALL MEXEC
	JC ERRX
	XRA A
	RET
;

ERRX:	STC
	RET


PUTTRK:			;TRKAKT,SEKAKT,DRVAKT ENTHALTEN NEUE
				;BUFFERADRESSE
	XRA A			;WIRD ZURUECKGESCHRIEBEN
	STA MWRTFLG
	LXI H,BUFFER
	LDA MSEKAKT
	MOV E,A
	LDA MDRVAKT
	ORI 11010000B	;LAUFWERK PHYS 0,1,2,3 DOUBLE DENSE
	MOV C,A
	MVI B,2		;WRITE	1K Sektor
	LDA MTRKAKT
	MOV D,A
	CALL MEXEC
	JC ERRX
	XRA A
	RET

FEXEC:	JMP 0f021h	;FLOMON neuer Vektor
EXEC:		JMP 0f024H	;FLOMON und MC
MEXEC:	JMP 0f027H	;FLOMON und MC
REXEC:	JMP 0f05bh	;FLOMON RAM-FLOPPY


			;Soft System
;
; RAM ZELLEN

MWRTFLG:	DB 0		;<>0 IST WRITEN
MDRVAKT:	DB 0		;DRIVE das geladen ist
MTRKAKT:	DB 0		;TRACK 
MSEKAKT:	DB 0		;SEKTOR
alloc:	db 0		; merker, 1=direktory write
;
                        ; SPEICHERZELLEN FUER DAS PROGRAMM

DBANK:   DB 0           ; NUMMER DES SELEKTIEREN LAUFWERKS
IOPB:    DB 80H         ; IO-BYTE
ION:     DB 1           ; SEKTORNUMMER
IOT:     DB OFFSET      ; NUMMER DER GEWUENSCHTEN SPUR
IOS:     DB 1           ; NUMMER DES GEWUENSCHTEN SEKTORS
IOD:     DW BUFF        ; DMA-ADRESSE
ALTDRV:  DB 1           ; SYSTEM-SPEICHERSTELLEN
INDADR:  DW 0
INDADR2: DW 0

          ENDEF

          END
