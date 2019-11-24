FDOPOSX2 equ 4
FDOPOSY2 equ 94
FDOPOSXDET2 equ 184
FDOPOSYDET2 equ 274
FDOBLSIZE2 equ 364
FRMSIZE2 equ 454


EF2_PATTERNDATA0: 
  dc.l PTR_CHECKERBOARD_DATA	
EF2_POSX0: 
  dc.w 16,16,16,16,16,16,16,16,16,16
  dc.w 17,17,17,17,17,17,17,17,17,19
  dc.w 19,19,19,19,19,19,19,19,20,20
  dc.w 20,20,20,20,20,21,21,21,21,21
  dc.w 21,21,21,21,21
EF2_POSY0: 
  dc.w 18,18,18,18,18,18,18,18,18,18
  dc.w 19,19,19,19,19,19,19,19,19,20
  dc.w 20,20,20,20,20,20,20,20,21,21
  dc.w 21,21,21,21,21,22,22,22,22,22
  dc.w 22,22,22,22,22
EF2_POSXDET0: 
  dc.w 5,5,5,5,5,5,5,5,5,5
  dc.w 10,10,10,10,10,10,10,10,10,2
  dc.w 2,2,2,2,2,2,2,2,2,2
  dc.w 2,2,2,2,2,1,1,1,1,1
  dc.w 1,1,1,12,12
EF2_POSYDET0: 
  dc.w 7,7,7,7,7,7,7,7,7,7
  dc.w 9,9,9,9,9,9,9,9,9,10
  dc.w 10,10,10,10,10,10,10,10,8,8
  dc.w 8,8,8,8,8,5,5,5,5,5
  dc.w 5,5,5,14,14
EF2_SIZE0: 
  dc.w 10,10,10,10,10,10,10,10,10,10
  dc.w 11,11,11,11,11,11,11,11,11,12
  dc.w 12,12,12,12,12,12,12,12,13,13
  dc.w 13,13,13,13,13,14,14,14,14,14
  dc.w 14,14,14,15,15
EF2_PATTERNDATA1: 
  dc.l PTR_CHECKERBOARDINV_DATA	
EF2_POSX1: 
  dc.w 25,25,25,25,25,25,25,25,25,24
  dc.w 24,24,24,24,24,24,24,24,24,24
  dc.w 24,24,24,24,23,23,23,23,23,23
  dc.w 23,23,23,23,23,22,22,22,22,22
  dc.w 22,22,21,21,21
EF2_POSY1: 
  dc.w 25,25,25,25,25,25,25,25,25,25
  dc.w 25,25,25,25,25,25,25,25,25,24
  dc.w 24,24,24,24,24,24,24,24,24,23
  dc.w 23,23,23,23,23,23,23,23,23,23
  dc.w 23,23,22,22,22
EF2_POSXDET1: 
  dc.w 12,12,12,12,5,5,5,5,5,18
  dc.w 18,18,18,10,10,10,10,10,10,1
  dc.w 1,1,1,1,11,11,11,11,11,1
  dc.w 1,1,1,1,1,8,8,8,8,8
  dc.w 8,8,12,12,12
EF2_POSYDET1: 
  dc.w 21,21,21,21,15,15,15,15,15,8
  dc.w 8,8,8,2,2,2,2,2,2,14
  dc.w 14,14,14,14,7,7,7,7,7,16
  dc.w 16,16,16,16,16,8,8,8,8,8
  dc.w 8,8,14,14,14
EF2_SIZE1: 
  dc.w 23,23,23,23,22,22,22,22,22,21
  dc.w 21,21,21,20,20,20,20,20,20,19
  dc.w 19,19,19,19,18,18,18,18,18,17
  dc.w 17,17,17,17,17,16,16,16,16,16
  dc.w 16,16,15,15,15
EF2_PATTERNDATA2: 
  dc.l PTR_CHECKERBOARD_DATA	
EF2_POSX2: 
  dc.w 25,25,25,25,25,25,26,26,26,26
  dc.w 26,26,26,26,26,26,26,26,26,26
  dc.w 26,26,26,26,26,27,27,27,27,27
  dc.w 27,27,27,27,27,27,27,27,27,27
  dc.w 27,27,27,27,28
