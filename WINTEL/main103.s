DEBUG = 0
SOUND    = 1
BLITTER  = 0
BPLWIDTH  = 40
BPLHEIGHT = 256
BPLCOUNT  = 8
MAXDEPTH = 8
CHKBLLINE = 0 ;Extra bit in map for empty line for fast processing
USEMAPHEIGHT = 1
AGA=1
MINLINE = 10 ;Min Number of Lines for Rotation

     include      "p61settings.i"
     ifeq DEBUG-0
	   include	"startup1.s"
Playrtn:
        include "p6112-Play.i"
     else
           jmp          StartProg
     endc
           include      "utils.s"
*****************************************************************************u

		    ;5432109876543210
DMASET	=	%1001001111100000	; copper,bitplane,blitter DMA


STARTPROG:
    lea    $dff000,a6                  ;a6 shall point to graphics register

    ifeq DEBUG-0
    move.w 	#DMASET,$96(a6)		; DMACON - abilita bitplane,copper
    ;move.l 	view_copper,$80(a6)

    ;move.w	d0,$88(a6)		; restart copperlist
    IFEQ AGA-1
    move.w	#$0,$1fc(a6)
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
    AND.L D1,D0		                    ; select vpos
    CMP.L D2,D0                            ; selected vpos reached
    BNE.S  .mlwaity

    lea    continue,a0
    cmp.w  #1,(a0)
    bne.s  .br1
    move.w #0,(a0)
    add.l  #4,jmplistpos
.br1
    move.l jmplistpos(pc),a0
    jmp    0(a0)

mlgoon:
    lea         $dff000,a6
    btst.b	#10,$16(a6)	; left mouse button clicked
    bne.s	MainLoop        ; if not continue programm
    ifeq SOUND-1
	lea	$dff000,a6
	exit:
	btst	#14,2(a6)		;Wait for blitter to finish
	bne.b	exit
	jsr	P61_End
	endc
	rts

continue:
        dc.w 0

jmplistpos:
        dc.l  jmplist
jmplist:
        bra.w Effect0_1
		bra.w Effect0_2
		bra.w Effect1_0
		bra.w Effect5_0
		bra.w Effect5_1
        bra.w Effect1_1
		bra.w Effect1_2
		bra.w Effect1_3
		bra.w Effect2_0
		bra.w Effect2_1
		bra.w Effect3_0
		bra.w Effect3_1
		bra.w Effect4_1
        rts

BLINCREMENT = 1
SPINCREMENT = 2
FRAMES=150

ColMultiplier: dc.w 0
Temporaneo: dc.l 0

Eff1ZoomIn:
  dc.w 0

Effect0_1:
  move.w #$f00,$dff180
  IFEQ DEBUG-0
  move.l #COPPERLISTIMAGE,$dff080
  ENDC
  move.w #256,ColMultiplier
  move.l #BPLLOGO,draw_buffer
  move.l #BPLLOGO,view_buffer
  move.l #IMGBPLPOINTERS,draw_cprbitmap
  move.l #IMGBPLPOINTERS,view_cprbitmap
  bsr.w  SetBitplanePointersDefault
  lea    PalettePic,a3
  bsr.w  CalculateFade
  move.w #$c00,$dff106
  move.w #$000,$dff180
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon

.counter: dc.w 1*50

Effect0_2:
  bsr.w  SetBitplanePointersDefault
  lea    PalettePic,a3
  bsr.w  CalculateFade
  sub.w  #4,ColMultiplier
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon

.counter dc.w 256/4

  IFEQ SOUND-0
    P61_Pos: dc.w 0
  ENDC

Effect1_0:
  move.l #bitplane,draw_buffer
  move.l #bitplane+40*40*8,view_buffer
  ifeq SOUND-1
        lea Module1,a0
        sub.l 	a1,a1
        sub.l 	a2,a2
        moveq 	#0,d0
  jsr	P61_Init
  endc
  move.w #1,continue
  bra.w mlgoon

Effect5_0:
  move.l #BPLLOGO,draw_buffer
  move.l #BPLLOGO,view_buffer
  move.l #COPPERLISTROTATE1,view_copper
  move.l #COPPERLISTROTATE2,draw_copper
  move.l #COLRBITPLANEPOINTERS1,view_cprbitmap
  move.l #COLRBITPLANEPOINTERS2,draw_cprbitmap
  move.l #COLRLINESELECT1,view_cprlnsel
  move.l #COLRLINESELECT2,draw_cprlnsel
  bsr.w  DrawLines4Rotation
  move.b #$2c,d1
  move.w #255,d0
  move.l view_cprlnsel,a3
.lp1
  move.b d1,(a3)
  add.l  #9*4,a3
  add.b  #1,d1
  dbf    d0,.lp1
  move.b #$2c,d1
  move.w #255,d0
  move.l draw_cprlnsel,a3
.lp2
  move.b d1,(a3)
  add.l  #9*4,a3
  add.b  #1,d1
  dbf    d0,.lp2
  
  move.w #1,continue
  bra.w  mlgoon

Effect5_1:
  movem.l empty,a0-a5/d0-d7
  move.w  #$c00,$dff106
  move.w  #$0f0,$dff180
  bsr.w   SetCopperList4Rotation
  clr.w   $200
  move.l  .frmpos,a5      
  move.l  .linesizepos,a2   
  bsr.w   WriteCopper4Rotation
  addq.l  #4,a5
  cmp.l   #$0fffffff,(a5)          
  bne.s   .br3
  lea.l   LINEMULTIPLIERS,a5
.br3
  addq.l  #4,a2
  cmp.l   #$0fffffff,(a2)          
  bne.s   .br2
  lea.l   LINESIZE,a2
.br2
  move.l  a5,.frmpos
  move.l  a2,.linesizepos
  move.w  #$c00,$dff106
  move.w  #$000,$dff180
  cmp.w   #12,P61_Pos
  beq.s   .br1
  bra.w   mlgoon
.br1
  move.w #1,continue
  move.w #1,continue
  bra.w  mlgoon
  
.frmpos: dc.l LINEMULTIPLIERS
.linesizepos: dc.l LINESIZE

Effect1_1:
  move.w #$00,$dff180
  move.w #0,Eff1ZoomIn
  bsr.w  Effect1_Main
  move.w #$c00,$dff106
  move.w #$000,$dff180
  cmp.w  #2,P61_Pos
  beq.s  .br1
  add.w  #1,.framecount
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon

.framecount dc.w 0

Effect1_2:
  move.w #$00,$dff180
  move.w #1,Eff1ZoomIn
  bsr.w  Effect1_Main
  move.w #$c00,$dff106
  move.w #$000,$dff180
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  lea    EF1_PATTERNDATA7,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  bra.w  mlgoon

.counter dc.w 67

Effect1_3:
  move.w #$0,$dff180
  cmp.w  #67,.framecount
  bne.s  .br1
  sub.w  #1,.ptrnleft
  bne.s  .br2
  move.w #1,continue
  bra.w  mlgoon
.br2
  move.w #0,.framecount
  lea    EF1_MoveX,a0
  bsr.w  RotateMove
  lea    EF1_MoveY,a0
  bsr.w  RotateMove
  move.l .ptrntohide,a0
  move.l #PTR_EMPTY_DATA,(a0)
  add.l  #FRMSIZE,.ptrntohide
