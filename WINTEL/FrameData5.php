EF61_LINEMULTIPLIERS:
<?php 
  $startsize = 10;
  $anglechange = 360 / 536;
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	   if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $linemultiplier = 320*256;
	  else
	    $linemultiplier = abs( floor( ( 1 / cos( deg2rad( $angle)) * 256)));	  
	  echo( $linemultiplier);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 535) break 2;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1)
	  
?>,$fffffff

EF61_LINESHIFTS:
<?php 
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $lineshift = 320*256;
	  else
	    $lineshift = floor( tan( deg2rad( $angle)) * 256);
	  echo( $lineshift);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 535) break 2;
	  if($i < 9) echo(", ");
      
	}
    echo("\n");	
  } while(1);
?>,$fffffff

EF61_LINESHIFTSCCW:
<?php 
  $angle = 360;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $lineshift = 320*256;
	  else
	    $lineshift = floor( tan( deg2rad( $angle)) * 256);
	  echo( $lineshift);
	  $angle -= $anglechange;
	  $y += 1;
	  if($y > 535) break 2;
	  if($i < 9) echo(", ");
      
	}
    echo("\n");	
  } while(1);
?>,$fffffff

<?php
  $size = 10;
  for($x=0;$x<4;$x++) { ?>
EF61_LINESIZE_<?php echo($x); ?>:
<?php
    $multfactor = 1.006486;
    $y = 0;
    do {
      echo( "  dc.l ");
      for($i = 0; $i < 10; $i++) {  
        echo( floor( $size));
        $angle += $anglechange;
        $size *= $multfactor;
        $y ++;
        if($y > 133) break 2;
        if($i < 9) echo(", ");
      }
     echo("\n");	
    } while(1)
?>,$fffffff
<?php
  }
?>

<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,134);
  $lwcount = 1;
  $size = 20;
  for($i=1;$i<=134;$i++) {
    $sizeuse = $size;
?>
EF61_COLORS<?php echo( $i); ?>:
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	    
		$sizeuse = 0;
		if( ( ($index & 2) != 0) 
			xor ( ($index & 1)  != 0))
          $sizeuse += $size * pow($layfactor, 0);
        if( ( ($index & 8) != 0) 
			xor ( ($index & 4)  != 0))
		  $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, 1)*0.8;	
        if( ( ($index & 32) != 0) 
			xor ( ($index & 16)  != 0))
          $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, 2)*0.8;	  
	    if( ( ($index & 128) != 0) 
			xor ( ($index & 64)  != 0))
          $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, 3)*0.8;		

	    $color = floor( $sizeuse / 320 * 255);
		$colorlw = ($color & 0b1111);
		$colorhw = ($color >> 4);
	    //$colorhw = $colorhw + ($colorhw << 4) + ($colorhw << 8);
	    //$colorlw = $colorlw + ($colorlw << 4) + ($colorlw << 8);
		echo($colorhw . "," . $colorlw);
		if($lwcount < 10 && $z < pow( 2,$y-1)) {
		  $lwcount++;
		  echo(",");
		} else {
		  echo("\n");
		  $lwcount = 1;
		}     
      }	 	  
	}
    $size *= $multfactor;
  }
?>
  dc.l $fffffff

EF64_LINESHIFTS:
<?php 
  $anglechange = 80 / 268;
  $angle = 80;
  $size = 10;
  $y = 0;
  $direction = 1;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $lineshift = 320*256;
	  else
	    $lineshift = floor( tan( deg2rad( $angle)) * 256);
	  echo( $lineshift);
	  $angle += ($anglechange * $direction);
	  $y += 1;
	  if($y > 267) break 2;
	  if($y == 133) $direction *= -1;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1);
?>,$fffffff
 
EF64_LINEMULTIPLIERS:
<?php 
  $anglechange = 80 / 268;
  $angle = 80;
  $size = 10;
  $y = 0;
  $direction = 1;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $linemultiplier = 320*256;
	  else
	    $linemultiplier = abs( floor( ( 1 / cos( deg2rad( $angle)) * 256)));
	  echo( $linemultiplier);
	  $angle += ($anglechange * $direction);
	  $y += 1;
	  if($y > 267) break 2;
	  if($y == 133) $direction *= -1;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1);
?>,$fffffff

EF65_LINESHIFTS:
<?php 
  $anglechange = 80 / 268;
  $angle = 150;
  $size = 10;
  $y = 0;
  $direction = 1;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $lineshift = 320*256;
	  else
	    $lineshift = floor( tan( deg2rad( $angle)) * 256);
	  echo( $lineshift);
	  $angle += ($anglechange * $direction);
	  $y += 1;
	  if($y > 267) break 2;
	  if($y == 133) $direction *= -1;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1);
?>,$fffffff
 
EF65_LINEMULTIPLIERS:
<?php 
  $anglechange = 80 / 268;
  $angle = 150;
  $size = 10;
  $y = 0;
  $direction = 1;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $linemultiplier = 320*256;
	  else
	    $linemultiplier = abs( floor( ( 1 / cos( deg2rad( $angle)) * 256)));
	  echo( $linemultiplier);
	  $angle += ($anglechange * $direction);
	  $y += 1;
	  if($y > 267) break 2;
	  if($y == 133) $direction *= -1;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1);
?>,$fffffff

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