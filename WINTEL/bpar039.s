DEBUG = 0
SOUND = 1
maxconfettispr = 200
lenposlistspr = 572

           include      "p61settings.i"
     ifeq DEBUG-0
	   include	"startup1.s"
     endc 	
*****************************************************************************

BOBCOUNT = 23

		;5432109876543210
DMASET	EQU	%1000001111100000	; copper,bitplane,blitter DMA

logocount: dc.w 50*5			; Show logo for x seconds	 

STARTPROG:
        bsr.w   ScambiaBufferLogo 
	lea	$dff000,a5		; CUSTOM REGISTER in a5
	
        ifeq DEBUG-0
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	MOVE.l  #COPPERLISTLOGO,$80(a5)

        ifeq SOUND-1
	;move	$1c(a6),-(sp)		;Old IRQ
	move	#$7fff,$9a(a5)		;Disable IRQs
	move	#$e000,$9a(a5)		;Master and lev6
	endc				;NO COPPER-IRQ!
	
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#3,$1fc(a5)		; Set fmode to 64bit
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$ef,$10c(a5)		; Sprites to use palette 7 and 8

        endc
        
	lea	reflcount(pc),a0	
	Move.w 	#5*50, (a0)		;Reflector Shows Zool for 5 Seconds 
					;Befor next Reflector

	
lpfadein:	
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
.lfwaity:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	.lfwaity

	BSR.w	CalculateFade   
	
	ADDQ.W	#1,MULTIPLIER	
	cmp.w	#255, MULTIPLIER
	beq.s	lplogo

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	lpfadein		; se no, torna a mouse
        rts	

;Show Logo
lplogo:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
lpwaity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	lpwaity2

	BSR	ScambiaBufferLogo

	subi.w  #1,logocount	; If counter = 0 skip to next part
	beq.s	lpfadeout

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	lplogo		; se no, torna a mouse
	rts	

lpfadeout:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
.lfowaity:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	.lfowaity

	move.w	wblstate, d1
	cmp.w	#$aa, d1
	beq	.lfwblmaxreached
	
	bsr	CalculateWobble
	add.w	#$11,d1
	move.w	d1,wblstate	

.lfwblmaxreached:

	BSR.w	CalculateFade   
	bsr.w	Wobble

	SUBQ.W	#1,MULTIPLIER	
	beq.s	loopinit

.lfnofade:

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	lpfadeout		; se no, torna a mouse
        rts	

loopinit:				; Get ready to dance
	move.l	draw_buffer, d5
	moveq  	#4-1, d4
.lpclrdb:
	move.w	#0, d0			; d0: startrow
	move.w	#256, d1		; d1: number of rows
	move.l	d5, d2			; d2: destination address
	move.w	#48, d3			; d3: size rows
	bsr	ClearPlane
	add.l	#48*512, d5
	dbra	d4, .lpclrdb

	move.l	view_buffer,d5
	moveq	#4-1, d4
.lpclrvb:
	move.w	#0, d0			; d0: startrow
	move.w	#256, d1		; d1: number of rows
	move.l	d5, d2			; d2: destination address
	move.w	#48, d3			; d3: size rows
	bsr	ClearPlane
	add.l	#48*512, d5
	dbra	d4, .lpclrvb

	MOVE.l  #COPPERLIST,$80(a5)
	Move.l  d0, $88(a5)

	bsr     setPalettes		


	ifeq SOUND-1
        lea Module1,a0
        sub.l 	a1,a1
        sub.l 	a2,a2
        moveq 	#0,d0
        jsr	P61_Init
        endc

	lea	$dff000,a5		;Restore pointer to Custom registers

loop:
;show dancing sprites
       
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity2

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	beq	loop2ini	
	sub.w	#1, (a0)	
	move.w	(a0),d0
       
        ;move.w  #$10,$9c(a5)

	bsr.w   ScambiaBufferDance

	lea	crtxtpos, a0
	lea	crtxtcount, a1
	move.l	#0, d4
	;bsr.w	ShowCredits

	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w	#1-1,d7			;One Reflector
	bsr	LoadReflectors
	;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop		; se no, torna a mouse

	ifeq SOUND-1
	lea	$dff000, a6
	exit:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit
	jsr	P61_End
	endc
        rts

loop2ini:
	;Delete Reflection for Zool in Buffer1
	lea 	bpbern1, a1		;Buffer 1
	add.l	#48*512*7+48*256, a1	;Plane 8
	lea	reflpos(pc),a3		;Pointer to pos		
	move.w	(a3), d0		;xpos
	move.w  2(a3),d1		;ypos
	move.w  #48, d2			;width
	move.w	#48,d3			;height
	bsr	ClearRect		;Delete

	lea 	bpbern2, a1		;Buffer 2
	add.l	#48*512*7+48*256, a1	;Plane 8
	lea	reflpos(pc),a3		;Pointer to pos		
	move.w	(a3), d0				
	move.w  2(a3),d1
	move.w  #48, d2
	move.w	#48,d3	
        bsr	ClearRect

	lea	reflpos(pc),a3		;Set Position for Mario
  	move.w	#177, (a3)
	move.w	#12, 2(a3)
	lea	reflcount(pc),a0	
	Move.w 	#5*50, (a0)		;Reflector Shows Mario for 5 Seconds 

	move.w	#1, crtxtcount
	move.l  #creditsmario, crtxtpos 

loop2:        

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity3:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity3

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	beq	loop3ini	
	sub.w	#1, (a0)	
	       
        move.w  #$10,$9c(a5)

	bsr.w   ScambiaBufferDance
	lea	crtxtpos, a0
	lea 	crtxtcount, a1
	move.l	#0, d4
	;bsr	ShowCredits

	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w	#1-1,d7			;Number of reflectors = 1
	bsr	LoadReflectors

	
	;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop2		; se no, torna a mouse
	ifeq SOUND-1
	lea	$dff000, a6
exit332:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit332
	jsr	P61_End
	endc
        rts


loop3ini:
	
	lea	reflcount(pc),a0	
	Move.w 	#50*20, (a0)		;Reflectors shown for 5 seconds 

	lea	reflpos(pc),a3		;Setup reflection for zool again
	move.w	#90, 4(a3)		;Set xpos for reflector 2
	move.w	#12, 6(a3)		;Set ypos for reflector 2

	move.w	#25, crtxtcount
	move.l  #creditsflashback, crtxtpos 

loop3:        

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity4:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity4

	bsr.w   ScambiaBufferDance
	lea	crtxtpos, a0
	lea 	crtxtcount, a1
	move.l  #0, d4
	;bsr	ShowCredits

	move.w  #$10,$9c(a5)
	move.w  #$0c00, $106(a5)
	;move.w	#$f00, $180(a5)


	move.w	#2-1,d6			;Cleanup two reflections
	bsr	ClearReflections	

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	bne	l3continue
	bsr.w	ScambiaBufferDance	;Cleanup Second Buffer
	move.w	#2-1,d6
	bsr	ClearReflections
	jmp	loop5ini
l3continue:	
	sub.w	#1, (a0)	
	move.w	(a0),d0

	
	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w  #2-1, d7
	bsr	LoadReflectors
	
	move.w	#2-1, d0		;Number of reflectors
	bsr	movereflector

	move.w  #$0c00, $106(a5)
	;move.w	#$000, $180(a5)

        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop3		; se no, torna a mouse
	ifeq SOUND-1
	lea	$dff000, a6
	exit3:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit3
	jsr	P61_End
	endc
        rts

loop5ini:
	
	lea	reflcount(pc),a0	
	Move.w 	#50*25, (a0)		;Reflectors shown for 5 seconds 

	lea	reflpos(pc),a3		;Setup reflection for Donkey Kong
	move.w	#2, (a3)		;Set xpos for reflector 1
	move.w	#220, 2(a3)		;Set ypos for reflector 1
	move.w	#174, 4(a3)		;Set xpos for reflector 2
	move.w	#170, 6(a3)		;Set ypos for reflector 2

	move.w	#1, crtxtcount
	move.l  #creditsdkc, crtxtpos 

loop5:        

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity5:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity5

	bsr.w   ScambiaBufferDance
	move.l	#0, d4
	lea	crtxtpos, a0
	lea 	crtxtcount, a1
	;bsr	ShowCredits

	move.w  #$10,$9c(a5)
	move.w  #$0c00, $106(a5)
	;move.w	#$f00, $180(a5)	

	move.w	#2-1,d6			;Cleanup two reflections
	bsr	ClearReflections	

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	bne	l5continue
	bsr.w	ScambiaBufferDance
	move.w	#2-1,d6
	bsr	ClearReflections
	jmp	loop6ini	
l5continue:
	sub.w	#1, (a0)	
	
	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w  #2-1, d7
	bsr	LoadReflectors
	
	move.w	#2-1, d0		;Number of reflectors
	bsr	movereflector

	move.w  #$0c00, $106(a5)
	;move.w	#$000, $180(a5)


	;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop5		; se no, torna a mouse
	ifeq SOUND-1
	lea	$dff000, a6
	exit4:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit4
	jsr	P61_End
	endc
        rts


loop6ini:
	
	lea	reflcount(pc),a0	
	Move.w 	#50*25, (a0)		;Reflectors shown for 5 seconds 

	lea	reflpos(pc),a3		;Setup reflection for Donkey Kong
	move.w	#2, (a3)		;Set xpos for reflector 1
	move.w	#115, 2(a3)		;Set ypos for reflector 1
	move.w	#250, 4(a3)		;Set xpos for reflector 2
	move.w	#120, 6(a3)		;Set ypos for reflector 2
	move.w	#1, crtxtcount
	move.l  #creditsmi, crtxtpos 


loop6:        

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity6:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity6

	bsr.w   ScambiaBufferDance
	move.l	#0, d4
	lea	crtxtpos, a0
	lea 	crtxtcount, a1
	;bsr	ShowCredits

	move.w  #$10,$9c(a5)
	move.w  #$0c00, $106(a5)
	;move.w	#$f00, $180(a5)	

	move.w	#2-1,d6			;Cleanup two reflections
	bsr	ClearReflections	

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	bne	l6continue
	bsr.w	ScambiaBufferDance
	move.w	#2-1,d6
	bsr	ClearReflections
	jmp	loop7ini	
l6continue:
	sub.w	#1, (a0)	
	
	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w  #2-1, d7
	bsr	LoadReflectors
	
	move.w	#2-1, d0		;Number of reflectors
	bsr	movereflector

	move.w  #$0c00, $106(a5)
	;move.w	#$000, $180(a5)


	;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop6		; se no, torna a mouse
	ifeq SOUND-1
	lea	$dff000, a6
	exit5:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit5
	jsr	P61_End
	endc
        rts


loop7ini:
	
	lea	reflcount(pc),a0	
	Move.w 	#50*25, (a0)		;Reflectors shown for 5 seconds 

	lea	reflpos(pc),a3		;Setup reflection for Donkey Kong
	move.w	#2, (a3)		;Set xpos for reflector 1
	move.w	#60, 2(a3)		;Set ypos for reflector 1
	move.w	#250, 4(a3)		;Set xpos for reflector 2
	move.w	#70, 6(a3)		;Set ypos for reflector 2
	move.w	#1, crtxtcount
	move.l  #creditszelda, crtxtpos 

loop7:        

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity7:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity7

	bsr.w   ScambiaBufferDance
	move.l	#60, d4
	lea	crtxtpos, a0
	lea 	crtxtcount, a1
	;bsr	ShowCredits

	move.w  #$10,$9c(a5)
	move.w  #$0c00, $106(a5)
	;move.w	#$f00, $180(a5)	

	move.w	#2-1,d6			;Cleanup two reflections
	bsr	ClearReflections	

	lea	reflcount(pc),a0
	cmp.w	#0,(a0)	
	bne	l7continue
	bsr.w	ScambiaBufferDance
	move.w	#2-1,d6
	bsr	ClearReflections
	jmp	loop1ini	
l7continue:
	sub.w	#1, (a0)	
	
	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs

	move.w  #2-1, d7
	bsr	LoadReflectors
	
	move.w	#2-1, d0		;Number of reflectors
	bsr	movereflector

	move.w  #$0c00, $106(a5)
	;move.w	#$000, $180(a5)


	;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop7		; se no, torna a mouse
	ifeq SOUND-1
	lea	$dff000, a6
	exit6:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit6
	jsr	P61_End
	endc
        rts

loop1ini:
	move.l  #bpbern1,d2		;Fill Plane to show all bobs
	move.l  #0, d0
	add.l	#48*512*7+48*256, d2
	move.l  #256, d1				    	
	bsr	FillPlane

	move.l  #bpbern2,d2		;Fill Plane to show all bobs
	move.l	#0, d0
	add.l	#48*512*7+48*256, d2
	move.l  #256, d1				    	
	bsr	FillPlane	


loop1:
;show dancing sprites
        lea    	scrollstart, a0
	move.w	(a0),d0
	cmp.w   #0, d0      	
        bne.b  	noscroll
        lea	scrollframe, a0      ;Slow down scrolling if required
        move.w	(a0), d0
        cmp.w	#0, d0
        bne.b	skipscroll
        move.w	#0, (a0)
        lea     bpoffset, a1         ; set scrolling offset
        cmp.w   #48*256, (a1)        ; top of scrollarea reached start
        beq.w   enddance 
        add.w   #48, (a1)             
        jmp     cdend                  ;countdown for start scrolling finished
noscroll:
        sub.w   #1, d0
        move.w  d0, (a0)
        jmp	cdend
skipscroll:
	sub.w	#1, d0
	move.w  d0, (a0)
cdend:        
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity1
               
        move.w  #$10,$9c(a5)
        
        bsr.w   ScambiaBufferDance

; parametri per routine RipristinaSfondo
        ;move.w  #$f00,$180(a5)
        ;jsr     mt_music
	bsr.w	Animazione	; sposta i fotogrammi nella tabella
        bsr.w   printallbobs
        ;move.w  #$000,$180(a5)
        btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.w	loop1		; se no, torna a mouse

	ifeq SOUND-1
	lea	$dff000, a6
	exit7:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit7
	jsr	P61_End
	endc
        rts

enddance:

	bsr	ScrambleConfetti

        ifeq SOUND-1
	jsr     P61_End
        endc

	;move.w	#$7fff,$dff096

        ifeq SOUND-1
	lea Module2,a0
        sub.l 	a1,a1
        sub.l 	a2,a2
        moveq 	#0,d0
        jsr	P61_Init
        endc

        ;lea     testo(pc),a0
	lea	$dff000,a5

        move.w  #0, bpoffset   
        move.l  #bpbern1+48*512, draw_buffer
        move.l  #bpbern2+48*512, view_buffer

	move.l  draw_bufferconf(pc),d2		;Cleanup Bobs because
	add.l	#48*256, d2
	move.l  #256, d1			;Plane is reused    	
	bsr.w	ClearPlane; pulisci lo schermo

	move.l  view_bufferconf(pc),d2		
	add.l	#48*256, d2
	move.l  #256, d1				    	
	bsr.w	ClearPlane; pulisci lo schermo

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$00100,d2	; linea da aspettare = $130
Waity9:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity9

	move.l	#copperlistbern,$80(a5)
	move.l	d0, $88(a5)        

	bsr.w 	ShowConfettiSpr


loop4:
	
;Bern silhouette           
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity8:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.W	Waity8

	move.w  #$10,$9c(a5)

	;move.w  #$f00, $180(a5)
	bsr.w   ScambiaBufferSprite
	bsr.w   ScambiaBufferBern 
	bsr.w	PRINTCHAR	; routine che stampa i nuovi chars
	bsr.w	Scorri		; esegui la routine di scorrimento

        move.l 	#200, d0
	;move.w  cclearypos(pc),d0
	move.l  #30, d1
        move.l  draw_bufferconf(pc), d2    	

	btst	#0, confframe(pc)
	beq	skipframe
        bsr.w	ClearPlane; pulisci lo schermo
	
	;move.w	#$f00, $180(a5)
	bsr.w   ShowConfetti
	;move.w	#$000, $180(a5)
skipframe:        
        bsr.w   ShowConfettiSpr
        ;move.w  #$000, $180(a5)
        
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	loop4		; se no, torna a mouse

	ifeq SOUND-1
	lea	$dff000, a6
	exit8:	
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit8
	jsr	P61_End
	endc

        ifeq SOUND-1
        jsr     P61_End
        ;move.w	#$7fff,$dff096
        endc
	
	rts

reflcount:
	dc.w 0		;number of frames till reflector moves

confframe:
	dc.b	0,0		;Jump every other frame for confetti

scrposstart:
	dc.l	testo

scrpos:
        dc.l    testo

scrpos2: ;double buffering
        dc.l    testo

crtxtpos: 
	dc.l	creditszool	; time till credit text changes	

crtxtcount:
	dc.w 1

scrollstart:
	;dc.w	 50*2 
        dc.w    50*20          ; time till scrolling starts toshow berne 

scrollframe:
	dc.w 0

bpoffset:
        dc.w    0                       ; used for scrolling

draw_buffer: 
        dc.l    bpbern1+48*256

view_buffer:
        dc.l    bpbern2+48*256

draw_bufferconf:
	dc.l	bpbern1

view_bufferconf:
	dc.l	bpbern2

Playrtn:
        include "p6112-Play.i"

cclearypos:
        dc.w 0

lenposlist = 754

MULTIPLIER:
	dc.w	0

temporaneo:
	dc.l	0