.br1
  move.w #1,Eff1ZoomIn
  bsr.w  Effect1_Main
  add.w  #1,.framecount
  move.w #$c00,$dff106
  move.w #$000,$dff180
  bra.w  mlgoon

.framecount: dc.w 67
.ptrntohide: dc.l EF1_PATTERNDATA0
.ptrnleft: dc.w 8

Effect2_0:
  move.w #$0,$dff180
  cmp.w  #4,P61_Pos
  beq.s  .br2
  bra.w  mlgoon
.br2
  move.w #1,continue
  IFEQ DEBUG-0
  move.l #COPPERLISTIMAGE,$dff080
  ENDC
  move.w #1,ColMultiplier
  move.l #BPLTITLE,draw_buffer
  move.l #BPLTITLE,view_buffer
  bra.w  mlgoon

Effect2_1:
  move.w #$000,$dff180
  bsr.w  SetBitplanePointersDefault
  lea    PalTitle,a3
  bsr.w  CalculateFade
  move.w #$c00,$dff106
  move.w #$000,$dff180
  cmp.w  #256,ColMultiplier
  beq.s  .br2
  add.w  #1,ColMultiplier
.br2
  cmp.w  #5,P61_Pos
  bne.s  .br1
  move.w #1,continue
.br1
  bra.w  mlgoon

Effect3_0:
  bsr.w  InitScreenBuffers
  move.l #BITPLANE,view_buffer
  move.l #BITPLANE+BPLWIDTH*40*BPLCOUNT,draw_buffer
  move.w #1,continue
  bra.w  mlgoon

Effect3_1:
  move.w #$00,$dff180
  move.w #1,Eff2ZoomIn
  bsr.w  Effect3_Main
  move.w #$c00,$dff106
  move.w #$000,$dff180
  cmp.w  #9,P61_Pos
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon

.counter dc.w 67

Effect4_1:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect4_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  cmp.w  #16,P61_Pos
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon

Eff2ZoomIn: dc.w 0

PalTitle:
  INCBIN "raw/titlepal.raw"

RotateMove:
  ;a0 Directions
  move.w (a0),d0
  REPT 7
  move.w 2(a0),(a0)+
  ENDR
  move.w d0,(a0)
  rts

EF1_dummy:
  dc.w 1,-1,0,0,1,-1,0,0

EF1_dummy2:
  dc.w 0,0,1,-1,0,0,1,-1

Effect1_Main:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)

        subq    #1,.counter		    ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitplanePointers     ;  SetBitplanePointers();
        move.w  #1,.counter            ;  counter = 1; //50 fps
		lea     .frame,a3              ;
		lea     EF1_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l nam  #FRMSIZE*7,a1         ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1),a6
		sub.l   #4,a6
		lea     blarraydim,a0			;  blarraydim.width =
		move.w  (a6),DIMWIDTH(a0)	;  	        *blarraycont.data.width;
		move.w  2(a6),DIMHEIGHT(a0)	;  blarraydim.height =
										;  		    blarraycont.data.height;
        move.w   #7,.i     		    ;  for(int i=0;i<8;i++)
		lea      EF1_MoveX,a5
		lea      EF1_MoveY,a6
.lp1  									;  {
		move.l  (a1),CNTBLMAP(a2)      ;    *frmdat.blmap = *laydat.blmap
		bsr.w   GetFrame        		;    GetFrame(  framedate,frmnr)
        bsr.w   MoveData
		bsr.w   SetFrame                ;    SetFrame(  input,laydat)
		addq.l  #2,a5
		addq.l  #2,a6
		sub.l   #FRMSIZE,a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE,a2         ;    laydat++;
		sub.w   #1,.i
		bpl.s   .lp1			        ;  }

        bsr.w    MoveAdjust             ;  MoveAdjust( );
		move.l  .colptr(pc),a5
		bsr.w   SetColData				;  SetColData(  colptr);
		cmp.w   #0,Eff1ZoomIn          ;  if(Eff1ZoomIn( )
		beq.s   .br3                    ;  {
		lea	   .colptr,a5
	    add.l  #2,(a3)				    ;    frame++
		cmp.l  #134,(a3)                ;    if(frame > 66) {
		bne.s  .br2                     ;      frame = 0;
		move.l 	#0,(a3)                 ;      colptr = EF1_COLOR0;
		move.l  #EF1_COLOR0,(a5)        ;    }
		bra.s   .br3                    ;    else
.br2                                    ;    {
		add.l  #1024,(a5)     	        ;      colptr++
.br3                                    ;    }
                                        ;  }
		bsr.w  DrawLines                ;  DrawLines(blarraydim);
        ;move.w #$c00,$dff106            ;  Reg_Col0 = 00;
	    ;move.w #$0,$dff180

.br1        							;}
        rts

.i dc.w 7
.counter: dc.w 1
.frame: dc.l 0
.colptr: dc.l EF1_COLOR0

Effect3_Main:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)

        subq    #1,.counter		    ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitplanePointers     ;  SetBitplanePointers();
        move.w  #1,.counter            ;  counter = 1; //50 fps
		lea     .frame,a3              ;
		lea     EF2_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l nam  #FRMSIZE*7,a1         ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1),a6
		sub.l   #4,a6
		lea     blarraydim,a0			;  blarraydim.width =
		move.w  (a6),DIMWIDTH(a0)	;  	        *blarraycont.data.width;
		move.w  2(a6),DIMHEIGHT(a0)	;  blarraydim.height =
										;  		    blarraycont.data.height;
        move.w   #7,.i     		    ;  for(int i=0;i<8;i++)
.lp1  									;  {
		move.l  (a1),CNTBLMAP(a2)      ;    *frmdat.blmap = *laydat.blmap
		bsr.w   GetFrame2        		;    GetFrame(  framedate,frmnr)
		bsr.w   SetFrame                ;    SetFrame(  input,laydat)
		sub.l   #FRMSIZE2,a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE,a2         ;    laydat++;
		sub.w   #1,.i
		bpl.s   .lp1			        ;  }
        bsr.w    MoveAdjust             ;  MoveAdjust( );
		move.l  .colptr(pc),a5
		bsr.w   SetColData				;  SetColData(  colptr);
		cmp.w   #0,Eff2ZoomIn          ;  if(Eff1ZoomIn( )
		beq.s   .br3                    ;  {
		lea	   .colptr,a5
		move.l .direction,d1
	    add.l  d1,(a3)					;    frame += direction
		move.l .dircolor,d2
		cmp.l  #90,(a3)                 ;    if(frame > 45
		beq.s  .br4                     ;                || frame == 0)
		cmp.l  #0,(a3)                 ;    {
		bne.s  .br2
.br4                                    ;
		neg.l   d1                      ;      direction =* -1;
		move.l  d1,.direction
		neg.l   d2
		move.l  d2,.dircolor			;      dircolor =* -1;
		add.l   d1,(a3)                ;      frame += direction;
		lea     EF2_PATTERNDATA0,a1
		move.w  #3,d1                  ;      for(int i=0;i<4;i++)
