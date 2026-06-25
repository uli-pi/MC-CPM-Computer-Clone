
	MACLIB DISKDEF	; LOAD DEFINTION FOR DISKS

;*************************************************
; Version 3.1a   Version 80 Spur-Laufwerk        *
; gebootet wird vom 80 Spur-Laufwerk             *
; A,B sind die beiden 80 Spur Laufwerke          *
; C,D ist ein 8Zoll LW, C=Vorderseite,D=Ruecks.  *
; E ist RAM-Floppy                               *
; (C) 1984 Rolf-Dieter Klein     841220          *
;                                                *
; 24.06.2026 *dg* Kommentare hinzugefuegt        *
;                 Binaer identisch zur Origial-  *
;                 Version                        *
;                 Work in progress...            *
; ************************************************
		

VERS	EQU 22	; CP/M version
TRUE	EQU 0FFFFH
FALSE	EQU NOT TRUE
TEST	EQU TRUE
CR	EQU 0DH		; Zeilenrücklauf
LF	EQU 0AH		; Zeilenvorschub


MSIZE 	EQU 60		; Speichergroesse, hier 60K

BIAS	EQU (MSIZE-20)*1024	; min=20K
CCP	EQU 3400H+BIAS	; Start des CCP
BDOS	EQU CCP+806H	; dort beginnt das BDOS
BIOS	EQU CCP+1600H	; und dort das BIOS

CPMB	EQU CCP		; Start CP/M-Boot

CPML	EQU BIOS-CPMB	; Laenge des CP/Ms
NSECTS	EQU CPML/128	; Anzahl der belegten Sektoren


	ORG BIOS	; Start of BIOS


CDISK	EQU 0004H	; address for last used drive
BUFF	EQU 0080H	; buffer address
RETRY	EQU 5		; Fehlerversuche bei BOOT etc.

;-----------------------------------------------------------------------------

; VEKTORTABELLE der BIOS-Einspruenge

	JMP BOOT	; Kalt-Start
	
WBOOTE:	JMP WBOOT	; Warm-Start, bei CTRL-C
	JMP CONST	; Consol Status, Ergebnis in A
	JMP CONIN	; Consol Eingabe, nach A	
	JMP CONOUT	; Consol Ausgabe von C
	JMP LIST	; Ausgabe auf den Drucker, von C
	JMP PUNCH	; Ausgabe auf PO, C-Register
	JMP READER	; Eingabe nach RI, A-Register

	JMP HOME	; Laufwerk nur Track 0
	JMP SELDSK	; Select drive, returns disk parameter header block in HL
	JMP SETTRK	; Spur auswaehlen
	JMP SETSEC	; Sektor auswaehlen
	JMP SETDMA      ; Adresse festlegen                     
	JMP READ	; Sektor lesen
	JMP WRITE	; Sektor schreiben
	JMP LISTST	; Drucker fertig ?
	JMP SECTRAN	; secor translation (skew only)

;-----------------------------------------------------------------------------

	; size of disks A and B
	; TRUNC(5 logical sectors * 1024 logical sector size * (2*80 tracks - 4 offset) / 2048 block size) - 1 = ca. 780 KB
	; TRUNC (5 * 1024 * (160-4)/2048) - 1 = ca. 780 K
SIZEAB	EQU 389
 
	; track offset for disk A and B
OFFSAB	EQU 4

	DISKS 5		; 5 Laufwerke definiert	

	; disk A
	DISKDEF 0,0,39,0,2048,SIZEAB,256,256,OFFSAB

			; *** DISKDEF BEDEUTUNG DER PARAMETER***
			; 0 = NUMMER DES LAUFWERKS
			; 0 = NUMMER DES ERSTEN SEKTORS EINER SPUR
			; 39 =  NUMMER DES LETZTEN SEKTORS EINER SPUR
			; 0 = OPTIONALER VERSCHIEBUNGSFAKTOR ZUM
			;     VERSETZEN ABSPEICHERN DER SEKTOREN
			; 2048 = GROESSE EINES BLOCKS
			; SIZEAB = ZAHL DER MAX. MOEGLICHEN BLOECKE
			; 256 = ZAHL DER DIRECTORY EINTRITTSPUNKTE
			; 256 = ZAHL DER GEPRUEFTEN EINTRITTSPUNKTE
			; OFFSAB = ADDITIVE KONSTANTE ZUM ANSPRECHEN DER SPUR 00

	; disk B (same as disk A)
	DISKDEF 1,0	; LAUFWERK 1 WIE LAUFWERK 0 DEFINIERT

	; disk C
	DISKDEF 2,1,26,6,1024,243,64,64,2 ; 8 Zoll Definition

	; disk D (same as disk C)
	DISKDEF 3,2	; LAUFWERK 3 WIE LAUFWERK 2 DEFINIERT

	DISKDEF 4,0,14,0,1024,180,64,64,0 ; RAM Floppy 60K,120K,180K