EF2_POSY2: 
  dc.w 25,26,26,26,26,26,26,26,26,26
  dc.w 26,26,26,26,26,26,26,26,26,26
  dc.w 26,27,27,27,27,27,27,27,27,27
  dc.w 27,27,27,27,27,27,27,27,27,27
  dc.w 27,27,27,27,27
EF2_POSXDET2: 
  dc.w 12,20,20,20,20,20,2,2,2,2
  dc.w 9,9,9,9,15,15,15,22,22,22
  dc.w 22,28,28,28,28,5,5,5,10,10
  dc.w 10,16,16,16,16,21,21,21,27,27
  dc.w 27,32,32,32,2
EF2_POSYDET2: 
  dc.w 21,4,4,4,4,4,9,9,9,9
  dc.w 15,15,15,15,20,20,20,26,26,26
  dc.w 26,2,2,2,2,7,7,7,11,11
  dc.w 11,16,16,16,16,20,20,20,25,25
  dc.w 25,29,29,29,34
EF2_SIZE2: 
  dc.w 23,24,24,24,24,24,25,25,25,25
  dc.w 26,26,26,26,27,27,27,28,28,28
  dc.w 28,29,29,29,29,30,30,30,31,31
  dc.w 31,32,32,32,32,33,33,33,34,34
  dc.w 34,35,35,35,36
EF2_PATTERNDATA3: 
  dc.l PTR_CHECKERBOARDINV_DATA	
EF2_POSX3: 
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,28,28,28,28,28,28,28,28
  dc.w 28,28,28,28,28,28,28,28,28,28
  dc.w 28,28,28,28,28
EF2_POSY3: 
  dc.w 29,29,29,29,29,29,29,29,29,28
  dc.w 28,28,28,28,28,28,28,28,28,28
  dc.w 28,28,28,28,28,28,28,28,28,28
  dc.w 28,28,28,28,28,28,28,28,28,28
  dc.w 28,28,28,28,28
EF2_POSXDET3: 
  dc.w 36,36,32,29,29,25,25,22,22,18
  dc.w 18,15,15,11,11,8,8,8,4,4
  dc.w 1,1,42,42,38,38,38,33,33,29
  dc.w 29,24,24,24,20,20,20,15,15,11
  dc.w 11,11,6,6,6
EF2_POSYDET3: 
  dc.w 12,12,9,7,7,4,4,2,2,50
  dc.w 50,47,47,43,43,40,40,40,36,36
  dc.w 33,33,29,29,26,26,26,22,22,19
  dc.w 19,15,15,15,12,12,12,8,8,5
  dc.w 5,5,1,1,1
EF2_SIZE3: 
  dc.w 56,56,55,54,54,53,53,52,52,51
  dc.w 51,50,50,49,49,48,48,48,47,47
  dc.w 46,46,45,45,44,44,44,43,43,42
  dc.w 42,41,41,41,40,40,40,39,39,38
  dc.w 38,38,37,37,37
EF2_PATTERNDATA4: 
  dc.l PTR_CHECKERBOARD_DATA	
EF2_POSX4: 
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30
EF2_POSY4: 
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,29,29,29,29,29,29,29
  dc.w 29,29,29,29,30
EF2_POSXDET4: 
  dc.w 36,39,39,43,43,46,46,50,53,53
  dc.w 57,57,60,0,0,2,2,5,7,7
  dc.w 10,12,12,15,17,17,20,22,25,25
  dc.w 27,30,30,32,35,37,40,40,42,45
  dc.w 47,47,50,52,55
EF2_POSYDET4: 
  dc.w 12,14,14,17,17,19,19,22,24,24
  dc.w 27,27,29,32,32,34,34,37,39,39
  dc.w 42,44,44,47,49,49,52,54,57,57
  dc.w 59,62,62,64,67,69,72,72,74,77
  dc.w 79,79,82,84,1