Wobble:
	LEA	CON1EFFETTO+8,A0 ; Indirizzo word sorgente in a0
	LEA	CON1EFFETTO,A1	; Indirizzo delle word destinazione in a1
	MOVEQ	#46-1,D2		; 45 bplcon1 da cambiare in COPLIST
SCAMBIA:
	MOVE.W	(A0),(A1)	; copia due word consecutive - scorrimento!
	ADDQ.W	#8,A0		; prossima coppia di word
	ADDQ.W	#8,A1		; prossima coppia di word
	DBRA	D2,SCAMBIA	; ripeti "SCAMBIA" il numero giusto di VOLTE

	MOVE.W	CON1EFFETTO,ULTIMOVALORE ; per rendere infinito il ciclo
	RTS				; copiamo il primo valore nell'ultimo
					; ogni volta.

wblstate:
	dc.w	$11			; How much it wobbles atm

CalculateWobble:
	;move.w	wblstate,d1		;Recent wobble max 		 
	LEA	CON1EFFETTO,A1		;copper pos
	Lea	wbltarget,A3		;wobble target for this scanline

	moveq	#46-1,d6		;45 values to set
.cwloop:
	;Calculate Wobble
	move.w	(A3)+,D4		; READ Wobble FROM TAB
	cmp.w	d4, d1			; Maximum reached?
	bhi.s	.cwmaxreached	
	move.w	d1, d5			; If not save recent max
	jmp	.cwcalculated
.cwmaxreached:
	move.w	d4, d5			; If yes save max for this raster line
.cwcalculated:
	move.w	d5,(a1)			; Save to copper
	addq.w	#8,a1			; Point to next copper instruction
	dbra	d6,.cwloop

	rts				


******************************************************************************
* Questa routine converte i colori a 24 bit, che si presentano come una      *
* longword $00RrGgBb, (dove R = nibble alto di RED, r = nibble basso di RED, *
* G = nibble alto di GREEN eccetera), nel formato della copperlist aga,      *
* ossia in due word: $0RGB con i nibble alti e $0rgb con i nibble bassi.     *
******************************************************************************

CalculateFade:
	LEA	temporaneo(PC),A0 	; Long temporanea per colore a 24
					; bit nel formato $00RrGgBb
	LEA	COLP0+2,A1		; Indirizzo del primo registro
					; settato per i nibble ALTI
	LEA	COLP0B+2,A2		; Indirizzo del primo registro
					; settato per i nibble BASSI
	Lea	PalettePic,A3		; 24bit colors tab address

	MOVEQ	#1-1,d7			; 8 banchi da 32 registri ciascuno
ConvertiPaletteBank:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#16-1,d6	; 32 registri colore per banco

DaLongARegistri:	; loop che trasforma i colori $00RrGgBb.l nelle 2
			; word $0RGB, $0rgb adatte ai registri copper.

;	CALCOLA IL ROSSO

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%000011111111,D4	; SELECT BLUE
	MULU.W	MULTIPLIER(PC),D4		; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%000011111111,D4	; SELECT BLUE VAL
	MOVE.L	D4,D5			; SAVE BLUE TO D5

;	CALCOLA IL VERDE

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%1111111100000000,D4	; SELECT GREEN
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	MULTIPLIER(PC),D4	; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%0000000011111111,D4	; SELECT GREEN
	LSL.L	#8,D4			; <- 8 bits (so from 8 to 15)
	OR.L	D4,D5			; SAVE GREEN TO D5

;	CALCOLA IL BLU

	MOVE.L	(A3)+,D4		; READ COLOR FROM TAB AND GO TO NEXT
	ANDI.L	#%111111110000000000000000,D4	; SELECT RED
	LSR.L	#8,D4			; -> 8 bits (so from 8 to 15)
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	MULTIPLIER(PC),D4	; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%0000000011111111,D4	; SELECT RED
	LSL.L	#8,D4			; <- 8 bits (so from 8 to 15)
	LSL.L	#8,D4			; <- 8 bits (so from 0 to 7)
	OR.L	D4,D5			; SAVE RED TO D5
	MOVE.L	D5,(A0)			; SAVE 24 BIT VALUE IN temporaneo

