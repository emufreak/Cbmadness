FRAMESEFF1=120


;Create one color
;\1 Current frame
;\2 Red part of color as word
;\3 Green part of color as word
;\4 Blue part of color as word
;\5 Repeats
;First create high color then low color 
CR8COLOR MACRO
 dcb.l \5,(\2*\1/(FRAMESEFF1*$10))*$1000000+\3*\1/(FRAMESEFF1*$10)*$100000+\4*\1/(FRAMESEFF1*$10)*10000+(\2*\1/FRAMESEFF1-(\2*\1/(FRAMESEFF1*$10))*$10)*$100+(\3*\1/FRAMESEFF1-(\3*\1/(FRAMESEFF1*$10))*$10)*$10+\4*\1/FRAMESEFF1-(\4*\1/(FRAMESEFF1*$10))
 ENDM


CR8COLORS MACRO
	CR8COLOR \1,$0,$0,$0,1 ;$118800 Color 0 Plane 1 
	CR8COLOR \1,$11,$88,$0,1 ;$118800 Color 1 Plane 1
	CR8COLOR \1,$ee,$11,$11,1 ;$ee1111 Color 2 Plane 2
	CR8COLOR \1,$cc,$11,$0,1 ;$cc1100 Color 3 Plane 2
	CR8COLOR \1,$ff,$dd,$33,4 ;Color 4-7 Plane 3
	CR8COLOR \1,$ff,$88,$22,4 ;Color 8-11 Plane 4
	CR8COLOR \1,$ff,$ee,$66,4 ;Color 12-15 Plane 4
	CR8COLOR \1,$22,$11,$ff,16 ;$221166 Color 16-31 Plane 5
	dc.l $f0000000 ;Placeholder for palette change 
	CR8COLOR \1,$11,$88,$ff,16 ;Color 32-47 880016 Plane 6
	CR8COLOR \1,$11,$33,$ff,16 ;Color 48-63 33ff16 Plane 6
	ENDM		
	
CR8COLORS2 MACRO
	CR8COLOR \1,$ff,$0,$0,1 ;$118800 Color 0 
	CR8COLOR \1,$22,$11,$66,1 ;$118800 Color 1
	CR8COLOR \1,$11,$88,$00,1 ;$ee1111 Color 2 
	CR8COLOR \1,$11,$33,$ff,1 ;$cc1100 Color 3
	CR8COLOR \1,$ff,$dd,$33,4 ;$221166 Color 4-7
	CR8COLOR \1,$ff,$88,$22,4 ;Color 8-11
	CR8COLOR \1,$ff,$ee,$66,4 ;Color 12-15
	CR8COLOR \1,$11,$88,$00,16 ;Color 16-31
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$ee,$11,$11,16 ;Color 32-47
	CR8COLOR \1,$cc,$11,$00,16 ;Color 48-64
	ENDM		

CR8COLORS3 MACRO
	CR8COLOR \1,$ff,$dd,$33,1 ;$118800 Color 0 
	CR8COLOR \1,$ff,$dd,$33,1 ;$118800 Color 1
	CR8COLOR \1,$ff,$88,$22,1 ;$ee1111 Color 2 
	CR8COLOR \1,$ff,$ee,$66,1 ;$cc1100 Color 3
	CR8COLOR \1,$11,$88,$00,4 ;$221166 Color 4-7
	CR8COLOR \1,$ee,$11,$11,4 ;Color 8-11
	CR8COLOR \1,$cc,$11,$00,4 ;Color 12-15
	CR8COLOR \1,$22,$11,$66,16 ;Color 16-31
	dc.l $f0000000 ;Placeholder for palette change
	CR8COLOR \1,$11,$88,$00,16 ;Color 32-47
	CR8COLOR \1,$11,$33,$ff,16 ;Color 48-64
	ENDM		

 ;SECTION COLORS,DATA
colortable:
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
 CR8COLORS 32 
 CR8COLORS 33 
 CR8COLORS 34 
 CR8COLORS 35 
 CR8COLORS 36 
 CR8COLORS 37  
 CR8COLORS 38 
 CR8COLORS 39 
 CR8COLORS 40 
 CR8COLORS 41 
 CR8COLORS 42 
 CR8COLORS 43 
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
 CR8COLORS2 65
 CR8COLORS2 66 
 CR8COLORS2 67  
 CR8COLORS2 68 
 CR8COLORS2 69 
 CR8COLORS2 70 
 CR8COLORS2 71  
 CR8COLORS2 72 
 CR8COLORS2 73 
 CR8COLORS2 74 
 CR8COLORS2 75
 CR8COLORS2 76 
 CR8COLORS2 77  
 CR8COLORS2 78 
 CR8COLORS2 79 
 CR8COLORS2 80 
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
 CR8COLORS3 97  
 CR8COLORS3 98 
 CR8COLORS3 99 
 CR8COLORS3 100 
 CR8COLORS3 101   
 CR8COLORS3 102 
 CR8COLORS3 103 
 CR8COLORS3 104 
 CR8COLORS3 105
 CR8COLORS3 106 
 CR8COLORS3 107  
 CR8COLORS3 108 
 CR8COLORS3 109 
 CR8COLORS3 110 
 CR8COLORS3 111   
 CR8COLORS3 112 
 CR8COLORS3 113 
 CR8COLORS3 114 
 CR8COLORS3 115
 CR8COLORS3 116 
 CR8COLORS3 117  
 CR8COLORS3 118 
 CR8COLORS3 119 
 CR8COLORS3 120 
endcltable: 

