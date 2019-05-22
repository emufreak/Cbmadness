DEBUG = 0
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
    endc						;NO COPPER-IRQ!
	
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
        dc.w 5000

jmplistpos:
        dc.l  jmplist
jmplist:
        bra.w Effect1_1
        rts

BLINCREMENT = 1
SPINCREMENT = 2
FRAMES=150

Effect1_1:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)

        subq    #1, .counter		    ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitPlanePointers     ;  SetBitplanePointers();
        move.w  #1, .counter            ;  counter = 1; //50 fps
        move.w  #$00f,$dff180           ;  Req_Col0 = 00f; //Coppermonitor
		lea     .frame, a3              ; 
		lea     EF1_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l   #FRMSIZE*7, a1           ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1), a6
		sub.l   #4, a6	
		lea     blarraydim, a0			;  blarraydim.width = 
		move.w  (a6), DIMWIDTH(a0)	;  	        *blarraycont.data.width;
		move.w  2(a6), DIMHEIGHT(a0)	;  blarraydim.height =	  
										;  		    blarraycont.data.height;
        moveq.l #7,d0				    ;  for(int i=0;i<8;i++) { 
.lp1  									;    SetFrameDefault(	 
		bsr.w   SetFrameDefault			;    frmdat, laydat, frame);
		sub.l   #FRMSIZE, a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE, a2         ;    laydat++;
		dbf     d0, .lp1			    ;  } 
		
		move.l  .colptr(pc), a5
		bsr.s   SetColData				;  SetColData(  colptr);
		lea	   .colptr, a5
	    add.l  #2, (a3)				    ;  frame++
		cmp.l  #134,(a3)                ;  if(frame > 66) {
		bne.s  .br2                     ;    frame = 0;
		move.l 	#0,(a3)                 ;    colptr = EF1_COLOR0; 
		move.l  EF1_COLOR0,(a5)         ; }
		bra.s   .br3                    ; else 
.br2                                    ; {
		add.l  #1024, (a5)     	    	;   colptr++	
.br3                                    ; }
		bsr.w  DrawLines                ;  DrawLines(blarraydim); 
	    move.w #$c00,$dff106            ;  Reg_Col0 = 00;
	    move.w #$0,$dff180
.br1        							;}
        bra.w  MlGoon
		
.counter: dc.w 1
.frame: dc.l 0
.colptr: dc.l EF1_COLOR0

Break:
    rts

SetFrameDefault:					    ;SetFrameDefault(  frmdat,
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
		move.l (a1), CNTBLMAP(a2)       ;  *frmdat.blmap = *frmdat.blmap
		add.l   (a3), a1                ;  //Get to right frame
		move.w FDOPOSX(a1), CNTBLPOSX(a2) ;  *frmdat.posx[frame] = *frmdat.posx
		move.w FDOPOSY(a1), CNTBLPOSY(a2) ;  '
		move.w FDOPOSXDET(a1), CNTPOSX(a2) ;'
		move.w FDOPOSYDET(a1), CNTPOSY(a2) ;'
		move.w FDOBLSIZE(a1), CNTBLSIZE(a2) ;'
		sub.l   (a3), a1                ;  //Get to right frame
        rts								;}

.ptrtomap
	dc.l blarraycont+CNTBLMAP
	
SetColData:								 ;SetColData(  colptr) 	
;a4 = copptr 
;a5 = colptr
;a6 = copptrlw 
;d0 = i      
                                         ;{	
		move.l  draw_copper, a4          ;  copptr = draw_buffer;
		add.l   #2,a4                    ;  copptr += 10;
		move.l  a4, a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4        ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW, a6     ;  copptrlw += offsclpalettelw;
br1
		move.w  #7,d2					 ;  for(	x=0;x<8;x++) 
.lp2                                     ;  {
		move.w  #31,d1		        	 ;  	for(	i=0;i<32;i++) {
.lp1                                     ;          *copptr.membar[z].
		move.w  (a5)+, (a4)              ;    		  .col[i] = colptr[i] 
		move.w  (a5)+, (a6)              ;   		  .collw[i] = colptrlw[i];
    	addq.l  #4, a4                   ;  //ASM for i++ (go to next coppos)
		addq.l  #4, a6
		dbf     d1, .lp1                 ;      }
		addq.l   #4, a4				 ;  //ASM for x++ (go to next membar)    	
		addq.l   #4, a6
		dbf     d2, .lp2				 ;  }	
		rts								 ;}


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
		beq.s           .br11
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
        move.w          #10,a2            ;lwcount = 10;
        moveq           #-1,d2            ;most_left_block = $ffff....,
        moveq           #32,d3            ;most_left_block << (32 - width)
        sub.w           d0,d3             ;
        lsl.l           d3,d2             ;                       
        move.l          d2,d6             ;most_right_block = most_left_block;
        rol.l           d0,d6             ;most_right_block = 
        ;get lw pos                       ; rotateleft(most_left_block, width);
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

      INCLUDE sources:graphics.s
   SECTION FRAMEDATA,DATA
      INCLUDE sources:FrameData.i	
	
 END

