Effect7_1:
  lea.l  COLRBPLCON0_1,a0
  move.w #$210,2(a0)
  lea.l  COLRBPLCON0_2,a0
  move.w #$210,2(a0)
  bsr.w  Main_Effect7_1
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon 

.counter: dc.w 268

Effect7_2:
  lea.l  COLRBPLCON0_1,a0
  move.w #$210,2(a0)
  lea.l  COLRBPLCON0_2,a0
  move.w #$210,2(a0)
  bsr.w  Main_Effect7_2
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon 

.counter: dc.w 50*50


Main_Effect7_1:

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
  lea.l   EF71_COLORS1,a5
.br5  
  move.l   a5,.colptr    
  movem.l  empty,d0-d7              
  lea.l    EF4_STARTPOS1,a0
  move.l   draw_cprlnsel,a3
  move.l   draw_cprbitmap,a1
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
  move.l   d3,d0
  lsr.w    d0
  btst.l   #0,d0
  beq.s    .br1
  lea.l    EF61_LINEMULTIPLIERS,a5
  lea.l    EF61_LINESHIFTS,a6
  bra.s    .br3
.br1
  lea.l    EF61_LINEMULTIPLIERS,a5
  lea.l    EF61_LINESHIFTSCCW,a6
.br3
  move.l   .curfrmpos,a4
  move.l   a5,(a4)
  add.l    #4,.curfrmpos
  move.l   .curlshiftpos,a4
  move.l   a6,(a4)
  add.l    #4,.curlshiftpos
  add.l    #4,.curlsizepos
  dbf      d3,.lp2
.br2
  move.w  #$c00,$dff106
  move.w  #$000,$dff180
  rts

.frmpos: 
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  
.lineshiftpos: 
  dc.l EF61_LINESHIFTS
  dc.l EF61_LINESHIFTS+134*4
  dc.l EF61_LINESHIFTSCCW
  dc.l EF61_LINESHIFTSCCW+134*4
  dc.l EF61_LINESHIFTS
  dc.l EF61_LINESHIFTS+134*4
  dc.l EF61_LINESHIFTSCCW
  dc.l EF61_LINESHIFTSCCW+134*4

.linesizepos: 
  dc.l EF61_LINESIZE_0
  dc.l EF61_LINESIZE_0
  dc.l EF61_LINESIZE_1
  dc.l EF61_LINESIZE_1
  dc.l EF61_LINESIZE_2
  dc.l EF61_LINESIZE_2
  dc.l EF61_LINESIZE_3
  dc.l EF61_LINESIZE_3
  
.colptr dc.l EF71_COLORS1
.curfrmpos: dc.l 0
.curlshiftpos: dc.l 0
.curlsizepos: dc.l 0

Main_Effect7_2:

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
  add.l   #0,a5
  cmp.l   #$0fffffff,(a5)   
  bne.s   .br5
  lea.l   EF71_COLORS276,a5
.br5  
  move.l   a5,.colptr    
  movem.l  empty,d0-d7              
  lea.l    EF4_STARTPOS1,a0
  move.l   draw_cprlnsel,a3
  move.l   draw_cprbitmap,a1
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
  move.l   d3,d0
  lsr.w    d0
  btst.l   #0,d0
  beq.s    .br1
  lea.l    EF61_LINEMULTIPLIERS,a5
  lea.l    EF61_LINESHIFTS,a6
  bra.s    .br3
.br1
  lea.l    EF61_LINEMULTIPLIERS,a5
  lea.l    EF61_LINESHIFTSCCW,a6
.br3
  move.l   .curfrmpos,a4
  move.l   a5,(a4)
  add.l    #4,.curfrmpos
  move.l   .curlshiftpos,a4
  move.l   a6,(a4)
  add.l    #4,.curlshiftpos
  add.l    #4,.curlsizepos
  dbf      d3,.lp2
.br2
  move.w  #$c00,$dff106
  move.w  #$000,$dff180
  rts

.frmpos: 
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  dc.l EF61_LINEMULTIPLIERS
  dc.l EF61_LINEMULTIPLIERS+134*4
  
.lineshiftpos: 
  dc.l EF61_LINESHIFTS
  dc.l EF61_LINESHIFTS+134*4
  dc.l EF61_LINESHIFTSCCW
  dc.l EF61_LINESHIFTSCCW+134*4
  dc.l EF61_LINESHIFTS
  dc.l EF61_LINESHIFTS+134*4
  dc.l EF61_LINESHIFTSCCW
  dc.l EF61_LINESHIFTSCCW+134*4

.linesizepos: 
  dc.l EF61_LINESIZE_0
  dc.l EF61_LINESIZE_0
  dc.l EF61_LINESIZE_1
  dc.l EF61_LINESIZE_1
  dc.l EF61_LINESIZE_2
  dc.l EF61_LINESIZE_2
  dc.l EF61_LINESIZE_3
  dc.l EF61_LINESIZE_3
  
.colptr dc.l EF71_COLORS276
.curfrmpos: dc.l 0
.curlshiftpos: dc.l 0
.curlsizepos: dc.l 0