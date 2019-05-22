����                                        DEBUG = 0
SOUND    = 0
BLITTER  = 0
BPLWIDTH  = 40
BPLHEIGHT = 256
BPLCOUNT  = 8  
MAXDEPTH = 8
CHKBLLINE = 0 ;Extra bit in map for empty line for fast processing
USEMAPHEIGHT = 1
AGA=1

           include      "sources:p61settings.i"
     ifeq DEBUG-0
	   include	"sources:startup1.s"
     else
           jmp          StartProg	   	 
     endc 
           include      "sources:utils.s"
*****************************************************************************u

		;5432109876543210
DMASET	=	%1001001111100000	; copper,bitplane,blitter DMA


STARTPROG:
    lea    $dff000, a6                  ;a6 shall point to graphics register
 
    ifeq DEBUG-0
    move.w 	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
    ;move.l 	view_copper,$80(a6)

    ifeq SOUND-1
    move.w	$1c(a6),-(sp)		;Old IRQ
    move.w	#$7fff,$9a(a6)		;Disable IRQs
    move.w	#$e000,$9a(a6)		;Master and lev6
    endc				;NO COPPER-IRQ!
	
    ;move.w	d0,$88(a6)		; restart copperlist
    IFEQ AGA-1
    move.w	#$3,$1fc(a6)
    move.w	#$c00,$106(a6)
    move.w	#$11,$10c(a6)
    ELSE
    move.w	#$0,$1fc(a6)		; 64bit Fetchmode for bpl and spr
    move.w	#$c00,$106(a6)		; disactivate AGA
    move.w	#$11,$10c(a6)		; disactivate AGA   		
    ENDC
    ENDC	

    bsr.w	InitScreenBuffers	
    bsr.w       SetCopperList	
    bsr.w	SetBitplanePointers
                
MainLoop:
    move.l #$1ff00,d1	                    ; bits that contain vpos
    move.l #$13000,d2	                    ; line to wait for = $130
.mlwaity:
    move.l 4(a6),d0	                    ; read register with 
    	                                    ; positions
    ANDI.L D1,D0		            ; select vpos
    CMPI.L D2,D0                            ; selected vpos reached
    BNE.S  .mlwaity

    move.l counterpos(pc),a0
    sub.w  #1,(a0)                
    bne.s  .br1             
    add.w  #2,counterpos                    ;go to next counter
    add.l  #4,jmplistpos
.br1   
    move.l jmplistpos(pc),a0     
    jmp    0(a0)                    
        
mlgoon:	
    lea         $dff000,a6
    btst.b	#10,$16(a6)	; left mouse button clicked
    bne.s	MainLoop        ; if not continue programm
    rts     

counterpos:
        dc.l counters

counters:
        dc.w 48000

jmplistpos:
        dc.l  jmplist
jmplist:
        bra.w Effect1
        rts

BLINCREMENT = 1
SPINCREMENT = 2
FRAMES=150

Effect1:
        subq   #1, .counter
        bne.s  .br1
        bsr.w    SetCopperList
        bsr.w    SetBitPlanePointers
        move.w #1, .counter        
        lea    blarraydim(pc), a0
        move.w #$00f,$dff180 
        ;bsr.s  Zoom  
	lea    blarraydim(pc), a0
        bsr.w  DrawLines
	move.w #$c00,$dff106
	move.w #$0,$dff180
.br1        
        bra.s  MlGoon

.counter:
        dc.w 1

InitScreenBuffers:
; Needs to be aligned to $10000. This way only low word has to be
;changed in copper

	move.l #bitplane,d0				
	sub.w  d0,d0
	add.l  #$10000,d0
	move.l d0,view_buffer
	add.w  #BPLWIDTH*40*BPLCOUNT,d0
	move.l d0,draw_buffer  	
	rts	

MAXOP = 130        
Zoom:
	move.w #$2000,.palette
        move.w DIMDEPTH(a0),d0
        subq   #1,d0
        lea    blarraycont,a1
        ;lea    .direction,a3
        move.l .posval,a5
        add.l #40, a5			;skip first 20 values (rastertime)
        move.w #0,.rotatecnt
.lp1
        ;move to next frame this plane
        move.w  CNTFRAME(a1),d1
       	cmp.w   DIMFRAMES(a0),d1
        beq.w   .reset
        addq    #1,CNTFRAME(a1)  
.br3
        sub.l   d1,d1
        move.w  CNTFRAME(a1),d1
        ;calc startframe
        subq    #1,d1
        lsl.l   d1  
        add.l   d1,a5
        move.w  (a5),d2      
        move.w  d2,CNTBLSIZE(a1)        
        move.w  #1,CNTSPSIZE(a1)
        move.w  FRAMES*2(a5),CNTPOSX(a1)
        move.w  FRAMES*4(a5),CNTPOSY(a1)
        move.w  FRAMES*6(a5),CNTBLPOSX(a1)
        move.w  FRAMES*8(a5),CNTBLPOSY(a1)        
        move.l  .posval,a5
	add.l	#40,a5
	sub.l   d1,d1
	
        add.l   #24,a1
        dbf     d0,.lp1
		
        ;rotation of planes   
        lea      .poscolors, a2      
        move.w   .rotatecnt,d3
        subq.w   #1,d3
        bmi.w   .br1        