EF2_SIZE4: 
  dc.w 56,57,57,58,58,59,59,60,61,61
  dc.w 62,62,63,64,64,65,65,66,67,67
  dc.w 68,69,69,70,71,71,72,73,74,74
  dc.w 75,76,76,77,78,79,80,80,81,82
  dc.w 83,83,84,85,86
EF2_PATTERNDATA5: 
  dc.l PTR_CHECKERBOARDINV_DATA	
EF2_POSX5: 
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30
EF2_POSY5: 
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30
EF2_POSXDET5: 
  dc.w 41,39,36,35,33,32,30,27,26,24
  dc.w 23,21,18,17,15,14,12,11,9,8
  dc.w 5,3,2,0,105,102,100,97,95,92
  dc.w 90,87,85,82,80,80,77,75,72,70
  dc.w 67,65,62,60,60
EF2_POSYDET5: 
  dc.w 73,71,68,67,65,64,62,59,58,56
  dc.w 55,53,50,49,47,46,44,43,41,40
  dc.w 37,35,34,32,31,29,28,26,25,23
  dc.w 22,20,19,17,16,16,14,13,11,10
  dc.w 8,7,5,4,4
EF2_SIZE5: 
  dc.w 134,133,131,130,129,128,127,125,124,123
  dc.w 122,121,119,118,117,116,115,114,113,112
  dc.w 110,109,108,107,106,105,104,103,102,101
  dc.w 100,99,98,97,96,96,95,94,93,92
  dc.w 91,90,89,88,88
EF2_PATTERNDATA6: 
  dc.l PTR_CHECKERBOARD_DATA	
EF2_POSX6: 
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31
EF2_POSY6: 
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30
EF2_POSXDET6: 
  dc.w 41,42,45,47,48,51,53,54,57,59
  dc.w 62,63,66,68,69,72,74,77,80,81
  dc.w 84,86,89,90,93,96,98,101,104,105
  dc.w 108,111,114,116,119,122,125,128,129,132
  dc.w 135,138,141,144,147
EF2_POSYDET6: 
  dc.w 73,74,77,79,80,83,85,86,89,91
  dc.w 94,95,98,100,101,104,106,109,112,113
  dc.w 116,118,121,122,125,128,130,133,136,137
  dc.w 140,143,146,148,151,154,157,160,161,164
  dc.w 167,170,173,176,179
EF2_SIZE6: 
  dc.w 134,135,137,138,139,141,142,143,145,146
  dc.w 148,149,151,152,153,155,156,158,160,161
  dc.w 163,164,166,167,169,171,172,174,176,177
  dc.w 179,181,183,184,186,188,190,192,193,195
  dc.w 197,199,201,203,205
EF2_PATTERNDATA7: 
  dc.l PTR_CHECKERBOARDINV_DATA	
EF2_POSX7: 
  dc.w 32,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31
EF2_POSY7: 
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,31,31,31,31,31,31
  dc.w 31,31,31,31,30,30,30,30,30,30
  dc.w 30,30,30,30,30,30,30,30,30,30
  dc.w 30,30,30,30,30
EF2_POSXDET7: 
  dc.w 0,314,309,305,300,297,293,288,284,279
  dc.w 275,270,267,263,258,255,251,246,243,239
  dc.w 234,231,227,224,221,216,213,209,206,203
  dc.w 198,195,192,188,185,182,179,176,171,168
  dc.w 165,162,159,156,153
EF2_POSYDET7: 
  dc.w 32,30,28,27,25,24,23,21,20,18
  dc.w 17,15,14,13,11,10,9,7,6,5
  dc.w 3,2,1,0,253,248,245,241,238,235
  dc.w 230,227,224,220,217,214,211,208,203,200
  dc.w 197,194,191,188,185
EF2_SIZE7: 
  dc.w 320,316,313,310,307,305,302,299,296,293
  dc.w 290,287,285,282,279,277,274,271,269,266
  dc.w 263,261,258,256,254,251,249,246,244,242
  dc.w 239,237,235,232,230,228,226,224,221,219
  dc.w 217,215,213,211,209