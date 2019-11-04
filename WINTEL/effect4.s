ef4_frame: dc.l 0
ef4_colptr: dc.l EF31_COLORS1

Effect4_11:  
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea    EF3_PATTERNDATA0,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA1,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA2,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA3,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA4,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA5,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea    EF3_PATTERNDATA6,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  lea    EF3_PATTERNDATA7,a0
  move.l #PTR_EMPTY_DATA,(a0)
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180  
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA5,a0 
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_12:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w   #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA4,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_13:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w   #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA3,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_14:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w   #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA2,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_15:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w   #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA1,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_16:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w   #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA0,a0
  move.l #PTR_CHECKERBOARD_DATA,(a0)
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  
  lea    EF3_PATTERNDATA7,a0
  move.l #PTR_CHECKERBOARDTNL_DATA,(a0)
  move.l #EF32_COLORS1,ef4_colptr
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  move.l #0,ef4_frame
  
  bra.w  mlgoon
  
.counter dc.w 39

Effect4_2:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect41_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
.br2
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  lea    EF3_PATTERNDATA7,a0
  move.l #PTR_CHECKERBOARDTNL_DATA,(a0)
  move.l #EF32_COLORS1,ef4_colptr
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  move.l #0,ef4_frame
  bra.w  mlgoon
  
.counter dc.w 530
  
Effect4_3:
  ;move.w #$f,$dff180
  move.w #1,Eff3ZoomIn
  lea 	 blarraycont,a0
  move.w #10,CNTHEIGHT(a0)
  bsr.w  Effect42_Main
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  ;cmp.l   #0,ef4_frame
  ;bne.s   .br2
  ;move.l  #EF3_COLORS1,ef4_colptr  
.br2
  cmp.w  #16,P61_Pos
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  lea 	 blarraycont,a0
  move.w #2,CNTHEIGHT(a0)
  bra.w  mlgoon

Effect41_Main:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)
        subq    #1,.counter		        ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitplanePointers     ;  SetBitplanePointers();
        move.w  #1,.counter             ;  counter = 1; //50 fps
		lea     ef4_frame,a3
		lea     EF3_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l nam  #FRMSIZE*7,a1         ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1),a6
		sub.l   #4,a6
		lea     blarraydim,a0			;  blarraydim.width =
		move.w  (a6),DIMWIDTH(a0)	    ;  	        *blarraycont.data.width;
		move.w  2(a6),DIMHEIGHT(a0)	    ;  blarraydim.height =
										;  		    blarraycont.data.height;
        move.w   #7,.i     		        ;  for(int i=0;i<8;i++)
.lp1  									;  {
		move.l  (a1),CNTBLMAP(a2)       ;    *frmdat.blmap = *laydat.blmap
		bsr.w   GetFrame3        		;    GetFrame(  framedate,frmnr)
		bsr.w   SetFrame                ;    SetFrame(  input,laydat)
		sub.l   #FRMSIZE3,a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE,a2          ;    laydat++;
		sub.w   #1,.i
		bpl.s   .lp1			        ;  }
		
        bsr.w    MoveAdjust             ;  MoveAdjust( );
		move.l  ef4_colptr,a5
		
		movem.l d0-d7/a0-a6,.save

		move.l  draw_copper,a4          ;  copptr = draw_buffer;
		add.l   #2,a4                   ;  copptr += 10;
		move.l  a4,a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4       ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW,a6     ;  copptrlw += offsclpalettelw;
		lea.l   blarraycont2,a0		
		sub.l   d5,d5
		move.w  CNTBLSIZE(a0),d5
		lsl.l   #8,d5                   ;  intensity = frmdat[7].size*256/320
		divu.l  #320,d5
		and.l   #$ffff,d5
		move.l  draw_copper,a4          ;  copptr = draw_buffer;
		add.l   #2,a4                   ;  copptr += 10;
		move.l  a4,a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4       ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW,a6     ;  copptrlw += offsclpalettelw;
		moveq.l #3,d2                   ;  repeats = 3
		bsr.w   SetColDataFade		    ;  SetColDataFade(intensity, repeats,colptr);
		
    	movem.l .save,d0-d7/a0-a6		
		cmp.w   #0,Eff3ZoomIn           ;  if(Eff3ZoomIn( )
		beq.s   .br3                    ;  {
		lea	    ef4_colptr,a5               
		move.l  .direction,d1
	    add.l   d1,(a3)					;    frame += direction
		move.l  .dircolor,d2
		cmp.w   #39,.counter2           ;    if(counter2 > 40) 
		bne.s   .br3                    ;    {
		move.w 	#0,.counter2            ;      counter2 = 0:
		add.l   d2,(a5)                 ;      colptr++;
		move.l  (a5),a1                 ;  		
		cmp.l   #$-1,(a1)               ;     if(*colptr == -1)    
        bne.s   .br3                    ;     {
        move.l  #EF31_COLORS1,ef4_colptr ;        colptr = &EF3_COLORS1;		
		                                ;     }   										
.br3                                    ;    }
        cmp.l  #546,(a3)                ;    if(frame > 270)
		bne.s  .br2
		move.l #0,(a3)
.br2
        add.w  #1,.counter2
		bsr.w  DrawLines                ;  DrawLines(blarraydim);
.br1        							;}
        rts

