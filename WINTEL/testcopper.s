DEBUG = 0
SOUND    = 0
BLITTER  = 0
BPLWIDTH  = 40
BPLHEIGHT = 256
BPLCOUNT  = 8  
MAXDEPTH = 8
CHKBLLINE = 0 ;Extra bit in map for empty line for fast processing
USEMAPHEIGHT = 0
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

    bsr.w      SetCopperList	
    ;bsr.w	SetBitplanePointers
                
MainLoop:
    move.l #$1ff00,d1	                    ; bits that contain vpos
    move.l #$13000,d2	                    ; line to wait for = $130
.mlwaity:
    move.l 4(a6),d0	                    ; read register with 
    	                                    ; positions
    ANDI.L D1,D0		            ; select vpos
    CMPI.L D2,D0                            ; selected vpos reached
    BNE.S  .mlwaity

    ;move.l counterpos(pc),a0
    ;sub.w  #1,(a0)                
    ;bne.s  .br1             
    ;add.w  #2,counterpos                    ;go to next counter
    ;add.l  #4,jmplistpos
.br1   
    ;move.l jmplistpos(pc),a0     
    ;jmp    0(a0)                    
        
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
        ;bsr.w  SetCopperList
        ;bsr.w  SetBitPlanePointers
        move.w #200, .counter              
.br1        
        bra.s  MlGoon

.counter:
        dc.w 200

      INCLUDE sources:testgraphics.s

 END

