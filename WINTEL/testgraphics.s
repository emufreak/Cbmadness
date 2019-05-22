DUMMY=0

view_buffer:
        dc.l    bitplane

draw_buffer:
        dc.l    bitplane

view_copper:
        dc.l    copperlist

draw_copper:
        dc.l    copperlist

	SECTION COPPER,DATA_C

SIZEPALETTE = 32
OFFSCLPALETTE = 52*2+4
;Palettes + Bankchanges / First palette only size 15 (no background)
OFFSBPLPOINTERS = OFFSCLPALETTE+SIZEPALETTE*7*4*2+2*7*4+(SIZEPALETTE-1)*4*2+1*4  
;OFFSBPLPOINTERS= OFFSCLPALETTE+SIZEPALETTE*8*4*2+2*7*4+1*4  
;OFFSCLBLOCKDRAW = OFFSBPLPOINTERS+32*2
;OFFSNEXTCOPPER = OFFSCLBLOCKDRAW+4*255+4*BPLCOUNT*255+4
;OFFSCLPALETTELW = OFFSCLPALETTE+SIZEPALETTE*8*4+8*4 


M_COPPTRS: MACRO
	dc.w \1<<8+$d9,$fffe
 	IFGE BPLCOUNT-1
	;dc.w $e0,$5
	dc.w $e2,0
	ENDC
	IFGE BPLCOUNT-2
	;dc.w $e4,$5
	dc.w $e6,40*256
	ENDC 
	IFGE BPLCOUNT-3
	;dc.w $e8,$5
	dc.w $ea,40*256*2
	ENDC
	IFGE BPLCOUNT-4
	;dc.w $ec,$5
        dc.w $ee,40*256*3
        ENDC
        IFGE BPLCOUNT-5
	;dc.w $f0,$5
	dc.w $f2,40*256*4
        ENDC
        IFGE BPLCOUNT-6
	;dc.w $f4,$5
	dc.w $f6,40*256*5
        ENDC
        IFGE BPLCOUNT-7
        ;dc.w $f8,$5
        dc.w $fa,40*256*6
        ENDC
        IFGE BPLCOUNT-8
        ;dc.w $fc,$6
        dc.w $fe,$1800
        ENDC        
 ENDM

M_COPPTRS10: MACRO
 M_COPPTRS \1
 M_COPPTRS (\1+1)
 M_COPPTRS (\1+2)
 M_COPPTRS (\1+3)
 M_COPPTRS (\1+4)
 M_COPPTRS (\1+5)
 M_COPPTRS (\1+6)
 M_COPPTRS (\1+7)
 M_COPPTRS (\1+8)
 M_COPPTRS (\1+9) 	
 ENDM

M_COPPTRS100: MACRO
 M_COPPTRS10 \1
 M_COPPTRS10 (\1+10)
 M_COPPTRS10 (\1+20)
 M_COPPTRS10 (\1+30)
 M_COPPTRS10 (\1+40)
 M_COPPTRS10 (\1+50)
 M_COPPTRS10 (\1+60)
 M_COPPTRS10 (\1+70)
 M_COPPTRS10 (\1+80)
 M_COPPTRS10 (\1+90) 	
 ENDM

	CNOP 0,8
copperlist:        
	
        ;Sprpointers
        dc.w    $120,0,$122,0,$124,0,$126,0,$128,0,$12a,0
        dc.w    $12c,0,$12e,0,$130,0,$132,0,$134,0,$136,0
        dc.w    $138,0,$13a,0,$13c,0,$13e,0

	dc.w	$96, $8020

	dc.w	$8E,$2c81	                 ; DiwStrt
	dc.w	$90,$2cc1	                 ; DiwStop
	dc.w	$92,$38		                 ; DdfStart
	dc.w	$94,$d0		                 ; DdfStop
	dc.w	$102,0		                 ; BplCon1
	dc.w	$104,$20	                 ; BplCon2
	dc.w	$108,BPLWIDTH-40                 ; Bpl1Mod
	dc.w	$10a,BPLWIDTH-40                 ; Bpl2Mod

	IFEQ BPLCOUNT-8
	dc.w	$100,$210
	ELSE
	dc.w	$100,BPLCOUNT*$1000+$200	 ; bplcon0
	ENDC