; ENDEF am Schluss nicht vergessen

;-----------------------------------------------------------------------------
; CP/M message after cold start

SIGNON:	DB 26
	DB CR,LF,'Welcome to 60 K CP/M 2.2'
	DB CR,LF,0

;-----------------------------------------------------------------------------
; Monitor routines and addresses

			; DIESE ROUTINE LIEFERT DEN STATUS DER
CONST:	JMP 0F012H	; EINGABETASTATUR. WURDE EIN ZEICHEN
			; EINGEGEBEN, SO LIEFERT DIE ROUTINE 0FFH. 
	
CONIN:	CALL 0F003H    ; DIE ROUTINE HOLT EIN ZEICHEN VON DER
                        ; TASTATUR AB UND SETZT DAS HOECHSTE BIT
                        ; (PARITY BIT) AUF NULL
	ANI 7FH
	RET

MON80	EQU 0F01EH	; Neustart des Monitors

RMON80  EQU 0F01EH

CONOUT	EQU 0F009H     ; ROUTINE ZUR AUSGABE EINES ZEICHENS IM
                        ; C-REGISTER AN DIE KONSOLE. DAZU SPRUNG 
                        ; IN DEN MONITOR IM EPROM

LIST	EQU 0F00FH     ; ADRESSE FUER DEN SPRUNG IN DIE AUSGABEROUTINE,
                        ; UM EIN ZEICHEN IM C-REGISTER AN DIE DRUCKER-
                        ; SCHNITTSTELLE ZU LIEFERN

PUNCH	EQU 0F00CH     ; ADRESSE FUER DEN SPRUNG IN DIE AUSGABEROUTINE,
                        ; UM EIN ZEICHEN IM C-REGISTER AN DIE STANZ-
                        ; SCHNITTSTELLE ZU LIEFERN

READER	EQU 0F006H     ; ADRESSE FUER DEN SPRUNG IN DIE EINGABEROUTINE,
                        ; UM EIN ZEICHEN VON LESER-KANAL ZU HOLEN,
                        ; UND DAS ZEICHEN IM A-REGISTER ABZULIEFERN (RI)	

;-----------------------------------------------------------------------------
; Cold boot

BOOT:	LXI SP,BUFF+80H	; output start message
	LXI H,SIGNON
	CALL PRMSG
	
	XRA A		; clear last used drive
	STA CDISK
	
	; Sektorenbuffer ist leer
	XRA A		; kein Schreibvorgang mehr aktuell
	STA MWRTFLG	; daher auf 0 setzen
	MVI A,0FFH	; Laufwerk ist undefiniert
	STA MDRVAKT	; nach dem Booten

	LXI H,WBOOT	; disable monitor entry
	SHLD 0F033H+1	; <- WBOOT
	SHLD 0F036H+1	; <- WBOOT
	JMP GOCPM	; start CP/M

;-----------------------------------------------------------------------------
; Warm boot

WBOOT:	LDA MWRTFLG	; wenn noch ein alter Track zum
	ORA A		; Schreiben da, dann zurueck damit.
	JZ NOTBAC	; sonst weiter.
	
	CALL PUTTRK	; normalerweise ist Schreibvorgang
			; nach einem Direktoryzugriff abgeschlossen
			;
NOTBAC:	MVI A,0FFH	; alle Tracks ungueltig, bei Diskettenwechsel wichtig
	STA MDRVAKT

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
	
	;---------------------------------------------------------------------

GOCPM:	LXI B,BUFF		; Buffer auf Default einstellen
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

BOOTERR:		; im Fehlerfalle, bei BAD-Sektor.
	POP B		; erst mal nocheinmal versuchen
	DCR C		;
	JZ BOOTE0	; bis hoffnungslos, dann Fehlermeldung
	
	PUSH B
	JMP WBOOT0	; try again

BOOTE0:	; Fehlermeldung ausgeben und Monitor neu starten, bzw. WBOOT.
	LXI H,BOOTMSG
	CALL PRMSG
	JMP MON80

BOOTMSG:		; Fehlermeldung
	DB '?BOOT',0

