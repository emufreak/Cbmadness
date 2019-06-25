FRM4SIZE=256*4

 CNOP 0,4

EF4_POSADD1:
  dcb.l 255, 1

EF4_STARTPOS1:
  dc.w 5

EF4_SIZE:
  dc.w 10
  
 REPT 7 
  dcb.l 255, 1
  dc.w 5
  dc.w 10
 ENDR

EF4_STARTPOS3:
  dc.l 5

EF4_POSADD3:
  dcb.l 255, 0

EF4_STARTPOS4:
  dc.l 5

EF4_POSADD4:
  dcb.l 255, 0

EF4_STARTPOS5:
  dc.l 5

EF4_POSADD5:
  dcb.l 255, 0

EF4_STARTPOS6:
  dc.l 5

EF4_POSADD6:
  dcb.l 255, 0

EF4_STARTPOS7:
  dc.l 5

EF4_POSADD7:
  dcb.l 255, 0
  
EF6_STARTPOS6:
  dc.l 5

EF6_POSADD6:
  dcb.l 255, 0

EF6_STARTPOS7:
  dc.l 5

EF6_POSADD7:
  dcb.l 255, 0
  
EF6_STARTPOS8:
  dc.l 5

EF6_POSADD8:
  dcb.l 255, 0