.lp2									;      {
		move.l  (a1),d3     			;        tmp = ptrndata[i*2];
		move.l  FRMSIZE2(a1),(a1)	    ;        ptrndata[i*2] =
		move.l  d3,FRMSIZE2(a1)		;             ptrndata[i*2+1];
		add.l   #FRMSIZE2*2,a1			;        ptrndata[i*2+1] = tmp;
		dbf     d1,.lp2				;      }
		bra.s   .br3                    ;    }
.br2                                    ;    else {
		add.l  d2,(a5)          		;      colptr++
.br3                                    ;    }
		bsr.w  DrawLines                ;  DrawLines(blarraydim);
        ;move.w #$c00,$dff106           ;  Reg_Col0 = 00;
	    ;move.w #$0,$dff180
.br1        							;}
        rts

.i dc.w 7
.counter: dc.w 1
.frame: dc.l 0
.colptr: dc.l EF2_COLOR0
.direction: dc.l 2
.dircolor: dc.l 1024

Effect4_Main:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)

        subq    #1,.counter		    ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitplanePointers     ;  SetBitplanePointers();
        move.w  #1,.counter            ;  counter = 1; //50 fps
		lea     .frame,a3
		lea     EF3_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l nam  #FRMSIZE*7,a1         ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1),a6
		sub.l   #4,a6
		lea     blarraydim,a0			;  blarraydim.width =
		move.w  (a6),DIMWIDTH(a0)	;  	        *blarraycont.data.width;
		move.w  2(a6),DIMHEIGHT(a0)	;  blarraydim.height =
										;  		    blarraycont.data.height;
        move.w   #7,.i     		    ;  for(int i=0;i<8;i++)
.lp1  									;  {
		move.l  (a1),CNTBLMAP(a2)      ;    *frmdat.blmap = *laydat.blmap
		bsr.w   GetFrame3        		;    GetFrame(  framedate,frmnr)
		bsr.w   SetFrame                ;    SetFrame(  input,laydat)
		sub.l   #FRMSIZE3,a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE,a2         ;    laydat++;
		sub.w   #1,.i
		bpl.s   .lp1			        ;  }
        bsr.w    MoveAdjust             ;  MoveAdjust( );
		move.l  .colptr(pc),a5
		bsr.w   SetColData				;  SetColData(  colptr);
		cmp.w   #0,Eff3ZoomIn          ;  if(Eff3ZoomIn( )
		beq.s   .br3                    ;  {
		lea	   .colptr,a5
		move.l .direction,d1
	    add.l  d1,(a3)					;    frame += direction
		move.l .dircolor,d2
		cmp.l  #540,(a3)                 ;    if(frame > 270
		bne.s  .br2
		move.l 	#0,(a3)                 ;      colptr = EF1_COLOR0;
		bchg.b  #0,EffInvert			;      EffInvert = !EffInvert
		move.l  #EF3_COLOR0,(a5)        ;    }
		bra.s   .br3                    ;    else
.br2                                    ;    else {
		add.l  d2,(a5)          		;      colptr++
.br3                                    ;    }
		bsr.w  DrawLines                ;  DrawLines(blarraydim);
.br1        							;}
        rts

.i dc.w 7
.counter: dc.w 1
.frame: dc.l 0
.colptr: dc.l EF3_COLOR0
.direction: dc.l 2
.dircolor: dc.l 1024
EffInvert: dc.w 0

Eff3ZoomIn: dc.w 0
Break:
    rts

GetFrame:
;input
;a1 = frmdat[]
;a3 = frame
;output;    GetFrame(  framedate,frmnr)
;d1 = blposx
;d2 = blposy
;d3 = detposx
;d4 = drtposy
;d5 = size
		add.l   (a3),a1                ;  //Get to right frame
		move.w FDOPOSX(a1),d1          ;  blposx = *frmdat.blposx[frame]
		move.w FDOPOSY(a1),d2          ;  '
		move.w FDOPOSXDET(a1),d3       ;  '
		move.w FDOPOSYDET(a1),d4       ;  '
		move.w FDOBLSIZE(a1),d5        ;  '
		sub.l  (a3),a1                ;  //Get to right frame
        rts								;}

GetFrame2:
;input
;a1 = frmdat[]
;a3 = frame
;output;    GetFrame(  framedate,frmnr)
;d1 = blposx
;d2 = blposy
;d3 = detposx
;d4 = drtposy
;d5 = size
		add.l   (a3),a1                ;  //Get to right frame
		move.w FDOPOSX2(a1),d1          ;  blposx = *frmdat.blposx[frame]
		move.w FDOPOSY2(a1),d2          ;  '
		move.w FDOPOSXDET2(a1),d3       ;  '
		move.w FDOPOSYDET2(a1),d4       ;  '
		move.w FDOBLSIZE2(a1),d5        ;  '
		sub.l  (a3),a1                ;  //Get to right frame
        rts								;}

GetFrame3:
;input
;a1 = frmdat[]
;a3 = frame
;output;    GetFrame(  framedate,frmnr)
;d1 = blposx
;d2 = blposy
;d3 = detposx
;d4 = drtposy
;d5 = size
		add.l   (a3),a1                ;  //Get to right frame
		move.w FDOPOSX3(a1),d1          ;  blposx = *frmdat.blposx[frame]
		move.w FDOPOSY3(a1),d2          ;  '
		move.w FDOPOSXDET3(a1),d3       ;  '
		move.w FDOPOSYDET3(a1),d4       ;  '
		move.w FDOBLSIZE3(a1),d5        ;  '
		sub.l  (a3),a1                ;  //Get to right frame
        rts						       ; }

SetFrame:			        		    ;SetFrameDefault(  frmdat,
;a2 = laydat
		move.w d1,CNTBLPOSX(a2)      ;  *frmdat.posx[frame] = *frmdat.posx
		move.w d2,CNTBLPOSY(a2)      ;  '
		move.w d3,CNTPOSX(a2)        ;'
		move.w d4,CNTPOSY(a2)        ;'
		move.w d5,CNTBLSIZE(a2)      ;'
        rts							  ;}

.ptrtomap
	dc.l blarraycont+CNTBLMAP

SetColData:								 ;SetColData(  colptr)
;a4 = copptr
;a5 = colptr
;a6 = copptrlw                                        ;{
		move.l  draw_copper,a4          ;  copptr = draw_buffer;
		add.l   #2,a4                    ;  copptr += 10;
		move.l  a4,a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4        ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW,a6     ;  copptrlw += offsclpalettelw;
		btst.b  #0,EffInvert            ;  if(EffInvert)
		bne.s   .br1					 ;  {
		bsr.s   SetColDataDefault        ;	  SetColDataDefault();
		rts                              ;  }
.br1                                     ;  else
        bsr.s 	SetColDataInvert         ;    SetColDataInvert();
		rts                              ;}

SetColDataInvert:
		move.w  #7,d2					 ;  for(	x=0;x<8;x++)
.lp2                                     ;  {
		move.w  #31,d1		        	 ;  	for(	i=0;i<32;i++) {
.lp1                                     ;        *copptr.membar[z].
        move.w  (a5)+,d0                ;    	   .col[i] = !colptr[i]
		not.w   d0 				   		 ;   	   .collw[i] = !colptrlw[i];
		move.w  d0,(a4)
        move.w	(a5)+,d0
		not.w   d0
		move.w  d0,(a6)
    	addq.l  #4,a4                   ;  //ASM for i++ (go to n	ext coppos)
		addq.l  #4,a6
		dbf     d1,.lp1                 ;      }
		addq.l   #4,a4				 ;  //ASM for x++ (go to next membar)
		addq.l   #4,a6
		dbf     d2,.lp2				 ;  }
		rts								 ;}