;-----------------------------------------------------------------------------
; List status (used by BDOS)
; LST-Status, derzeit kurzgeschlossen

LISTST:			
	NOP
	XRA A		; ggf. hier Sprung einbauen.
	RET

;-----------------------------------------------------------------------------
; Home drive (used by BDOS)

HOME:	MVI C,0		; aber nur anwaehlen, nicht
	JMP SETTRK	; ausfuehren

;-----------------------------------------------------------------------------
; Select disk (used by BDOS)

SELDSK:	LXI H,0		; und pruefen ob gueltig
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

;-----------------------------------------------------------------------------
; Spur merken (used by BDOS)

SETTRK:	LXI H,IOT		; dazu im Speicherzelle laden
	MOV M,C
	RET

;-----------------------------------------------------------------------------
; Sector merken (used by BDOS)

SETSEC:	LXI H,IOS		; dazu in Speicherzelle laden
	MOV M,C
	RET

;-----------------------------------------------------------------------------
; Sector translation (used by BDOS)
; sector in C
; skew table address in DE (or 0)

SECTRAN:MOV A,D		; wenn ein SKEW-Faktor verwendet wird,
        ORA E		; wie z.B. bei 8 Zoll ueblich.
        JZ SECTR1	; =0, -> no skew

	MVI B,0		; sonst in DE Adresse der Skew-Tabelle
	XCHG		; skew table -> HL
	DAD B		; add BC
	MOV A,M		; load skew value
	STA IOS		; save in IOS 
	MOV L,A		; and in L
	RET

SECTR1:	; no skew
	MOV L,C		; sonst nur einfache Wert
        MOV A,C		; uebernehmen, ohne Umrechnung.
        STA IOS		; auch merken
        MVI H,0		; se 0..255 max
        RET

;-----------------------------------------------------------------------------
; Adresse fuer Floppy-Zugriff festlegen

SETDMA:	MOV L,C
	MOV H,B
	SHLD IOD
	RET

;-----------------------------------------------------------------------------
; 0-terminerte Text ausgaben, Adresse in HL

PRMSG: 	MOV A,M
	ORA A
	RZ		; -> end of text
	
	PUSH H
	MOV C,A
	CALL CONOUT
	POP H
	INX H
	JMP PRMSG	; -> next char

;=============================================================================
; Read and write sector using EXEC into monitor

; HL=DMA ADR
; DE=TRACK/SECTOR
; B=0 RSTORE
;   1 READ
;   2 WRITE
; C=DRIVE 0...3		; bei MEXEC, EXEC
; bei FEXEC ist C bei bestimmt.

READ:	LDA DBANK	; dazu Laufwerk bestimmen
	CPI 2		; 
	JC MINIRD	; drive 0,1 -> Mini disks
	
	CPI 4		
	JC MAXIREAD	; drive 2,3 -> Maxi disks

	; --- RAM disk ---

	CALL ADRERZ	; hl=Quelladresse
        XCHG		; Adressumrechnung durchfuehren
        LHLD IOD	; zieladresse laden
        XCHG		; und de=ziel, hl=quelle, c=bank quelle
        MVI B,0		; Ziel ist Bank 0
        CALL REXEC	; und 128 Bytes kopieren, carry=Fehler
	JNC NORERR
	
	MVI A,1		; Fehler da, Bank nicht vorhanden,
	RET		; wirkt wie BAD-Sektor
	
NORERR:	XRA A		; sonst ok.
	RET

	;---------------------------------------------------------------------
	; Calculate address for ram disk, source in HL
	; SEKTOR 0..E,  TRAck 0..5fh
	; SSSSTTTT T0000000   , adresse fuer RAM-Floppy
ADRERZ:	LDA IOT		; Track holen
 	RRC 			; und umrechnen
 	ANI 0FH		; unterer Teil vom MSB
 	MOV H,A
 	LDA IOS		; dann Sektor dazu
 	RLC
 	RLC
 	RLC
 	RLC
 	ANI 0F0H
 	ORA H
 	MOV H,A		; damit sssstttt ok
 	LDA IOT
 	RRC			; txxxxxxx
 	ANI 80H
 	MOV L,A		; t0000000
 	LDA IOT		; nun noch bank bestimmen, in c und b	
 	RLC			; und dazu msb-Teil des Tracks verwenden
 	RLC			; 0mmttttt
 	RLC			; Banknummer
 	ANI 03H		; 000000mm
	ADI 1			; erst ab Bank 1 starten
 	MOV B,A		; da BANK 0=CP/M RAM und TPA
 	MOV C,A		; ok beide definiert
 	RET

	;---------------------------------------------------------------------
  
	; umrechnen fuer 8Zoll
	; und neuen Floppy-Einsprung verwenden.
	; nach c laden
	; LW=2, dann Vorderseite LW 3
	; LW=3, dann Rueckseite LW 3
