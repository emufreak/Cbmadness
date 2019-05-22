ùúùú        g                  CA=CreatePattern:

;input
;a0 - pointer to array with dimensions
;a1 - pointer to array with content
;processing       
;a2 - space width
;a3 - block width  
;a4 - line to draw current pos
;a5 - line to draw start this layer

        move.w   DIMDEPTH(a0),d1

        ;get block width
        move.w   d1,d3 
        move.w   #CNTBLSIZE,d4           
        bsr.w    GetArrValue
        move.l   a2,a3

        lea      blpattern(pc),a5
        subq     #1,d1                 ;Prepare number of layers as dbf counter
.nextlayer:
        move.l   a5,a4 
        lea      40(a5),a5             ;Prepare for next layer already 
        move.w   (a3)+,d0    
        move.w   (a2)+,d4               ;get free space after block   
.lp1:
        ;draw block template
        moveq.l  #0,d3                 ;create pattern if only one lw
        subq.l   #1,d3                 ;ffffffff startpattern for block                      
        
        moveq    #32,d2                ;Calc shift
        sub.w    d0,d2
        bmi.s    .br1                  ;Line still to draw gt lw
        lsl.l    d2,d3
.br1:
        move.l   d3,(a4)+
        move.w   d2,d0
        neg.w    d0                    ;get remainder of line
        bpl.s    .lp1                  ;loop if something left        
        dbf      d1, .nextlayer
        rts