; Conversione dei nibble bassi da $00RgGgBb (long) al colore aga $0rgb (word)

	MOVE.B	1(A0),(a2)	; Byte alto del colore $00Rr0000 copiato
				; nel registro cop per nibble bassi
	ANDI.B	#%00001111,(a2) ; Seleziona solo il nibble BASSO ($0r)
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	lsl.b	#4,d2		; Sposta a sinistra di 4 bit il nibble basso
				; del GREEN, "trasformandolo" in nibble alto
				; di del byte basso di D2 ($g0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24bit
	ANDI.B	#%00001111,d3	; Seleziona solo il nibble BASSO ($0b)
	or.b	d2,d3		; "FONDI" i nibble bassi di green e blu...
	move.b	d3,1(a2)	; Formando il byte basso finale $gb da mettere
				; nel registro colore, dopo il byte $0r, per
				; formare la word $0rgb dei nibble bassi

; Conversione dei nibble alti da $00RgGgBb (long) al colore aga $0RGB (word)

	MOVE.B	1(A0),d0	; Byte alto del colore $00Rr0000 in d0
	ANDI.B	#%11110000,d0	; Seleziona solo il nibble ALTO ($R0)
	lsr.b	#4,d0		; Shifta a destra di 4 bit il nibble, in modo
				; che diventi il nibble basso del byte ($0R)
	move.b	d0,(a1)		; Copia il byte alto $0R nel color register
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	ANDI.B	#%11110000,d2	; Seleziona solo il nibble ALTO ($G0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24 bit
	ANDI.B	#%11110000,d3	; Seleziona solo il nibble ALTO ($B0)
	lsr.b	#4,d3		; Shiftalo di 4 bit a destra trasformandolo in
				; nibble basso del byte basso di d3 ($0B)
	ori.b	d2,d3		; Fondi i nibble alti di green e blu ($G0+$0B)
	move.b	d3,1(a1)	; Formando il byte basso finale $GB da mettere
				; nel registro colore, dopo il byte $0R, per
				; formare la word $0RGB dei nibble alti.

	addq.w	#4,a1		; Saltiamo al prossimo registro colore per i
				; nibble ALTI in Copperlist
	addq.w	#4,a2		; Saltiamo al prossimo registro colore per i
				; nibble BASSI in Copperlist

	dbra	d6,DaLongARegistri

	add.w	#(128+8),a1	; salta i registri colore + il dc.w $106,xxx
				; dei nibble ALTI
	add.w	#(128+8),a2	; salta i registri colore + il dc.w $106,xxx
				; dei nibble BASSI

	dbra	d7,ConvertiPaletteBank	; Converte un banco da 32 colori per
	rts				; loop. 8 loop per i 256 colori.

; Tabella con la palette a 24 bit in formato $00RRGGBB. Avremmo potuto anche
; usare quella attaccata in fondo alla PIC, ma per variare eccola in dc.l!
; Si puo' salvare da PicCon se non si seleziona "Copperlist".





;Input
;a0 = Text pointer
;a1 = Textcounter
ShowCredits:
	move.l	(a0), a2
	cmp.b	#0, (a2)
	bne	nocreditsend
	rts
nocreditsend:
	cmp.w	#1, (a1)
	bhi	nocreditswitch	
	move.l  draw_buffer,d2			;Load params for function
	move.l	#0, d0
	add.l	#48*512*7, d2
	mulu	#48, d4
	add.l	d4, d2
	move.l  #8, d1				;Number of lines to clear		    	
	bsr.w	ClearPlane; pulisci lo schermo
	move.l	draw_buffer, a3		;Switch credittext	
	add.l	#48*512*7,a3		;Last plane top				
	add.l	d4, a3
	bsr	STAMPA2
	cmp.w   #0, (a1)		;Credit text counter = 0	
	bne	nocreditswitch
	move.l  a2, (a0)		;Write to memory
	move.w  #50*2, (a1)		;Reinitialize counter
nocreditswitch:		
	sub.w   #1, (a1)	;Countdown credittext
	rts

;d7 = Number of reflectors
LoadReflectors:
	lea	reflpos(pc),a3		;Pointer to pos
lrloop
	lea	reflframe,a0		;Load Reflection Mario
	lea	reflframe,a1		;Mask Reflection = Bob Reflection
	move.w	(a3), d0		;Load xpos
	move.w  2(a3), d1		;Load ypos
	move.w	#48, d2			;width
	move.w	#48, d3			;height
	bsr	UniBobFull		;create bob on screen		 
	add.l	#4, a3
	dbra	d7, lrloop
	rts

; d6 = number of reflectors
ClearReflections:
	lea	reflpos(pc),a3		;Pointer to pos
loopcr:
	move.l 	draw_buffer(pc), a1	;Draw_buffer
	add.l	#48*512*7, a1	;Plane 8		
	move.w	(a3), d0		;xpos
	move.w  2(a3),d1		;ypos
	sub.w	#2, d0			;some extra pixels because of dblbuff
	move.w  #64, d2			;width
	move.w	#49,d3			;height
	bsr	ClearRect		;Delete
	add.l	#4, a3			;Next Reflector position
	dbra	d6, loopcr
	rts

;d0 = Number of reflections

movereflector:
	lea	refldir(pc),a2
	lea	reflpos(pc),a3
loopreflector:				;Move xposition of reflector
	btst.b	#0, (a2)
	beq	positive
	cmp.w	#0, (a3)
	bne	subtract
	bchg.b	#0, (a2)
	jmp	reflmoveend	
subtract:	
	sub.w	#1, (a3)
	jmp	reflmoveend
positive:
	cmp.w	#320-64,(a3)	
	bne	addition
	bchg.b  #0, (a2)
	jmp	reflmoveend
addition:
	add.w	#1, (a3)
reflmoveend:	
	add.l	#2, a2			;Next position	
	add.l	#4, a3
	dbra	d0, loopreflector
	rts

;other
;a0 - 	bitplane
;a1 - 	xpos (Starting xpos for confettis)
;a2 - 	ypos on bitplane (unused)
;a3 - 	pos tablist (pointer to list of movement for each confetti)	
;a4 - 	maxypos for effect		- load effective xpos
;	multiple other purpose(s)	
;d0 - 	confetticount
;d1 -					xposcalculation				
;d2 -	no fix usage			confettis left for line	


ScrambleConfetti:
	lea	conftpos, a3
	moveq	#0, d0			;Value to add
	move.w	#maxconfetti,d1
	move.w	#370-1,d2		;Numper of confettis per line
.sc2lpcnf:				;Loop for each confetti
	add.l	d0, (a3)+		;Add offset
	addq.w	#2, d0			;Change offset for next tabpointer
	dbra	d2, .sc2noreset		;Last xpos reached
	moveq	#0, d0			;Reset offset for pointer	
.sc2noreset				
	dbra	d1, .sc2lpcnf		;last confetti reached 
	rts

ShowConfetti:
	move.l  draw_bufferconf, a0	
	add.l	#48*200, a0		 ; Move further down in plane
	lea     confxpos,a1
        lea     conftpos,a3
	move.w  #maxconfetti,d0
	move.w	#16-1, d2		 ; confettis to show each line
	btst	#6,2(a5)
.scwblit:                                ; blitter register that stay the same go here
	btst	#6,2(a5)		
	bne.s	.scwblit        

        move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word

        move.w  #44, $62(a5)        
        move.w	#$fffe,$64(a5)	        ; BLTBMOD e BLTAMOD=$fffe=-2 torna
					; indietro all'inizio della riga.

	move.w	#0,$60(a5)		; BLTCMOD, dmod  rowsize - confsize -
	move.w	#44,$66(a5)		; extra for shift
        move.w	#0,$42(a5)		; BLTCON1 - valore di shift
					; nessun modo speciale
	
.scmloop:
	move.w  (a1)+,d1                ; xpos used for calc
        move.l  (a3),a4                 ; prepare load xpos to add
        move.w  (a4)+,d3                ; load xpos to add
        
        cmp.w	#$ffff,d3		;last xpos reached?
	bne.s	.scnoresetpos	
	sub.l   #lenposlist+2, a4	;if yes reset conftabpos 
	move.w  (a4)+,d3
        ;clr.w	(a2)
.scnoresetpos:
        add.w   d3,d1
        move.l  a4, (a3)+               ; save pointer to xpos to add                   

; calcolo indirizzo di partenza del blitter

        move.l  a0, a4          ; copy bitplanestart
	move.w	d1,d6		; copy x
	lsr.w	#3,d1		; divide x width 8
	and.w	#$fffe,d1	; only even
	add.w	d1,a4		; add x to bitplane address

	and.w	#$000f,d6	; shift for channel a and b
	lsl.w	#8,d6		; move to right bits for bltcon1
	lsl.w	#4,d6		 

        or.w	#$0dfc,d6	; valori da mettere in BLTCON0

	btst	#6,2(a5)
.scwblit2:                                ; blitter register that stay the same go here
	btst	#6,2(a5)		
	bne.s	.scwblit2

        move.l	#co2frame,$50(a5)         
	
; inizializza i registri che restano costanti

	move.w	d6,$40(a5)		; BLTCON0 - valore di shift
					; cookie-cut

	move.l	a4,$54(a5)		; BLTDPT  destination 
	move.l	a4,$4c(a5)		; BLTBPT  background
	move.w	#4*64+2,$58(a5)		; BLTSIZE height 4 and width 2 words

	dbra	d2, .scnonewline 	; 16 confettis shown
	move.w	#16-1, d2
	add.l	#48, a0			; Jump to next line
.scnonewline:
	dbra	d0, .scmloop

	rts

ShowConfettiOld:
        move.l  draw_bufferconf(pc), a0
        sub.l   #3*48,a0
        lea     confxpos,a1
	lea    	confypos,a2
        lea     conftpos,a3
        move.w  confetticount(pc),d0   
        lea     maxypos(pc),a4
        addq.w  #1,(a4)			     ;frame	
        cmp.w   #28+3,(a4)		     ;row 48 on screen  plus buffer
	bls.s	clearscreenisnull
        cmp.w   #48*(256+120), (a2)	     ;First confetti shows up on top 	
        bls.s   noresetypos2		     ;again	
        move.w  #0, (a4)
        ;lea     cclearypos(pc), a4
        ;move.w  #0, (a4)    
        jmp     clearscreenisnull
noresetypos2:
        ;lea     cclearypos(pc),a4             ;count up clear area
	;add.w   #1, (a4)
clearscreenisnull:
        moveq     #0,d2
        move.w    d0,d2
        subq.w    #1,d2
        add.w     d2,d2                  ;*2 gets address space in words
        move.l    a2,a4                  ;copy confypos for calc    
        add.l     d2,a4                  ;address of last confetti
	cmp.w     #1*48, (a4)            ;last confetti on yposition = 2
        bne       nonewconfettis         ;if not no new confettis on screen
        ;move.w    maxconfetti(pc), d1
        cmp.w     #maxconfetti,d0        ;maximum number of confettis reached
        
        beq.s     nonewconfettis         ;if yes no new confettis on screen
        add.w     #16,d0                 ;load next confettis
        lea       confetticount,a4
        move.w    d0,(a4)                ;save to ram 
        
nonewconfettis:  

        sub.w   #1, d0                  ; loopcounter = confcount - 1
        
	btst	#6,2(a5)
WBlit_u3:                                ; blitter register that stay the same go here
	btst	#6,2(a5)		
	bne.s	WBlit_u3        

        move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word

        move.w  #44, $62(a5)        
        move.w	#$fffe,$64(a5)	        ; BLTBMOD e BLTAMOD=$fffe=-2 torna
					; indietro all'inizio della riga.

	move.w	#0,$60(a5)		; BLTCMOD, dmod  rowsize - confsize -
	move.w	#44,$66(a5)		; extra for shift
        move.w	#0,$42(a5)		; BLTCON1 - valore di shift
					; nessun modo speciale

confettiloop:
	move.w  (a1)+,d1                 ; xpos used for calc
        move.l  (a3),a4                 ; prepare load xpos to add
        move.w  (a4)+,d3                ; load xpos to add
        
        cmp.w	#$ffff,d3		;last xpos reached?
	bne.s	noresetpos	
	sub.l   #lenposlist+2, a4	;if yes reset conftabpos 
	move.w  (a4)+,d3
        clr.w	(a2)
noresetpos:
        add.w   d3,d1
        move.l  a4, (a3)+               ; save pointer to xpos to add        	
        move.w  (a2),d2                 ; ypos used for calc        
        add.w   #48,(a2)+               ; new ypos          

; calcolo indirizzo di partenza del blitter

        move.l  a0, a4          ; copy bitplanestart
        ;add.w   d2, a4          ; add y offset in words
	move.w	d1,d6		; copy x
	lsr.w	#3,d1		; divide x width 8
	and.w	#$fffe,d1	; only even
	add.w	d1,a4		; add x to bitplane address

	and.w	#$000f,d6	; shift for channel a and b
	lsl.w	#8,d6		; move to right bits for bltcon1
	lsl.w	#4,d6		; 

	;move.w	d6,d5		; copy to calculate bltcon0
        or.w	#$0dfc,d6	; valori da mettere in BLTCON0

	btst	#6,2(a5)
WBlit_u1:                                ; blitter register that stay the same go here
	btst	#6,2(a5)		
	bne.s	WBlit_u1

        move.l	#co2frame,$50(a5)         
	
; inizializza i registri che restano costanti

	move.w	d6,$40(a5)		; BLTCON0 - valore di shift
					; cookie-cut

	move.l	a4,$54(a5)		; BLTDPT  destination 
	move.l	a4,$4c(a5)		; BLTBPT  background
	move.w	#4*64+2,$58(a5)		; BLTSIZE height 4 and width 2 words

	dbra	d0,confettiloop

	rts



; Routine universale di posizionamento degli sprite.
; Questa routine modifica la posizione dello sprite il cui indirizzo e`
; contenuto nel registro a1 e la cui altezza e` contenuta nel registro d2,
; e posiziona lo sprite alle coordinate Y e X contenute rispettivamente nei
; registri d0 e d1.
; Prima di chiamare questa routine e` necessario mettere l'indirizzo dello
; sprite nel registro a1, la sua altezza nel registro d2, la coordinata Y nel
; registro d0, la X nel registro d1

; Questa procedura e` chiamata "passaggio di parametri".
; Notate che questa routine modifica i registri d0 e d1.

;
;	Parametri in entrata di UniMuoviSprite:
;
;	a6 = Indirizzo dello sprite
;	d2 = posizione verticale Y dello sprite sullo schermo (0-255)
;	d1 = posizione orizzontale X dello sprite sullo schermo (0-320)
;

UniMuoviSprite:
; posizionamento verticale
	ADD.W	#$1c,d2		; aggiungi l'offset dell'inizio dello schermo

; a1 contiene l'indirizzo dello sprite

	MOVE.b	d2,(a6)		; copia il byte in VSTART
	btst.l	#8,d2
	beq.s	NonVSTARTSET
	bset.b	#2,3(a6)	; Setta il bit 8 di VSTART (numero > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3(a6)	; Azzera il bit 8 di VSTART (numero < $FF)
ToVSTOP:
	ADD.w	#8,D2		; Aggiungi l'altezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d2,2(a6)	; Muovi il valore giusto in VSTOP
	btst.l	#8,d2
	beq.s	NonVSTOPSET
	bset.b	#1,3(a6)	; Setta il bit 8 di VSTOP (numero > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3(a6)	; Azzera il bit 8 di VSTOP (numero < $FF)
VstopFIN:

; posizionamento orizzontale

	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO
	bset	#0,3(a6)	; Settiamo il bit basso di HSTART
	bra.s	PlaceCoords

BitBassoZERO:
	bclr	#0,3(a6)	; Azzeriamo il bit basso di HSTART
PlaceCoords:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra
				; il valore di HSTART, per "trasformarlo" nel
				; valore fa porre nel byte HSTART, senza cioe'
				; il bit basso.
	move.b	D1,1(a6)	; Poniamo il valore XX nel byte HSTART
	rts

ShowConfettiSpr:
        lea     confxposspr,a1
        lea     confyposspr,a2
        lea     conftposspr,a3

        move.l  a2,a4
        cmp.w     #286, (a4)
        bne       noresetypos
        move.w    #8-1,d4
loopresetypos:
        move.w    #0, (a4)+
        dbra      d4, loopresetypos
        lea       confyposspr(pc), a4
noresetypos:       


        ;move.l  a2,a4
        ;add.l   #(maxconfettispr*4)-1,a4          ;jump to last ypos
        cmp.w   #0,(a2)                      ;if last ypos will move to top                                               ;of screen rotate positions
        bne     norotatepos            

	move.w  #(maxconfettispr/2)-5, d0
        move.l  a1, a4      
        move.w  (a4)+,d1
        move.w  (a4)+,d2
        move.w  (a4)+,d3
        move.w  (a4)+,d4
        move.w  (a4)+,d5
        move.w  (a4)+,d6
        move.w  (a4)+,d7
        move.w  (a4)+,a6       
looprxpos:
        move.l  (a4)+,-20(a4) 
        dbra    d0, looprxpos	;shift whole table 8 words forward 

	sub.l   #16, a4		;Pointer to last 8 words	

        move.w  d1, (a4)	;Move old first line to last line
        move.w  d2, 2(a4)
        move.w  d3, 4(a4)
        move.w  d4, 6(a4)
        move.w  d5, 8(a4)
        move.w  d6, 10(a4)
        move.w  d7, 12(a4)
        move.w  a6, 14(a4)

        move.w  #maxconfettispr-9, d0

        move.l  a3, a4      
        move.l  (a4)+,d1
        move.l  (a4)+,d2
        move.l  (a4)+,d3
        move.l  (a4)+,d4
        move.l  (a4)+,d5
        move.l  (a4)+,d6
        move.l  (a4)+,d7
        move.l  (a4)+,a6       

looprtpos:
        move.l  (a4)+,-36(a4) 
        dbra    d0, looprtpos	;Shift whole table 8 longword forward 

	sub.l   #32, a4		;Pointer to last 8 longwords	

        move.l  d1, (a4)	;Move 8 first longwords to end of table
        move.l  d2, 4(a4)
        move.l  d3, 8(a4)
        move.l  d4, 12(a4)
        move.l  d5, 16(a4)
        move.l  d6, 20(a4)
        move.l  d7, 24(a4)
        move.l  a6, 28(a4)                    

        move.w  #(maxconfettispr/2)-5, d0

        move.l  a2, a4
      
        move.l  (a4)+,d1
        move.l  (a4)+,d2
        move.l  (a4)+,d3
        move.l  (a4)+,d4
        
looprypos:
        move.l  (a4)+,-20(a4) 
        dbra    d0, looprypos	;Shift whole table 8 words forward 

	sub.l   #16, a4		;Pointer to last 8 bytes	

        move.l  d1, (a4)	;Move first 8 bytes to end of table
        move.l  d2, 4(a4)
        move.l  d3, 8(a4)
        move.l  d4, 12(a4)
norotatepos:    
        move.w    confetticountspr(pc),d0   
        clr.l     d2
        move.w    d0,d2
        sub.w     #1,d2
        add.w     d2,d2                ;*2 gets address space in words
        move.l    a2,a4                 ;copy confypos for calc    
        add.l     d2,a4                 ;address of last confetti
        cmp.w     #12, (a4)             ;last confetti on yposition = 12
        bne       nonewconfettisspr     ;if not no new confettis on screen
        cmp.w     #maxconfettispr,d0	;maximum number of confettis reached
        
        beq       nonewconfettisspr     ;if yes no new confettis on screen
	add.w     #8,d0                 ;load next confettis
        lea       confetticountspr,a4
        move.w    d0,(a4)		;save to ram       
nonewconfettisspr: 
        move.l    drawbufferspr(pc),a6
        clr.l     d4
        move.w    d0, d4                ;start at highest spriteposition          
        divu.w    #8, d4                ;this way sprites are ordered from
        sub.w     #1, d4
        mulu.w    #36, d4               ;lowest to highest ypos
        add.l     d4,a6                               
        sub.w     #1, d0		; loopcounter = confcount - 1
confettiloopspr:
        move.w  (a1)+,d1                ; xpos used for calc
        move.l  (a3),a4                 ; prepare load xpos to add
        move.w  (a4)+,d3                ; load xpos to add
        cmp.w	#$ffff,d3		;last xpos reached?
	bne	noresetposspr	
	sub.l   #lenposlistspr+2, a4	;if yes reset conftabpos 
	move.w  (a4)+,d3
noresetposspr:
        add.w   d3,d1
        cmp.w   #321,d1                 ;xpos too high
        bls     norecalc
        sub.w   #320,d1 
norecalc:        
        move.l  a4, (a3)+               ; save pointer to xpos to add
        clr.w	d2        	
        move.w  (a2),d2                 ; ypos used for calc 

        bsr     UniMuoviSprite

	move.l  drawbufferspr(pc), a5			
	add.l	#36*32*7,a5	

	cmp.l   a5,a6			  ; compare if sprite8 reached	
        bcc     lastspritereached         ; higher or equal a6     
        add.l   #36*32+4,a6               ; pointer to next sprite         
        jmp     spraddrset(pc)
lastspritereached:
        sub.w   #(36*32+4)*7+36,a6           ; pointer to first sprite next pos                
spraddrset:            
br3:
        add.w   #1,(a2)+                  ; new ypos                  

        dbra	d0,confettiloopspr

	move.l	#$dff000, a5

	rts

drawbufferspr: dc.l sprite1_2
viewbufferspr: dc.l sprite1

maxypos: dc.w 0

confetticount:
        dc.w     16

maxconfetti = 400

confetticountspr: dc.w 8

;***************************************************
; Every bob can choose a 16 color palette out of 8. 
; The palette number is defined by the top three bitplanes
; As the bobs don`t change size and not move this planes
; have to be set only once at start and not for every
; frame
;****************************************************

setPalettes:
	lea     OGG_Y, a2  
	lea     palettenumbers,a3
	move.w  #$ffff, d4                 ; Pattern to filllane with
        move.w  #BOBCOUNT-1, d5 
looppalette:
        move.w  (a3)+,d7                 ;store palette value in d7
        move.w  #3-1, d6                 ;run for bitplane 5-7
loopplane:   
     
        btst    #0, d7   
        beq     palnotset
        move.l  draw_buffer, a6           ; load destination bitplane
        moveq   #6, d0                    ; maximum number of bitplanes - 1
        sub.w   d6, d0                    ; minus turns left - 1 = recent 
                                          ; bitplane to set -1
        mulu    #48*512,d0                ; * bytes per plane = offset 
        add.l   d0, a6                    ; added to address = addr recent 
                                          ; plane
	move.w	28*2(a2),d0              ; posizione X
	;addq.w	#8,d0
	move.w	28*2*2(a2),d2            	; dimensione X
	move.w	28*2*3(a2),d3		 ; dimensione Y
	move.w	(a2),d1                  ; posizione Y
	bsr.w	BlitRett
	
	move.l  view_buffer,a6
	move.w  #6, d0                    ; maximum number of bitplanes - 1
        sub.w   d6, d0                    ; minus turns left - 1 = recent 
                                          ; bitplane to set -1
        mulu    #48*512,d0                ; * bytes per plane = offset 
        add.l   d0, a6                    ; added to address = addr recent 
                                          ; plane
	move.w	28*2(a2),d0              ; posizione X
	;addq.w	#8,d0
	move.w	28*2*2(a2),d2            ; dimensione X
	move.w	28*2*3(a2),d3		 ; dimensione Y
	move.w	(a2),d1                 ; posizione Y	
	bsr.w   BlitRett
palnotset:
        lsr     #1, d7
        dbra    d6, loopplane
        lea     2(a2), a2   
	dbra    d5,looppalette
        rts



	include "bpa:srcraw/sinetable.i"

	even

; variabili posizione BOB
OGG_Y:		dc.w	126,117,118,119,108,114 ;124
		dc.w	170,185,171,189
		dc.w	63,63,69,80,73,65,63
		dc.w	12,26,15,14,12,18,0,0,0,0,0			
OGG_X:		dc.w	0,48,96,144,192,240
		dc.w	0,80,144,208
                dc.w	0,32,64,112,160,208,256
                dc.w	0,64,96,144,192,240,0,0,0,0,0
BobWidth:       dc.w    32,48,32,32,48,32
		dc.w	80,64,64,96
                dc.w    32,32,48,48,32,48,64
                dc.w	64,32,48,32,32,32,0,0,0,0,0
BobHeight:      dc.w    39,48,47,46,57,51
		dc.w	83,68,82,64
		dc.w    30,30,24,13,20,40,33
		dc.w	45,31,42,43,45,39,0,0,0,0,0
Heightplane:    dc.w    390,336,423,368,912,816
		dc.w	837,816,984,1536	
                dc.w	120,180,96,78,160,320,660
                dc.w	360,248,504,516,360,507,0,0,0,0,0
palettenumbers: dc.w    0,1,2,3,4,5
		dc.w	0,1,2,3
                dc.w    0,1,2,3,4,5,6
                dc.w	0,1,2,3,4,5,0,0,0,0





printallbobs:
	lea     frametabs, a1
	lea     OGG_Y, a2
        move.w  #BOBCOUNT-1, d6
printbob1:

        move.l  (a1)+,a0                 ; load pointer to frame
        move.l  (a0),a0                  ; load frame
        move.l  draw_buffer(pc), a6      ; load destination bitplane
        move.w  28*2*4(a2),d7            ; height plane
	move.w	28*2(a2),d0              ; posizione X
	move.w	28*2*2(a2),d2            ; dimensione X
	move.w	28*2*3(a2),d3		 ; dimensione Y
	move.w	(a2)+,d1                  ; posizione Y
	bsr.w	UniBob			 ; disegna il bob con la routine
	dbra    d6, printbob1	         ; universale
        rts
        
;d6: startbob
;d7: numberofbobs

printbobs:
	move.l	frametabbuzzkill(pc),a0	; mette il puntatore al fotogramma
					; da disegnare in A0
	lea     OGG_X, a1
	mulu.w  #2, d6                  ; add offset for startbob
	add.l   d6, a1	
	lea     OGG_Y, a2
	add.l   d6, a2                  ; add offset for startbob
	lea     BobWidth, a3
	add.l   d6, a3                
	lea     BobHeight, a4
	add.l   d6, a4
	sub.w   #2-1, d7
printbob2:
;parameters for routine unibob
        lea  bpprepare, a6     ; destination frame for preparation
                                        ; reflection effect follows
        move.w  28*2*3(a1),d6
	move.w	(a1)+,d0		; posizione X
	move.w	(a2)+,d1		; posizione Y
	move.w	(a3)+,d2			; dimensione X
	move.w	(a4)+,d3			; dimensione Y
	bsr.w	UniBob			; disegna il bob con la routine
	dbra    d7, printbob2				; universale
        rts

ScambiaBufferSprite:
        lea        drawbufferspr(pc),a1
        lea        viewbufferspr(pc),a2
        move.l     (a1),d0
        move.l     (a2),(a1)
        move.l     d0, (a2)
        ;move.l     (a1),d0
        lea        COPPERLISTBERN, a0
        move.w     #8-1, d1
sprpointerloop:
        move.w     d0, 6(a0)
        swap       d0
        move.w     d0, 2(a0)
        swap       d0
        add.l      #36*32+4,d0    ;pointer to next sprite in memory
        add.l      #8, a0       ;pointer to next sprite in cl   
        dbra       d1, sprpointerloop

        rts

sbbypos: 		
	dc.w	CONFETTILINES	;If 0 reached show next confetti shower

sbbbyteoffset:
	dc.w	0		;Number of bytes to move "bitplane in screen
				;for scrolling"		

sbbyoffset:
	dc.b	0
	EVEN

sbbbplrepeat:
	dc.w	1-1		;Number of times the bitplane should repeat	
	
TOPCONFETTI = 170*48
CONFETTILINES = 50
OFFSETBPL = 10
REPEAT = 6

ScambiaBufferBern:
	move.l	draw_buffer(pc),d0		; scambia il contenuto
	move.l	view_buffer(pc),draw_buffer	; delle variabili
	move.l	d0,view_buffer			; in d0 c'e` l'indirizzo						; del nuovo buffer						; da visualizzare

	bchg	#0,confframe			;Move confetti only every other frame
	btst	#0,confframe(pc)
	beq	keepbuffer
	move.l	draw_bufferconf(pc),d1
	move.l 	view_bufferconf(pc),draw_bufferconf
	move.l	d1,view_bufferconf
keepbuffer:
	move.l	view_bufferconf(pc),d1

	;Confetti Movement
	move.w	sbbbyteoffset, d2
	move.w	sbbbplrepeat, d3	;
	moveq	#0, d5
	move.b	sbbyoffset, d5
	btst	#0, confframe(pc)	;No movement in this frame skip
	beq.s	.sbbsetbplpos
	
	subi.w	#1, sbbypos		;Countdown for next confetti shower
	bne.s	.sbbcontinue		;No restart continue scrolling
	move.w	#0, d2			;Reset ypos byte offset
	move.w	#CONFETTILINES, sbbypos		;Reset counter for next frame
	moveq	#0, d5
	cmp.w	#REPEAT, d3
	beq.s	.sbbmxreached			
	add.w	#1, d3
.sbbmxreached
	jmp	.sbbsetbplpos
.sbbcontinue:				
	add.w	#48, d2			;Add bytes for scrolling offset		
	add.w	#1, d5	
.sbbsetbplpos:				;Save values
	move.w	d2, sbbbyteoffset	
	move.w	d3, sbbbplrepeat
	move.b	d5, sbbyoffset
	add.l	#TOPCONFETTI+CONFETTILINES*48,d1
	LEA	BPLPOINTERSBERN, A1
	sub.w	d2, d1	

	moveq	#4-1,d4
.sbbbplloop
	move.w  d1,6(a1)		;Set Main bitplane pointers
	swap	d1
	move.w	d1,2(a1)
	swap	d1
	add.l	#OFFSETBPL*48,d1		;Next bitplane for confetti
					; uses same plane but 10 positions
					;further down to create illusion of 
					;many confettis on screen
	addq.w	#8, a1
	dbra	d4,.sbbbplloop

	cmp.w	#0,d3
	beq.s	.sbblpend
	
	lea	XTRBPLPOINTERS, a1
	move.l	view_bufferconf, d1	;Bitplane position always top
	add.l   #TOPCONFETTI, d1	;of confetti
	add.w	#$2c, d5		;Waitpositions copper	
	subq.w	#1, d3

.sbbbpleloop:
	move.w	#$e0, d2	
	move.l	view_bufferconf, d1	;Bitplane position always top
	add.l   #TOPCONFETTI, d1	;of confetti
	move.b	d5, (a1)+		;Write wait position
	move.b  #$07, (a1)+ 
	move.w	#$fffe, (a1)+
	moveq	#4-1, d4						
.sbbbplbmplp:				;Write bplpointer for each bitmap
	cmp.w	#3-1, d4		;This bitplane are not used 
	bne.s	.sbbcontinue2		;by confetti so skip them
	move.w	#$f0, d2
.sbbcontinue2
	swap	d1
	move.w  d2, (a1)+
	move.w  d1, (a1)+
	swap	d1
	addq	#2, d2
	move.w	d2, (a1)+
	addq	#2, d2
	move.w	d1, (a1)+
	add.l	#OFFSETBPL*48, d1
	dbra	d4, .sbbbplbmplp
	add.w	#CONFETTILINES, d5	
	cmp.w	#$ff,d5			;Higher part of screen
	bls.s	.sbbcontinue3
	cmp.w	#0, d3
	beq	.sbbcontinue3		;Stop loop if end is reached already
	sub.w	#255, d5		;change to valid value (0 - 255)
	move.l	#$ffd9fffe,(a1)+	;Second half of screen reached needs
					;special wait line for copper
.sbbcontinue3
	dbra	d3,.sbbbpleloop
	move.l	#$fffffffe, (a1)				
.sbblpend:	
	;Set conventional bitplanes
	LEA	BPLPOINTERSBERN+32,A1	;1st 4 pointers already set
	;move.l	draw_buffer, d0
	;add.l	#48*512,d0

	move.w	d0,6(a1)		;Second bitplane is background 
	swap	d0			;Use normal buffer
	move.w	d0,2(a1)
	swap	d0		
	add.l	#48*512,d0
	addq.w	#8,a1

	move.w	d0,6(a1)		;Third bitplane is Scroller 
	swap	d0			;Use normal buffer
	move.w	d0,2(a1)
	swap	d0		
	add.l	#48*512,d0
	addq.w	#8,a1

	move.w	d0,6(a1)		;Fourth bitplane is Title 
	swap	d0			;Use normal buffer
	move.w	d0,2(a1)
	swap	d0		
	add.l	#48*512*4,d0
	addq.w	#8,a1

	move.w	d0,6(a1)		;Eight Bitplane stays empty
	swap	d0
	move.w	d0,2(a1)		;Use normal buffer
	swap	d0	

	rts

ScambiaBufferDance:
	move.l	draw_buffer,d0			; scambia il contenuto
	move.l	view_buffer,draw_buffer		; delle variabili
	move.l	d0,view_buffer			; in d0 c'e` l'indirizzo						; del nuovo buffer

	clr.l	d1	
        move.w  bpoffset(pc), d1                ; scrolling
        sub.l   d1, d0
        cmp.w   #0, d1
        beq     noscroll3
        
       	clr.l   d1
        move.w	scrollframe, d1
        cmp.w   #0, d1
	bne 	noscroll3

	;calculate new copper position
        lea     paletteset4, a1
        cmp.w   #$ffff, (a1)
        beq     checkpalette3
        cmp.b   #$ff,(a1)
        beq     ffreached
  	add.b   #1, (a1)      
ffreached:    					;copperposition ff reached   
        cmp.b   #$2a,4(a1)
        bne     setpalette4
        ;end of palette 4 
        move.w  #$ffff, (a1)
        jmp     checkpalette3
setpalette4:  
        add.b   #1, 4(a1)
checkpalette3:
        lea     paletteset3, a1
        cmp.w   #$ffff, (a1)                    ; end of screen already reached
        beq     checkpalette2
        cmp.b   #$ff,(a1)
        beq	ffreached2
        add.b   #1, (a1)
ffreached2:					;copperposition ff reached
        cmp.b   #$2a,4(a1)                       ; end of screen now reached
        bne     setpalette3     
        move.w  #$ffff, (a1)                    ; this is now the end of the cl
        jmp     checkpalette2
setpalette3:  
        add.b   #1, 4(a1)
checkpalette2:
	lea     paletteset2, a1
        cmp.w   #$ffff, (a1)                    ; end of screen already reached
        beq     checkpalette1  
        cmp.b   #$ff,(a1)
        beq	ffreached3
        add.b   #1, (a1)
ffreached3:					;copperposition ff reached
        cmp.b   #$2a,4(a1)                       ; end of screen now reached
        bne     setpalette2     
        move.w  #$ffff, (a1)                    ; this is now the end of the cl
        jmp    	checkpalette1
setpalette2:  
        add.b   #1, 4(a1)
checkpalette1:
	lea     paletteset1, a1
        cmp.w   #$ffff, (a1)                    ; end of screen already reached
        beq     noscroll3    
        cmp.b   #$ff,(a1)
        beq	ffreached4
        add.b   #1, (a1)
ffreached4:					;copperposition ff reached
        cmp.b   #$2a,4(a1)                       ; end of screen now reached
        bne     setpalette1     
        move.w  #$ffff, (a1)                    ; this is now the end of the cl
        jmp    	noscroll3
setpalette1:  
        add.b   #1, 4(a1)

noscroll3:     
; aggiorna la copperlist puntando i bitplanes del nuovo buffer da visualizzare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#8-1,D1		; numero di bitplanes
POINTBP2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#48*512,d0	; + lunghezza bitplane (qua e' alto 512 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP2

	rts

ScambiaBufferLogo:

	move.l	draw_buffer,d0			; scambia il contenuto
	move.l	view_buffer,draw_buffer		; delle variabili
	move.l	d0,view_buffer			; in d0 c'e` l'indirizzo						; del nuovo buffer
     
	; aggiorna la copperlist puntando i bitplanes del nuovo buffer da visualizzare
	LEA	LGBPLPOINTERS,A1	; puntatori COP
	MOVEQ	#8-1,D1		; numero di bitplanes
.sblpointbp:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#48*512,d0	; + lunghezza bitplane (qua e' alto 512 linee)
	addq.w	#8,a1
	dbra	d1,.sblpointbp

	rts


;****************************************************************************
; Questa routine crea l'animazione, spostando gli indirizzi dei fotogrammi
; in maniera che ogni volta il primo della tabella vada all'ultimo posto,
; mentra gli altri scorrono tutti di un posto in direzione del primo
;****************************************************************************


Animazione:
	addq.b	#1,ContaAnim    ; queste tre istruzioni fanno si' che il
	cmp.b	#4,ContaAnim    ; fotogramma venga cambiato una volta
	bne.s	NonCambiare     ; si e 3 no.
	clr.b	ContaAnim
	lea     frametabs(pc),a1   
	move.w  #BOBCOUNT-1,d6
loopframetabs:                  ; rotate frames for all bobs
        move.l  (a1)+, a0       
	;LEA	FRAMETAB(PC),a0 ; tabella dei fotogrammi
	MOVE.L	(a0),d0		; salva il primo indirizzo in d0
loopframes:
        move.l  4(a0),(a0)+
	cmp.l   #0,4(a0)
	bne     loopframes 
	move.l  d0, (a0)
	dbra    d6, loopframetabs
NonCambiare:
	rts

ContaAnim:
	dc.w	0

; Questa e` la tabella degli indirizzi dei fotogrammi. Gli indirizzi
; presenti nella tabella vengono "ruotati" all'interno della tabella dalla
; routine Animazione, in modo che il primo nella lista sia la prima volta il
; fotogramma1, la volta dopo il Fotogramma2, poi il 3, il 4 e di nuovo il
; primo, ciclicamente. In questo modo basta prendere l'indirizzo che sta
; all'inizio della tabella ogni volta dopo il "rimescolamento" per avere gli
; indirizzi dei fotogrammi in sequenza.

frametabpossum:
	dc.l	possumframe+10*10
	dc.l	possumframe+10*93+10*10
	dc.l	possumframe+10*93*2+10*10
	dc.l	possumframe+10*93*3
	dc.l	possumframe+10*93*4+10*10
	dc.l	possumframe+10*93*5+10*10
	dc.l	possumframe+10*93*6+10*10
	dc.l	possumframe+10*93*7+10*10
	dc.l	possumframe+10*93*8+10*10
	dc.l	possumframe2+10*10
	dc.l	possumframe2+10*93+10*10
	dc.l	0

frametabbuzzkill:
	DC.L	buzzkillframe
	DC.L	buzzkillframe+4*39
	DC.L	buzzkillframe+4*39*2
	DC.L	buzzkillframe+4*39*3
        DC.L	buzzkillframe+4*39*4
	DC.L	buzzkillframe+4*39*5
	DC.L	buzzkillframe+4*39*6
	DC.L	buzzkillframe+4*39*7
	DC.L	buzzkillframe+4*39*8
	DC.L	buzzkillframe+4*39*9	
	dc.l    0

frametabdk:
        DC.L	dkframe
	DC.L	dkframe+6*41
	DC.L	dkframe+6*41*2
	DC.L	dkframe+6*41*3
        DC.L	dkframe+6*41*4
	DC.L	dkframe+6*41*5
	DC.L	dkframe+6*41*6
	DC.L	dkframe+6*41*7
	DC.L	dkframe+6*41*8
	DC.L	dkframe+6*41*9
	DC.L	dkframe+6*41*10
	DC.L	dkframe+6*41*11
	DC.L	dkframe+6*41*12
	DC.L	dkframe+6*41*13
	DC.L	dkframe+6*41*14
	DC.L	dkframe+6*41*15
	DC.L	dkframe+6*41*16
	DC.L	dkframe+6*41*17
        DC.L	dkframe+6*41*18
        DC.L	dkframe+6*41*19
        dc.l    0

frametabwerewolf:
        DC.L	wereframe
	DC.L	wereframe+8*45
	DC.L	wereframe+8*45*2
	DC.L	wereframe+8*45*3
        DC.L	wereframe+8*45*4
	DC.L	wereframe+8*45*5
	DC.L	wereframe+8*45*6
	DC.L	wereframe+8*45*7
	dc.l    0

frametabhatman:
        DC.L	hatmanframe
	DC.L	hatmanframe+4*45
	DC.L	hatmanframe+4*45*2
	DC.L	hatmanframe+4*45*3
        DC.L	hatmanframe+4*45*4
	DC.L	hatmanframe+4*45*5
	DC.L	hatmanframe+4*45*6
	DC.L	hatmanframe+4*45*7
	dc.l    0


frametabugly:
        DC.L	uglyframe
	DC.L	uglyframe+4*31
	DC.L	uglyframe+4*31*2
	DC.L	uglyframe+4*31*3
        DC.L	uglyframe+4*31*4
	DC.L	uglyframe+4*31*5
	DC.L	uglyframe+4*31*6
	DC.L	uglyframe+4*31*7
	dc.l    0


frametabdisco:
	DC.L	discoframe
	DC.L	discoframe+4*46
	DC.L	discoframe+4*46*2
	DC.L	discoframe+4*46*3
        DC.L	discoframe+4*46*4
	DC.L	discoframe+4*46*5
	DC.L	discoframe+4*46*6
	DC.L	discoframe+4*46*7
	dc.l    0

frametabelisa:
	DC.L	elisaframe
	DC.L	elisaframe+6*42
	DC.L	elisaframe+6*42*2
	DC.L	elisaframe+6*42*3
        DC.L	elisaframe+6*42*4
	DC.L	elisaframe+6*42*5
	DC.L	elisaframe+6*42*6
	DC.L	elisaframe+6*42*7
	DC.L	elisaframe+6*42*8
	DC.L	elisaframe+6*42*9
	DC.L	elisaframe+6*42*10
	DC.L	elisaframe+6*42*11
	dc.l    0


frametabbatman:
	DC.L	batmanframe
	DC.L	batmanframe+6*48
	DC.L	batmanframe+6*48*2
	DC.L	batmanframe+6*48*3
        DC.L	batmanframe+6*48*4
	DC.L	batmanframe+6*48*5
	DC.L	batmanframe+6*48*6
        dc.l    0

frametabcowboy:
	DC.L	cowboyframe
	DC.L	cowboyframe+4*47
	DC.L	cowboyframe+4*47*2
	DC.L	cowboyframe+4*47*3
        DC.L	cowboyframe+4*47*4
	DC.L	cowboyframe+4*47*5
	DC.L	cowboyframe+4*47*6
	DC.L	cowboyframe+4*47*7
	DC.L	cowboyframe+4*47*8	
        dc.l    0

frametabexplorer:
	DC.L	explorerframe
	DC.L	explorerframe+6*57
	DC.L	explorerframe+6*57*2
	DC.L	explorerframe+6*57*3
        DC.L	explorerframe+6*57*4
	DC.L	explorerframe+6*57*5
	DC.L	explorerframe+6*57*6
	DC.L	explorerframe+6*57*7
	DC.L	explorerframe+6*57*8
	DC.L	explorerframe+6*57*9
	DC.L	explorerframe+6*57*10
	DC.L	explorerframe+6*57*11
        DC.L	explorerframe+6*57*12
	DC.L	explorerframe+6*57*13
	DC.L	explorerframe+6*57*14
	DC.L	explorerframe+6*57*15	      
        dc.l    0

frametabi8:
	DC.L	i8frame
	DC.L	i8frame+8*68
	DC.L	i8frame+8*68*2
	DC.L	i8frame+8*68*3
        DC.L	i8frame+8*68*4
	DC.L	i8frame+8*68*5
	DC.L	i8frame+8*68*6
	DC.L	i8frame+8*68*7
	DC.L	i8frame+8*68*8
	DC.L	i8frame+8*68*9
	DC.L	i8frame+8*68*10
	DC.L	i8frame+8*68*11
	dc.l    0

frametabbearded:
	DC.L	beardedframe
	DC.L	beardedframe+4*43
	DC.L	beardedframe+4*43*2
	DC.L	beardedframe+4*43*3
        DC.L	beardedframe+4*43*4
	DC.L	beardedframe+4*43*5
	DC.L	beardedframe+4*43*6
        DC.L	beardedframe+4*43*7
	DC.L	beardedframe+4*43*8
	DC.L	beardedframe+4*43*9
        DC.L	beardedframe+4*43*10
        DC.L	beardedframe+4*43*11
	dc.l    0

frametabcrab:
	DC.L	crabframe
	DC.L	crabframe+4*30
	DC.L	crabframe+4*30*2
	DC.L	crabframe+4*30*3
	dc.l    0

frametaboctobus:
	DC.L	octobusframe
	DC.L	octobusframe+4*30
	DC.L	octobusframe+4*30*2
	DC.L	octobusframe+4*30*3
        DC.L	octobusframe+4*30*4
        DC.L	octobusframe+4*30*5       
	dc.l    0

frametabjumper:
	DC.L	jumperframe
	DC.L	jumperframe+6*24
	DC.L	jumperframe+6*24*2
	DC.L	jumperframe+6*24*3      
	dc.l    0

frametabfish:
	DC.L	fishframe
	DC.L	fishframe+4*20
	DC.L	fishframe+4*20*2
	DC.L	fishframe+4*20*3
        DC.L	fishframe+4*20*4
        DC.L	fishframe+4*20*5      
	dc.l	fishframe+4*20*6
	dc.l	fishframe+4*20*7
	dc.l    0

frametabfishbig:
	DC.L	fishbigframe
	DC.L	fishbigframe+6*40
	DC.L	fishbigframe+6*40*2
	DC.L	fishbigframe+6*40*3
        DC.L	fishbigframe+6*40*4
        DC.L	fishbigframe+6*40*5
        DC.L	fishbigframe+6*40*6
        DC.L	fishbigframe+6*40*7
        dc.l    0

frametabseamonster:
	DC.L	seamonsterframe
	DC.L	seamonsterframe+8*33
	DC.L	seamonsterframe+8*33*2
	DC.L	seamonsterframe+8*33*3
        DC.L	seamonsterframe+8*33*4
        DC.L	seamonsterframe+8*33*5
        DC.L	seamonsterframe+8*33*6
        DC.L	seamonsterframe+8*33*7
	DC.L	seamonsterframe+8*33*8
	DC.L	seamonsterframe+8*33*9
        DC.L	seamonsterframe+8*33*10
        DC.L	seamonsterframe+8*33*11
        DC.L	seamonsterframe+8*33*12
        DC.L	seamonsterframe+8*33*13
        DC.L	seamonsterframe+8*33*14
	DC.L	seamonsterframe+8*33*15
        DC.L	seamonsterframe+8*33*16
        DC.L	seamonsterframe+8*33*17
        DC.L	seamonsterframe+8*33*18
        DC.L	seamonsterframe+8*33*19
        dc.l    0

frametabwi:
	DC.L	wiframe
	DC.L	wiframe+4*35
	DC.L	wiframe+4*35*2
	DC.L	wiframe+4*35*3
        DC.L	wiframe+4*35*4
        dc.l    0


frametabfishdart:
	DC.L	fishdartframe
	DC.L	fishdartframe+6*13
	DC.L	fishdartframe+6*13*2
	DC.L	fishdartframe+6*13*3
        DC.L	fishdartframe+6*13*4
        DC.L	fishdartframe+6*13*5              
	dc.l    0

frametaboldman:
	DC.L	oldmanframe
	DC.L	oldmanframe+4*39
	DC.L	oldmanframe+4*39*2
	DC.L	oldmanframe+4*39*3
        DC.L	oldmanframe+4*39*4
	DC.L	oldmanframe+4*39*5
	DC.L	oldmanframe+4*39*6
        DC.L	oldmanframe+4*39*7
        DC.L	oldmanframe+4*39*8
	DC.L	oldmanframe+4*39*9
        DC.L	oldmanframe+4*39*10
        DC.L	oldmanframe+4*39*11
	DC.L	oldmanframe+4*39*12
	DC.L	oldmanframe+4*39*12
	DC.L	oldmanframe+507*4*4
	DC.L	oldmanframe+507*4*4+4*39
	DC.L	oldmanframe+507*4*4+4*39*2
	DC.L	oldmanframe+507*4*4+4*39*3
	DC.L	oldmanframe+507*4*4+4*39*4
	DC.L	oldmanframe+507*4*4+4*39*5
	DC.L	oldmanframe+507*4*4+4*39*6
	DC.L	oldmanframe+507*4*4+4*39*7
	DC.L	oldmanframe+507*4*4+4*39*8
	DC.L	oldmanframe+507*4*4+4*39*9
	DC.L	oldmanframe+507*4*4+4*39*10
	DC.L	oldmanframe+507*4*4+4*39*11
	DC.L	oldmanframe+507*4*4+4*39*12	
	dc.l    0
        
frametabgirl:
	DC.L	girlframe
	DC.L	girlframe+4*51
	DC.L	girlframe+4*51*2
	DC.L	girlframe+4*51*3
        DC.L	girlframe+4*51*4
	DC.L	girlframe+4*51*5
	DC.L	girlframe+4*51*6
	DC.L	girlframe+4*51*7
	DC.L	girlframe+4*51*8
	DC.L	girlframe+4*51*9
	DC.L	girlframe+4*51*10
	DC.L	girlframe+4*51*11
	DC.L	girlframe+4*51*12
	DC.L	girlframe+4*51*13
	DC.L	girlframe+4*51*14
	DC.L	girlframe+4*51*15	      
        dc.l    0

frametabrobo:
	DC.L	roboframe
	DC.L	roboframe+8*82
	DC.L	roboframe+8*82*2
	DC.L	roboframe+8*82*3
        DC.L	roboframe+8*82*4
	DC.L	roboframe+8*82*5
	DC.L	roboframe+8*82*6
	DC.L	roboframe+8*82*7
	DC.L	roboframe+8*82*8
        dc.l    roboframe+8*82*9
	DC.L	roboframe+8*82*10
	DC.L	roboframe+8*82*11
        dc.l    0

frametabxeon:
	DC.L	xeonframe
	DC.L	xeonframe+12*64
	DC.L	xeonframe+12*64*2
	DC.L	xeonframe+12*64*3
        DC.L	xeonframe+12*64*4
	DC.L	xeonframe+12*64*5
	DC.L	xeonframe+12*64*6
	DC.L	xeonframe+12*64*7
	DC.L	xeonframe+12*64*8
	DC.L	xeonframe+12*64*9
	DC.L	xeonframe+12*64*10
	DC.L	xeonframe+12*64*11
	DC.L	xeonframe+12*64*12
	DC.L	xeonframe+12*64*13
	DC.L	xeonframe+12*64*14
	DC.L	xeonframe+12*64*15
	DC.L	xeonframe+12*64*16
	DC.L	xeonframe+12*64*17
	DC.L	xeonframe+12*64*18
	DC.L	xeonframe+12*64*19
	DC.L	xeonframe+12*64*20
	DC.L	xeonframe+12*64*21
	DC.L	xeonframe+12*64*22
	DC.L	xeonframe+12*64*23
      	dc.l    0

frametabs:
        dc.l frametabbuzzkill,frametabbatman,frametabcowboy,frametabdisco
        dc.l frametabexplorer,frametabgirl
        dc.l frametabpossum,frametabi8,frametabrobo,frametabxeon

	dc.l frametabcrab,frametaboctobus,frametabjumper,frametabfishdart
        dc.l frametabfish,frametabfishbig,frametabseamonster

	dc.l frametabwerewolf,frametabugly,frametabelisa
        dc.l frametabbearded,frametabhatman,frametaboldman,frametaboldman
endframetabs:
  

;***************************************************************************
; Questa e` la routine universale per disegnare bob di forma e dimensioni
; arbitrarie. Tutti i parametri sono passati tramite registri.
; La routine funziona su schermo INTERLEAVED
;
; A0 - indirizzo figura bob
; A1 - indirizzo maschera bob
; A6 - address bitplane
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
; D7 - height one bitplane containing all frames
;****************************************************************************

;	       ___  Oo          .:/
;	      (___)o_o        ,,///;,   ,;/
;	 //====--//(_)       o:::::::;;///
;	         \\ ^       >::::::::;;\\\
;	                      ''\\\\\'" ';\

UniBob:

; calcolo indirizzo di partenza del blitter

	mulu.w	#48,d1	        ; calcola indirizzo: ogni riga e` costituita da
				; 2 planes di 48 bytes ciascuno
	add.l	d1,a6		; aggiungi ad indirizzo
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a6		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	move.l	#$000009f0,d5		; copia per calcolare il valore di BLTCON0 

; calcolo modulo blitter

	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari) 
	move.w	#48,d4		; larghezza schermo in bytes
	sub.w	d2,d4		; modulo=larg. schermo-larg. rettangolo
	move.w  d2,d0
        mulu    d7,d2           ; multiplicate with height of plane
