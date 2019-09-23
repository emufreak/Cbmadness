<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,134);
  $lwcount = 1;
  $size = 20;
  for($i=1;$i<=276;$i++) {
    $sizeuse = $size;
?>

EF71_COLORS<?php echo( $i); ?>
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	    
		for($i2=0;$i2<=3;$i2++) {
	      if( ( $index & pow( 2,$i2*2)) != 0) {
		    $colorlayer = $size * pow($layfactor, $i2)*0.8;	
	        if( ( $index & pow(2,$i2*2+1)) != 0) {
			  $colorlayer = $colorlayer * $i / 276;	
		    }
		    $sizeuse = $sizeuse*0.2 + $colorlayer;
		  } elseif( ($index & pow(2,$i2*2+1)) != 0) {
		   $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, $i2)*0.8;	
		  }
	    }	
		
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
    //$size *= $multfactor;
  }
?>
  dc.l $fffffff

<?php
  $size = 10;
  for($i=1;$i<8;$i++) { ?>
EF72_LINESIZE_<?php echo($i); ?>:
<?php
    $multfactor = 1.006486;
    $y = 0;
	if($i & 1 == 0) {
	  $size *= pow($multfactor,67); 	
	}
    do {
      echo( "  dc.l ");
      for($i2 = 0; $i2 < 10; $i2++) {  
        echo( floor( $size));
        $angle += $anglechange;
		if($i & 1 == 0) {
          $size *= $multfactor;
		}
        $y ++;
        if($y > 66) break 2;
        if($i2 < 9) echo(", ");
      }
     echo("\n");	
    } while(1)
?>,$fffffff
<?php
  }
?>