SetColDataDefault:
		move.w  #7,d2					 ;  for(	x=0;x<8;x++)
.lp2                                     ;  {
		move.w  #31,d1		        	 ;  	for(	i=0;i<32;i++) {
.lp1                                     ;          *copptr.membar[z].
		move.w  (a5)+,(a4)              ;    		  .col[i] = colptr[i]
		move.w  (a5)+,(a6)              ;   		  .collw[i] = colptrlw[i];
    	addq.l  #4,a4                   ;  //ASM for i++ (go to next coppos)
		addq.l  #4,a6
		dbf     d1,.lp1                 ;      }
		addq.l   #4,a4				 ;  //ASM for x++ (go to next membar)
		addq.l   #4,a6
		dbf     d2,.lp2				 ;  }
		rts								 ;}

MoveData:                               ;MoveData(	input
;input                                  ;{
;d1 = blposx
;d2 = blposy
;d3 = detposx
;d4 = detposy
;d5 = size
;a5 = movex
;a6 = movey
;process
  move.w  (a5),d6                      ;  if(*movex != 0)
  beq.s   .br1                          ;  {
  move.w  d3,d0
  move.w  d1,a4
  bsr.s   MoveDataItem                  ;    MoveColDataItem( posdet,pos);
  move.w  a4,d1
  move.w  d0,d3
.br1                                    ;  }
  move.w  (a6),d6                      ;  if(EF1_MoveY != 0)
  beq.s   .br2                          ;  {
  move.w  d4,d0                        ;    MoveColDataItem( );
  move.w  d2,a4
  bsr.s   MoveDataItem
  move.w  a4,d2
  move.w  d0,d4
.br2                                    ;  }
  rts									;}

MoveDataItem:                        ;MoveDataItem(	posdet,pos)
;d6 = movedir
;d0 = posdet
;a4 = pos
  move.w  d5,d7                        ;{

  mulu.w  percentage,d7               ;    posdet -= size * prct / 100
  divu.w  #100,d7	                    ;                        * movedir;
  cmp.w   #0,d6
  bpl.s   .br3
  neg.w   d7
.br3
  sub.w   d7,d0
  moveq.l #2,d7                        ;    for(int i=0;i < 2; i++)
.lp1 									;    {
  move.w  d0,d0							;      if(posdet < 0)
  bpl.s   .br1                          ;      {
  beq.s   .br2
  add.w   d5,d0                        ;	     posdet += size;
  addq    #1,a4						;	     pos++;
  dbf     d7,.lp1
  bra.s   .br2
.br1									;      }
  cmp.w   d5,d0							;      else if(posdet >= size)
  blt.s   .br2							;      {
  sub.w   d5,d0							;	     posdet -= size;
  subq    #1,a4							;	     pos--;
.br2
  dbf     d7,.lp1                       ;      }                   				;    }
  rts									;}

percentage:
	dc.w 168;

MoveAdjust:
  move.w  percentage(pc),d7           ;    if(percentage <	200)
  cmp.w   #200,d7                      ;    {
  bge.s   .br4
  addq    #3,d7                        ;      percentage += 3;
  bra.s   .br5                          ;    } else
.br4                                    ;    {
  sub.w   d7,d7                         ;      percentage = 0;
.br5								    ;    }
  move.w  d7,percentage
  rts

CalculateFade:
	LEA	Temporaneo(PC),A0 	; Long temporanea per colore a 24
					; bit nel formato $00RrGgBb
	LEA	COLP0+2,A1		; Indirizzo del primo registro
					; settato per i nibble ALTI
	LEA	COLP0B+2,A2		; Indirizzo del primo registro
					; settato per i nibble BASSI

	MOVEQ	#8-1,d7			; 8 banchi da 32 registri ciascuno
ConvertiPaletteBank:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6	; 32 registri colore per banco

DaLongARegistri:	; loop che trasforma i colori $00RrGgBb.l nelle 2
			; word $0RGB,$0rgb adatte ai registri copper.

;	CALCOLA IL ROSSO

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%000011111111,D4	; SELECT BLUE
	MULU.W	ColMultiplier(PC),D4		; Eff0Multiplier
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%000011111111,D4	; SELECT BLUE VAL
	MOVE.L	D4,D5			; SAVE BLUE TO D5

;	CALCOLA IL VERDE

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%1111111100000000,D4	; SELECT GREEN
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	ColMultiplier(PC),D4	; Eff0Multiplier
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%0000000011111111,D4	; SELECT GREEN
	LSL.L	#8,D4			; <- 8 bits (so from 8 to 15)
	OR.L	D4,D5			; SAVE GREEN TO D5