; calcolo dimensione blittata

	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d0		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d0,d3		; metti insieme le dimensioni

; inizializza i registri
	btst	#6,2(a5)
WBlit_u4:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	WBlit_u4

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word

	move.w	d5,$40(a5)		; BLTCON0 - valore di shift 0
					; copy a to d

	move.l	#$0000,$62(a5)	        ; BLTBMOD e BLTAMOD=0 torna
					; indietro all'inizio della riga

	move.w	d4,$66(a5)		; BLTDMOD valore calcolato

        move.w  #4-1,d0
loopplane2:
        btst    #6, 2(a5)
wblit_u2:
        btst    #6, 2(a5)
        bne     wblit_u2

	move.l	a0,$50(a5)		; BLTAPT  Bob
	move.l	a6,$54(a5)		; BLTDPT  (linee di schermo)
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

        add.l   d2,a0 
        lea     48*512(a6),a6 
        dbra    d0, loopplane2
	rts

;***************************************************************************
; Questa e` la routine universale per disegnare bob di forma e dimensioni
; arbitrarie. Tutti i parametri sono passati tramite registri.
; La routine funziona su schermo normale
;
; A0 - indirizzo figura bob
; A1 - indirizzo maschera bob
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
;****************************************************************************

UniBobFull:

; calcolo indirizzo di partenza del blitter

	move.l	draw_buffer(pc),a2	;address of bitplane
	add.l	#48*512*7, a2		;p
	mulu.w	#48,d1		; offset Y
	add.l	d1,a2		; aggiungi ad indirizzo
	move.w	d0,d6		; copia la X
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a2		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	and.w	#$000f,d6	; si selezionano i primi 4 bit della X perche'
				; vanno inseriti nello shifter dei canali A,B 
	lsl.w	#8,d6		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d6		; della word. Questo e` il valore di BLTCON1

	move.w	d6,d5		; copia per calcolare il valore di BLTCON0 
	or.w	#$0FCA,d5	; valori da mettere in BLTCON0