.lp3
        lea    DIMCONTENT(a0), a1
        move.l (a1),d1
        move.w #MAXDEPTH-2,d2 
.lp2                                ;Rotate Bitplane content pointers       
        move.l 4(a1),(a1)
        addq   #4,a1
        dbf    d2, .lp2
        move.l d1,(a1)              ;Previousli First Pointer now last pointer
        dbf    d3, .lp3             ;Different Planes may reach maxsize at the
        			    ;same time. Then Rotation needs to repeat
.br1  
        move.l  (a2),a2             ;load pointer to recent palette
        move.l  draw_copper,a3
        move.l	a3,a0
        add.l   #OFFSCLPALETTE+2,a3
	add.l	#OFFSCLPALETTELW+2,a0
        ;write color palette to copper
	move.w	#2<<(MAXDEPTH-1)-1,d4
	IFGT	MAXDEPTH-5
	addq.w	#(2^MAXDEPTH-32)/32,d4 ;Calculate number of palette changes
                                       ;(ie for 6 bitplanes palette has
                                       ;to be changed once using dff160
                                       ;because there
                                       ;are only 32 colors register		
	ENDC
	move.l .palpos,a1	       ;Load palette	
	
	add.l  #2<<(MAXDEPTH-1)*4,.palpos  ;Update palette for next frame
        IFGT   MAXDEPTH-5
        add.l  #((2<<(MAXDEPTH-1))-32)/32*4,.palpos
        ENDC
	cmp.l  #endcltable,.palpos     ;Reset .palpos if end reached
	bne.w  .lp4
	move.l #colortable,.palpos	
.lp4
	cmp.w  #$f000,(a1)	       ;Placeholder for other command in 
				       ;copper which has to be skipped
				       ;Usually this is dff106 for palet change		
	bne.s  .br2
	addq.l #4,a1		
	bra.s  .br4  
.br2 
	;Insert colors
	move.w (a1)+,(a3)	
	move.w (a1)+,(a0)
	;Prepare for next loop
.br4
        addq.l #4,a3
        addq.l #4,a0   
        dbf    d4, .lp4                                  
        rts
        
.reset:
        move.w  #1, CNTFRAME(a1) 
        add.w   #1, .rotatecnt         ;rotate in next round?
        bra.w  .br3           

.palpos:
	dc.l colortable

.palette:
	dc.w $2000

.rotatecnt
        dc.w 0
.posval:
        dc.l .valwidth
  
.opacity
        dc.w  1,1,1,1 ;Plane 1+2
        dcb.w 12,40	;Plane 3+4
	dcb.w 48,80     ;Plane 5+6  
 
.poscolors:
        dc.l .colors, .colors2, .colors3
        
	dc.w	$216,$13f,$190

.colors
        dc.w    $180,$180,$e11,$c10 ;first 2 planes combined colors
        dc.w    $216,$216,$216,$216,$180,$180,$180,$180,$13f,$13f,$13f,$13f
                ;plane 3 to 4 2nd palette
	IFGT	MAXDEPTH-4
	dcb.w   16,$fd3
	dc.w	0 ;PlaceHolder for palette change
	dcb.w	16,$f82
	dcb.w	16,$fe6 ;plane 5 and 6
	ENDC
	
.colors2
        ;colors after plane rotation
        dc.w    $216,$216,$180,$13f
	IFEQ	MAXDEPTH-4
	dcb.w	4,$180
        dcb.w	4,$e11
        dcb.w	4,$c10
	ELSE
        dcb.w	4,$fd3
        dcb.w	4,$216
        dcb.w	4,$180
	dcb.w   16,$180
	dc.w	0 ;PlaceHolder for palette change
	dcb.w	16,$e11
	dcb.w	16,$c10 ;plane 5 and 6
	ENDc

.colors3
	;colors after plane rotation
        dc.w    $fd3,$fd3,$216,$180
        dcb.w	4,$180
        dcb.w	4,$e11
        dcb.w	4,$c10
	dcb.w   16,$216
	dc.w	0 ;PlaceHolder for palette change
	dcb.w	16,$180
	dcb.w	16,$13f ;plane 5 and 6

	

;.colors
        dc.w    $fd3,$f82,$fe6 ;first 2 planes combined colors
        dc.w    $160,$160,$160,$160,$800,$800,$800,$800,$b10,$b10,$b10,$b10
                ;plane 3 to 4 2nd palette

;.colors2
        ;colors after plane rotation
        dc.w    $190,$c00,$f20
        dc.w    $fd3,$fd3,$fd3,$fd3,$f82,$f82,$f82,$f82,$fe6,$fe6,$fe6,$fe6


;.colors1a:
        dc.w    $fd3,$f82,$fe6 ;first 2 planes combined colors
        dc.w    $170,$170,$170,$170,$a00,$a00,$a00,$a00,$c20,$c20,$c20,$c20
                ;plane 3 to 4 2nd palette

;.colorsba:
        dc.w    $fd3,$f82,$fe6 ;first 2 planes combined colors
        dc.w    $180,$180,$180,$180,$b00,$b00,$b00,$b00,$e20,$e20,$e20,$e20
                ;plane 3 to 4 2nd palette

;.colors2a:
        dc.w    $fd3,$f82,$fe
        dc.w    $190,$190,$190,$190,$c00,$c00,$c00,$c00,$f20,$f20,$f20,$f20
                ;plane 3 to 4 2nd palette
        
;.colors2
        ;colors after plane rotation
        dc.w    $190,$c00,$f20
        dc.w    $fd3,$fd3,$fd3,$fd3,$f82,$f82,$f82,$f82,$fe6,$fe6,$fe6,$fe6

.valwidth
 REPT 4
;framewidth:
     dc.w 12,12,12,13,13,13,13,14,14,14
     dc.w 15,15,15,16,16,16,17,17,18,18
     dc.w 18,19,19,20,20,21,21,22,22,23
     dc.w 23,24,24,25,25,26,26,27,28,28
     dc.w 29,29,30,31,31,32,33,34,34,35
     dc.w 36,37,38,38,39,40,41,42,43,44
     dc.w 45,46,47,48,49,50,51,52,53,55
     dc.w 56,57,58,60,61,62,64,65,66,68
     dc.w 69,71,73,74,76,77,79,81,83,85
     dc.w 86,88,90,92,94,96,99,101,103,105
     dc.w 108,110,112,115,117,120,123,125,128,131
     dc.w 134,137,140,143,146,149,153,156,159,163
     dc.w 167,170,174,178,182,186,190,194,198,203
     dc.w 207,212,216,221,226,231,236,241,247,252
     dc.w 258,263,269,275,281,287,294,300,307,313
;posx:
     dc.w 11,11,11,10,10,10,10,7,7,7
     dc.w 2,2,2,13,13,13,5,5,14,14
     dc.w 14,3,3,12,12,20,20,5,5,12
     dc.w 12,20,20,1,1,7,7,13,20,20
     dc.w 26,26,1,6,6,12,17,22,22,27
     dc.w 33,0,4,4,8,13,17,21,25,30
     dc.w 34,38,42,47,1,4,7,11,14,20
     dc.w 24,27,30,37,40,43,50,53,56,63
     dc.w 66,0,5,7,12,14,18,23,27,32
     dc.w 34,39,43,48,52,57,63,68,72,77
     dc.w 84,88,93,99,104,111,117,122,0,3
     dc.w 7,11,15,18,22,26,31,35,38,43
     dc.w 48,52,57,62,67,72,77,82,87,93
     dc.w 98,105,110,116,122,128,135,141,148,155
     dc.w 162,168,176,183,191,198,207,215,223,231
;posy:
     dc.w 4,4,4,0,0,0,0,9,9,9
     dc.w 2,2,2,11,11,11,1,1,8,8
     dc.w 8,15,15,2,2,8,8,14,14,20
     dc.w 20,2,2,7,7,12,12,17,23,23
     dc.w 28,28,2,6,6,11,15,19,19,23
     dc.w 28,32,36,36,0,4,7,10,13,17
     dc.w 20,23,26,30,33,36,39,43,46,52
     dc.w 56,1,3,8,10,12,17,19,21,26
     dc.w 28,32,37,39,44,46,50,55,59,64
     dc.w 66,71,75,80,84,89,95,100,0,3
     dc.w 7,9,12,15,18,22,25,28,32,35
     dc.w 39,43,47,50,54,58,63,67,70,75
     dc.w 80,84,89,94,99,104,109,114,119,125
     dc.w 130,137,142,148,154,160,167,173,180,187
     dc.w 194,200,208,215,223,230,239,247,255,263
;blposx:
     dc.w 1,1,1,2,2,2,2,3,3,3
     dc.w 4,4,4,4,4,4,5,5,5,5
     dc.w 5,6,6,6,6,6,6,7,7,7
     dc.w 7,7,7,8,8,8,8,8,8,8
     dc.w 8,8,9,9,9,9,9,9,9,9
     dc.w 9,10,10,10,10,10,10,10,10,10
     dc.w 10,10,10,10,11,11,11,11,11,11
     dc.w 11,11,11,11,11,11,11,11,11,11
     dc.w 11,12,12,12,12,12,12,12,12,12
     dc.w 12,12,12,12,12,12,12,12,12,12
     dc.w 12,12,12,12,12,12,12,12,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
;blposy:
     dc.w 4,4,4,5,5,5,5,5,5,5
     dc.w 6,6,6,6,6,6,7,7,7,7
     dc.w 7,7,7,8,8,8,8,8,8,8
     dc.w 8,9,9,9,9,9,9,9,9,9
     dc.w 9,9,10,10,10,10,10,10,10,10
     dc.w 10,10,10,10,11,11,11,11,11,11
     dc.w 11,11,11,11,11,11,11,11,11,11
     dc.w 11,12,12,12,12,12,12,12,12,12
     dc.w 12,12,12,12,12,12,12,12,12,12
     dc.w 12,12,12,12,12,12,12,12,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
     dc.w 13,13,13,13,13,13,13,13,13,13
 
 ENDR
        
        
.counter
        dc.w 132
.direction
        dc.w 0

.changebl
        dc.w 0,0
mapypos:
        dc.w 0
blmappos:
        dc.l 0
bllnflagpos: 
        dc.l 0

GetArrValue:
;input
;a1 - Array Start
;d4 - Index for value
;d3 - Array depth
;
;output
;a2 - value first pos pointer

        lea      (a1,d4),a2
        rts

;1 - depth
        ;2 - index
        ;3 - output register
        
DrawBlankLine:
        IFEQ BLITTER-0
        move.l    currentdrawpos,a5
        REPT 10
        move.l    #0, (a5)+
        ENDR
        ENDC
        rts

DrawLines:
        ;input
        ;a0 - map dimension
        ;d0 - plane number
        
        ;processing
        ;a1 - dimcontent
        ;a2 - space size
        ;a3 - ypos
        ;a5 - bl map y
        ;a6 - bl map x

        move.w   DIMDEPTH(a0),d5
        subq     #1,d5 
        lea      DIMCONTENT(a0),a1           ; load start of ptr list
        move.l   a1,.contentptr              ; save ptr list pos
.lp1
        move.l   (a1),a1                     ; load ptr to first layer
        move.l   draw_copper, copperpos
        add.l    #OFFSCLBLOCKDRAW,copperpos
        cmp.l    #0,d5
        beq.s    .br6
        addq.l   #6,copperpos
        move.l   d5,d0
        lsl.w    #2,d0
        add.l    d0,copperpos
.br6
        move.l   draw_buffer,a2
        move.l   d5,d0
        mulu.w   #BPLWIDTH*40,d0
        add.l    d0,a2
        move.l   a2,currentdrawpos
        
        lea      CNTPOSY(a1),a3       
        lea      CNTBLPOSY(a1),a5
        lea      CNTBLPOSX(a1),a6
        lea      CNTSPSIZE(a1),a2
 
        ;calc map startpos
        sub.l    d1,d1
        move.w   (a6),d1
        lsr.w    #5, d1               ; divide through 32
        lsl.w    #2, d1               ; start pos for x in bytes rounded to lw        
        move.w   d1, d6               ; save blxpos          
        move.w   DIMWIDTH(a0), d0
        mulu.w   (a5),d0
        add.w    d1,d0
        move.l   CNTBLMAP(a1), blmappos
        move.l   CNTBLLNFLAG(a1), bllnflagpos
        add.l    d0,blmappos  
        IFNE chkblline-0             
        move.w   (a5),d0
        lsl.w    d0                  ;word size it
        add.l    d0,bllnflagpos        
        ENDC
             
        move.w   CNTBLSIZE(a1),d0
        cmp.w    #31,d0
        bne.s    .nodebug
        move.w   d0,d0
.nodebug
        move.w   (a2),d2
        add.w    d0,d2
        move.w   d2,.totsize
        movem.l  a0-a2/d1/d3-d7,.saveregs
        lea      DrawLine,a4
        cmp.w    #32,d2
        bhs.s    .br7
        move.w   CNTPOSX(a1),d1
        move.w   (a2),d5         
        bsr.w    PreProcessDL
        lea      dldata,a4
.br7  
        movem.l  .saveregs(pc),a0-a2/d1/d3-d7      

        move.w    (a5), mapypos

        ;d0 - temp use              
        ;d1 - temp use
        ;d2 - number of lines to repeat
        ;d3 - gets cleared by subroutine
        ;d4 - temp use
        ;d5 - layer counter 
        ;d6 - copperpos to draw              

        IFEQ USEMAPHEIGHT-1
        ;save counter for mapheight. Subtract 1 
        move.w   CNTHEIGHT(a1),.heightpos                  
        ENDC

        move.w   #255,d0               
        move.b   #$2c, d6
        move.w   CNTBLSIZE(a1),d1
        IFEQ CHKBLLINE-1
        ;move.l   a4,.lfuncbak
        ENDC
        sub.w    (a3),d1
        beq.s    .linesleftspace
        bmi.s    .linesleftspace
 
.linesleftblock                        ;Still block to draw for this element
        
        IFEQ CHKBLLINE-1
        move.l   bllnflagpos(pc),a5
        cmp.w    #0, (a5)                 ; check for line marker empty
        beq.s    .br8
        ;lea        DrawBlankline,a4  
        bsr.w      DrawBlankLine  
        bra.s    .br10
.br8    
        ;move.l    .lfuncbak,a4
        ENDC

        movem.l         a1-a3/a6/d0-d1/d4-d6, .saveregs
        move.w          (a6),d5                      ;load mapxpos for later
        lea             0(a2),a6
        lea             CNTPOSX(a1),a3          
        move.l          currentdrawpos(pc),a2        
        move.l          blmappos(pc),a5
        ;shift mapppos to exact position
        move.l          (a5)+,d0                         ;load mappos
        and.w           #%11111,d5                       ;get relevant part
        lsl.l           d5,d0                            ;shift map part 1
        move.l          (a5),d6                          ;load map part2
        sub.w           #32,d5
        neg.w           d5
        lsr.l           d5,d6                            ;rotate to right pos
        or.l            d6,d0                            ;combine words
                                    
        moveq           #0,d5
        jsr             0(a4)
        movem.l         .saveregs(pc),a1-a3/a6/d0-d1/d4-d6 
.br10
        cmp.l           #0,d5
        bne.s           .br2
        bsr.w           WriteCopper
        bra.s           .br3
.br2
        bsr.w           WriteCopperPosAdd     
.br3
        cmp.w           #0,d0
        beq.s           .br1  
        add.l           #BPLWIDTH,currentdrawpos       	        
.linesleftspace
        move.w          (a2),d4
.llftspcempty
        add.w           d4, d1             ;get pixels left to draw y for space
        bne.s           .next
        move.w          d1,d1
.next
        bsr.w           DrawBlankLine
        cmp.w           #0,d5
        bne.s           .br4
        bsr.w           WriteCopper 
        bra.w           .br5
.br4   
        bsr.w           WriteCopperPosAdd
.br5   
        cmp.w           #0,d0
        beq.s           .br1

        IFEQ            USEMAPHEIGHT-1
        sub.w           #1,.heightpos
        bpl.s           .br9
        bsr.w           RepeatCopper
        bra.s           .br1
        ENDC
.br9
        add.l           #BPLWIDTH,currentdrawpos
        move.w          CNTBLSIZE(a1),d1
        sub.l           d7,d7
        move.w          DIMWIDTH(a0),d7
        IFEQ CHKBLLINE-1
        add.l           #2,bllnflagpos
        ENDC 
        add.l           d7,blmappos
        bra.w           .linesleftblock
.br1        
        lea             .contentptr,a1         ;load ptr pos
        addq.l          #4,(a1)               ;increase ptr
        move.l          (a1), a1              ;load content of ptr
                                              ;which is ptr to cont array
                  
        dbf             d5,.lp1
        rts

.lfuncbak:
        dc.l 0
.saveregs
         dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.totsize
         dc.w     0

.heightpos:
         dc.w     0

.contentptr
         dc.l     0

RepeatCopper:
         add.l    #BPLWIDTH, currentdrawpos
         sub.l    d4,d4
         ;Revert bitplanepointer
         move.w   CNTHEIGHT(a1), d7          ;Number of blocks
         move.w   d7,d4			     ;Copy to d7 we need d7 later      
	 lsl      d4                         ;One block line and one block gap
	 mulu.w   #BPLWIDTH,d4               ;Get Number of Bytes	 

.lp2 ;Loop for whole map
 
         sub.l    d4, currentdrawpos         ;Revert bplpointer             
	 subq.w   #1, d7                     ;Prepare use of d0 as loopcounter

.lp1 ; Loop for one lines of block
         ;Copper for Block
         move.w   CNTBLSIZE(a1), d1
         subq.w   #1,d1
	 ;Different Copperroutine for first plane                             
	 cmp.w    #0,d5
	 bne.s    .br1
         bsr.s    WriteCopper
         bra.s    .br2
.br1    
         bsr.w    WriteCopperPosAdd   
.br2
         cmp.w    #0, d0
         beq.s    .br3 

         add.l    #BPLWIDTH, currentdrawpos

         ;Copper for Space
         move.w   CNTSPSIZE(a1), d1
         subq.w   #1,d1
	 ;Different Copperroutine for first plane                             
	 cmp.w    #0,d5
	 bne.s    .br4
         bsr.s    WriteCopper
         bra.s    .br5
.br4    
         bsr.s    WriteCopperPosAdd   
.br5
         cmp.w    #0,d0
         beq.s    .br3                      ;End of screen reached
	 
	 add.l    #BPLWIDTH, currentdrawpos	
	 dbf      d7,.lp1
         move.w   CNTHEIGHT(a1),d7          ;Restore d7
	 bra.s    .lp2 
.br3
	 rts

.backup:
         dc.w 0
        
WriteCopper:
        ;d1  number of lines
        ;subq     #1,d1
        ;d6 copperpos
        move.l   copperpos(pc), a5
        move.b   #$1,d3
        move.l   currentdrawpos,d2
.lp1        
        move.b   d6,(a5)
        addq.w   #6, a5       
        ;swap    d2
        ;move.w  d2,(a5)
        ;addq    #4,a5
        ;swap    d2
        move.w   d2,(a5)
        ;add.l   #(BPLCOUNT-1)*8+2,a5
        add.l    #(BPLCOUNT-1)*4+2,a5
        add.b    d3,d6 
        bcs.s    .resetpos
.br1
        subq     #1,d0
        beq.s    .br2
        dbf      d1, .lp1
.br2  
        move.l   a5,copperpos
        rts

.resetpos
        sub.w    d6,d6
        bra.s    .br1

copperpos:
        dc.l draw_copper+OFFSCLBLOCKDRAW

WriteCopperPosAdd:
        ;d1  number of lines
        ;d6 copperpos
        move.l   copperpos(pc), a5
        move.l   currentdrawpos,d2
.lp1              
        ;swap     d2
        move.w   d2,(a5)
        ;addq.l   #4,a5
        ;swap     d2
        ;move.w   d2,(a5)
        add.l    #(BPLCOUNT)*4+4,a5 
        subq     #1,d0
        beq.s    .br2
        dbf      d1, .lp1  
.br2               
        move.l   a5,copperpos
        rts

PreProcessDL:
        ;d0 - Width / Width including space
        ;d1 - Offset / Width
        ;d2 - most left block
        ;d3 - recent block
        ;a1 - patternbit to test
        ;a2 - lwcount
        ;d5 - tempuse
        ;d6 - most right block
        ;d7 - old block
        ;d4 - position lw
                
        ;get start pattern
        move.w          #10,a2
        moveq           #-1,d2
        moveq           #32,d3 
        sub.w           d0,d3 
        lsl.l           d3,d2             ;blockdata
        move.l          d2,d6
        rol.l           d0,d6             ;most right block
        ;get lw pos 
        move.w          d0,d4
        sub.w           d1,d4
        ;calculate complete block size
        move.w          d0,d7           ;backup copy
        ;move.w          d0,d4           
        ;lsr.w           d4
        add.w           d5,d0

        move.l          #31,a1            ;bit of pattern to test
        lea             dldata(pc),a0         ;write the binary here
        move.w          .init(pc),(a0)+

        move.w          d1,d4             ;recent lw pos = offset
        ;get 1st block with offset
        move.l          d2,d3            
        lsl.l           d4,d3
        ;Write Single block
        bsr.w           WriteBlock1
        subq            #1,a1             ;next block in pattern
        move.l          d2,d3             ;restore block start data
        move.l          d0,d5             ;working copy of block size
        sub.l           d4,d5             ;get rshift for 2nd block
        move.w           d5,d4             ;new block pos      
        move.l          d7,d1             ;blocksize without space to d1
.lp1
        cmp.w           #-1,a1
        beq.s           .resetmap 
.br6                                                       
        move.l          d3,d7             ;save old block
        lsr.l           d5,d3             ;calc 2nd block
        beq.s           .br2              ;block partly or complete in this lw
        cmp.l           d3,d6
        ble.s           .br5              ;block complete in this lw
        ;block cut now check for last lw 
        cmp.w           #1,a2
        bne.s           .br3              ;jump to block partly in lw handling
        bsr.s           WriteBlock1
        bra.s           .br4
.br5                                      
        bsr.s           WriteBlock1
        add.w           d0,d4
        move.l          d0,d5
        subq            #1,a1
        bra.s           .lp1
.br2                                      ;block in next lw
        subq            #1,a2
        cmp.w           #0,a2
        beq.s           .br4
        sub.w           #32,d4
        move.w          .writelw(pc),(a0)+
        move.w          .init(pc),(a0)+
        ror.l           d0,d7
        move.l          d7,d3
        bsr.s           WriteBlock1 
        subq            #1,a1
        add.w           d0,d4
        bra.s           .lp1
.br3                                      ;block partly in this lw
        add.w            d1,d4  
        sub.w            #32,d4 
        move.w           d1,d7           
        sub.w            d4,d7            ;bits to shift left
        move.l           d2,d5            ;most left pattern   
        lsl.l            d7,d5            ;shift it
        add.w            d4,d7
        bsr.s            WriteBlock2
        sub.w            d1,d4 
        add.w            d0,d4
        subq             #1,a2
        beq.s            .br4
        subq             #1,a1  
        move.l           d2,d3            ;startpattern = most left
        move.l           d4,d5            ;ls to pos in lw     
        bra.s            .lp1
.br4   
        move.w           .writelw(pc),(a0)+ 
        move.w           .end(pc),(a0)+
        rts

.resetmap
        move.w           .mapfwd,(a0)+
        move.l           #31,a1
        bra.w            .br6
        
.init
        sub.l           d4,d4

.end
        rts

.writelw
        move.l          d4,(a2)+       

.mapfwd
        move.l          (a5)+,d0
        
WriteBlock1:
;input
;a1 - pattern position to test
;d3 - block data

        move.w          .bl1(pc),(a0)+
        move.w          a1,(a0)+         ;set btst to correct block
        move.l          .bl1+4(pc),(a0)+
        move.l          d3,(a0)+
        rts

.bl1
        btst.l          #31,d0
        beq.s           .br1
        or.l          #$fff00000,d4
.br1

WriteBlock2:
;input
;a1 - pattern pos to test
;d3 - block data w
;d5 - block data lw

        move.w          .bl2(pc),(a0)+
        move.w          a1,(a0)+
        cmp.l           #$ffff,d3
        bhi.s           .br3                  ;write word
        move.l          .bl2+4,(a0)+
        move.w          d3,(a0)+
        bra.s           .br4
.br3
        move.b          .bl2+4,(a0)+
        move.b          #$10,(a0)+
        move.w          .writelw(pc),(a0)+
        move.l          d3,(a0)+        
.br4        
        move.l          .bl2+10,(a0)+   
        move.l          d5,(a0)+ 
.br5        
        move.l          .bl2+18,(a0)+
        move.w          .bl2+22,(a0)+
        rts
        
.bl2
        btst.l          #31,d0
        beq.s           .br1
        or.w            #$03ff,d4 
        move.l          d4,(a2)+           ;2
        move.l          #$c0000000,d4
        bra.s           .br2 
.br1
        move.l          d4,(a2)+           ;2
        sub.l           d4,d4
.br2
     
.writelw:
        or.l            #$00fff000,d4

WriteBlock3:
;input
;a1 - pattern pos to test
;d3 - block data w
;d5 - block data lw

        move.w          .bl2(pc),(a0)+
        move.w          a1,(a0)+
        move.l          .bl2+4,(a0)+
        move.w          d3,(a0)+
        move.l          .bl2+10,(a0)+
        move.l          d5,(a0)+
        move.l          .bl2+18,(a0)+
        move.w          .bl2+22,(a0)+
        rts
.bl2
        btst.l          #31,d0
        beq.s           .br1
        or.w            #$03ff,d4 
        move.l          d4,(a2)+           ;2
        move.l          #$c0000000,d4
        bra.s           .br2 
.br1
        move.l          d4,(a2)+           ;2
        sub.l           d4,d4
.br2

LwMapLength:
        dc.w 0

DrawLine:
        ;d2 - number of lines to repeat
        ;d5 - layer counter        
        ;a0 - blarraydim
        ;a1 - blarraycontent
        ;a2 - space size
        ;a5 - blmap
        ;a3 - bl map y

        move.w  #32,d7
        ;calculate map position
        move.w   #10, .lwrdcounter        

        IFEQ blitter-0     
        
        ;Line Calculation
        move.w   CNTBLSIZE(a1),d4      ;get width block
        move.w    (a3),d3              ;xpos (offset)
        lea      mapypos(pc), a3
        sub.w     d6,d6 
        sub.l     d5,d5                ;lw to write
        sub.l     d1,d1                ;cleanup d1
.ldrawbl2
        move.w    d4,d1
        sub.l     d2,d2                ;full lw base for calc = 0 
        btst.l    #31,d0               ;block to draw?                 
        beq.s       .br5         
        subq.l    #1,d2                ;#ffffffff = d2                      
.br5           
        sub.w     #32,d1               ;calculate empty ...
        sub.w     d3,d1                ;... space in this lw to the left
        bpl.s     .bigblock            ;Result > 32 ?
.br1        
        neg.w     d1                   ;if not 
        cmp.w     #32,d1
        bgt.s     .clearalllw          ;offset greater than than lw       
        lsl.l     d1,d2                ;cut off part not visible and too much..
        lsr.l     d6,d2                ;.... or move to right
.br7
        ;prepare next block
        neg.w     d1                   ;offset to left (neg) ...
        add.w     #32,d1               ;....and size of lw
        add.w     d6,d1                ;....and lsr offset = last pos block
.br2
        or.l      d2,d5                ;write to register
        cmp.w     #32,d1               ;block ends in next lw?
        ble.s     .br3                 ;if no jump
.br6   
        move.l    d5,(a2)+             ;write lw
        sub.w     #1, .lwrdcounter
        beq.s     .end
        sub.l     d5,d5                ;delete data 
        sub.w     #32,d1                          
        sub.w     d4,d1                ;calc offset to left        
        neg.w     d1
        move.w    d1,d3   
        sub.w     d6,d6                ;lsr = 0  
        bra.s     .ldrawbl2
.br3 
        lsl.l     d0
        subq      #1, d7
        beq.s     .mapfwd                           
        add.w     (a6),d1   ;add blspace = startpos next block
        cmp.w     #32,d1
        blt.s     .br4
        move.l    d5,(a2)+
        sub.l     d5,d5
        sub.w     #1, .lwrdcounter
        beq.s     .end  
        sub.w     #32,d1
        cmp.w     #32,d1
        bge.s     .bigspace   
.br4    
        and.w     #%11111,d1           ;get offset for lsr 
        move.w    d1,d6
        sub.w     d3,d3                ;no loffset for block
        bra.s     .ldrawbl2
.end
        ENDC
        move.w    DIMWIDTH(a0),d7
        rts

.clearalllw:
        sub.l     d2,d2
        bra.s     .br7 

.bigblock:
        add.l     d6,d1                      ;offset of block to draw later
        move.l    d2,d3                      ;d3 unused atm use this to save d2
        lsr.l     d6,d3                      ;offset to right for first lw
        or.l      d3,d5                      ;finish pattern this lw
        move.l    d5,(a2)+                   ;write to screenbuffer
        sub.w     #1,.lwrdcounter
        beq.s     .end
        sub.w     #32,d1
        bmi.s     .bb1
.bb2
        move.l    d2,(a2)+                   ;save complete block
        sub.w     #1, .lwrdcounter
        beq.s     .end
        sub.w     #32,d1
        bpl.s     .bb2
.bb1
        sub.l     d5,d5
        sub.l     d6,d6
        sub.l     d3,d3
        bra.w     .br1        

.mapfwd:
        move.l     (a1)+,d0            
        moveq.l     #32,d7
        bra.w      .br5

.bigspace
        moveq.l    #0,d2
.bs1
        move.l     d2,(a2)+
        sub.w      #1, .lwrdcounter
        beq.s      .end
        sub.w      #32, d1
        cmp.w      #32, d1
        bge.s      .bs1
        bra.s      .br4

.saveregs: dc.l 0,0,0,0,0,0,0,0
.savespacewidth: dc.w 0
.lwrdcounter: dc.w BPLWIDTH 

currentdrawpos: dc.l 0
patternpos: dc.l 0
                                                            
mpchkblline:
        dcb.w 4*60,0

bllnflag:
        REPT 5
        ;dcb.w 14,1
        dcb.w 11,0
        dcb.w 3,1 
        ENDR
bllnflag2:
        REPT 5
        ;dcb.w 14,1
        dcb.w 5,1
        dcb.w 3,0
        dcb.w 2,1
        dcb.w 3,0
        dc.w 1
        ENDR
bllnflag3:
        REPT 5
        ;dcb.w 11,1
        dcb.w 4,0
        dcb.w 2,1
        dcb.w 2,0
        dcb.w 3,1
        ENDR
bllnflag4:
        REPT 5
        ;dcb.w 11,1
        dcb.w 4,1
        dcb.w 6,0
        dc.w 1
        ENDR
bllnflag5:
        REPT 5
        ;dcb.w 14,1
        dcb.w 1,1
        dcb.w 6,0
        dcb.w 1,1
        dcb.w 1,0
        dcb.w 1,1
        dcb.w 2,0
        dcb.w 2,1
        ENDR
bllnflag6:
        REPT 5
        ;dcb.w 14,1
        dcb.w 3,1
        dcb.w 11,0
        ENDR
bllnflag7:
        REPT 5
        ;dcb.w 11,1
        dcb.w 1,1
        dcb.w 7,0
        ENDR
bllnflag8:
        REPT 5
        ;dcb.w 11,1
        dcb.w 1,1
        dcb.w 3,0
        dcb.w 4,1
        ENDR



blmap:
	dcb.b 384,$ff 
        ;incbin "sources:raw/bellpl1.raw"
blmap2:
	dcb.b 384,$ff
        ;incbin "sources:raw/bellpl2.raw"
blmap3:
	dcb.b 384,$ff
        ;incbin "sources:raw/cherrypl1.raw"
blmap4:
	dcb.b 384,$ff
        ;incbin "sources:raw/cherrypl2.raw"          
blmap5:
	dcb.b 384,$ff
        ;incbin "sources:raw/strawberrypl1.raw"
blmap6:
	dcb.b 384,$ff
        ;incbin "sources:raw/strawberrypl2.raw"
blmap7:
	dcb.b 384,$ff
        ;incbin "sources:raw/zwetschgepl1.raw"
blmap8:
	dcb.b 384,$ff
        ;incbin "sources:raw/zwetschgepl2.raw"


blarraydim:
.blwidth: dc.w 6 ;width in bytes
.blheight: dc.w 14
.bldepth: dc.w MAXDEPTH
.frames: dc.w 130
.blstruct: dc.l blarraycont, blarraycont2, blarraycont3, blarraycont4
	   dc.l blarraycont5, blarraycont6,blarraycont7, blarraycont8

blarraycont:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 7
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blpfrstrt: dc.w 99
.blmap: dc.l blmap8
.bllnflag: dc.l bllnflag8
.blheight: dc.w 9

blarraycont2:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 8
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 99
.blmap: dc.l blmap7
.bllnflag: dc.l bllnflag7
.blheight: dc.w 9

blarraycont3:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 9
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstart: dc.w 66
.blmap: dc.l blmap6
.bllnflag dc.l bllnflag6
.blheight: dc.w 9

blarraycont4:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 10
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 66
.blmap: dc.l blmap5
.bllnflag dc.l bllnflag5
.blheight: dc.w 9

blarraycont5:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 14
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blpfrstrt: dc.w 34 
.blmap: dc.l blmap4
.bllnflag: dc.l bllnflag4
.blheight: dc.w 11

blarraycont6:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 14
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 34
.blmap: dc.l blmap3
.bllnflag: dc.l bllnflag3
.blheight: dc.w 11

blarraycont7:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 12
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstart: dc.w 1
.blmap: dc.l blmap2
.bllnflag dc.l bllnflag2
.blheight: dc.w 14 

blarraycont8:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 12
.spsize: dc.w 1
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 1
.blmap: dc.l blmap
.bllnflag dc.l bllnflag
.blheight: dc.w 14

dldata:dcb.b 2000
        
DIMWIDTH = 0
DIMHEIGHT = 2
DIMDEPTH = 4
DIMFRAMES = 6
DIMCONTENT = 8

CNTPOSX = 0
CNTPOSY = 2
CNTBLSIZE = 4
CNTSPSIZE = 6
CNTBLPOSY = 8
CNTBLPOSX = 10
CNTFRAME = 12
CNTBLMAP = 14
CNTBLLNFLAG = 18
CNTHEIGHT = 22

      INCLUDE sources:graphics.s

 END