;	CALCOLA IL BLU

	MOVE.L	(A3)+,D4		; READ COLOR FROM TAB AND GO TO NEXT
	ANDI.L	#%111111110000000000000000,D4	; SELECT RED
	LSR.L	#8,D4			; -> 8 bits (so from 8 to 15)
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	ColMultiplier(PC),D4	; Eff0Multiplier
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
				; del GREEN,"trasformandolo" in nibble alto
				; di del byte basso di D2 ($g0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24bit
	ANDI.B	#%00001111,d3	; Seleziona solo il nibble BASSO ($0b)
	or.b	d2,d3		; "FONDI" i nibble bassi di green e blu...
	move.b	d3,1(a2)	; Formando il byte basso finale $gb da mettere
				; nel registro colore,dopo il byte $0r,per
				; formare la word $0rgb dei nibble bassi

; Conversione dei nibble alti da $00RgGgBb (long) al colore aga $0RGB (word)

	MOVE.B	1(A0),d0	; Byte alto del colore $00Rr0000 in d0
	ANDI.B	#%11110000,d0	; Seleziona solo il nibble ALTO ($R0)
	lsr.b	#4,d0		; Shifta a destra di 4 bit il nibble,in modo
				; che diventi il nibble basso del byte ($0R)
	move.b	d0,(a1)		; Copia il byte alto $0R nel color register
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	ANDI.B	#%11110000,d2	; Seleziona solo il nibble ALTO ($G0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24 bit
	ANDI.B	#%11110000,d3	; Seleziona solo il nibble ALTO ($B0)
	lsr.b	#4,d3		; Shiftalo di 4 bit a destra trasformandolo in
				; nibble basso del byte basso di d3 ($0B)
	or.b	d2,d3		; Fondi i nibble alti di green e blu ($G0+$0B)
	move.b	d3,1(a1)	; Formando il byte basso finale $GB da mettere
				; nel registro colore,dopo il byte $0R,per
				; formare la word $0RGB dei nibble alti.

	addq.w	#4,a1		; Saltiamo al prossimo registro colore per i
				; nibble ALTI in Copperlist
	addq.w	#4,a2		; Saltiamo al prossimo registro colore per i
				; nibble BASSI in Copperlist

	dbra	d6,DaLongARegistri

	addq.l	#4,a1	        ; salta i registri colore + il dc.w $106,xxx
				; dei nibble ALTI
	addq.l	#4,a2	        ; salta i registri colore + il dc.w $106,xxx
				; dei nibble BASSI

	dbra	d7,ConvertiPaletteBank	; Converte un banco da 32 colori per
	rts				; loop. 8 loop per i 256 colori.

PalettePic:

	dc.l	$00000100,$00030005,$00000105,$0001000e,$00060000,$00000200
	dc.l	$00080100,$0000002a,$00000214,$00000121,$00030025,$00000219
	dc.l	$00000125,$00010400,$0000021d,$0000012f,$00020501,$00000044
	dc.l	$000a0301,$00000609,$0000023b,$0007040a,$000b0503,$00050804
	dc.l	$00040a0d,$001c1e33,$00252120,$00272025,$002c1f25,$00212320
	dc.l	$00272529,$00232729,$001a1ebc,$002b2826,$000028c7,$000029c0
	dc.l	$000f27b9,$00002bc2,$00002db5,$00042acb,$001426c1,$00002cc4
	dc.l	$000c2ba6,$00002dbd,$001825c8,$001f25b2,$001229b4,$00002fb0
	dc.l	$00072ad3,$00222797,$001a299e,$00112bad,$001927c2,$001f27ac
	dc.l	$00052dc5,$00192b99,$00162d8d,$00002ed3,$000e2ea1,$001729bc
	dc.l	$00212a8c,$001e29a6,$00062ec6,$002a288c,$001b28c4,$000c2ccd
	dc.l	$000d309c,$000030ce,$001a2d94,$00242a93,$001b2abd,$001e29c5
	dc.l	$001f2ca2,$001a2cb7,$00242e7b,$002a2d71,$00172faa,$00202ac6
	dc.l	$00212f88,$00102fc7,$000f30c1,$00202e9d,$0027316e,$001c2fb3
	dc.l	$000039b9,$001e32ae,$00213494,$003e3434,$00023cb5,$001736b8
	dc.l	$002933a3,$002336ab,$001b39a6,$001939b3,$00183aae,$003e3a39
	dc.l	$0041393e,$00233aa1,$00443843,$003a3c39,$00433b40,$00413f3e
	dc.l	$0030408c,$003d3e7a,$002e40a2,$003c409f,$0034439c,$003649b3
	dc.l	$0054504e,$00535057,$00424fa8,$00515350,$00565349,$004d546b
	dc.l	$004b55a5,$004657bf,$004a59b1,$005a5e71,$00525dad,$004f5dbd
	dc.l	$0064605e,$005a6179,$00606556,$00666267,$00626561,$00696463
	dc.l	$005b6ace,$00616ebf,$00606ec9,$00686fb9,$007a7076,$00767372
	dc.l	$006b72b4,$007075a6,$006b74d1,$006775db,$006a77c0,$007175c0
	dc.l	$006778d4,$006f77c7,$007478bd,$006e7bd1,$00787dbb,$00868180
	dc.l	$007581cb,$00828480,$0088828a,$008283b1,$007f8bd9,$00868bd1
	dc.l	$008f918e,$00818ee8,$009090ac,$00959190,$008990cd,$009b9094
	dc.l	$00909ae6,$00929ae1,$00979bc9,$00909af0,$00aa99a1,$00a59b9f
	dc.l	$00a29d9d,$00959cdc,$009d9f9c,$0098a3f9,$009fa5d9,$0099a5f2
	dc.l	$009da5e6,$009fa5e0,$009ea5ed,$00aca7a7,$00a4a9c7,$009faafa
	dc.l	$00b1acab,$00aaaaea,$00a5adea,$00adafbe,$00a9afdd,$00aaafe4
	dc.l	$00a8b1ff,$00aab1f9,$00bdb2b5,$00bab5b4,$00b5b7b4,$00b1bbff
	dc.l	$00c4bcc8,$00b9bdf2,$00c3bfbd,$00c5c1c6,$00bbc3ff,$00cbc6c5
	dc.l	$00c7c7d1,$00c7c6e4,$00c5c8ff,$00c5ccd4,$00c0cbff,$00d3cecc
	dc.l	$00ced0cc,$00cdcdff,$00c7cfff,$00ccd1fa,$00d0d4ea,$00d7d6da
	dc.l	$00d6d8d5,$00dcd7d5,$00d1d7ff,$00ddd7fd,$00d6dcff,$00e0decf
	dc.l	$00e6e1e0,$00dce2fe,$00e3e6e2,$00f1e4e5,$00e9e7eb,$00e4e9ff
	dc.l	$00f1ecea,$00f1ecff,$00f5edf9,$00e7f1ff,$00eeefff,$00f0f2ef
	dc.l	$00f2f2fc,$00fbf0f7,$00f5f2f6,$00f7f2f0,$00fef1f2,$00f5f4ff
	dc.l	$00f9f4f2,$00fff3ed,$00fbf3ff,$00eff7ff,$00faf5f3,$00f4f7f3
	dc.l	$00f3f7fa,$00fdf5ee,$00fff4f5,$00f7f6ff,$00fff4fb,$00f9f6fa
	dc.l	$00fbf6f5,$00fcf7f6,$00f8f9ef,$00fff7f0,$00f7f9f6,$00f8fae9
	dc.l	$00fbf8fd,$00fff7fd,$00fef8f7,$00f5fbfd,$00fff9f8,$00fffaf9
	dc.l	$00fafcf9,$00fffcfa,$00fffcff,$00fcfefb

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
ia
        lea      (a1,d4),a2

;input 
;d0: sizecol
;d1: invsin
;d2: slope
CalcRotation:                       ;CalcRotation(sizecol, 
                                    ;      slope, invsin) { 
  move.l  d0,d3                     ;  startpos = sizelinehor / 2;
 ;lsr.l   #9,d3                     ;  startpos =>> 8;
                                    ;  // /2 and to word = rshift 9
  move.l  d2,d4                     ;  tmp = 128*slope;
  lsr.l   d4                        ;  //*128 and to word = rshift 1
  sub.w   d4,d3                     ;  startpos -= tmp;
  move.l  d2,d4                     ;  
  add.l   d4,d4
  divu.w  d3,d4                     ;   
  lsr.l   #8,d0                     ;  sizelinehor =>> 8;  
  bsr.s  WriteCopper4Rotation       ;  WriteCopper4Rotation(sizelinehor
  rts								;                         , slope);								
                                    ;}

WriteCopper4Rotation:               ;WriteCopper4Rotation(sizelinehor
                                    ;                  slope,startpos);							
  movem.l  empty,d0-d7              ;{
  lea.l    EF4_STARTPOS1,a0
  move.l   view_cprlnsel,a3
  move.l   view_cprbitmap,a1
  moveq.l  #8-1,d3                  ;  for(x=0;x < 6;x++)
.lp2
  ;Calculate size horizontal line   ;  {
  move.l   (a2),d1                  ;    sizecol = frame.sizecol[x];
  move.l   EF5_LINEMULT(a5),d0      ;    invsin = frame.invsin[x];
  mulu.l   d0,d1                    ;    sizelinehor = sizecol*invsin
  lsr.l    #8,d1
  move.l   d1,d7
  sub.l    d0,d0                    ;
  move.l   #linebuffer,d0           ;    64kalign(linebuffer)
  add.l    #$10000,d0               ;   
  clr.w    d0  
  cmp.l    #320,d1                  ;    if(size > 320) sizepos = 320;             
  ble.s    .br1                     ;    else sizepos = size;
  move.l   #320,d1
.br1  
  sub.l    #MINLINE,d1
  moveq.l  #12,d2                   ;    bufferpos = 32*120*sizepos+linebuffer;
  lsl.l    d2,d1 
  add.l    d0,d1  
  swap     d1
  move.w   d1,2(a1)
  swap     d1
  move.l   a3,a4                    ;    curcopperpos = copperpos;
  moveq.l  #8-1,d4                  ;      tmp = (x-1)*4 + 6;
  sub.l    d3,d4                    ;
  lsl.l    #2,d4                    ;
  addq.l   #6,d4                    ;
  add.l    d4,a4                    ;    curcopperpos += tmp;
  move.l   d7,d2
  add.l    d7,d7    
  move.l   #640,d4                  ;     maxpos = 640; 
  cmp.l    d4,d7                    ;     if(size*2 < 640) {
  bge.s    .br3                     ;       maxpos =
  divu.l   d7,d4                    ;       (int)640/(size*2) *size*2;   
  mulu.l   d7,d4
  bra.s    .br2                     ;     }
.br3                                ;     else {
  move.l   d7,d4                    ;       maxpos = size * 2;
.br2                                ;     } 
  move.l   EF5_LINESHIFTS(a5),a6    ;   curlineshift = frame.lshift[x];
  move.l   d2,d7
  move.l   d7,d0                    ;   startpos = (size * 1.5) - 160;    
  lsr.l    d0  
  add.l    d7,d0
  sub.l    #160,d0
  move.l   d0,d2
  move.l   a6,d0
  divs.l   #2,d0                    ;     tmp = (word) lineshift * 128;
  sub.l    d0,d2                    ;     startpos -= tmp;
  move.l   d3,.save
  bsr.s    WriteCopperLine4Rotation ;    WriteCopperLine4Rotation2(linebuffer,
                                    ;         cutrstartposrstartpos, linesize);
  move.l   .save(pc),d3
  add.l    #FRM4SIZE,a0             ;    Startpos++;
  addq.l   #8,a1
  dbf      d3,.lp2                  ;  }
  rts                               ;}

.save
  dc.l 0
 
WriteCopperLine4Rotation:           ;WriteCopperLine4Rotation() {
  move.w   #256-1,d0                ;  for(i=0;i<256,i++) {
  lsl.l    #8,d4
  mulu.l    #256,d2
  move.l   d2,d3                    ;    effpos = curpos
.lp1 
  tst.l    d3                       ;    if(effpos < 0)
  bge.s    .br2                     ;    { 
  add.l    d4,d3                    ;      effpos += maxpos;
  bra.s    .br1
.br2                                ;    }
  cmp.l    d4,d3                    ;    else if(effpos > maxpos)
  ble.s    .br1                     ;    {
  sub.l    d4,d3                    ;      effpos -= maxpos;
.br1                                ;    }
  move.l   d3,d2                    ;    curpos = effpos
  lsr.l    #8,d2
  move.l   #320,d5                  ;    
  cmp.l    d5,d7                    ;    if(320 < linesize)
  ble.s    .br3                     ;    {
  sub.l    d7,d2                    ;      curpos -= linesize;
  bpl.s    .br4                     ;      if(curpos < 0) {
  add.l    d5,d2                    ;        curpos += 320
  bpl.s    .br3                     ;        if(curpos < 0)
  sub.l    d2,d2                    ;          curpos = 0;
  bra.s    .br3                     ;      }
.br4                                ;      else {
  sub.l    d7,d2                    ;        curpos -= linesize + 640
  add.l    #640,d2 
  cmp.l   d5,d2                    ;        if(curpos < 320)
  bge.s    .br3                     ;        {
  move.l   d5,d2                    ;         curpos = 320; }      
                                    ;      }
                                    ;    }
.br3                                ;    //Pixelexact offset part
  move.l   d2,d5                    ;    addroffs = curpos;
  and.l    #%11111,d5               ;    addroffs = tmp %11111;
  move.l   d5,d6                    ;    addroffs *= 128
  lsl.l    #7,d5
  move.l   d2,d6                    ;    tmp = curstartpos;
  lsr.l    #3,d6                    ;    tmp >= 3 & $fffc;
  and.l    #$fffc,d6
  add.l    d6,d5                    ;    addroffs += tmp;
  add.l    d1,d5                    ;    addroffs += bufferpos;
  move.w   d5,(a4)                  ;
  add.l    #36,a4
  add.l    a6,d3                    ;    effpos += *curposadd++;
  dbf      d0,.lp1                  ;  }
  rts                               ;}