; calcola offset tra i planes della figura
	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	move.w	d2,d0		; copia larghezza divisa per 8
	mulu	d3,d2		; moltiplica per l'altezza

; calcolo modulo blitter

	addq.w	#2,d0		; la blittata e` una word piu` larga 
	move.w	#48,d4		; larghezza schermo in bytes
	sub.w	d0,d4		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata

	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d0		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d0,d3		; metti insieme le dimensioni

; inizializza i registri che restano costanti
	btst	#6,2(a5)
WBlit_u5:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	WBlit_u5

	move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word

	move.w	d6,$42(a5)		; BLTCON1 - valore di shift
					; nessun modo speciale

	move.w	d5,$40(a5)		; BLTCON0 - valore di shift
					; cookie-cut

	move.l	#$fffefffe,$62(a5)	; BLTBMOD e BLTAMOD=$fffe=-2 torna
					; indietro all'inizio della riga.

	move.w	d4,$60(a5)		; BLTCMOD valore calcolato
	move.w	d4,$66(a5)		; BLTDMOD valore calcolato

	;moveq	#1-1,d7			; ripeti per ogni plane
PlaneLoop:
	btst	#6,2(a5)
WBlit_u6:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.w	wblit_u6


	move.l	a1,$50(a5)		; BLTAPT  (maschera)
	move.l	a2,$54(a5)		; BLTDPT  (linee di schermo)
	move.l	a2,$48(a5)		; BLTCPT  (linee di schermo)
	move.l	a0,$4c(a5)		; BLTBPT  (figura bob)
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

	add.l	d2,a0			; punta al prossimo plane sorgente

	lea	48*256(a2),a2		; punta al prossimo plane destinazione
	;dbra	d7,PlaneLoop

	rts


;****************************************************************************
; Questa routine stampa un carattere. Il carattere viene stampato in una
; parte di schermo invisibile.
; A0 punta al testo da stampare.
;****************************************************************************

