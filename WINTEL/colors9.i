FRAMESEFF1=130


;Create one color
;\1 Current frame
;\2 Red part of color as word
;\3 Green part of color as word
;\4 Blue part of color as word
;\5 Repeats
;First create high color then low color 
CR8COLOR MACRO
 dcb.l \5,(\2*\1/(FRAMESEFF1*$10))*$1000000+\3*\1/(FRAMESEFF1*$10)*$100000+\4*\1/(FRAMESEFF1*$10)*$10000+(\2*\1/FRAMESEFF1-(\2*\1/(FRAMESEFF1*$10))*$10)*$100+(\3*\1/FRAMESEFF1-(\3*\1/(FRAMESEFF1*$10))*$10)*$10+\4*\1/FRAMESEFF1-(\4*\1/(FRAMESEFF1*$10))*$10
 ENDM


CR8COLORS MACRO
	CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$ff,$0,$0,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$ff,$0,$0,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$ff,$0,$0,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR \1,$0,$ff,$00,4 ;Color 4-7 Plane 3
	CR8COLOR \1,$0,$ff,$00,4 ;Color 8-11 Plane 4
	CR8COLOR \1,$0,$ff,$00,4 ;Color 12-15 Plane 4
	CR8COLOR \1,$0,$0,$ff,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR \1,$0,$0,$ff,16 ;Color 32-47 880016 Plane 6
	CR8COLOR \1,$0,$0,$ff,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR \1,$ff,$ff,$00,32 ;Color 64-95 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$ff,$00,32 ;Color 96-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$ff,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$ff,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$ff,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$ff,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		
	
CR8COLORS2 MACRO
	CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$ff,$ff,$0,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$ff,$ff,$0,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$ff,$ff,$0,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR \1,$ff,$0,$00,4 ;Color 4-7 Plane 3
	CR8COLOR \1,$ff,$0,$00,4 ;Color 8-11 Plane 4
	CR8COLOR \1,$ff,$0,$00,4 ;Color 12-15 Plane 4
	CR8COLOR \1,$00,$ff,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR \1,$0,$ff,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR \1,$0,$ff,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR \1,$00,$00,$ff,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$00,$ff,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$00,$ff,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$00,$ff,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$00,$ff,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$00,$ff,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		


CR8COLORS3 MACRO
	CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$00,$00,$ff,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$00,$00,$ff,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$00,$00,$ff,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR \1,$ff,$ff,$00,4 ;Color 4-7 Plane 3
	CR8COLOR \1,$ff,$ff,$00,4 ;Color 8-11 Plane 4
	CR8COLOR \1,$ff,$ff,$00,4 ;Color 12-15 Plane 4
	CR8COLOR \1,$ff,$00,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR \1,$ff,$00,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR \1,$ff,$00,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR \1,$00,$ff,$00,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$ff,$00,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$ff,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$ff,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$ff,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$00,$ff,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		

CR8COLORS4 MACRO
	CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$00,$ff,$00,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$00,$ff,$00,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$00,$ff,$00,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR \1,$00,$00,$ff,4 ;Color 4-7 Plane 3
	CR8COLOR \1,$00,$00,$ff,4 ;Color 8-11 Plane 4
	CR8COLOR \1,$00,$00,$ff,4 ;Color 12-15 Plane 4
	CR8COLOR \1,$ff,$ff,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR \1,$ff,$ff,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR \1,$ff,$ff,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR \1,$ff,$00,$00,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$00,$00,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$00,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$00,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$00,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ff,$00,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		


 ;SECTION COLORS,DATA