DrawLines4Rotation: 
        lea      linebuffer,a2
		move.l   a2,d0 
		add.l    #$10000,d0          ;do not cross 64k border to optimize
		clr.w    d0                  ;copper
        moveq.l  #MINLINE,d7
.lp1
        sub.l    d3,d3               ;fill in parameters
		move.l   d7,d4
		move.l   d0,a2
		bsr.w    DrawLine4Rotation
        move.l   d0,a0               ;fill in parameters
        move.l   d0,d4
		add.l    #126,d4
        bsr.s    DrawLineSize4Rotation  
		add.l    #128*32,d0
.br1
		addq.w   #1,d7
        cmp.w    #320+1,d7
        bne.s    .lp1 	
        rts

.regsave dc.w 0								  
                                  

DrawLineSize4Rotation:            ;DrawLine4Rotation(writeptr, readptr) 
								  ;{
  move.w  #15*4096,d1             ;  bltconx = 15 >> 12
.wblit:                           ;  wblit();
  btst    #6,$2(a6)
  bne.s   .wblit 
  move.w  d1,$42(a6)   			  ;  set_register_bltcon1(bltconx)  
  or.w    #$9f0,d1                ;  bltconx.w |= 0x9f0
  move.w  d1,$40(a6)               ;  set_register_bltcon0(bltconx);
  move.l  #$ffffffff,$44(a6)       ;  set_register_bltafwm(#$0000fffe)
  move.w  #2,$64(a6)			  ;  set_register_bltamod(-2);
  move.w  #2,$66(a6)			  ;  set_register_bltdmod(-2);                                ;  set_register_bltdmod(-2);
  move.l  a0,$50(a6)				  ;  set_register_bltapt(readptr);
  ;subq.l  #2,d4                   ;  writeptr -= 2
  move.l  d4,$54(a6)               ;  set_register_bltdpt(writeptr);
  move.w  #31*64+63,$58(a6)		  ;  bltsize = 31*64+63; 
  rts                             ;}
	
DrawLine4Rotation:
        ;input
        ;d3 - offset
        ;d4 - block size
        ;a2 - write pos

        ;d1 - backup block size
        ;d2 - recent block cache§
        ;d3 - offset left
        ;d5 - line cache
        ;d6 - offset right

        ;calculate map position
        move.w   #31,.lwrdcounter

        ;Line Calculation
        sub.w     d6,d6
        sub.l     d5,d5                ;lw to write
        sub.l     d1,d1                ;cleanup d1
.ldrawbl2
        move.w    d4,d1                ;backup block size
        move.l    #-1,d2               ;startpattern whole lw line