printReflection:
;copy reflected area
	moveq	#2-1,d7			; 2 bit-plane
	lea     bpprepare+40*48, a0
	move.l  draw_buffer(pc), a1
	add.l   #40*48,a1

	;move.w	MascheraX(PC),d0 ; posizione riflettore
	move.w	d0,d2		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	or.w	#$0dc0,d0	; ...giusti per inserirsi nel registro BLTCON0
				; notate LF=$C0 (cioe` AND tra A e B)
	lsr.w	#3,d2		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d2	; escludo il bit 0 del
	add.w	d2,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto nella figura
	add.w	d2,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

Drawloop:
	btst	#6,2(a5) ; dmaconr
WBlit5:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	WBlit5

	move.l	#$ffffffff,$44(a5)	; maschere
	move.w	d0,$40(a5)		; BLTCON0
	move.w	#$0000,$42(a5)		; BLTCON1 modo ascendente
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#40,$62(a5)		; BLTBMOD (42-8)
	move.w	#40,$66(a5)		; BLTDMOD (42)

	move.l	#Maschera,$50(a5)	; BLTAPT  puntatore maschera
	move.l	a0,$4c(a5)		; BLTBPT  puntatore figura
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*39)+4,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 4 word
					; altezza 39 linee

	add.l	#48*256,a0		; ind. prossimo plane figura
	add.l	#48*512,a1		; ind. prossimo plane destinazione
	dbra	d7,Drawloop

;add color of reflector light
        sub.l   #48*512, a1         ; move back to start pos of bitplane

        and.w   #$f000,d0       ; reset MINTERMS
        or.w	#$0fd0,d0	; only set color if all bitplanes are 0    
        move.l  a1, a2          
        add.l   #48*512, a2         ; address of second bitplane

        btst	#6,2(a5) ; dmaconr
wblit7:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit7

	move.l	#$ffffffff,$44(a5)	; maschere
	move.w	d0,$40(a5)		; BLTCON0
	move.w	#$0000,$42(a5)		; BLTCON1 modo ascendente
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#40,$62(a5)		; BLTBMOD (42-8)
	move.w  #40,$60(a5)             ; BLTCMOD (42-8)
	move.w	#40,$66(a5)		; BLTDMOD (42-8)

	move.l	#Maschera,$50(a5)	; BLTAPT  puntatore maschera
	move.l	a1,$4c(a5)		; BLTBPT  bitplane 1 on screen
	move.l  a2,$48(a5)              ; BLTCPT  bitplane 2 on screen
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*39)+4,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 4 word
					; altezza 39 linee


	rts

reflpos:
 		dc.w	90,12,0,0	; posizione attuale maschera

refldir:
		dc.b	0,0,0,0
	        
TABXPOINT:
		dc.l	TABX	; puntatore alla tabella

TABXPOINT2:
                dc.l    TABX+200


; tabella posizioni maschera

TABX:
	DC.W	$12,$16,$19,$1D,$21,$25,$28,$2C,$30,$34
	DC.W	$37,$3B,$3F,$43,$46,$4A,$4E,$51,$55,$58
	DC.W	$5C,$60,$63,$67,$6A,$6E,$71,$74,$78,$7B
	DC.W	$7F,$82,$85,$89,$8C,$8F,$92,$95,$98,$9C
	DC.W	$9F,$A2,$A5,$A8,$AA,$AD,$B0,$B3,$B6,$B8
	DC.W	$BB,$BE,$C0,$C3,$C5,$C8,$CA,$CC,$CF,$D1
	DC.W	$D3,$D5,$D8,$DA,$DC,$DE,$E0,$E1,$E3,$E5
	DC.W	$E7,$E8,$EA,$EC,$ED,$EE,$F0,$F1,$F2,$F4
	DC.W	$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FB,$FC,$FD
	DC.W	$FD,$FE,$FE,$FF,$FF,$FF,$100,$100,$100,$100
	DC.W	$100,$100,$100,$100,$FF,$FF,$FF,$FE,$FE,$FD
	DC.W	$FD,$FC,$FB,$FB,$FA,$F9,$F8,$F7,$F6,$F5
	DC.W	$F4,$F2,$F1,$F0,$EE,$ED,$EC,$EA,$E8,$E7
	DC.W	$E5,$E3,$E1,$E0,$DE,$DC,$DA,$D8,$D5,$D3
	DC.W	$D1,$CF,$CC,$CA,$C8,$C5,$C3,$C0,$BE,$BB
	DC.W	$B8,$B6,$B3,$B0,$AD,$AA,$A8,$A5,$A2,$9F
	DC.W	$9C,$98,$95,$92,$8F,$8C,$89,$85,$82,$7F
	DC.W	$7B,$78,$74,$71,$6E,$6A,$67,$63,$60,$5C
	DC.W	$58,$55,$51,$4E,$4A,$46,$43,$3F,$3B,$37
	DC.W	$34,$30,$2C,$28,$25,$21,$1D,$19,$16,$12
FINETABX:

PRINTCHAR:
        lea     scrpos, a0        ;switch scroller position
        move.l  (a0),d0           ;for the right buffer
        lea     scrpos2, a1
        move.l  (a1),(a0)
        move.l  d0, (a1) 
        move.l  scrpos(pc),a0    

        lea     contatore, a3     ;switch counter 1 and counter2
        move.w  (a3),d0           ;separate counter required because of dbuffer
        lea     contatore2,a4
        move.w  (a4), (a3)
        move.w  d0,(a4)
	subq.w	#1,(a3)		; diminuisci il contatore di 1
	bne.s	NoPrint		; se e` diverso da 0, non stampiamo,
	move.w	#8,(a3)		; altrimenti si; reinizializza il contatore

	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	bne.s	noreset		; Se e` diverso da 0 stampalo,
	lea     scrpos, a0 	;switch scroller position
        move.l  #testo, (a0)    ;for the right buffer
        lea     scrpos2, a1
        move.l  #testo, (a1) 
        move.l  scrpos(pc),a0    

	MOVE.B	(A0)+,D2	; Primo carattere in d2
noreset:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	ADD.L	D2,D2		; MOLTIPLICA PER 2 IL NUMERO PRECEDENTE,
				; perche` ogni carattere e` largo 16 pixel
	MOVE.L	D2,A2

	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	btst	#6,$02(a5)	; aspetta che il blitter finisca
	move.l  draw_buffer(pc),a1
	add.l   #48*512*1+150*48+40,a1
waitblit:
	btst	#6,$02(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0: copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

	move.l	a2,$50(a5)			; BLTAPT: indirizzo font
	move.l	a1,$54(a5)	; BLTDPT: indirizzo bitplane
						; fisso, fuori dalla parte
						; visibile dello schermo.
	move	#120-2,$64(a5)			; BLTAMOD: modulo font
	move	#48-2,$66(a5)			; BLTDMOD: modulo bit planes
	move	#(20<<6)+1,$58(a5) 		; BLTSIZE: font 16*20
	move.l  a0,scrpos
NoPrint:
	rts

contatore
	dc.w	8
contatore2:
        dc.w    8

firstshift:
        dc.b    1;     decides wether to move scroll 1 or two pixels
                       ;depending on the buffer use
        even

STAMPA:
        ;lea     title,a0

	MOVEQ	#1-1,D3	; NUMERO RIGHE DA STAMPARE: 10

PRINTRIGA:
	MOVEQ	#20-1,D0	; NUMERO COLONNE PER RIGA: 20

PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	ADD.L	D2,D2		; MOLTIPLICA PER 2 IL NUMERO PRECEDENTE,
				; perche` ogni carattere e` largo 16 pixel.
				; In questo modo troviamo l'offset.
	MOVE.L	D2,A2

	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	btst	#6,$02(a5)	; aspetta che il blitter finisca
waitblit5:
	btst	#6,$02(a5)
	bne.s	waitblit5

	move.l	#$09f00000,$40(a5)	; BLTCON0: copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

	move.l	a2,$50(a5)	; BLTAPT: indirizzo font (sorgente A)
	move.l	a3,$54(a5)	; BLTDPT; indirizzo bitplane (destinazione D)
	move	#120-2,$64(a5)	; BLTAMOD: modulo font
	move	#48-2,$66(a5)	; BLTDMOD: modulo bit planes
	move	#(20<<6)+1,$58(a5) ; BLTSIZE: 16 pixel, ossia 1 word di larg.
				   ; * 20 linee di altezza. Da notare che per
				   ; shiftare il 20 si e' usato il comodo
				   ; simbolo <<, che shifta a sinistra.
				   ; (20<<6) e' equivalente a (20*64).

	ADDQ.w	#2,A3		; A3+2,avanziamo di 16 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (20) CARATTERI PER RIGA

        ADD.W	#40*19,A3	; ANDIAMO A CAPO
				; ci spostiamo in basso di 19 righe.

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE


	RTS

creditszool:
	dc.b " Zool by Gremlin Graphics "
	dc.b "  Ripped by shadowman44   "	
	dc.b "                          " 
	dc.b 0,0

creditsmario:
	dc.b " Mario World  by Nintendo "
	dc.b "   Ripped by MISTER MAN   "
	dc.b "                          "
	dc.b 0,0

creditsflashback:
	dc.b "   Flashback by U.S Gold  "
        dc.b "   Ripped by LuigiBlood   "
	dc.b "                          "
	dc.b 0,0

creditsdkc:
	dc.b "    Donkey Kong Country   "
	dc.b "        by Rareware       "
	dc.b "     Ripped by Frario,    "	
	dc.b "  Ant19831983, A.J Nitro, "
	dc.b "        Tonberry2k,       "     
	dc.b "   and RandomTalkingBush  "
	dc.b "                          "
	dc.b 0,0

creditsmi:
	dc.b "    Monkey Island 1 & 2   "
	dc.b "    Ripped by ULTIMECIA   "
	dc.b "                          "
	dc.b 0,0

creditszelda:
	dc.b "    The Legend of Zelda   "
	dc.b "     Ripped by daemoth    " 
	dc.b "        and Unknown       "
	dc.b "                          "
	dc.b 0,0

;A2	->	Address to print


STAMPA2:
	MOVEQ	#1-1,D3	; NUMERO RIGHE DA STAMPARE: 10

	btst	#6,2(a5)		; aspetta che il blitter finisca
st2wblit:
	btst	#6,2(a5)
	bne.s	st2wblit

PRINTRIGA2:
	MOVEQ	#26-1,D0	; NUMERO COLONNE PER RIGA: 26
	MOVE.l   #0, D5
PRINTCHAR3:

	MOVE.l	#0,D2		; Pulisci d2
	MOVE.B	(A2)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...

	move.l	#0, a6		;Fetch width of next character
	move.l	d2, a6
	add.l	#font2distance, a6	

	LSL  	#4,D2		;Fetch next char
	MOVE.L	D2,A4


	move.l  #0,d4
	ADD.L	#font2,A4	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	move.w  (a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l	d4, (a3)
	clr.l	d4
	move.w  2(a4), d4
	swap.w  d4
	lsr.l	d5, d4
	or.l	d4, 48(a3)
	clr.l	d4
	move.w  4(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l  	d4, 48*2(a3)
	clr.l	d4
	move.w  6(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l	d4, 48*3(a3)
	clr.l	d4
	move.w  8(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l  	d4, 48*4(a3)
	clr.l	d4	
	move.w  10(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l  	d4, 48*5(a3)
	clr.l	d4
	move.w  12(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l  	d4, 48*6(a3)
	clr.l	d4
	move.w  14(a4), d4
	swap	d4
	lsr.l	d5, d4
	or.l  	d4, 48*7(a3)    
	clr.l	d4

	add.b   (a6), d5
	;add.w   #5,d5
	cmp.w   #8,d5
	bcs	noadditionalchar
	addq.w  #1, a3
	sub.w   #8,d5

noadditionalchar:
	ADDQ.w	#1,A3		; A3+2,avanziamo di 16 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR3	; STAMPIAMO D0 (20) CARATTERI PER RIGA

        ADD.W	#40*19,A3	; ANDIAMO A CAPO
				; ci spostiamo in basso di 19 righe.

	DBRA	D3,PRINTRIGA2	; FACCIAMO D3 RIGHE


	RTS

Scorri:

; Gli indirizzi sorgente e destinazione sono uguali.
; Shiftiamo verso sinistra, quindi usiamo il modo discendente.
        move.l  draw_buffer(pc),d0
        add.l   #48*512*1+((24*(150+20))-1)*2,d0	; ind. sorgente e
        
ScorriLoop:
	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit2:
	btst	#6,2(a5)
	bne.s	waitblit2

        lea     firstshift, a0
        btst    #0, (a0)
        bne     notfirst                     ;first shift = 1
        bchg    #0, (a0)
        move.w  #$19f0, $40(a5)         
        jmp     first
notfirst: 
        move.w  #$29f0, $40(a5)         ;shift 2
first:
	move.w	#$0002,$42(a5)	        ; BLTCON1 - copia da A a D
					; con shift di un pixel

	move.l	#$ffff7fff,$44(a5)	; BLTAFWM e BLTALWM
					; BLTAFWM = $ffff - passa tutto
					; BLTALWM = $7fff = %0111111111111111
					;   cancella il bit piu` a sinistra

; carica i puntatori

	move.l	d0,$50(a5)			; bltapt - sorgente
	move.l	d0,$54(a5)			; bltdpt - destinazione

; facciamo scorrere un immagine larga tutto lo schermo, quindi
; il modulo e` azzerato.

	move.l	#$00000000,$64(a5)		; bltamod e bltdmod 
	move.w	#(20*64)+24,$58(a5)		; bltsize
						; altezza 20 linee, largo 21
	rts					; words (tutto lo schermo)





;****************************************************************************
; Questa routine realizza l'effetto sine-scroll. Attenzione a BLTALWM, perche'
; e' il registro dove ogni volta selezioniamo la "fettina" o "striscina"
; verticale su cui operare. Qua ci sono le differenze con il sine da 2 pixel!
;****************************************************************************

;	  ,-~~-.___.
;	 / |  '     \
;	(  )         0
;	 \_/-, ,----'
;	    ====           //
;	   /  \-'~;    /~~~(O)
;	  /  __/~|   /       |
;	=(  _____| (_________|   W<

Sine:
	lea	buffer,a2		; puntatore al buffer contenente
					; lo scrolltext
	move.l	draw_buffer(pc),a1		; puntatore alla destinazione
	add.l   #48*512*2,a1              ; change second bitplane

	move.l	SinusPtr(pc),a3		; indirizzo primo valore seno (*42)
	subq.w	#2,a3			; modifica primo valore
	cmp.l	#Sinustab,a3		; se siamo all'inizio della tabella
	bhs.s	nostartptr		; ricomincia dalla fine
	lea	EndSinustab(pc),a3
nostartptr:
	move.l	a3,SinusPtr		; memorizza primo valore usato

	move.w	#$8000,d5		; valore iniziale maschera
	moveq	#20-1,d6		; ripeti per tutte le word dello schero
FaiUnaWord:
	moveq	#16-1,d7		; routine da 1 pixel. Per ogni word
					; ci sono 16 "fettine" da 1 pixel

FaiUnaColonna:
	move.w	(a3)+,d0		; legge un valore dalla tabella
	sub.w   #48*120,d0              ; move up sine effect
	cmp.l	#EndSinustab,a3		; se siamo alla fine della tabella
	blo.s	nostartsine		; ricomincia da capo
	lea	Sinustab(pc),a3
nostartsine:
	move.l	a1,a4			; copia indirizzo bitplane
	add.w	d0,a4			; aggiunge la coordnata Y

	btst	#6,2(a5)	; dmaconr - aspetta che il blitter finisca
waitblit_sine:
	btst	#6,2(a5)
	bne.s	waitblit_sine

	move.w	#$ffff,$44(a5)		; BLTAFWM
	move.w	d5,$46(a5)		; BLTALWM - contiene la maschera che
					; seleziona le "fettine" di scrolltext
		
	move.l	#$0bfa0000,$40(a5)	; BLTCON0/BLTCON1 - attiva A,C,D
					; D=A OR C

	move.w	#46,$60(a5)		; BLTCMOD=42-2=$28
 	move.l	#$002e002e,$64(a5)	; BLTAMOD=42-2=$28
					; BLTDMOD=84-2=$52 (jump 1 bitplane)

	move.l	a2,$50(a5)		; BLTAPT  (al buffer)
	move.l	a4,$48(a5)		; BLTCPT  (allo schermo)
	move.l	a4,$54(a5)		; BLTDPT  (allo schermo)
	move.w	#(64*20)+1,$58(a5)	; BLTSIZE (blitta un rettangolo
					; alto 20 righe e largo 1 word)

	ror.w	#1,d5			; spostati alla "fettina" successiva
					; va a destra e dopo l'ultima "fettina"
					; di una word ricomincia dalla prima
					; della word seguente.
					; per lo scroll da 1 pixel ogni
					; "fettina" e` larga 1 pixel

	dbra	d7,FaiUnaColonna

	addq.w	#2,a2			; punta alla word seguente
	addq.w	#2,a1			; punta alla word seguente
	dbra	d6,FaiUnaWord
	rts

; Questo e` il testo. con lo 0 si termina. Il font usato ha solo i caratteri
; maiuscoli, attenzione!

testo:
	dc.b	" EMUFR3AK PRESENTS    BERN PARTIES AGAIN     "
	dc.b	" GREETINGS AND THANKS GO TO... "
	dc.b    " RAMJAM FOR THE WORLD BEST ASM COURSE "
	dc.b    " BUENZLI FOR REVIVING THE SCENE IN SWITZERLAND "
	dc.b    " GHOSTOWN TBL SPACEBALLS FOR INSPIRING ME AND "
	dc.b    " ALL THE PEOPLE WORKING ON UNFORGETTABLE "
	dc.b	" GAMES "
	dc.b    "    ", 0            
	even

;****************************************************************************
; Questa routine disegna un rettangolo sullo schermo.
;
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
; D4 - "pattern" con cui disegnare un rettangolo
;****************************************************************************

;	             |\__/,|   (`\
;	             |o o  |__ _) )
;	           _.( T   )  `  /
;	 n n._    ((_ `^--' /_<  \
;	 <" _ }=- `` `-'(((/  (((/
;	  `" "

BlitRett:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	WBlit1

; calcolo indirizzo di partenza del blitter

	;lea	bitplane1,a1	; indirizzo bitplane
	mulu.w	#48,d1
			; offset Y
	add.l	d1,a6		; aggiungi ad indirizzo
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a6		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

; calcolo modulo blitter

	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	move.w	#48,d0		; larghezza schermo in bytes
	sub.w	d2,d0		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata

	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d2		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d2,d3		; metti insieme le dimensioni

; carica i registri

	move.l	#$01f00000,$40(a5)	; BLTCON0 e BLTCON1
					; usa SOLO il canale D
					; LF=$F0 (copia da A a D)
					; modo ascendente
	move.l	#$ffffffff,$44(a5)

	move.w	d4,$74(a5)		; BLTADAT
	move.w	d0,$66(a5)		; BLTDMOD
	move.l	a6,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

	rts

;****************************************************************************
; Clears one bitplane
; 
; d0: startrow
; d1: number of rows
; d2: destination address
; d3: size rows
;****************************************************************************

ClearPlane:
	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	WBlit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0000,$66(a5)          ; BLTDMOD=0
	mulu.w  #48,d0                ; calculate start with startrow in d0
	add.l   d0, d2
	
	lsl.l   #6, d1                  ; multiply with 64
	add.l   #24,d1                  ; add wordsize

loopplane3:
        btst    #6,2(a5)
wblit9:
        btst    #6,2(a5)
        bne     wblit9
        
        move.l	d2,$54(a5)	        ; BLTDPT
	move.w	d1,$58(a5)	        ; BLTSIZE (via al blitter !)
					; cancella dalla riga 130
	rts

FillPlane:
	btst	#6,2(a5)
WBlit8:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	WBlit8

	move.l	#$01f00000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0000,$66(a5)          ; BLTDMOD=0
	mulu.w  #48,d0                  ; calculate start with startrow in d0
	add.l   d0, d2
	
	lsl.l   #6, d1                  ; multiply with 64
	add.l   #24,d1                  ; add wordsize
        
	move.w 	#$ffff, $74(a5)	
        move.l	d2,$54(a5)	        ; BLTDPT
	move.w	d1,$58(a5)	        ; BLTSIZE (via al blitter !)
					; cancella dalla riga 130
	rts



;****************************************************************************
; Routine to delete Rectangular Area on Screen;
; 
; D0 - xpos
; D1 - ypos
; D2 - Width
; D3 - Height
; A1 - Start of Target Plane		
;****************************************************************************


ClearRect:
; calculate Startaddress of Blitter

	mulu.w	#48,d1		; offset Y
	add.l	d1,a1		; Add Y offset in Bytes 
	lsr.w	#3,d0		; divide x through eight to get bytes 
	and.w	#$fffe,d0	; Round to even
	add.w	d0,a1		; Add to startaddress

; calcola offset tra i planes della figura
	lsr.w	#3,d2		; divide width through 8 to get bytes
	and.w	#$fffe,d2	; round to even
	addq.w	#2,d2		; Blitwidth needs to be 1 word higher
	move.w	d2,d0		; copy effective Blitwidth
	mulu	d3,d0		; multiplicate width height to get Bltsize

; calcolo modulo blitter
	move.w	#48,d4		; Width of plane in bytes
	sub.w	d2,d4		; minus blitwidth equals modulo to skip

; calcolo dimensione blittata
	lsl.w	#6,d3		; Shift height to right register
	lsr.w	#1,d2		; Width in Pixel divided width 16
				; to get Words
	or	d2,d3		; Registervalue for Bltsize

	moveq	#1-1,d7		; Only one plane
PlaneLoop2:
	btst	#6,2(a5) ; dmaconr
WBlit4:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	WBlit4

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff delete all
					; BLTALWM = $ffff delete all

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1 set to delete
	move.w	d4,$66(a5)		; BLTDMOD set to calculated value
	move.l	a1,$54(a5)		; Startaddress for blitter to delete
	move.w	d3,$58(a5)		; Set BLTSIZE and start blit

	lea	48*512(a1),a1		; punta al prossimo plane sorgente
	add.l	d0,a2			; punta al prossimo plane destinazione

	dbra	d7,PlaneLoop2

	rts




;****************************************************************************
; Clears whole screen
; 
; d0: startrow
; d1: size in rows
 ; d2: destination address
;****************************************************************************

ClearScreen:
	btst	#6,2(a5)
WBlit6:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	WBlit6

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0000,$66(a5)          ; BLTDMOD=0
	mulu.w  #48,d0                  ; calculate start with startrow in d0
	add.l   d0, d2
	move.l	d2,$54(a5)	        ; BLTDPT
	lsl.l   #6, d1                  ; multiply with 64
	add.l   #21,d1                  ; add wordsize

        move.w  #2-1, d0
loopplane4:
        btst    #6, 2(a5)
wblit10:
        btst    #6, 2(a5)
        bne     wblit10 	
        
	move.l	d2,$54(a5)	        ; BLTDPT
	move.w	d1,$58(a5)	        ; BLTSIZE (via al blitter !)
					; cancella dalla riga 130
					; fino alla riga 193
       
        add.l   48*512, d2              ; point to next bitplane
        dbra    d0,loopplane4
        
	rts


;***************************************************************************

; questo puntatore contiene l'indirizzo del primo valore da leggere dalla
; tabella

SinusPtr:	dc.l	Sinustab

; Questa e` la tabella che contiene i valori delle posizioni verticali
; dello scrolltext. Le posizioni sono gia` moltiplicate per 42, quindi
; possono essere addizionate direttamente all'indirizzo del BITPLANE

Sinustab:
	DC.W	$189C,$18C6,$18F0,$191A,$1944,$196E,$1998,$19C2
	DC.W    $19C2,$19EC
	DC.W	$1A16,$1A40,$1A6A,$1A6A,$1A94,$1ABE,$1ABE,$1AE8
	DC.W    $1B12,$1B12
	DC.W	$1B3C,$1B3C,$1B66,$1B66,$1B90,$1B90,$1BBA,$1BBA
	DC.W    $1BBA,$1BBA
	DC.W	$1BE4,$1BE4,$1BE4,$1BE4,$1BE4,$1BE4,$1BE4,$1BE4
	DC.W    $1BE4,$1BE4
	DC.W	$1BBA,$1BBA,$1BBA,$1BBA,$1B90,$1B90,$1B66,$1B66
	DC.W    $1B3C,$1B3C
	DC.W	$1B12,$1B12,$1AE8,$1ABE,$1ABE,$1A94,$1A6A,$1A6A
	dc.w    $1A40,$1A16
	DC.W	$19EC,$19C2,$19C2,$1998,$196E,$1944,$191A,$18F0
	dc.w    $18C6,$189C
	DC.W	$189C,$1872,$1848,$181E,$17F4,$17CA,$17A0,$1776
	dc.w    $1776,$174C
	DC.W	$1722,$16F8,$16CE,$16CE,$16A4,$167A,$167A,$1650
	dc.w    $1626,$1626
	DC.W	$15FC,$15FC,$15D2,$15D2,$15A8,$15A8,$157E,$157E
	dc.w    $157E,$157E
	DC.W	$1554,$1554,$1554,$1554,$1554,$1554,$1554,$1554
	dc.w    $1554,$1554
	DC.W	$157E,$157E,$157E,$157E,$15A8,$15A8,$15D2,$15D2
	dc.w    $15FC,$15FC
	DC.W	$1626,$1626,$1650,$167A,$167A,$16A4,$16CE,$16CE
	dc.w    $16F8,$1722
	DC.W	$174C,$1776,$1776,$17A0,$17CA,$17F4,$181E,$1848
	dc.w    $1872,$189C
EndSinustab:

PalettePic:
	dc.l	$000050,$b00000,$303090,$000050,$800000,$3050d0
	dc.l	$0050b0,$f06010,$e0a010,$005000,$c08000,$f0f0f0
	dc.l    $109030,$e0e0e0,$c00000,$000000

wbltarget:
	dc.w	$00,$00,$00,$11,$11,$11,$11,$22,$22,$22
	dc.w	$33,$33,$44,$44,$55,$66,$77,$88,$88,$99
	dc.w	$99,$aa,$aa,$aa,$99,$99,$88,$88,$77,$66
	dc.w	$55,$44,$44,$33,$33,$22,$22,$22,$11,$11
	dc.w	$11,$11,$00,$00,$00,$00
	
;****************************************************************************

	SECTION	GRAPHIC,DATA_C

	CNOP 0,8
        dcb.b   48*100,0
bpbern1:	
        incbin  bpa:srcraw/background384*512*3.raw
	incbin  bpa:srcraw/backgroundbp4384*512*1.raw
	dcb.b   48*512*4,0     ;other bitplanes for both screens


	CNOP 0,8
        dcb.b   48*100,0
bpbern2:
        incbin  bpa:srcraw/background384*512*3.raw
	incbin  bpa:srcraw/backgroundbp4384*512*1.raw
        dcb.b   48*512*4,0     ;other bitplanes for both screens

bpprepare:
        dcb.b   48*256*6,0



COPPERLISTLOGO:

        ;Sprpointers
        dc.w    $120,0,$122,0,$124,0,$126,0,$128,0,$12a,0
        dc.w    $12c,0,$12e,0,$130,0,$132,0,$134,0,$136,0
        dc.w    $138,0,$13a,0,$13c,0,$13e,0


	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24	; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,%0000001000010001	; bplcon0

LGBPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
        dc.w $e8,$0000,$ea,$0000
        dc.w $ec,$0000,$ee,$0000
        dc.w $f0,$0000,$f2,$0000
        dc.w $f4,$0000,$f6,$0000
        dc.w $f8,$0000,$fa,$0000
	dc.w $fc,$0000,$fe,$0000

	dc.w	$106, $0c00
COLP0:
	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000

	dc.w	$106, $0e00
COLP0B:
	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000

	dc.w $106,$2c00	     		;Reset Colors 32-63	
        dc.w $180,$000 
        dc.w $182,$000 
        dc.w $184,$000  
        dc.w $186,$000 
        dc.w $188,$000 
        dc.w $18a,$000 
        dc.w $18c,$000 
        dc.w $18e,$000 
        dc.w $190,$000 
        dc.w $192,$000 
        dc.w $194,$000 
        dc.w $196,$000 
        dc.w $198,$000 
        dc.w $19a,$000 
        dc.w $19c,$000 
        dc.w $19e,$000 	
	dc.w $1a0,$000 
        dc.w $1a2,$000 
        dc.w $1a4,$000  
        dc.w $1a6,$000 
        dc.w $1a8,$000 
        dc.w $1aa,$000 
        dc.w $1ac,$000 
        dc.w $1ae,$000 
        dc.w $1b0,$000 
        dc.w $1b2,$000 
        dc.w $1b4,$000 
        dc.w $1b6,$000 
        dc.w $1b8,$000 
        dc.w $1ba,$000 
        dc.w $1bc,$000 
        dc.w $1be,$000 

	dc.w $106,$4c00	     ;Reset Colors 64-95	
        dc.w $180,$000 
        dc.w $182,$000 
        dc.w $184,$000  
        dc.w $186,$000 
        dc.w $188,$000 
        dc.w $18a,$000 
        dc.w $18c,$000 
        dc.w $18e,$000 
        dc.w $190,$000 
        dc.w $192,$000 
        dc.w $194,$000 
        dc.w $196,$000 
        dc.w $198,$000 
        dc.w $19a,$000 
        dc.w $19c,$000 
        dc.w $19e,$000 	
	dc.w $1a0,$000 
        dc.w $1a2,$000 
        dc.w $1a4,$000  
        dc.w $1a6,$000 
        dc.w $1a8,$000 
        dc.w $1aa,$000 
        dc.w $1ac,$000 
        dc.w $1ae,$000 
        dc.w $1b0,$000 
        dc.w $1b2,$000 
        dc.w $1b4,$000 
        dc.w $1b6,$000 
        dc.w $1b8,$000 
        dc.w $1ba,$000 
        dc.w $1bc,$000 
        dc.w $1be,$000 

	dc.w $106,$6c00	     ;Reset Colors 96-127	
        dc.w $180,$000 
        dc.w $182,$000 
        dc.w $184,$000  
        dc.w $186,$000 
        dc.w $188,$000 
        dc.w $18a,$000 
        dc.w $18c,$000 
        dc.w $18e,$000 
        dc.w $190,$000 
        dc.w $192,$000 
        dc.w $194,$000 
        dc.w $196,$000 
        dc.w $198,$000 
        dc.w $19a,$000 
        dc.w $19c,$000 
        dc.w $19e,$000 	
	dc.w $1a0,$000 
        dc.w $1a2,$000 
        dc.w $1a4,$000  
        dc.w $1a6,$000 
        dc.w $1a8,$000 
        dc.w $1aa,$000 
        dc.w $1ac,$000 
        dc.w $1ae,$000 
        dc.w $1b0,$000 
        dc.w $1b2,$000 
        dc.w $1b4,$000 
        dc.w $1b6,$000 
        dc.w $1b8,$000 
        dc.w $1ba,$000 
        dc.w $1bc,$000 
        dc.w $1be,$000 

	DC.W	$3007,$FFFE,$102
	CON1EFFETTO:
	DC.W	$00
	DC.W	$3407,$FFFE,$102,$00
	DC.W	$3807,$FFFE,$102,$00
	DC.W	$3C07,$FFFE,$102,$00
	DC.W	$4007,$FFFE,$102,$00
	DC.W	$4407,$FFFE,$102,$00
	DC.W	$4807,$FFFE,$102,$00
	DC.W	$4C07,$FFFE,$102,$00
	DC.W	$5007,$FFFE,$102,$00
	DC.W	$5407,$FFFE,$102,$00
	DC.W	$5807,$FFFE,$102,$00
	DC.W	$5C07,$FFFE,$102,$00
	DC.W	$6007,$FFFE,$102,$00
	DC.W	$6407,$FFFE,$102,$00
	DC.W	$6807,$FFFE,$102,$00
	DC.W	$6C07,$FFFE,$102,$00
	DC.W	$7007,$FFFE,$102,$00
	DC.W	$7407,$FFFE,$102,$00
	DC.W	$7807,$FFFE,$102,$00
	DC.W	$7C07,$FFFE,$102,$00
	DC.W	$8007,$FFFE,$102,$00
	DC.W	$8407,$FFFE,$102,$00
	DC.W	$8807,$FFFE,$102,$00
	DC.W	$8C07,$FFFE,$102,$00
	DC.W	$9007,$FFFE,$102,$00
	DC.W	$9407,$FFFE,$102,$00
	DC.W	$9807,$FFFE,$102,$00
	DC.W	$9C07,$FFFE,$102,$00
	DC.W	$A007,$FFFE,$102,$00
	DC.W	$A407,$FFFE,$102,$00
	DC.W	$A807,$FFFE,$102,$00
	DC.W	$AC07,$FFFE,$102,$00
	DC.W	$B007,$FFFE,$102,$00
	DC.W	$B407,$FFFE,$102,$00
	DC.W	$B807,$FFFE,$102,$00
	DC.W	$BC07,$FFFE,$102,$00
	DC.W	$C007,$FFFE,$102,$00
	DC.W	$C407,$FFFE,$102,$00
	DC.W	$C807,$FFFE,$102,$00
	DC.W	$CC07,$FFFE,$102,$00
	DC.W	$D007,$FFFE,$102,$00
	DC.W	$D407,$FFFE,$102,$00
	DC.W	$D807,$FFFE,$102,$00
	DC.W	$DC07,$FFFE,$102,$00
	DC.W	$E007,$FFFE,$102,$00
	DC.W	$E407,$FFFE,$102
ULTIMOVALORE:
	DC.W	$00

	dc.w 	$ffff, $fffe	


COPPERLIST:

        ;Sprpointers
        dc.w    $120,0,$122,0,$124,0,$126,0,$128,0,$12a,0
        dc.w    $12c,0,$12e,0,$130,0,$132,0,$134,0,$136,0
        dc.w    $138,0,$13a,0,$13c,0,$13e,0


	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24	; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

 	dc.w	$100,%0111001000000001	; bplcon0
	
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
        dc.w $e8,$0000,$ea,$0000
        dc.w $ec,$0000,$ee,$0000
        dc.w $f0,$0000,$f2,$0000
        dc.w $f4,$0000,$f6,$0000
        dc.w $f8,$0000,$fa,$0000
        dc.w $fc,$0000,$fe,$0000

	dc.w	$100,%0000001000010001	; bplcon0

	;Bplane 1 = confetti 1
	;bplane 2 = background
	;bplane 3 = scrolltext
	;bplane 4 = lighttext
	;bplane 5 = confetti 2
	
	dc.w $106,$0c00
        dc.w $180,$000 ;000000
        dc.w $184,$055 ;000010 
	dc.w $190,$000 ;001000					
	dc.w $194,$055 ;001010			

        paletteset1:         ;needed for scrolling to mark line ff and later
                             ;end of copperlist
        dc.w    $30d9,$fffe
	dc.w 	$31d9,$fffe

	dc.w $106,$0c00		;Reset Colors 0-31 

        dc.w $180,$000 
        dc.w $182,$000 
        dc.w $184,$000  
	dc.w $186,$000 
	dc.w $188,$000 
	dc.w $18a,$000 
	dc.w $18c,$000 
	dc.w $18e,$000 
	dc.w $190,$000 
	dc.w $192,$000 
	dc.w $194,$000 
	dc.w $196,$000 
	dc.w $198,$000 
	dc.w $19a,$000
	dc.w $19c,$000
	dc.w $19e,$000 	

	dc.w $1a0,$000
	dc.w $1a2,$000
	dc.w $1a4,$000
	dc.w $1a6,$000
	dc.w $1a8,$000
	dc.w $1aa,$000
	dc.w $1ac,$000
	dc.w $1ae,$000
	dc.w $1b0,$000
	dc.w $1b2,$000
	dc.w $1b4,$000
	dc.w $1b6,$000
	dc.w $1b8,$000
	dc.w $1ba,$000
	dc.w $1bc,$000
	dc.w $1be,$000

	;palette1
        dc.w    $106,$8c00
	dc.w	$0180,$035d,$0182,$0210,$0184,$0222,$0186,$0333
	dc.w	$0188,$0531,$018a,$0964,$018c,$0777,$018e,$0ca6
	dc.w	$0190,$0fb1,$0192,$0bbb,$0194,$0000,$0196,$0fff
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000

        ;palette2 
	dc.w	$0180+32,$035d,$0182+32,$0742,$0184+32,$0b81,$0186+32,$0110
	dc.w	$0188+32,$0ec7,$018a+32,$0ffe,$018c+32,$0000,$018e+32,$0000
	dc.w	$0190+32,$0000,$0192+32,$0000,$0194+32,$0000,$0196+32,$0000
	dc.w	$0198+32,$0000,$019a+32,$0000,$019c+32,$0000,$019e+32,$0000
	
        ;palette3
        dc.w    $0106,$ac00
	dc.w	$0180,$035d,$0182,$0703,$0184,$0533,$0186,$0444
	dc.w	$0188,$0345,$018a,$0f34,$018c,$0946,$018e,$0a54
	dc.w	$0190,$0878,$0192,$0e66,$0194,$0d87,$0196,$09ac
	dc.w	$0198,$0102,$019a,$0ec9,$019c,$0eeb,$019e,$0fff

	;palette4 
	dc.w	$0180+32,$035d,$0182+32,$0523,$0184+32,$0523,$0186+32,$0721
	dc.w	$0188+32,$0942,$018a+32,$0b61,$018c+32,$0877,$018e+32,$0d95
	dc.w	$0190+32,$0cb9,$0192+32,$0423,$0194+32,$0fdb,$0196+32,$0000
	dc.w	$0198+32,$0000,$019a+32,$0000,$019c+32,$0000,$019e+32,$0000

	;palette5
	dc.w   	$106,$cc00
	dc.w	$0180,$035d,$0182,$0423,$0184,$0523,$0186,$0523
	dc.w	$0188,$0721,$018a,$0942,$018c,$0877,$018e,$0d95
	dc.w	$0190,$0112,$0192,$0fdb,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000

	;palette6
	dc.w	$0180+32,$035d,$0182+32,$0513,$0184+32,$0813,$0186+32,$0423
	dc.w	$0188+32,$0523,$018a+32,$0721,$018c+32,$0342,$018e+32,$0942
	dc.w	$0190+32,$0552,$0192+32,$0b61,$0194+32,$0877,$0196+32,$0d95
	dc.w	$0198+32,$0112,$019a+32,$0fdb,$019c+32,$0000,$019e+32,$0000

	paletteset2:
	dc.w $64d9,$fffe
	dc.w $65d9,$fffe

	;palette1
	dc.w    $106,$8c00
	dc.w	$0180,$035d,$0182,$0715,$0184,$0718,$0186,$0b07
	dc.w	$0188,$0337,$018a,$0a2a,$018c,$0e29,$018e,$045a
	dc.w	$0190,$0c73,$0192,$0e6f,$0194,$069e,$0196,$0416
	dc.w	$0198,$0bce,$019a,$0000,$019c,$0000,$019e,$0000

	;palette2
	dc.w	$0180+32,$035d,$0182+32,$0132,$0184+32,$0b07,$0186+32,$0242
	dc.w	$0188+32,$0462,$018a+32,$0e58,$018c+32,$0683,$018e+32,$08a3
	dc.w	$0190+32,$0bc5,$0192+32,$0715,$0194+32,$0000,$0196+32,$0000
	dc.w	$0198+32,$0000,$019a+32,$0000,$019c+32,$0000,$019e+32,$0000
	
	;palette3
	dc.w   $106, $ac00
	dc.w	$0180,$035d,$0182,$0711,$0184,$0133,$0186,$0832
	dc.w	$0188,$0254,$018a,$0168,$018c,$0264,$018e,$0382
	dc.w	$0190,$038b,$0192,$0b73,$0194,$05b3,$0196,$0ea4
	dc.w	$0198,$07be,$019a,$07d7,$019c,$0611,$019e,$0ec8

	;palette4
	dc.w	$0180+32,$035d,$0182+32,$0522,$0184+32,$0732,$0186+32,$0a52
	dc.w	$0188+32,$0d84,$018a+32,$0313,$018c+32,$0000,$018e+32,$0000
	dc.w	$0190+32,$0000,$0192+32,$0000,$0194+32,$0000,$0196+32,$0000
	dc.w	$0198+32,$0000,$019a+32,$0000,$019c+32,$0000,$019e+32,$0000

	;palette5
	dc.w    $106, $cc00
	dc.w 	$0180,$035d,$0182,$0615,$0184,$0832,$0186,$0925
	dc.w	$0188,$0b35,$018a,$0b62,$018c,$0313,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000	

	;palette6 
	dc.w	$0180+32,$035d,$0182+32,$0522,$0184+32,$0043,$0186+32,$0235
	dc.w	$0188+32,$0732,$018a+32,$0257,$018c+32,$0254,$018e+32,$0a52
	dc.w	$0190+32,$0b62,$0192+32,$0478,$0194+32,$0014,$0196+32,$0000
	dc.w	$0198+32,$0000,$019a+32,$0000,$019c+32,$0000,$019e+32,$0000
	
	;palette7 
	dc.w	$106, $ec00
	dc.w	$0180,$035d,$0182,$0120,$0184,$0261,$0186,$0861
	dc.w	$0188,$04b2,$018a,$0da2,$018c,$0110,$018e,$08e3
	dc.w	$0190,$0feb,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		     
        paletteset3:
        dc.w $93d9,$fffe
	dc.w $94d9,$fffe

	;       palette frame1

        dc.w   $106, $8c00
	dc.w	$0180,$035d,$0182,$0811,$0184,$0333,$0186,$0b22
	dc.w	$0188,$0666,$018a,$0f66,$018c,$0899,$018e,$0b90
	dc.w	$0190,$0faa,$0192,$0eb4,$0194,$0ec0,$0196,$0000
	dc.w	$0198,$0fcc,$019a,$0fc7,$019c,$0ddd,$019e,$0ffe

        ;       palette frame2
	dc.w	$0180+32,$035d,$0182+32,$0000,$0184+32,$0000,$0186+32,$0222
	dc.w	$0188+32,$0444,$018a+32,$0950,$018c+32,$0950,$018e+32,$0a60
	dc.w	$0190+32,$0777,$0192+32,$0b70,$0194+32,$0c81,$0196+32,$0bcb
	dc.w	$0198+32,$0000,$019a+32,$0fff,$019c+32,$0fff,$019e+32,$0fff
		
        ;palette frame3
        dc.w   $106, $ac00
	dc.w	$0180,$035d,$0182,$0003,$0184,$0900,$0186,$0345
	dc.w	$0188,$0930,$018a,$0930,$018c,$0934,$018e,$0b33
	dc.w	$0190,$0a50,$0192,$0a60,$0194,$0c80,$0196,$0f96
	dc.w	$0198,$0000,$019a,$0ccc,$019c,$0fc9,$019e,$0fff

        ;palette frame4 
	dc.w	$0180+32,$035d,$0182+32,$0111,$0184+32,$0118,$0186+32,$0222
	dc.w	$0188+32,$0521,$018a+32,$0332,$018c+32,$0822,$018e+32,$0333
	dc.w	$0190+32,$0531,$0192+32,$0236,$0194+32,$0a23,$0196+32,$0a60
	dc.w	$0198+32,$0c80,$019a+32,$0000,$019c+32,$0fd0,$019e+32,$0fff

        ;palette frame 5
        dc.w    $106, $cc00
	dc.w	$0180,$035d,$0182,$0223,$0184,$0424,$0186,$0633
	dc.w	$0188,$0a33,$018a,$0853,$018c,$056d,$018e,$0878
	dc.w	$0190,$0d72,$0192,$0d96,$0194,$09ab,$0196,$0000
	dc.w	$0198,$0eb9,$019a,$0cdf,$019c,$0fff,$019e,$0000

        ;palette frame 6
	dc.w	$0180+32,$035d,$0182+32,$0424,$0184+32,$0343,$0186+32,$0633
	dc.w	$0188+32,$0a33,$018a+32,$0463,$018c+32,$0953,$018e+32,$066d
	dc.w	$0190+32,$0d56,$0192+32,$0397,$0194+32,$0d72,$0196+32,$0d7b
	dc.w	$0198+32,$07b3,$019a+32,$0da7,$019c+32,$0111,$019e+32,$0cdf

        ;row 4
        paletteset4:
        dc.w    $d7d9, $fffe ;stopper for positions higher than $ff
	dc.w    $d8d9, $fffe
	
	;palette1
	dc.w	$0106,$8c00

	dc.w	$0180,$035d,$0182,$0322,$0184,$0d00,$0186,$0543
	dc.w	$0188,$0940,$018a,$0555,$018c,$0875,$018e,$0d60
	dc.w	$0190,$0777,$0192,$0ca7,$0194,$0aaa,$0196,$0610
	dc.w	$0198,$0fba,$019a,$0dcb,$019c,$0eee,$019e,$0000
	
        ;palette2
	dc.w	$0180+32,$035d,$0182+32,$0421,$0184+32,$0630,$0186+32,$0050
	dc.w	$0188+32,$0a40,$018a+32,$0080,$018c+32,$0c40,$018e+32,$0e60
	dc.w	$0190+32,$0888,$0192+32,$0e84,$0194+32,$0aaa,$0196+32,$0fa6
	dc.w	$0198+32,$0faa,$019a+32,$0030,$019c+32,$0fda,$019e+32,$0eee

	        
        dc.w   $0106, $ac00
        ;palette3
	dc.w	$0180,$035d,$0182,$0111,$0184,$010f,$0186,$0113
	dc.w	$0188,$0800,$018a,$0222,$018c,$0b11,$018e,$0455
	dc.w	$0190,$0080,$0192,$0876,$0194,$0aa7,$0196,$01f0
	dc.w	$0198,$0bbb,$019a,$0500,$019c,$0edc,$019e,$0fff
	        
        ;palette 4
	dc.w	$0180+32,$035d,$0182+32,$0421,$0184+32,$0444,$0186+32,$0641
	dc.w	$0188+32,$0a60,$018a+32,$0c60,$018c+32,$0490,$018e+32,$0787
	dc.w	$0190+32,$0c91,$0192+32,$0aaa,$0194+32,$0fa0,$0196+32,$0fc0
	dc.w	$0198+32,$0110,$019a+32,$08e4,$019c+32,$0ff6,$019e+32,$0eee

        
	dc.w    $ffd9, $fffe ;stopper for positions higher than $ff
	dc.w    $00e1, $fffe
                         
        dc.w	$FFFF,$FFFE	; Fine della copperlist

COPPERLISTBERN:

        ;Sprpointers
        dc.w    $120,0,$122,0,$124,0,$126,0,$128,0,$12a,0
        dc.w    $12c,0,$12e,0,$130,0,$132,0,$134,0,$136,0
        dc.w    $138,0,$13a,0,$13c,0,$13e,0


	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24	; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,%0000001000010001	; bplcon0
	
	;Bplane 1 = confetti 1
	;bplane 2 = background
	;bplane 3 = scrolltext
	;bplane 4 = lighttext
	;bplane 5 = confetti 2
	
	dc.w $106,$0c00
        dc.w $180,$000 ;000000
        dc.w $182,$048 ;000001
        dc.w $184,$055 ;000010 
        dc.w $186,$048 ;000011
        dc.w $188,$fff ;000100
        dc.w $18a,$fff ;000101
        dc.w $18c,$fff ;000110
        dc.w $18e,$fff ;000111
        dc.w $190,$000 ;001000
        dc.w $192,$09f ;001001
        dc.w $194,$055 ;001010
        dc.w $196,$09f ;001011
        dc.w $198,$fff ;001100
        dc.w $19a,$fff ;001101
        dc.w $19c,$fff ;001110
        dc.w $19e,$fff ;001111	
	dc.w $1a0,$091 ;010000
        dc.w $1a2,$091 ;010001
        dc.w $1a4,$091 ;010010 
        dc.w $1a6,$091 ;010011
        dc.w $1a8,$fff ;010100
        dc.w $1aa,$fff ;010101
        dc.w $1ac,$fff ;010110
        dc.w $1ae,$fff ;010111
        dc.w $1b0,$0f5 ;011000
        dc.w $1b2,$0f5 ;011001
        dc.w $1b4,$0f5 ;011010
        dc.w $1b6,$0f5 ;011011
        dc.w $1b8,$0ff ;011100
        dc.w $1ba,$0ff ;011101
        dc.w $1bc,$0ff ;011110
        dc.w $1be,$0ff ;011111		
        
	dc.w $106,$2c00
        dc.w $180,$838 ;100000
        dc.w $182,$048 ;100001
        dc.w $184,$838 ;100010 
        dc.w $186,$048 ;100011
        dc.w $188,$fff ;100100
        dc.w $18a,$fff ;100101
        dc.w $18c,$fff ;100110
        dc.w $18e,$fff ;100111
        dc.w $190,$f9f ;101000
        dc.w $192,$09f ;101001
        dc.w $194,$f9f ;101010
        dc.w $196,$09f ;101011
        dc.w $198,$fff ;101100
        dc.w $19a,$fff ;101101
        dc.w $19c,$fff ;101110
        dc.w $19e,$fff ;101111	
	dc.w $1a0,$091 ;110000
        dc.w $1a2,$091 ;110001
        dc.w $1a4,$091 ;110010 
        dc.w $1a6,$091 ;110011
        dc.w $1a8,$fff ;110100
        dc.w $1aa,$fff ;110101
        dc.w $1ac,$fff ;110110
        dc.w $1ae,$fff ;110111
        dc.w $1b0,$0f5 ;111000
        dc.w $1b2,$0f5 ;111001
        dc.w $1b4,$0f5 ;111010
        dc.w $1b6,$0f5 ;111011
        dc.w $1b8,$fff ;111100
        dc.w $1ba,$fff ;111101
        dc.w $1bc,$fff ;111110
        dc.w $1be,$fff ;111111	

	dc.w $106,$4c00
        dc.w $180,$06a ;1000000
        dc.w $182,$048 ;1000001
        dc.w $184,$06a ;1000010 
        dc.w $186,$048 ;1000011
        dc.w $188,$fff ;1000100
        dc.w $18a,$fff ;1000101
        dc.w $18c,$fff ;1000110
        dc.w $18e,$fff ;1000111
        dc.w $190,$0fe ;1001000
        dc.w $192,$09f ;1001001
        dc.w $194,$0fe ;1001010
        dc.w $196,$09f ;1001011
        dc.w $198,$fff ;1001100
        dc.w $19a,$fff ;1001101
        dc.w $19c,$fff ;1001110
        dc.w $19e,$fff ;1001111	
	dc.w $1a0,$091 ;1010000
        dc.w $1a2,$001 ;1010001
        dc.w $1a4,$091 ;1010010 
        dc.w $1a6,$091 ;1010011
        dc.w $1a8,$fff ;1010100
        dc.w $1aa,$fff ;1010101
        dc.w $1ac,$fff ;1010110
        dc.w $1ae,$fff ;1010111
        dc.w $1b0,$0f5 ;1011000
        dc.w $1b2,$0f5 ;1011001
        dc.w $1b4,$0f5 ;1011010
        dc.w $1b6,$0f5 ;1011011
        dc.w $1b8,$fff ;1011100
        dc.w $1ba,$fff ;1011101
        dc.w $1bc,$fff ;1011110
        dc.w $1be,$fff ;1011111	

	dc.w $106,$6c00
        dc.w $180,$838 ;1100000
        dc.w $182,$048 ;1100001
        dc.w $184,$838 ;1100010 
        dc.w $186,$048 ;1100011
        dc.w $188,$fff ;1100100
        dc.w $18a,$fff ;1100101
        dc.w $18c,$fff ;1100110
        dc.w $18e,$fff ;1100111
        dc.w $190,$0fe ;1101000
        dc.w $192,$048 ;1101001
        dc.w $194,$048 ;1101010
        dc.w $196,$09f ;1101011
        dc.w $198,$fff ;1101100
        dc.w $19a,$fff ;1101101
        dc.w $19c,$fff ;1101110
        dc.w $19e,$fff ;1101111	
	dc.w $1a0,$091 ;1110000
        dc.w $1a2,$091 ;1110001
        dc.w $1a4,$091 ;1110010 
        dc.w $1a6,$091 ;1110011
        dc.w $1a8,$fff ;1110100
        dc.w $1aa,$fff ;1110101
        dc.w $1ac,$fff ;1110110
        dc.w $1ae,$fff ;1110111
        dc.w $1b0,$0f5 ;1111000
        dc.w $1b2,$0f5 ;1111001
        dc.w $1b4,$0f5 ;1111010
        dc.w $1b6,$0f5 ;1111011
        dc.w $1b8,$fff ;1111100
        dc.w $1ba,$fff ;1111101
        dc.w $1bc,$fff ;1111110
        dc.w $1be,$fff ;1111111	

	dc.w $106,$fc00 ;Colors sprite

	dc.w $182,$00f
	dc.w $18a,$0ff
	dc.w $192,$09f
	dc.w $19a,$0f9
	dc.w $1a2,$9ff
	dc.w $1aa,$0ff
	dc.w $1b2,$90f
	dc.w $1ba,$f09

	dc.w $106,$0c00

	;dc.w $000f,$fffe
        dc.w $09c,$8010

	BPLPOINTERSBERN:
	dc.w $e0,$0000,$e2,$0000	;1st	 bitplane
	dc.w $f0,$0000,$f2,$0000	;5th
        dc.w $f4,$0000,$f6,$0000	;6th
        dc.w $f8,$0000,$fa,$0000	;7th   	
	dc.w $e4,$0000,$e6,$0000	;2nd
        dc.w $e8,$0000,$ea,$0000	;3rd
        dc.w $ec,$0000,$ee,$0000	;4rd
        dc.w $fc,$0000,$fe,$0000	;8th
        
	;dc.w $ffff,$fffe

	XTRBPLPOINTERS:			;Repeat bitplane for confetti
	dc.w $ffff,$fffe
	dcb.w 1000, 1	

FONT:
	incbin "font16x20.raw"

font2distance:
	dc.b 0, 5, 5, 5, 5, 5, 5, 5, 5, 5	;Ascii  32 -  41
	dc.b 5, 5, 5, 5, 0, 5, 5, 5, 5, 5 	;Ascii  42 -  51
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5	;Ascii  52 -  61
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5	;Ascii  62 -  71
	dc.b 5, 0, 5, 5, 5, 5, 5, 5, 5, 5	;Ascii  72 -  81
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 3, 5	;Ascii  82 -  91
	dc.b 5, 5, 5, 5, 5, 3, 5, 5, 5, 2	;Ascii  92 - 101
	dc.b 5, 5, 5, 0, 5, 5, 0, 5, 5, 2	;Ascii 102 - 111
	dc.b 5, 5, 5, 3, 2, 5, 5, 7, 5, 5	;Ascii 112 - 121
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	dc.b 5, 5, 5, 5, 5, 5, 5, 5, 5, 5

font2:
	incbin bpa:srcraw/ruby16*8*1.raw

;*****************************************************************************

; Questa e` la maschera. E` una figura formata da un solo bitplane,
; alta 39 linee e larga 4 words

Maschera:
        ;dcb.w   4*39, $ffffffff

	dc.l	$00007fc0,$00000000,$0003fff8,$00000000,$000ffffe,$00000000
	dc.l	$001fffff,$00000000,$007fffff,$c0000000,$00ffffff,$e0000000
	dc.l	$01ffffff,$f0000000,$03ffffff,$f8000000,$03ffffff,$f8000000
	dc.l	$07ffffff,$fc000000,$0fffffff,$fe000000,$0fffffff,$fe000000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$0fffffff,$fe000000,$0fffffff,$fe000000,$07ffffff,$fc000000
	dc.l	$03ffffff,$f8000000,$03ffffff,$f8000000,$01ffffff,$f0000000
	dc.l	$00ffffff,$e0000000,$007fffff,$c0000000,$001fffff,$00000000
	dc.l	$000ffffe,$00000000,$0003fff8,$00000000,$00007fc0,$00000000
	
;*****************************************************************************

;****************************************************************************
; Questi sono i frames che compongono l'animazione

co2frame:
        incbin bpa:srcraw/confetti16*4*1.raw

buzzkillframe:
        incbin bpa:srcraw/buzzkill39*4*10*4.raw

elisaframe:
        incbin bpa:srcraw/elisa42*6*12*4.raw

possumframe:
        incbin bpa:srcraw/possum1-93*10*9*4.raw
possumframe2:
	incbin bpa:srcraw/possum2-93*10*2*4.raw

dkframe:
        incbin sources:bernpartiesagain/dkframes20*48*41*4.raw

i8frame:
        incbin bpa:srcraw/i8aic68*8*12*4.raw        

roboframe:
        incbin bpa:srcraw/robo82*8*12*4.raw        

xeonframe:
        incbin bpa:srcraw/xeon64*12*24*4.raw     

beardedframe:
	incbin bpa:srcraw/bearded43*4*12*4.raw

batmanframe:
        incbin bpa:srcraw/batman48*6*7*4.raw

cowboyframe:
        incbin bpa:srcraw/cowboy47*4*9*4.raw

girlframe:
        incbin bpa:srcraw/girl51*4*16*4.raw

hatmanframe:
        incbin bpa:srcraw/hatman45*4*8*4.raw

explorerframe:
        incbin bpa:srcraw/explorer57*6*16*4.raw

discoframe:
        incbin bpa:srcraw/disco46*4*8*4.raw

wereframe: ;also used for luigi just with different palette
        incbin bpa:srcraw/werewolf2-45*8*8*4.raw

uglyframe:
	incbin bpa:srcraw/ugly31*4*8*4.raw

fishframe:
	incbin bpa:srcraw/fish20*4*8*4.raw

oldmanframe:
	incbin bpa:srcraw/oldman1-39*4*13*4.raw
	incbin bpa:srcraw/oldman2-39*4*13*4.raw

crabframe:
	incbin bpa:srcraw/crab30*4*4*4.raw

octobusframe:
	incbin bpa:srcraw/octobus30*4*6*4.raw

jumperframe:
	incbin bpa:srcraw/jumper24*6*4*4.raw

fishdartframe:
	incbin bpa:srcraw/fishdart17*6*6*4.raw

fishbigframe:
	incbin bpa:srcraw/fishbig40*6*8*4.raw

seamonsterframe:
	incbin bpa:srcraw/watermonster33*8*20*4.raw

wiframe:
	incbin sources:bernpartiesagain/wiframes5*32*35*4.raw

reflframe
	incbin bpa:srcraw/reflection48*48*1.raw
	
buffer:
        dcb.b   48*20,0


Module1:
        incbin  bpa:srcraw/P61.GITAR

Module2:
	incbin	bpa:srcraw/P61.ROCKNROLL
	
sprite1:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite3:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite4:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite5:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite6:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite7:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite8:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite1_2:
        dc.w    $2090,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite2_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite3_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite4_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite5_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite6_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite7_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	

sprite8_2:

	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
        dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000
	dc.w	$3000,$0000
	dc.w	$3800,$0000
	dc.w	$3f00,$0000
	dc.w	$7f00,$0000
	dc.w	$fe00,$0000
	dc.w	$fc00,$0000
	dc.w	$1c00,$0000
	dc.w	$0c00,$0000
	dc.w	$0000,$0000	
	        
	end

Tools/Resources used for this production

	Web
	-http://spriters-resource.com 
	 (To get all the sprites from the old games)
	-http://www.mirsoft.info
	 (Amiga Gamemusic in module format)
	-http://www.aminet.net
	 (Resource for Amiga Software)
	-http://www.ramjam.it
	 (Best ASM Course. Unfortunately in Italian only)
	-http://translate.google.com
	 (To Translate the course)		 
	

	PC/Mac
	-Shoebox (To convert the sprites in a suitable format)
	-Gimp (Further preparations of the png-files 	
	-Excel (To create sinetables)

	AAMIGAAA
	-Personal Paint (Load png/save as iff)
	-Piccon (Load iff save as binary directly useable in assembler)
	-ThePlayer6.1A (Assembler routine to play modfiles
	-ASMOne 1.20 (The Assembler)

	Bitplane Introduction:
	Bitplanes built a picture on a screen. An AGA-Screen can use up to 
	8 Bitplanes. A bitplane is a chain of 0 and 1. 

	Example(s):

	Binary	  	Hexadecimal	Result 	
	%11111111 	$ff		Straight line		
	%10101010	$aa		Dotted line	

	1 Bitplane (max 2 colors) Possible Colors:

	Combination	Colorvalue
	0		Colorvalue from Register $dff180
	1		Colorvalue from Register $dff182
	
	2 Bitplanes (max 4 colors) Possible Colors:

	Combination	Colorvalue
	00		Colorvalue from Register $dff180
	01		Colorvalue from Register $dff182				
	10		Colorvalue from Register $dff184
	11		Colorvalue from Register $dff186

	-8 Bitplanes (max 256 colors) 
	-But of course this can be extended :-)
	-Colorrregister can be changed several time in one frame 