NEUBANK:
	LDA DBANK
	CPI 2
	JNZ NEU1
	
	MVI C,00010100b	; SD,8 ZOll, LW=3
	RET
NEU1:	MVI C,10010100b
	RET

	;---------------------------------------------------------------------
	; Read Maxi disk

MAXIREAD:
SK1:	MVI B,RETRY	; Anzahl der Leseversuche
LP:	PUSH B		; dann ausfuehren
	LHLD IOD		; Zieladresse holen
	LDA IOT		; Spurnummer
	MOV D,A	
	LDA IOS		; Sektornummer
	MOV E,A
	MVI B,1		; Lese-Befehlscode
	CALL NEUBANk	; vorher Laufwerkscode umrechnen
	CALL FEXEC		; und dann ausfuehren
	POP B			; Retry-Zaehler
	RZ			; kein Fehler, dann ok zurueck
	DCR B			; sonst nochmals probieren
	JNZ LP		
	MVI A,1		; BAD SEKTOR
	ORA A
	RET

;-----------------------------------------------------------------------------
; Write sector using EXEC into monitor

; HL=DMA ADR
; DE=TRACK/SECTOR
; B=0 RSTORE
;   1 READ
;   2 WRITE
; C=DRIVE 0...3		; bei MEXEC, EXEC
; bei FEXEC ist C bei bestimmt.

WRITE:	LDA DBANK	; dazu Laufwerkscode laden
	CPI 2		; und Floppy-Typ bestimmen
	JC MINIWR	; drive 0,1 -> Mini disks
	
	CPI 4		; drive 2,3 -> Maxi disks
	JC MAXIWR
	
	; --- RAM disk ---

	CALL ADRERZ	; hl=Quelladresse
        XCHG		; umrechnen
        LHLD IOD	; ziel in BANK hl=Quelle diesmal
        MVI C,0		; Quelle ist Bank 0, b=Ziel, de=Ziel
        CALL REXEC	; und 128 Bytes kopieren, carry=Fehler
	JNC NORERR		; OK Bank war da, sonst
	MVI A,1		; Fehler ausgeben
	RET

	;---------------------------------------------------------------------
	; Write Maxi disk

maxiwr:	MVI B,RETRY
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

;=============================================================================
; Read Mini disk, 80 Spur, DD, DS

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

BLKBUF	EQU 0FC00H	; Memory area of interactive Monitor for logical sextor (1K)

;-----------------------------------------------------------------------------
; Calculates physical drive from DBANK and IOT -> C
; DBANK, IOT     C
;  0     F    -> 0
;  1     F    -> 2
;  0     B    -> 1
;  1     B    -> 3

; calculates physical sector from logical sector, IOS -> E
; logical sector 0..39 -> physical sector 1..5

; calculates logical track from physical track, IOT -> D
; 0..159 -> 0..79 (max 127)

; only for Mini disks 0 and 1

CALC:	; logical sector (1K) to physical sector (128 byte)
	; 0..39 -> 0..4
	LDA IOS		; 0..39 IST DER BEREICH (logic sector)
	RRC		; X000NNNN 0..15
        RRC
        RRC
	ANI 00000111b
	INR A		; 0..4 -> 1..5
	MOV E,A		; save in E

	LDA DBANK       ; DRIVE 0->0  1->2
			; nur 0,1 SUI 4 ; und Track umrechnen , Laufwerk 0,1
	CPI 1		; 0,2,4,6,8 ist Vorderseite 1,3,5... Rueckseite
	JNZ CAL2

	; DBANK=1 
	MVI A,2
	
CAL2:	MOV C,A		; physical drive

	LDA IOT
	RRC		; Track / 2,  = Phys Track, carry=backside
	MOV D,A		; Track merken
	JNC CAL3	; frontside

	; backside, track=0
	MOV A,C
	ORI 1		; drive 0 -> drive 1,  drive 2 -> drive 3
	MOV C,A
	
CAL3:	MOV A,D
	ANI 7FH		; Bereich Track 0..79 real
	MOV D,A

	; D=track=D, E=sector, c=drive
	RET
	
