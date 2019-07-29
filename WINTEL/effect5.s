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

;a4 = copptr
;a5 = colptrhw
;a6 = copptrlw   

  movem.l empty,a0-a5/d0-d7
  move.w  #$c00,$dff106
  move.w  #$0,$dff180
  bsr.w   SetCopperList4Rotation  
  move.l  .colptr(pc),a5
  move.l  draw_cprpalh,a4
  move.l  draw_cprpall,a6 
  bsr.w   SetColDataDefault 
  move.l  .colptr(pc),a5
  add.l   #1024,a5
  cmp.l   #$0fffffff,(a5)   
  bne.s   .br5
  lea.l   EF51_COLORS1,a5
.br5  
  move.l  a5,.colptr 
  move.l  .frmpos,a5  
  move.l  .lineshiftpos,a6 
  move.l  .linesizepos,a2  
  
  movem.l  empty,d0-d7              ;{
  lea.l    EF4_STARTPOS1,a0
  move.l   view_cprlnsel,a3
  move.l   view_cprbitmap,a1
  moveq.l  #8-1,d3                  ;  for(x=0;x < 6;x++)
.lp2
  bsr.w    WriteCopper4Rotation
  dbf      d3,.lp2
  
  addq.l  #4,a5
  addq.l  #4,a6
  
  cmp.l   #$0fffffff,(a5)          
  bne.s   .br3
  lea.l   EF51_LINEMULTIPLIERS,a5
  lea.l   EF51_LINESHIFTS,a6
.br3
  addq.l  #4,a2
  cmp.l   #$0fffffff,(a2)          
  bne.s   .br2
  lea.l   EF51_LINESIZE,a2
.br2
  move.l  a5,.frmpos
  move.l  a6,.lineshiftpos
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
  
.frmpos: 
  REPT 8
  dc.l EF51_LINEMULTIPLIERS
  ENDR
.lineshiftpos: dc.l EF51_LINESHIFTS
.linesizepos: dc.l EF51_LINESIZE
.colptr dc.l EF51_COLORS1

Effect5_21:
  lea.l  COLRBPLCON0_1,a0
  move.w #$1200,2(a0)
  lea.l  COLRBPLCON0_2,a0
  move.w #$1200,2(a0)
  bsr.w  Effect_52x
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon 

.counter: dc.w 10*50
  
Effect5_2Ol:

;a4 = copptr
;a5 = colptrhw
;a6 = copptrlw   

  movem.l empty,a0-a5/d0-d7
  move.w  #$c00,$dff106
  move.w  #$0,$dff180
  bsr.w   SetCopperList4Rotation  
  move.l  .colptr(pc),a5
  move.l  draw_cprpalh,a4
  move.l  draw_cprpall,a6 
  bsr.w   SetColDataDefault 
  move.l  .colptr(pc),a5
  ;add.l   #1024,a5
  cmp.l   #$0fffffff,(a5)   
  bne.s   .br5
  lea.l   EF51_COLORS1,a5
.br5  
  move.l  a5,.colptr 
  move.l  .frmpos,a5  
  move.l  .lineshiftpos,a6 
  move.l  .linesizepos,a2  
  
  movem.l  empty,d0-d7              ;{
  lea.l    EF4_STARTPOS1,a0
  move.l   view_cprlnsel,a3
  move.l   view_cprbitmap,a1
  moveq.l  #8-1,d3                  ;  for(x=0;x < 6;x++)
.lp2
  bsr.w    WriteCopper4Rotation
  dbf      d3,.lp2
 
  addq.l  #4,a5
  addq.l  #4,a6
  
  cmp.l   #$0fffffff,(a5) 
  bne.s   .br3
  lea.l   EF52_LINEMULTIPLIERS,a5
  lea.l   EF52_LINESHIFTS,a6
.br3
  ;addq.l  #4,a2
  cmp.l   #$0fffffff,(a2)          
  bne.s   .br2
  lea.l   EF52_LINESIZE_0,a2
.br2
  move.l  a5,.frmpos
  move.l  a6,.lineshiftpos
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
  
.frmpos: dc.l EF52_LINEMULTIPLIERS
.lineshiftpos: dc.l EF52_LINESHIFTS
.linesizepos: dc.l EF52_LINESIZE_0
.colptr dc.l EF51_COLORS1

Effect_52x:

;a4 = copptr
;a5 = colptrhw
;a6 = copptrlw   

  movem.l empty,a0-a5/d0-d7
  move.w  #$c00,$dff106
  move.w  #$0,$dff180
  bsr.w   SetCopperList4Rotation  
  move.l  .colptr(pc),a5
  move.l  draw_cprpalh,a4
  move.l  draw_cprpall,a6 
  bsr.w   SetColDataDefault 
  move.l  .colptr(pc),a5
  cmp.l   #$0fffffff,(a5)   
  bne.s   .br5
  lea.l   EF52_COLORS1,a5
.br5  
  move.l   a5,.colptr  
  ;move.l  .linesizepos,a2  
  movem.l  empty,d0-d7              
  lea.l    EF4_STARTPOS1,a0
  move.l   view_cprlnsel,a3
  move.l   view_cprbitmap,a1
  move.l   #.frmpos,.curfrmpos
  move.l   #.lineshiftpos,.curlshiftpos
  move.l   #.linesizepos,.curlsizepos
  moveq.l  #8-1,d3
.lp2
  move.l   .curfrmpos,a5        ;load frame[curplane].linemultiplier[pos]
  move.l   (a5),a5
  move.l   .curlshiftpos,a6
  move.l   (a6),a6
  move.l    .curlsizepos,a2
  move.l   (a2),a2
  bsr.w    WriteCopper4Rotation
  addq.l   #4,a5
  addq.l   #4,a6
  cmp.l    #$0fffffff,(a5)          
  bne.s    .br3
  lea.l    EF52_LINEMULTIPLIERS,a5
  btst.l   #0,d3
  beq.s    .br4
  lea.l    EF52_LINESHIFTS,a6
  bra.s    .br3
.br4
  lea.l    EF52_LINESHIFTSCCW,a6
.br3
  move.l   .curfrmpos,a4
  move.l   a5,(a4)
  add.l    #4,.curfrmpos
  move.l   .curlshiftpos,a4
  move.l   a6,(a4)
  add.l    #4,.curlshiftpos
  add.l    #4,.curlsizepos
  dbf      d3,.lp2
  
  ;cmp.l   #$0fffffff,(a2)          
  ;bne.s   .br2
  ;lea.l   EF52_LINESIZE_0,a2
.br2
  ;move.l  a6,.lineshiftpos
  ;move.l  a2,.linesizepos
  move.w  #$c00,$dff106
  move.w  #$000,$dff180
  rts
  
.frmpos: 
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  dc.l EF52_LINEMULTIPLIERS
  
.lineshiftpos: 
  dc.l EF52_LINESHIFTS
  dc.l EF52_LINESHIFTSCCW
  dc.l EF52_LINESHIFTS
  dc.l EF52_LINESHIFTSCCW
  dc.l EF52_LINESHIFTS
  dc.l EF52_LINESHIFTSCCW
  dc.l EF52_LINESHIFTS
  dc.l EF52_LINESHIFTSCCW

.linesizepos: 
  dc.l EF52_LINESIZE_0
  dc.l EF52_LINESIZE_1
  dc.l EF52_LINESIZE_2
  dc.l EF52_LINESIZE_3
  dc.l EF52_LINESIZE_4
  dc.l EF52_LINESIZE_5
  dc.l EF52_LINESIZE_6
  dc.l EF52_LINESIZE_7
  
.colptr dc.l EF52_COLORS1
.curfrmpos: dc.l 0
.curlshiftpos: dc.l 0
.curlsizepos: dc.l 0