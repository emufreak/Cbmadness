<?php
  $linecount = 101;
  $startsize = 10;
?>
EF5_LINEMULT = 0
EF5_LINESHIFTS = <?php echo( $linecount*4+4 . "\n"); ?>
EF5_LINESIZE = <?php echo( ($linecount*4+4)*2 . "\n"); ?>

EF51_LINEMULTIPLIERS:
<?php 
  $anglechange = 360 / 101;
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
      $linemultiplier = abs( floor( ( 1 / cos( deg2rad( $angle)) * 256)));	  
	  echo( $linemultiplier);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 100) break 2;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1)
?>,$fffffff

EF51_LINESHIFTS:
<?php 
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
      $lineshift = floor( tan( deg2rad( $angle)) * 256);
	  echo( $lineshift);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 100) break 2;
	  if($i < 9) echo(", ");
      
	}
    echo("\n");	
  } while(1);
?>,$fffffff

EF51_LINESIZE:
<?php 
  $multfactor = 1.021;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {  
	  
	  echo( floor( $size));
	  $angle += $anglechange;

	  if($y < 150)
		$size *= $multfactor;
	  else 
		$size /= $multfactor;
	
  	  $y ++;
	  if($y > 300) break 2;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1)
?>,$fffffff

<?php
  $lwcount = 1;
  $size = $startsize;
  for($i=1;$i<=301;$i++) {
?>
EF51_COLORS<?php echo( $i); ?>:
<?php
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	    $color = floor( $size / 320 * 255);
		$colorlw = ($color & 0b1111);
		$colorhw = ($color >> 4);
	    $colorhw = $colorhw + ($colorhw << 4) + ($colorhw << 8);
	    $colorlw = $colorlw + ($colorlw << 4) + ($colorlw << 8);
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
    if($i < 150)
      $size *= $multfactor;
	else 
	  $size /= $multfactor;
  }
?>
 dc.l $fffffff

EF52_LINEMULTIPLIERS:
<?php 
  $anglechange = 360 / 536;
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	   if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $angleuse = 90.0011;
	  else
	    $angleuse = $angle;
      $linemultiplier = abs( floor( ( 1 / cos( deg2rad( $angleuse)) * 256)));	  
	  echo( $linemultiplier);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 535) break 2;
	  if($i < 9) echo(", ");
	}
    echo("\n");	
  } while(1)
	  
?>,$fffffff

EF52_LINESHIFTS:
<?php 
  $angle = 0;
  $size = 10;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $angleuse = 90.0011;
	  else
	    $angleuse = $angle;
      $lineshift = floor( tan( deg2rad( $angleuse)) * 256);
	  echo( $lineshift);
	  $angle += $anglechange;
	  $y += 1;
	  if($y > 535) break 2;
	  if($i < 9) echo(", ");
      
	}
    echo("\n");	
  } while(1);
?>,$fffffff

EF52_LINESHIFTSCCW:
<?php 
  $angle = 360;
  $y = 0;
  do {
	echo( "  dc.l ");
    for($i = 0; $i < 10; $i++) {
	  if(  (  $angle > 89.9989 && $angle < 90.0011)
	      || (  $angle > 269.9989 && $angle < 270.0011))
        $angleuse = 90.0011;
	  else
	    $angleuse = $angle;
      $lineshift = floor( tan( deg2rad( $angleuse)) * 256);
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
  for($x=0;$x<8;$x++) { ?>
EF52_LINESIZE_<?php echo($x); ?>:
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
        if($y > 66) break 2;
        if($i < 9) echo(", ");
      }
     echo("\n");	
    } while(1)
?>,$fffffff
<?php
  }
?>

<?php
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = $startsize;
  for($i=1;$i<=67;$i++) {
    $sizeuse = $size;
?>
EF52_COLORS<?php echo( $i); ?>:
<?php
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	    $color = floor( $sizeuse / 320 * 255);
		$colorlw = ($color & 0b1111);
		$colorhw = ($color >> 4);
	    $colorhw = $colorhw + ($colorhw << 4) + ($colorhw << 8);
	    $colorlw = $colorlw + ($colorlw << 4) + ($colorlw << 8);
		echo($colorhw . "," . $colorlw);
		if($lwcount < 10 && $z < pow( 2,$y-1)) {
		  $lwcount++;
		  echo(",");
		} else {
		  echo("\n");
		  $lwcount = 1;
		}     
      }	 
      $sizeuse *= $layfactor;	  
	}
    $size *= $multfactor;
  }
?>

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