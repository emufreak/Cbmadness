EF5_LINEMULT = 0
EF5_LINESHIFTS = 408

LINEMULTIPLIERS:
  dc.l 256, 256, 257, 260, 264, 268, 274, 282, 291, 302
  dc.l 315, 330, 348, 370, 397, 430, 470, 521, 587, 675
  dc.l 797, 979, 1274, 1834, 3295, 16461, 5489, 2357, 1504, 1108
  dc.l 880, 732, 628, 553, 495, 450, 413, 384, 360, 340
  dc.l 323, 309, 297, 287, 279, 272, 267, 263, 260, 258
  dc.l 257, 257, 258, 260, 263, 267, 272, 279, 287, 297
  dc.l 309, 323, 340, 360, 384, 413, 450, 495, 553, 628
  dc.l 732, 880, 1108, 1504, 2357, 5489, 16461, 3295, 1834, 1274
  dc.l 979, 797, 675, 587, 521, 470, 430, 397, 370, 348
  dc.l 330, 315, 302, 291, 282, 274, 268, 264, 260, 257
  dc.l 256,$fffffff

LINESHIFTS:
  dc.l 0, 15, 32, 48, 65, 82, 100, 119, 139, 160
  dc.l 183, 208, 236, 268, 304, 345, 394, 454, 528, 624
  dc.l 755, 945, 1248, 1816, 3285, 16459, -5483, -2343, -1482, -1078
  dc.l -841, -685, -574, -490, -423, -369, -324, -286, -253, -223
  dc.l -196, -172, -150, -129, -110, -92, -74, -57, -41, -24
  dc.l -8, 7, 23, 40, 56, 73, 91, 109, 128, 149
  dc.l 171, 195, 222, 252, 285, 323, 368, 422, 489, 573
  dc.l 684, 840, 1077, 1481, 2342, 5482, -16460, -3286, -1817, -1249
  dc.l -946, -756, -625, -529, -455, -395, -346, -305, -269, -237
  dc.l -209, -184, -161, -140, -120, -101, -83, -66, -49, -33
  dc.l -16,$fffffff

EF5FRM0SIZE:
  dcb.l 8,10

EF5FRM0SINMUL:
  dc.l 2,2,2,2,2,2,2,2

EF5LINESHFT:
  dcb.l 8,0

FRM4SIZE=256*4


 CNOP 0,4
 
SIZETST: dc.l 50

EF4_POSADD1
  dcb.l 255,256*1

EF4_STARTPOS1:
  dc.w 5

EF4_SIZE:
  dc.w 163
  
 REPT 7 
  dcb.l 255,256*1
  dc.w 5
  dc.w 64
 ENDR

EF4_STARTPOS3:
  dc.l 64

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