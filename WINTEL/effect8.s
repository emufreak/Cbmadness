Effect8_1:

  ifeq SOUND-1
  lea	$dff000,a6
.exit:
  btst	#14,2(a6)		;Wait for blitter to finish
  bne.b	.exit
  jsr	P61_End
  endc
  lea.l   CREDITSCHK,a0
  lea.l   BPLIMAGE,a1
  bsr.w   c2p1x1_4_c5_gen
  lea    PalCredits,a5
  move.l  #255,d5
  moveq.l #0,d2
  lea    colp0,a4
  addq.l #2,a4
  lea    colp0b,a6
  addq.l #2,a6
  bsr.w  SetColDataFade
  ;move.w #$f00,$dff180
  IFEQ DEBUG-0
  move.l #COPPERLISTIMAGE,$dff080
  ENDC
  move.w #255,ColMultiplier
  move.l #BPLIMAGE,draw_buffer
  move.l #BPLIMAGE,view_buffer
  move.l #IMGBPLPOINTERS,draw_cprbitmap
  move.l #IMGBPLPOINTERS,view_cprbitmap
  bsr.w  SetBitplanePointersDefault
  ;move.w #$c00,$dff106
  ;move.w #$000,$dff180
  sub.w  #1,.counter
  beq.s  .br1
  bra.w  mlgoon
.br1
  move.w #1,continue
  bra.w  mlgoon

.counter dc.w 250