.br5
        sub.w     #32,d1               ;lw
        sub.w     d3,d1                ;+ offset
        bpl.s     .bigblock            ;< block size?
.br1
        neg.w     d1                   ;get value for lshift
        cmp.w     #32,d1
        bgt.s     .clearalllw          ;offset greater than lw
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
        sub.w     #1,.lwrdcounter
        beq.s     .end
        sub.l     d5,d5                ;delete data
        sub.w     #32,d1
        sub.w     d4,d1                ;calc offset to left
        neg.w     d1
        move.w    d1,d3
        sub.w     d6,d6                ;lsr = 0
        bra.s     .ldrawbl2
.br3
        add.w     d4,d1                ;add empty space = startpos next block
		bpl.s     .br8
		add.w     d4,d1
		bmi.s     .br3
		beq.s     .br3
		sub.w     d6,d6
		sub.w     d4,d1
		neg.w     d1
		move.w    d1,d3
		bra.s     .ldrawbl2
.br8		
        cmp.w     #32,d1
        blt.s     .br4
        move.l    d5,(a2)+             ;write to buffer
        sub.l     d5,d5                ;reset recent buffer cache
        sub.w     #1,.lwrdcounter
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
        sub.w     #1,.lwrdcounter
        beq.s     .end
        sub.w     #32,d1
        bpl.s     .bb2
.bb1
        sub.l     d5,d5
        sub.l     d6,d6
        sub.l     d3,d3
        bra.w     .br1

.bigspace
        moveq.l    #0,d2
.bs1
        move.l     d2,(a2)+
        sub.w      #1,.lwrdcounter
        beq.s      .end
        sub.w      #32,d1
        cmp.w      #32,d1
        bge.s      .bs1
        bra.s      .br4

.lwrdcounter: dc.w 40

;1 - depth
        ;2 - index
        ;3 - output register

DrawBlankLine:
        IFEQ BLITTER-0
        move.l    currentdrawpos,a5
        REPT 10
        move.l    #0,(a5)+
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
		sub.l    d5,d5
        move.w   DIMDEPTH(a0),d5
        subq     #1,d5
        lea      DIMCONTENT(a0),a1           ; load start of ptr list
        move.l   a1,.contentptr              ; save ptr list pos
.lp1
        move.l   (a1),a1                     ; load ptr to first layer
        move.l   draw_copper,copperpos
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
        lsr.w    #5,d1               ; divide through 32
        lsl.w    #2,d1               ; start pos for x in bytes rounded to lw
        move.w   d1,d6               ; save blxpos
        move.w   DIMWIDTH(a0),d0
        mulu.w   (a5),d0
        add.w    d1,d0
        move.l   CNTBLMAP(a1),blmappos
        move.l   CNTBLLNFLAG(a1),bllnflagpos
        add.l    d0,blmappos
        IFEQ CHKBLLINE-0
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

        move.w    (a5),mapypos

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
        move.b   #$2c,d6
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
        cmp.w    #0,(a5)                 ; check for line marker empty
        beq.s    .br8
        ;lea        DrawBlankline,a4
        bsr.w      DrawBlankLine
        bra.s    .br10
.br8
        ;move.l    .lfuncbak,a4
        ENDC

        movem.l         a1-a3/a6/d0-d1/d4-d6,.saveregs
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
		beq.s           .br11
.llftspcempty
        add.w           d4,d1             ;get pixels left to draw y for space
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
.br11
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
        move.l          (a1),a1              ;load content of ptr
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
         add.l    #BPLWIDTH,currentdrawpos
         sub.l    d4,d4
         ;Revert bitplanepointer
         move.w   CNTHEIGHT(a1),d7          ;Number of blocks
         move.w   d7,d4			     ;Copy to d7 we need d7 later
	 lsl      d4                         ;One block line and one block gap
	 mulu.w   #BPLWIDTH,d4               ;Get Number of Bytes

.lp2 ;Loop for whole map

         sub.l    d4,currentdrawpos         ;Revert bplpointer
	 subq.w   #1,d7                     ;Prepare use of d0 as loopcounter

.lp1 ; Loop for one lines of block
         ;Copper for Block
         move.w   CNTBLSIZE(a1),d1
         subq.w   #1,d1
	 ;Different Copperroutine for first plane
	 cmp.w    #0,d5
	 bne.s    .br1
         bsr.s    WriteCopper
         bra.s    .br2
.br1
         bsr.w    WriteCopperPosAdd
.br2
         cmp.w    #0,d0
         beq.s    .br3

         add.l    #BPLWIDTH,currentdrawpos

         ;Copper for Space
         move.w   CNTSPSIZE(a1),d1
		 beq.s    .br6
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
.br6
	 add.l    #BPLWIDTH,currentdrawpos
	 dbf      d7,.lp1
         move.w   CNTHEIGHT(a1),d7          ;Restore d7
	 bra.s    .lp2
.br3
	 rts

.backup:
         dc.w 0

WriteCopper:
        move.l   copperpos(pc),a5
        move.b   #$1,d3
        move.l   currentdrawpos,d2
.lp1
        move.b   d6,(a5)
        addq.w   #6,a5
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
        dbf      d1,.lp1
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
        move.l   copperpos(pc),a5
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
        dbf      d1,.lp1
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
        move.w          #10,a2            ;lwcount = 10;
        moveq           #-1,d2            ;most_left_block = $ffff....,
        moveq           #32,d3            ;most_left_block << (32 - width)
        sub.w           d0,d3             ;
        lsl.l           d3,d2             ;
        move.l          d2,d6             ;most_right_block = most_left_block;
        rol.l           d0,d6             ;most_right_block =
        ;get lw pos                       ; rotateleft(most_left_block,width);
        ;calculate complete block size
        move.w          d0,d7             ;//move width to d7
        add.w           d5,d0             ;widthincspace = width + space;
        move.l          #31,a1            ;ptrntotest = 31;
        lea             dldata(pc),a0     ;
        move.w          .init(pc),(a0)+   ;binary = init;
        move.w          d1,d4             ;shift = offset
        ;get 1st block with offset
        move.l          d2,d3             ;recentblock = most_left_block
        lsl.l           d4,d3             ;recentblock =<< shift;
        ;Write Single block
        bsr.w           WriteBlock1       ;writeblock1();
        subq            #1,a1             ;ptrntotest--;
        move.l          d2,d3             ;recentblock = most_left_block;
        move.l          d0,d5             ;
        sub.l           d4,d5             ;positionlw = widthincspace -
        move.w          d5,d4             ;                           offset;
        move.l          d7,d1             ;//blocksize without space to d1
.lp1
        cmp.w           #-1,a1            ;do {
        beq.s           .resetmap