colortable:
 ;REPT 130
 ;CR8COLORS 130
 ;ENDR

 ;IFEQ 1-2
 CR8COLORS 1 
 CR8COLORS 2 
 CR8COLORS 3  
 CR8COLORS 4 
 CR8COLORS 5 
 CR8COLORS 6 
 CR8COLORS 7  
 CR8COLORS 8 
 CR8COLORS 9 
 CR8COLORS 10 
 CR8COLORS 11 
 CR8COLORS 12 
 CR8COLORS 13 
 CR8COLORS 14 
 CR8COLORS 15 
 CR8COLORS 16 
 CR8COLORS 17  
 CR8COLORS 18 
 CR8COLORS 19 
 CR8COLORS 20 
 CR8COLORS 21 
 CR8COLORS 22 
 CR8COLORS 23 
 CR8COLORS 24 
 CR8COLORS 25 
 CR8COLORS 26 
 CR8COLORS 27  
 CR8COLORS 28 
 CR8COLORS 29 
 CR8COLORS 30 
 CR8COLORS 31 
 CR8COLORS2 32 
 CR8COLORS2 33 
 CR8COLORS2 34 
 CR8COLORS2 35 
 CR8COLORS2 36 
 CR8COLORS2 37  
 CR8COLORS2 38 
 CR8COLORS2 39 
 CR8COLORS2 40 
 CR8COLORS2 41 
 CR8COLORS2 42 
 CR8COLORS2 43 
 CR8COLORS2 44 
 CR8COLORS2 45 
 CR8COLORS2 46 
 CR8COLORS2 47  
 CR8COLORS2 48 
 CR8COLORS2 49  
 CR8COLORS2 50 
 CR8COLORS2 51  
 CR8COLORS2 52 
 CR8COLORS2 53 
 CR8COLORS2 54 
 CR8COLORS2 55
 CR8COLORS2 56 
 CR8COLORS2 57  
 CR8COLORS2 58 
 CR8COLORS2 59 
 CR8COLORS2 60 
 CR8COLORS2 61  
 CR8COLORS2 62 
 CR8COLORS2 63 
 CR8COLORS2 64 
 CR8COLORS3 65
 CR8COLORS3 66 
 CR8COLORS3 67  
 CR8COLORS3 68 
 CR8COLORS3 69 
 CR8COLORS3 70 
 CR8COLORS3 71  
 CR8COLORS3 72 
 CR8COLORS3 73 
 CR8COLORS3 74 
 CR8COLORS3 75
 CR8COLORS3 76 
 CR8COLORS3 77  
 CR8COLORS3 78 
 CR8COLORS3 79 
 CR8COLORS3 80 
 CR8COLORS3 81  
 CR8COLORS3 82 
 CR8COLORS3 83 
 CR8COLORS3 84 
 CR8COLORS3 85
 CR8COLORS3 86 
 CR8COLORS3 87  
 CR8COLORS3 88 
 CR8COLORS3 89 
 CR8COLORS3 90 
 CR8COLORS3 91  
 CR8COLORS3 92 
 CR8COLORS3 93 
 CR8COLORS3 94 
 CR8COLORS3 95
 CR8COLORS3 96 
 CR8COLORS4 97  
 CR8COLORS4 98 
 CR8COLORS4 99 
 CR8COLORS4 100 
 CR8COLORS4 101   
 CR8COLORS4 102 
 CR8COLORS4 103 
 CR8COLORS4 104 
 CR8COLORS4 105
 CR8COLORS4 106 
 CR8COLORS4 107  
 CR8COLORS4 108 
 CR8COLORS4 109 
 CR8COLORS4 110 
 CR8COLORS4 111   
 CR8COLORS4 112 
 CR8COLORS4 113 
 CR8COLORS4 114 
 CR8COLORS4 115
 CR8COLORS4 116 
 CR8COLORS4 117  
 CR8COLORS4 118 
 CR8COLORS4 119 
 CR8COLORS4 120  
 CR8COLORS4 121   
 CR8COLORS4 122 
 CR8COLORS4 123 
 CR8COLORS4 124 
 CR8COLORS4 125
 CR8COLORS4 126 
 CR8COLORS4 127  
 CR8COLORS4 128 
 CR8COLORS4 129 
 CR8COLORS  130 

 ;ENDC
endcltable: 



