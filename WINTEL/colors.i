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
	;CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	dc.w $000,$000
	CR8COLOR \1,$ff,$0,$0,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$ff,$0,$0,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$ff,$0,$0,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR (\1+31),$0,$ff,$00,4 ;Color 4-7 Plane 3
	CR8COLOR (\1+31),$0,$ff,$00,4 ;Color 8-11 Plane 4
	CR8COLOR (\1+31),$0,$ff,$00,4 ;Color 12-15 Plane 4
	CR8COLOR (\1+64),$0,$0,$ff,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR (\1+64),$0,$0,$ff,16 ;Color 32-47 880016 Plane 6
	CR8COLOR (\1+64),$0,$0,$ff,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 64-95 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 96-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$ff,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		
	
CR8COLORS2 MACRO
	;CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	dc.w $000,$000
	CR8COLOR \1,$ff,$ff,$0,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$ff,$ff,$0,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$ff,$ff,$0,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR (\1+31),$ff,$0,$00,4 ;Color 4-7 Plane 3
	CR8COLOR (\1+31),$ff,$0,$00,4 ;Color 8-11 Plane 4
	CR8COLOR (\1+31),$ff,$0,$00,4 ;Color 12-15 Plane 4
	CR8COLOR (\1+64),$00,$ff,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR (\1+64),$0,$ff,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR (\1+64),$0,$ff,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$00,$ff,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		


CR8COLORS3 MACRO
	;CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	dc.w $000,$000
	CR8COLOR \1,$00,$00,$ff,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$00,$00,$ff,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$00,$00,$ff,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR (\1+31),$ff,$ff,$00,4 ;Color 4-7 Plane 3
	CR8COLOR (\1+31),$ff,$ff,$00,4 ;Color 8-11 Plane 4
	CR8COLOR (\1+31),$ff,$ff,$00,4 ;Color 12-15 Plane 4
	CR8COLOR (1+63),$ff,$00,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR (\1+63),$ff,$00,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR (\1+63),$ff,$00,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$00,$ff,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		

CR8COLORS4 MACRO
	dc.w $000,$000
	;CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$00,$ff,$00,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$00,$ff,$00,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$00,$ff,$00,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR (\1+31),$00,$00,$ff,4 ;Color 4-7 Plane 3
	CR8COLOR (\1+31),$00,$00,$ff,4 ;Color 8-11 Plane 4
	CR8COLOR (\1+31),$00,$00,$ff,4 ;Color 12-15 Plane 4
	CR8COLOR (\1+63),$ff,$ff,$00,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR (\1+63),$ff,$ff,$00,16 ;Color 32-47 880016 Plane 6
	CR8COLOR (\1+63),$ff,$ff,$00,16 ;Color 48-63 33ff16 Plane 6
	dc.l $f0000000 ;Placeholder for palette change
        CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 64-92 33ff16 Plane 7
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 92-127 33ff16 Plane 7  
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 128-159 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 160-191 33ff16 Plane 8 
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 192-223 33ff16 Plane 8
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR (\1+96),$ff,$00,$00,32 ;Color 224-255 33ff16 Plane 8	
	ENDM		


 ;SECTION COLORS,DATA
colortable:
 ;REPT 130
 ;CR8COLORS 130
 ;ENDR

 ;IFEQ 1-2 
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
 CR8COLORS 32
 CR8COLORS2 1 
 CR8COLORS2 2 
 CR8COLORS2 3 
 CR8COLORS2 4 
 CR8COLORS2 5 
 CR8COLORS2 6  
 CR8COLORS2 7 
 CR8COLORS2 8 
 CR8COLORS2 9 
 CR8COLORS2 10 
 CR8COLORS2 11 
 CR8COLORS2 12 
 CR8COLORS2 13 
 CR8COLORS2 14 
 CR8COLORS2 15 
 CR8COLORS2 16  
 CR8COLORS2 17 
 CR8COLORS2 18  
 CR8COLORS2 19 
 CR8COLORS2 20  
 CR8COLORS2 21 
 CR8COLORS2 22 
 CR8COLORS2 23 
 CR8COLORS2 24
 CR8COLORS2 25 
 CR8COLORS2 26  
 CR8COLORS2 27 
 CR8COLORS2 28 
 CR8COLORS2 29 
 CR8COLORS2 30  
 CR8COLORS2 31 
 CR8COLORS2 32 
 CR8COLORS2 33 
 CR8COLORS3 1
 CR8COLORS3 2 
 CR8COLORS3 3  
 CR8COLORS3 4 
 CR8COLORS3 5 
 CR8COLORS3 6 
 CR8COLORS3 7  
 CR8COLORS3 8 
 CR8COLORS3 9 
 CR8COLORS3 10 
 CR8COLORS3 11
 CR8COLORS3 12 
 CR8COLORS3 13  
 CR8COLORS3 14 
 CR8COLORS3 15 
 CR8COLORS3 16 
 CR8COLORS3 17  
 CR8COLORS3 18 
 CR8COLORS3 19 
 CR8COLORS3 20 
 CR8COLORS3 21
 CR8COLORS3 22 
 CR8COLORS3 23  
 CR8COLORS3 24 
 CR8COLORS3 25 
 CR8COLORS3 26 
 CR8COLORS3 27  
 CR8COLORS3 28 
 CR8COLORS3 28 
 CR8COLORS3 30 
 CR8COLORS3 31
 CR8COLORS3 32 
 CR8COLORS4 1  
 CR8COLORS4 2 
 CR8COLORS4 3 
 CR8COLORS4 4 
 CR8COLORS4 5   
 CR8COLORS4 6 
 CR8COLORS4 7 
 CR8COLORS4 8 
 CR8COLORS4 9
 CR8COLORS4 10 
 CR8COLORS4 11  
 CR8COLORS4 12 
 CR8COLORS4 13 
 CR8COLORS4 14 
 CR8COLORS4 15   
 CR8COLORS4 16 
 CR8COLORS4 17 
 CR8COLORS4 18 
 CR8COLORS4 19
 CR8COLORS4 20 
 CR8COLORS4 21  
 CR8COLORS4 22 
 CR8COLORS4 23 
 CR8COLORS4 24  
 CR8COLORS4 25   
 CR8COLORS4 26 
 CR8COLORS4 27 
 CR8COLORS4 28 
 CR8COLORS4 29
 CR8COLORS4 30 
 CR8COLORS4 31  
 CR8COLORS4 32 
 CR8COLORS4 33 
 CR8COLORS  1 

 ;ENDC
endcltable: 