.br6
        move.l          d3,d7             ;  oldblock = recentblock;
        lsr.l           d5,d3             ;  recentblock =>> positionlw;
        beq.s           .br2              ;  if(	recentblock != 0) {
		;  //block at least partly in this lw
        cmp.l           d3,d6             ;    if(  recentblock >
        ble.s           .br5              ;          most_right_block) {
        ;//block partly in this lw
        cmp.w           #1,a2             ;      if(  lwcount == 1)
        bne.s           .br3              ;      {
        bsr.s           WriteBlock1       ;        writeblock1();
										  ;        finish_preprocess();
        bra.s           .br4              ;      } else {
										  ;			process_part_block();
										  ;      }
.br5                                      ;    } else {
                                          ;    //block completely in this lw
        bsr.s           WriteBlock1      ;     writeblock1();
        add.w           d0,d4             ;      offset += widthincspace;
        move.l          d0,d5             ;      positionlw = widthincspace;
        subq            #1,a1             ;      ptrntotest--;
        bra.s           .lp1              ;    }
.br2                                      ;  } else {
										  ;  //block in next lw
        subq            #1,a2             ;    lwcount--;
        cmp.w           #0,a2             ;    if(  lwcount > 0)
        beq.s           .br4              ;    {
        sub.w           #32,d4            ;      positionlw -= 32;
        move.w          .writelw(pc),(a0)+;      binary += writelw;
        move.w          .init(pc),(a0)+   ;      binary += init;
        ror.l           d0,d7             ;      oldblock =
										  ;        rotateright(	widthincspace)
        move.l          d7,d3             ;      recentblock = oldblock;
        bsr.s           WriteBlock1       ;      writeblock1();
        subq            #1,a1             ;      ptrntotest--;
        add.w           d0,d4             ;      offset += widthincspace;
        bra.s           .lp1              ;    } else finish_preprocess();
		                                  ;  }
										  ;  if(ptrntotest < 0)resetmap();
										  ;}

.br3                                      ;process_part_block() {
        add.w            d1,d4            ;  bitsoverflow   = positionlw
        sub.w            #32,d4           ;                       + width - 32;
        move.w           d1,d7            ;  shift = width - bitsoverflow;
        sub.w            d4,d7            ;
        move.l           d2,d5            ;  nextblock = most_left_block
        lsl.l            d7,d5            ;  						  << shift;
        add.w            d4,d7            ;  shift += bitsoverflow //width
        bsr.s            WriteBlock2      ;  writeblock2();
        sub.w            d1,d4            ;  positionlw -= width;
        add.w            d0,d4            ;  positionlw += widthincspace;
        subq             #1,a2            ;  lwcount--;
        beq.s            .br4             ;  if(lwcount == 0)
										  ;		finish_preprocess();
        subq             #1,a1  		  ;  ptrntotest--;
        move.l           d2,d3            ;  recentblock = most_left_block;
        move.l           d4,d5            ;  calc = positionlw;
        bra.s            .lp1             ;}
.br4                                      ;finish_preprocess() {
        move.w           .writelw(pc),(a0)+ ;binary += init;
        move.w           .end(pc),(a0)+   ;  binary += end;
        rts                               ;}

.resetmap
        move.w           .mapfwd,(a0)+    ;resetmap() {
        move.l           #31,a1           ;ptrntotest = 31;
        bra.w            .br6             ;}

.init
        sub.l           d4,d4

.end
        rts

.writelw
        move.l          d4,(a2)+

.mapfwd
        move.l          (a5)+,d0

WriteBlock1:                              ;writeblock1()
;input
;a1 - pattern position to test
;d3 - block data
                                          ;{
        move.w          .bl1(pc),(a0)+    ;  binary += bl1.readword();
        move.w          a1,(a0)+          ;  binary += (word) ptrntotest;
        move.l          .bl1+4(pc),(a0)+  ;  binary += bl1.readlw();
        move.l          d3,(a0)+          ;  binary += recentblock();
        rts                               ;}

.bl1
        btst.l          #31,d0
        beq.s           .br1
        or.l            #$fff00000,d4
.br1

WriteBlock2:                               ;WriteBlock2() {
;input
;a1 - pattern pos to test
;d3 - block data w
;d5 - block data lw
                                           ;{
        move.w          .bl2(pc),(a0)+     ;  byte += block2.readword();
        move.w          a1,(a0)+           ;  byte += ptrntotest;
        cmp.l           #$ffff,d3          ;  if(recentblock <= $ffff)
        bhi.s           .br3               ;  {
        move.l          .bl2+4,(a0)+       ;    byte += block2.readlw();
        move.w          d3,(a0)+           ;    byte += (word) recentblock;
        bra.s           .br4               ;  }
.br3                                       ;  else {
        move.b          .bl2+4,(a0)+       ;    byte +=  block2.readbyte();
        move.b          #$10,(a0)+         ;    byte +=  10;
        move.w          .writelw(pc),(a0)+ ;    byte +=  writelw;
        move.l          d3,(a0)+           ;    byte +=  recentblock;
.br4                                       ;  }
        move.l          .bl2+10,(a0)+      ;  byte += readbyte();
        move.l          d5,(a0)+           ;  byte += nextblock;
.br5                                       ;
        move.l          .bl2+18,(a0)+      ;  byte += block2.readlw();
        move.w          .bl2+22,(a0)+      ;  byte += block2.readword();
        rts                                ;}

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
        move.w   #10,.lwrdcounter

        IFEQ BLITTER-0

        ;Line Calculation
        move.w   CNTBLSIZE(a1),d4      ;get width block
        move.w    (a3),d3              ;xpos (offset)
        lea      mapypos(pc),a3
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
        sub.w     #1,.lwrdcounter
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
        subq      #1,d7
        beq.s     .mapfwd
        add.w     (a6),d1   ;add blspace = startpos next block
        cmp.w     #32,d1
        blt.s     .br4
        move.l    d5,(a2)+
        sub.l     d5,d5
        sub.w     #1,.lwrdcounter
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
        sub.w     #1,.lwrdcounter
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
        sub.w      #1,.lwrdcounter
        beq.s      .end
        sub.w      #32,d1
        cmp.w      #32,d1
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
.blstruct: dc.l blarraycont,blarraycont2,blarraycont3,blarraycont4
	   dc.l blarraycont5,blarraycont6,blarraycont7,blarraycont8

blarraycont:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 7
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blpfrstrt: dc.w 99
.blmap: dc.l blmap8
.bllnflag: dc.l bllnflag8
.blheight: dc.w 2

blarraycont2:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 8
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 99
.blmap: dc.l blmap7
.bllnflag: dc.l bllnflag7
.blheight: dc.w 2

blarraycont3:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 9
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstart: dc.w 66
.blmap: dc.l blmap6
.bllnflag dc.l bllnflag6
.blheight: dc.w 2

blarraycont4:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 10
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 66
.blmap: dc.l blmap5
.bllnflag dc.l bllnflag5
.blheight: dc.w 2

blarraycont5:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 14
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blpfrstrt: dc.w 34
.blmap: dc.l blmap4
.bllnflag: dc.l bllnflag4
.blheight: dc.w 2

blarraycont6:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 14
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 34
.blmap: dc.l blmap3
.bllnflag: dc.l bllnflag3
.blheight: dc.w 2

blarraycont7:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 12
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstart: dc.w 1
.blmap: dc.l blmap2
.bllnflag dc.l bllnflag2
.blheight: dc.w 2

blarraycont8:
.posx: dc.w 0
.posy: dc.w 0
.blsize: dc.w 12
.spsize: dc.w 0
.blposy: dc.w 1-1
.blposx: dc.w 1
.blfrstrt: dc.w 1
.blmap: dc.l blmap
.bllnflag dc.l bllnflag
.blheight: dc.w 2

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
CNTOBJSIZE = 24

empty: dcb.l 52,0

      INCLUDE graphics.s
      
 END