;bplpointers:
	dc.w $e0,$0005,$e2,$0000	; bitplane pointers
	dc.w $e4,$0005,$e6,BPLWIDTH*BPLHEIGHT
        dc.w $e8,$0005,$ea,BPLWIDTH*BPLHEIGHT*2
        dc.w $ec,$0005,$ee,BPLWIDTH*BPLHEIGHT*3
        dc.w $f0,$0005,$f2,BPLWIDTH*BPLHEIGHT*4
        dc.w $f4,$0005,$f6,BPLWIDTH*BPLHEIGHT*5
        dc.w $f8,$0005,$fa,BPLWIDTH*BPLHEIGHT*6
        dc.w $fc,$0006,$fe,$1800

	IFEQ DUMMY-1
        dc.w    $106,$c00    
	dc.w	$180,$000    ;Dummy operation as placeholder
        dc.w    $182,$f00    ;01
        dc.w    $184,$0f0    ;10
        dc.w    $186,$0f0    ;11
        dc.w    $188,$00f    ;100
        dc.w    $18a,$00f    ;101
        dc.w    $18c,$00f    ;110
        dc.w    $18e,$00f    ;111
        dc.w    $190,$ff0    ;1000
        dc.w    $192,$ff0    ;1001
        dc.w    $194,$ff0    ;1010
        dc.w    $196,$ff0    ;1011
        dc.w    $198,$ff0    ;1100
        dc.w    $19a,$ff0    ;1101
        dc.w    $19c,$ff0    ;1110
        dc.w    $19e,$ff0    ;1111
	dc.w    $1a0,$0ff    ;10000
        dc.w    $1a2,$0ff    ;10001
        dc.w    $1a4,$0ff    ;10010
        dc.w    $1a6,$0ff    ;10011
        dc.w    $1a8,$0ff    ;10100
        dc.w    $1aa,$0ff    ;10101
        dc.w    $1ac,$0ff    ;10110
        dc.w    $1ae,$0ff    ;10111
        dc.w    $1b0,$0ff    ;11000
        dc.w    $1b2,$0ff    ;11001
        dc.w    $1b4,$0ff    ;11010
        dc.w    $1b6,$0ff    ;11011
        dc.w    $1b8,$0ff    ;11100
        dc.w    $1ba,$0ff    ;11101
        dc.w    $1bc,$0ff    ;11110
        dc.w    $1be,$0ff    ;11111

	dc.w	$106,$2c00
	dc.w    $180,$fff    ;100000
        dc.w    $182,$fff    ;100001
        dc.w    $184,$fff    ;100010
        dc.w    $186,$fff    ;100011
        dc.w    $188,$fff    ;100100
        dc.w    $18a,$fff    ;100101
        dc.w    $18c,$fff    ;100110
        dc.w    $18e,$fff    ;100111
        dc.w    $190,$fff    ;101000
        dc.w    $192,$fff    ;101001
        dc.w    $194,$fff    ;101010
        dc.w    $196,$fff    ;101011
        dc.w    $198,$fff    ;101100
        dc.w    $19a,$fff    ;101101
        dc.w    $19c,$fff    ;101110
        dc.w    $19e,$fff    ;101111
	dc.w    $1a0,$fe6    ;110000
        dc.w    $1a2,$fe6    ;110001
        dc.w    $1a4,$fe6    ;110010
        dc.w    $1a6,$fe6    ;110011
        dc.w    $1a8,$fe6    ;110100
        dc.w    $1aa,$fe6    ;110101
        dc.w    $1ac,$fe6    ;110110
        dc.w    $1ae,$fe6    ;110111
        dc.w    $1b0,$fe6    ;111000
        dc.w    $1b2,$fe6    ;111001
        dc.w    $1b4,$fe6    ;111010
        dc.w    $1b6,$fe6    ;111011
        dc.w    $1b8,$fe6    ;111100
        dc.w    $1ba,$fe6    ;111101
        dc.w    $1bc,$fe6    ;111110
        dc.w    $1be,$fe6    ;111111

	dc.w	$106,$4c00	
	dc.w    $180,$190    ;1000000
        dc.w    $182,$190    ;1000001
        dc.w    $184,$190    ;1000010
        dc.w    $186,$190    ;1000011
        dc.w    $188,$190    ;1000100
        dc.w    $18a,$190    ;1000101
        dc.w    $18c,$190    ;1000110
        dc.w    $18e,$190    ;1000111
        dc.w    $190,$190    ;1001000
        dc.w    $192,$190    ;1001001
        dc.w    $194,$190    ;1001010
        dc.w    $196,$190    ;1001011
        dc.w    $198,$190    ;1001100
        dc.w    $19a,$190    ;1001101
        dc.w    $19c,$190    ;1001110
        dc.w    $19e,$190    ;1001111
	dc.w    $1a0,$190    ;1010000
        dc.w    $1a2,$190    ;1010001
        dc.w    $1a4,$190    ;1010010
        dc.w    $1a6,$190    ;1010011
        dc.w    $1a8,$190    ;1010100
        dc.w    $1aa,$190    ;1010101
        dc.w    $1ac,$190    ;1010110
        dc.w    $1ae,$190    ;1010111
        dc.w    $1b0,$190    ;1011000
        dc.w    $1b2,$190    ;1011001
        dc.w    $1b4,$190    ;1011010
        dc.w    $1b6,$190    ;1011011
        dc.w    $1b8,$190    ;1011100
        dc.w    $1ba,$190    ;1011101
        dc.w    $1bc,$190    ;1011110
        dc.w    $1be,$190    ;1011111

	dc.w	$106,$6c00
	dc.w    $180,$190    ;1100000
        dc.w    $182,$190    ;1100001
        dc.w    $184,$190    ;1100010
        dc.w    $186,$190    ;1100011
        dc.w    $188,$190    ;1100100
        dc.w    $18a,$190    ;1100101
        dc.w    $18c,$190    ;1100110
        dc.w    $18e,$190    ;1100111
        dc.w    $190,$190    ;1101000
        dc.w    $192,$190    ;1101001
        dc.w    $194,$190    ;1101010
        dc.w    $196,$190    ;1101011
        dc.w    $198,$190    ;1101100
        dc.w    $19a,$190    ;1101101
        dc.w    $19c,$190    ;1101110
        dc.w    $19e,$190    ;1101111
	dc.w    $1a0,$190    ;1110000
        dc.w    $1a2,$190    ;1110001
        dc.w    $1a4,$190    ;1110010
        dc.w    $1a6,$190    ;1110011
        dc.w    $1a8,$190    ;1110100
        dc.w    $1aa,$190    ;1110101
        dc.w    $1ac,$190    ;1110110
        dc.w    $1ae,$190    ;1110111
        dc.w    $1b0,$190    ;1111000
        dc.w    $1b2,$190    ;1111001
        dc.w    $1b4,$190    ;1111010
        dc.w    $1b6,$190    ;1111011
        dc.w    $1b8,$190    ;1111100
        dc.w    $1ba,$190    ;1111101
        dc.w    $1bc,$190    ;1111110
        dc.w    $1be,$190    ;1111111

	dc.w	$106,$8c00
	dc.w    $180,$c00    ;10000000
        dc.w    $182,$c00    ;10000001
        dc.w    $184,$c00    ;10000010
        dc.w    $186,$c00    ;10000011
        dc.w    $188,$c00    ;10000100
        dc.w    $18a,$c00    ;10000101
        dc.w    $18c,$c00    ;10000110
        dc.w    $18e,$c00    ;10000111
        dc.w    $190,$c00    ;10001000
        dc.w    $192,$c00    ;10001001
        dc.w    $194,$c00    ;10001010
        dc.w    $196,$c00    ;10001011
        dc.w    $198,$c00    ;10001100
        dc.w    $19a,$c00    ;10001101
        dc.w    $19c,$c00    ;10001110
        dc.w    $19e,$c00    ;10001111
	dc.w    $1a0,$c00    ;10010000
        dc.w    $1a2,$c00    ;10010001
        dc.w    $1a4,$c00    ;10010010
        dc.w    $1a6,$c00    ;10010011
        dc.w    $1a8,$c00    ;10010100
        dc.w    $1aa,$c00    ;10010101
        dc.w    $1ac,$c00    ;10010110
        dc.w    $1ae,$c00    ;10010111
        dc.w    $1b0,$c00    ;10011000
        dc.w    $1b2,$c00    ;10011001
        dc.w    $1b4,$c00    ;10011010
        dc.w    $1b6,$c00    ;10011011
        dc.w    $1b8,$c00    ;10011100
        dc.w    $1ba,$c00    ;10011101
        dc.w    $1bc,$c00    ;10011110
        dc.w    $1be,$c00    ;10011111

	dc.w	$106,$ac00
	dc.w    $180,$c00    ;10100000
        dc.w    $182,$c00    ;10100001
        dc.w    $184,$c00    ;10100010
        dc.w    $186,$c00    ;10100011
        dc.w    $188,$c00    ;10100100
        dc.w    $18a,$c00    ;10100101
        dc.w    $18c,$c00    ;10100110
        dc.w    $18e,$c00    ;10100111
        dc.w    $190,$c00    ;10101000
        dc.w    $192,$c00    ;10101001
        dc.w    $194,$c00    ;10101010
        dc.w    $196,$c00    ;10101011
        dc.w    $198,$c00    ;10101100
        dc.w    $19a,$c00    ;10101101
        dc.w    $19c,$c00    ;10101110
        dc.w    $19e,$c00    ;10101111
	dc.w    $1a0,$c00    ;10110000
        dc.w    $1a2,$c00    ;10110001
        dc.w    $1a4,$c00    ;10110010
        dc.w    $1a6,$c00    ;10110011
        dc.w    $1a8,$c00    ;10110100
        dc.w    $1aa,$c00    ;10110101
        dc.w    $1ac,$c00    ;10110110
        dc.w    $1ae,$c00    ;10110111
        dc.w    $1b0,$c00    ;10111000
        dc.w    $1b2,$c00    ;10111001
        dc.w    $1b4,$c00    ;10111010
        dc.w    $1b6,$c00    ;10111011
        dc.w    $1b8,$c00    ;10111100
        dc.w    $1ba,$c00    ;10111101
        dc.w    $1bc,$c00    ;10111110
        dc.w    $1be,$c00    ;10111111

	dc.w	$106,$cc00
	dc.w    $180,$f20    ;11000000
        dc.w    $182,$f20    ;11000001
        dc.w    $184,$f20    ;11000010
        dc.w    $186,$f20    ;11000011
        dc.w    $188,$f20    ;11000100
        dc.w    $18a,$f20    ;11000101
        dc.w    $18c,$f20    ;11000110
        dc.w    $18e,$f20    ;11000111
        dc.w    $f20,$f20    ;11001000
        dc.w    $192,$f20    ;11001001
        dc.w    $194,$f20    ;11001010
        dc.w    $196,$f20    ;11001011
        dc.w    $198,$f20    ;11001100
        dc.w    $19a,$f20    ;11001101
        dc.w    $19c,$f20    ;11001110
        dc.w    $19e,$f20    ;11001111
	dc.w    $1a0,$f20    ;11010000
        dc.w    $1a2,$f20    ;11010001
        dc.w    $1a4,$f20    ;11010010
        dc.w    $1a6,$f20    ;11010011
        dc.w    $1a8,$f20    ;11010100
        dc.w    $1aa,$f20    ;11010101
        dc.w    $1ac,$f20    ;11010110
        dc.w    $1ae,$f20    ;11010111
        dc.w    $1b0,$f20    ;11011000
        dc.w    $1b2,$f20    ;11011001
        dc.w    $1b4,$f20    ;11011010
        dc.w    $1b6,$f20    ;11011011
        dc.w    $1b8,$f20    ;11011100
        dc.w    $1ba,$f20    ;11011101
        dc.w    $1bc,$f20    ;11011110
        dc.w    $1be,$f20    ;11011111

	dc.w	$106,$ec00
	dc.w    $180,$f20    ;11100000
        dc.w    $182,$f20    ;11100001
        dc.w    $184,$f20    ;11100010
        dc.w    $186,$f20    ;11100011
        dc.w    $188,$f20    ;11100100
        dc.w    $18a,$f20    ;11100101
        dc.w    $18c,$f20    ;11100110
        dc.w    $18e,$f20    ;11100111
        dc.w    $f20,$f20    ;11101000
        dc.w    $192,$f20    ;11101001
        dc.w    $194,$f20    ;11101010
        dc.w    $196,$f20    ;11101011
        dc.w    $198,$f20    ;11101100
        dc.w    $19a,$f20    ;11101101
        dc.w    $19c,$f20    ;11101110
        dc.w    $19e,$f20    ;11101111
	dc.w    $1a0,$f20    ;11110000
        dc.w    $1a2,$f20    ;11110001
        dc.w    $1a4,$f20    ;11110010
        dc.w    $1a6,$f20    ;11110011
        dc.w    $1a8,$f20    ;11110100
        dc.w    $1aa,$f20    ;11110101
        dc.w    $1ac,$f20    ;11110110
        dc.w    $1ae,$f20    ;11110111
        dc.w    $1b0,$f20    ;11111000
        dc.w    $1b2,$f20    ;11111001
        dc.w    $1b4,$f20    ;11111010
        dc.w    $1b6,$f20    ;11111011
        dc.w    $1b8,$f20    ;11111100
        dc.w    $1ba,$f20    ;11111101
        dc.w    $1bc,$f20    ;11111110
        dc.w    $1be,$f20    ;11111111

	dc.w	$106,$e00	
	dc.w	$182,$fd3    ;Dummy operation as placeholder	
	dc.w    $182,$fd3    ;00001
        dc.w    $184,$fff    ;00010
        dc.w    $186,$fe6    ;00011
        dc.w    $188,$190    ;00100
        dc.w    $18a,$190    ;00101
        dc.w    $18c,$190    ;00110
        dc.w    $18e,$190    ;00111
        dc.w    $190,$c00    ;01000
        dc.w    $192,$c00    ;01001
        dc.w    $194,$c00    ;01010
        dc.w    $196,$c00    ;01011
        dc.w    $198,$f20    ;01100
        dc.w    $19a,$f20    ;01101
        dc.w    $19c,$f20    ;01110
        dc.w    $19e,$f20    ;01111
	dc.w    $1a0,$fd3    ;10000
        dc.w    $1a2,$fd3    ;10001
        dc.w    $1a4,$fd3    ;10010
        dc.w    $1a6,$fd3    ;10011
        dc.w    $1a8,$fd3    ;10100
        dc.w    $1aa,$fd3    ;10101
        dc.w    $1ac,$fd3    ;10110
        dc.w    $1ae,$fd3    ;10111
        dc.w    $1b0,$fd3    ;11000
        dc.w    $1b2,$fd3    ;11001
        dc.w    $1b4,$fd3    ;11010
        dc.w    $1b6,$fd3    ;11011
        dc.w    $1b8,$fd3    ;11100
        dc.w    $1ba,$fd3    ;11101
        dc.w    $1bc,$fd3    ;11110
        dc.w    $1be,$fd3    ;11111
        
	dc.w	$106,$2e00
	dc.w    $180,$fff    ;100000
        dc.w    $182,$fff    ;100001
        dc.w    $184,$fff    ;100010
        dc.w    $186,$fff    ;100011
        dc.w    $188,$fff    ;100100
        dc.w    $18a,$fff    ;100101
        dc.w    $18c,$fff    ;100110
        dc.w    $18e,$fff    ;100111
        dc.w    $190,$fff    ;101000
        dc.w    $192,$fff    ;101001
        dc.w    $194,$fff    ;101010
        dc.w    $196,$fff    ;101011
        dc.w    $198,$fff    ;101100
        dc.w    $19a,$fff    ;101101
        dc.w    $19c,$fff    ;101110
        dc.w    $19e,$fff    ;101111
	dc.w    $1a0,$fff    ;110000
        dc.w    $1a2,$fff    ;110001
        dc.w    $1a4,$fff    ;110010
        dc.w    $1a6,$fff    ;110011
        dc.w    $1a8,$fff    ;110100
        dc.w    $1aa,$fff    ;110101
        dc.w    $1ac,$fff    ;110110
        dc.w    $1ae,$fff    ;110111
        dc.w    $1b0,$fff    ;111000
        dc.w    $1b2,$fff    ;111001
        dc.w    $1b4,$fff    ;111010
        dc.w    $1b6,$fff    ;111011
        dc.w    $1b8,$fff    ;111100
        dc.w    $1ba,$fff    ;111101
        dc.w    $1bc,$fff    ;111110
        dc.w    $1be,$fff    ;111111


	dc.w	$106,$4e00
	dc.w    $180,$f0f    ;1000000
        dc.w    $182,$f0f    ;1000001
        dc.w    $184,$f0f    ;1000010
        dc.w    $186,$f0f    ;1000011
        dc.w    $188,$f0f    ;1000100
        dc.w    $18a,$f0f    ;1000101
        dc.w    $18c,$f0f    ;1000110
        dc.w    $18e,$f0f    ;1000111
        dc.w    $f0f,$f0f    ;1001000
        dc.w    $192,$f0f    ;1001001
        dc.w    $194,$f0f    ;1001010
        dc.w    $196,$f0f    ;1001011
        dc.w    $198,$f0f    ;1001100
        dc.w    $19a,$f0f    ;1001101
        dc.w    $19c,$f0f    ;1001110
        dc.w    $19e,$f0f    ;1001111
	dc.w    $1a0,$f0f    ;1010000
        dc.w    $1a2,$f0f    ;1010001
        dc.w    $1a4,$f0f    ;1010010
        dc.w    $1a6,$f0f    ;1010011
        dc.w    $1a8,$f0f    ;1010100
        dc.w    $1aa,$f0f    ;1010101
        dc.w    $1ac,$f0f    ;1010110
        dc.w    $1ae,$f0f    ;1010111
        dc.w    $1b0,$f0f    ;1011000
        dc.w    $1b2,$f0f    ;1011001
        dc.w    $1b4,$f0f    ;1011010
        dc.w    $1b6,$f0f    ;1011011
        dc.w    $1b8,$f0f    ;1011100
        dc.w    $1ba,$f0f    ;1011101
        dc.w    $1bc,$f0f    ;1011110
        dc.w    $1be,$f0f    ;1011111		

	dc.w	$106,$6e00
	dc.w    $180,$f0f    ;1100000
        dc.w    $182,$f0f    ;1100001
        dc.w    $184,$f0f    ;1100010
        dc.w    $186,$f0f    ;1100011
        dc.w    $188,$f0f    ;1100100
        dc.w    $18a,$f0f    ;1100101
        dc.w    $18c,$f0f    ;1100110
        dc.w    $18e,$f0f    ;1100111
        dc.w    $f0f,$f0f    ;1101000
        dc.w    $192,$f0f    ;1101001
        dc.w    $194,$f0f    ;1101010
        dc.w    $196,$f0f    ;1101011
        dc.w    $198,$f0f    ;1101100
        dc.w    $19a,$f0f    ;1101101
        dc.w    $19c,$f0f    ;1101110
        dc.w    $19e,$f0f    ;1101111
	dc.w    $1a0,$f0f    ;1110000
        dc.w    $1a2,$f0f    ;1110001
        dc.w    $1a4,$f0f    ;1110010
        dc.w    $1a6,$f0f    ;1110011
        dc.w    $1a8,$f0f    ;1110100
        dc.w    $1aa,$f0f    ;1110101
        dc.w    $1ac,$f0f    ;1110110
        dc.w    $1ae,$f0f    ;1110111
        dc.w    $1b0,$f0f    ;1111000
        dc.w    $1b2,$f0f    ;1111001
        dc.w    $1b4,$f0f    ;1111010
        dc.w    $1b6,$f0f    ;1111011
        dc.w    $1b8,$f0f    ;1111100
        dc.w    $1ba,$f0f    ;1111101
        dc.w    $1bc,$f0f    ;1111110
        dc.w    $1be,$f0f    ;1111111
	

	dc.w	$106,$8e00	
	dc.w    $180,$c00    ;10000000
        dc.w    $182,$c00    ;10000001
        dc.w    $184,$c00    ;10000010
        dc.w    $186,$c00    ;10000011
        dc.w    $188,$c00    ;10000100
        dc.w    $18a,$c00    ;10000101
        dc.w    $18c,$c00    ;10000110
        dc.w    $18e,$c00    ;10000111
        dc.w    $f0f,$c00    ;10001000
        dc.w    $192,$c00    ;10001001
        dc.w    $194,$c00    ;10001010
        dc.w    $196,$c00    ;10001011
        dc.w    $198,$c00    ;10001100
        dc.w    $19a,$c00    ;10001101
        dc.w    $19c,$c00    ;10001110
        dc.w    $19e,$c00    ;10001111
	dc.w    $1a0,$c00    ;10010000
        dc.w    $1a2,$c00    ;10010001
        dc.w    $1a4,$c00    ;10010010
        dc.w    $1a6,$c00    ;10010011
        dc.w    $1a8,$c00    ;10010100
        dc.w    $1aa,$c00    ;10010101
        dc.w    $1ac,$c00    ;10010110
        dc.w    $1ae,$c00    ;10010111
        dc.w    $1b0,$c00    ;10011000
        dc.w    $1b2,$c00    ;10011001
        dc.w    $1b4,$c00    ;10011010
        dc.w    $1b6,$c00    ;10011011
        dc.w    $1b8,$c00    ;10011100
        dc.w    $1ba,$c00    ;10011101
        dc.w    $1bc,$c00    ;10011110
        dc.w    $1be,$c00    ;10011111

	
	dc.w	$106,$ae00	
	dc.w    $180,$c00    ;10100000
        dc.w    $182,$c00    ;10100001
        dc.w    $184,$c00    ;10100010
        dc.w    $186,$c00    ;10100011
        dc.w    $188,$c00    ;10100100
        dc.w    $18a,$c00    ;10100101
        dc.w    $18c,$c00    ;10100110
        dc.w    $18e,$c00    ;10100111
        dc.w    $f0f,$c00    ;10101000
        dc.w    $192,$c00    ;10101001
        dc.w    $194,$c00    ;10101010
        dc.w    $196,$c00    ;10101011
        dc.w    $198,$c00    ;10101100
        dc.w    $19a,$c00    ;10101101
        dc.w    $19c,$c00    ;10101110
        dc.w    $19e,$c00    ;10101111
	dc.w    $1a0,$c00    ;10110000
        dc.w    $1a2,$c00    ;10110001
        dc.w    $1a4,$c00    ;10110010
        dc.w    $1a6,$c00    ;10110011
        dc.w    $1a8,$c00    ;10110100
        dc.w    $1aa,$c00    ;10110101
        dc.w    $1ac,$c00    ;10110110
        dc.w    $1ae,$c00    ;10110111
        dc.w    $1b0,$c00    ;10111000
        dc.w    $1b2,$c00    ;10111001
        dc.w    $1b4,$c00    ;10111010
        dc.w    $1b6,$c00    ;10111011
        dc.w    $1b8,$c00    ;10111100
        dc.w    $1ba,$c00    ;10111101
        dc.w    $1bc,$c00    ;10111110
        dc.w    $1be,$c00    ;10111111
		
	dc.w	$106,$ce00	
	dc.w    $180,$c00    ;11000000
        dc.w    $182,$c00    ;11000001
        dc.w    $184,$c00    ;11000010
        dc.w    $186,$c00    ;11000011
        dc.w    $188,$c00    ;11000100
        dc.w    $18a,$c00    ;11000101
        dc.w    $18c,$c00    ;11000110
        dc.w    $18e,$c00    ;11000111
        dc.w    $c00,$c00    ;11001000
        dc.w    $192,$c00    ;11001001
        dc.w    $194,$c00    ;11001010
        dc.w    $196,$c00    ;11001011
        dc.w    $198,$c00    ;11001100
        dc.w    $19a,$c00    ;11001101
        dc.w    $19c,$c00    ;11001110
        dc.w    $19e,$c00    ;11001111
	dc.w    $1a0,$c00    ;11010000
        dc.w    $1a2,$c00    ;11010001
        dc.w    $1a4,$c00    ;11010010
        dc.w    $1a6,$c00    ;11010011
        dc.w    $1a8,$c00    ;11010100
        dc.w    $1aa,$c00    ;11010101
        dc.w    $1ac,$c00    ;11010110
        dc.w    $1ae,$c00    ;11010111
        dc.w    $1b0,$c00    ;11011000
        dc.w    $1b2,$c00    ;11011001
        dc.w    $1b4,$c00    ;11011010
        dc.w    $1b6,$c00    ;11011011
        dc.w    $1b8,$c00    ;11011100
        dc.w    $1ba,$c00    ;11011101
        dc.w    $1bc,$c00    ;11011110
        dc.w    $1be,$c00    ;11011111
	
        
	dc.w	$106,$ee00	
	dc.w    $180,$c00    ;11100000
        dc.w    $182,$c00    ;11100001
        dc.w    $184,$c00    ;11100010
        dc.w    $186,$c00    ;11100011
        dc.w    $188,$c00    ;11100100
        dc.w    $18a,$c00    ;11100101
        dc.w    $18c,$c00    ;11100110
        dc.w    $18e,$c00    ;11100111
        dc.w    $c00,$c00    ;11101000
        dc.w    $192,$c00    ;11101001
        dc.w    $194,$c00    ;11101010
        dc.w    $196,$c00    ;11101011
        dc.w    $198,$c00    ;11101100
        dc.w    $19a,$c00    ;11101101
        dc.w    $19c,$c00    ;11101110
        dc.w    $19e,$c00    ;11101111
	dc.w    $1a0,$c00    ;11110000
        dc.w    $1a2,$c00    ;11110001
        dc.w    $1a4,$c00    ;11110010
        dc.w    $1a6,$c00    ;11110011
        dc.w    $1a8,$c00    ;11110100
        dc.w    $1aa,$c00    ;11110101
        dc.w    $1ac,$c00    ;11110110
        dc.w    $1ae,$c00    ;11110111
        dc.w    $1b0,$c00    ;11111000
        dc.w    $1b2,$c00    ;11111001
        dc.w    $1b4,$c00    ;11111010
        dc.w    $1b6,$c00    ;11111011
        dc.w    $1b8,$c00    ;11111100
        dc.w    $1ba,$c00    ;11111101
        dc.w    $1bc,$c00    ;11111110
        dc.w    $1be,$c00    ;11111111
	ENDC

;clblockdraw:
	M_COPPTRS100 $2c
	M_COPPTRS100 $2c+100	 		
        dc.l $fffffffe

 ORG $50000
bitplane:
	dc.b $ff
	REPT 39
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b 0,$ff
	REPT 38
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b $0,0,$ff
	REPT 37
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b $0,0,0,$ff
	REPT 36
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b 0,0,0,0,$ff
	REPT 35
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b 0,0,0,0,0,$ff
	REPT 34
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b 0,0,0,0,0,0,$ff
	REPT 33
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

	dc.b 0,0,0,0,0,0,0,$ff
	REPT 32
	dc.b 0
	ENDR
	dcb.b BPLWIDTH*(BPLHEIGHT-1),0