;-----------------------------------------------------------------------------
; Read Mini disk
; DBANK, IOT, IOS,

minird:	CALL CALC	; calculate physical drive data

	LDA MDRVAKT
	CMP C		; compare drive
	JNZ RLOAD	; -> drive not equal, load
	
	LDA MTRKAKT
	CMP D		; compare track
	JNZ RLOAD	; -> track not equal, load
	
	LDA MSEKAKT
	CMP E		; compare sector
	JNZ RLOAD	; -> sector not equal, laden

R1RD:	; OK IST SCHON IN BUFFER
	LXI H,BLKBUF	; ADRESSE BERECHNEN
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
	CALL GETTRK		; neuen Sektor lesen
	JC ERRIO		; Fehler aufgetreten
	
	JMP R1RD		; Ende

;-----------------------------------------------------------------------------
; Write Mini disk 

miniwr:	MOV A,C
	STA ALLOC		; Information 1=Direktory Write
	CALL CALC		; FUER VERGLEICH, Berechung ausfuehren
	LDA MDRVAKT		; und wie bei minird
	CMP C			;
	JNZ WLOAD
	
	LDA MTRKAKT
	CMP D
	JNZ WLOAD
	LDA MSEKAKT
	CMP E
	JNZ WLOAD		
	
W1WR:	; laden unnoetig, Sektor schon im Buffer
	LXI H,BLKBUF		; ADRESSE BERECHNEN
	LDA IOS			; 0..39   * 128 + BUFFER
	ANI 00000111B		; 0,1,2,3,4,5,6,7
	MOV D,A
	MVI E,0			; SCHIEBEN MIT Z80 BEFS
	DB 0CBH,2AH		; SRA D
	DB 0CBH,1BH		; RR E   = *256/2
	DAD D			; +BUFFER
	XCHG			; NACH DE IST ZIEL
	LHLD IOD		; DMA ADRESSE QUELLE HIER
	LXI B,128		; LAENGE ZIEL DE
	DB 0EDH,0B0H		; LDIR
	MVI A,1
	STA MWRTFLG		; NUN BESCHRIEBEN
	LDA ALLOC		; =1 dann zurueck
  	CPI 1			; wenn Direktory Zugriff, dann
	JNZ W2WR		; gleich zurueckschreiben.
	CALL PUTTRK 
	JC ERRIO		; falls Fehler, dann BAD SEKTOR

W2WR:	XRA A			; kein Fehler
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

;-----------------------------------------------------------------------------
; BUFFERVERWALTUNG

; TRKAKT,SEKAKT,DRVAKT ENTHALTEN NEUE BUFFERADRESSE

GETTRK:	XRA A
	STA MWRTFLG	; Sektor einlesen
	
	LXI H,BLKBUF
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

ERRX:	STC
	RET

;-----------------------------------------------------------------------------
;TRKAKT,SEKAKT,DRVAKT ENTHALTEN NEUE BUFFERADRESSE

PUTTRK:	XRA A			;WIRD ZURUECKGESCHRIEBEN
	STA MWRTFLG
	
	LXI H,BLKBUF
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
EXEC:	JMP 0f024H	;FLOMON und MC (not used)
MEXEC:	JMP 0f027H	;FLOMON und MC
REXEC:	JMP 0f05bh	;FLOMON RAM-FLOPPY

;-----------------------------------------------------------------------------

; RAM ZELLEN

MWRTFLG:	DB 0		;<>0 IST WRITEN
MDRVAKT:	DB 0		;DRIVE das geladen ist
MTRKAKT:	DB 0		;TRACK 
MSEKAKT:	DB 0		;SEKTOR
ALLOC:		DB 0		; merker, 1=direktory write

                        ; SPEICHERZELLEN FUER DAS PROGRAMM

DBANK:   DB 0           ; NUMMER DES SELEKTIEREN LAUFWERKS
IOPB:    DB 80H         ; IO-BYTE (not used)
ION:     DB 1           ; SEKTORNUMMER (not used)
IOT:     DB OFFSAB      ; NUMMER DER GEWUENSCHTEN SPUR (start value is first usable track)
IOS:     DB 1           ; NUMMER DES GEWUENSCHTEN SEKTORS
IOD:     DW BUFF        ; DMA-ADRESSE
ALTDRV:  DB 1           ; SYSTEM-SPEICHERSTELLEN (not used)
INDADR:  DW 0		; not used
INDADR2: DW 0		; not used

          ENDEF		; end macro

          END
	  
; END OF FILE