.save dcb.l 15,0
.i dc.w 7
.counter: dc.w 1
.counter2: dc.w 1
.direction: dc.l 2
.dircolor: dc.l 1024
.inverted dc.b 0,0		
		
Effect42_Main:
;a0 = blarraydim
;a1 = frmdat[]
;a2 = laydat
;a3 = frame
;a4 = reserved SetColData
;a5 = colptr
;a6 = *blarraycont.data (temp)
        subq    #1,.counter		        ;if(counter-- == 0)
        bne.w   .br1				    ;{
        bsr.w   SetCopperList			;  Setcopperlist();
        bsr.w   SetBitplanePointers     ;  SetBitplanePointers();
        move.w  #1,.counter             ;  counter = 1; //50 fps
		lea     ef4_frame,a3
		lea     EF3_PATTERNDATA7,a1		;  frmdat = EFF1_PATTERNDATA7
		;sub.l nam  #FRMSIZE*7,a1         ; DEBUG
		lea	    blarraycont,a2			;  laydat = blarraycont.data
		move.l  (a1),a6
		sub.l   #4,a6
		lea     blarraydim,a0			;  blarraydim.width =
		move.w  (a6),DIMWIDTH(a0)	    ;  	        *blarraycont.data.width;
		move.w  2(a6),DIMHEIGHT(a0)	    ;  blarraydim.height =
										;  		    blarraycont.data.height;
        move.w   #7,.i     		        ;  for(int i=0;i<8;i++)
.lp1  									;  {
		move.l  (a1),CNTBLMAP(a2)       ;    *frmdat.blmap = *laydat.blmap
		bsr.w   GetFrame3        		;    GetFrame(  framedate,frmnr)
		bsr.w   SetFrame                ;    SetFrame(  input,laydat)
		sub.l   #FRMSIZE3,a1		    ;  	 frmdat++; //Next object
		add.l   #CNTOBJSIZE,a2          ;    laydat++;
		sub.w   #1,.i
		bpl.s   .lp1			        ;  }
		
        bsr.w    MoveAdjust             ;  MoveAdjust( );
		move.l  ef4_colptr,a5
		
		movem.l d0-d7/a0-a6,.save

		move.l  draw_copper,a4          ;  copptr = draw_buffer;
		add.l   #2,a4                   ;  copptr += 10;
		move.l  a4,a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4       ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW,a6     ;  copptrlw += offsclpalettelw;
		lea.l   blarraycont2,a0		
		sub.l   d5,d5
		move.w  CNTBLSIZE(a0),d5
		lsl.l   #8,d5                   ;  intensity = frmdat[7].size*256/320
		divu.l  #320,d5
		and.l   #$ffff,d5
		move.l  draw_copper,a4          ;  copptr = draw_buffer;
		add.l   #2,a4                   ;  copptr += 10;
		move.l  a4,a6                   ;  copptrlw = copptr;
		add.l   #OFFSCLPALETTE,a4       ;  copptr += offsclpalette;
		add.l   #OFFSCLPALETTELW,a6     ;  copptrlw += offsclpalettelw;
		cmp.b   #1,.inverted
		beq.s   .br4
		moveq.l #3,d2                   ;  repeats = 3tet
		bsr.w   SetColDataFade		    ;  SetColDataFade(intensity, repeats,colptr);
		bra.s   .br5
.br4
        sub.l   d2,d2                   ;  intensitywhite = 255 - intensity 
		move.b  d5,d2
		not.b   d2
		move.l  d2,a0
		moveq.l #3,d2                   ;  repeats = 3
        bsr.w   SetColDataFadeWhite
.br5
        cmp.b   #0,.inverted             
		beq.s   .br6		
        sub.l   d2,d2                   
		move.b  d5,d2                   ;  
		not.b   d2                      ;  blackinnerlayer = 255 - intensity		
		lea.l   blarraycont,a1          ;     
		move.w  CNTBLSIZE(a1),d3
		mulu.w  d3,d5                   ;  intensity *= sizebglayer / 320;
		divu.l  #320,d5
        mulu.w  d3,d2                   ;  blackinnerlayer *= sizebglayer / 320;
		divu.l  #320,d2
		add.l   d5,d2                   ;  intensitywhite = 255 - 
	    not.b   d2                      ;  (blackinnerlayer + intensity)
		move.l  d2,a0  
		moveq.l #3,d2                   ;  repeats = 3
		bsr.w   SetColDataFadeWhite		;  SetColDataFade(intensity);
        bra.s   .br7
.br6
		sub.l   d2,d2                   ;  intensitywhite = (255 - intensity)
		move.b  d5,d2
		not.b   d2
		lea.l   blarraycont,a1         
		move.w  CNTBLSIZE(a1),d3
		mulu.w  d3,d5                   ;  intensity *= sizebglayer / 320;
		divu.l  #320,d5
		mulu.w  d3,d2                   ;  intensitywhite *= sizebglayer / 320;
		divu.l  #320,d2
		move.l  d2,a0
		moveq.l #3,d2                   ;  repeats = 3
		bsr.w   SetColDataFadeWhite  	;  SetColDataFade(intensity);
.br7
    	movem.l .save,d0-d7/a0-a6		
		cmp.w   #0,Eff3ZoomIn           ;  if(Eff3ZoomIn( )
		beq.s   .br3                    ;  {
		lea	    ef4_colptr,a5               
		move.l  .direction,d1
	    add.l   d1,(a3)					;    frame += direction
		move.l  .dircolor,d2
		cmp.w   #39,.counter2           ;    if(counter2 > 40) 
		bne.s   .br3                    ;    {
		move.w 	#0,.counter2            ;      counter2 = 0:
		add.l   d2,(a5)                 ;      colptr++;
		move.l  (a5),a1                 ;  		
		cmp.l   #$-1,(a1)               ;     if(*colptr != -1)    
        bne.s   .br3                    ;     {
        move.l  #EF32_COLORS1,ef4_colptr ;        colptr = &EF3_COLORS1;		
		                                ;     }   										
.br3                                    ;    }
        cmp.l  #546,(a3)                ;    if(frame > 270)
		bne.s  .br2
		move.l #0,(a3)
		bchg.b #0,.inverted
.br2
        add.w  #1,.counter2
		bsr.w  DrawLines                ;  DrawLines(blarraydim);
.br1        							;}
        rts
	
.save dcb.l 15,0
.i dc.w 7
.counter: dc.w 1
.counter2: dc.w 1
.direction: dc.l 2
.dircolor: dc.l 1024
.inverted dc.b 0,0