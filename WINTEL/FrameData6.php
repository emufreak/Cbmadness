<?php
  //$multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,134);
  $lwcount = 1;
  $size = 10;
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
			$sizeuse = $sizeuse*0.2 +  $size * pow($layfactor, $i2)*0.8;	 
	        if( ( $index & pow(2,$i2*2+1)) != 0) {
			  $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, $i2)*0.8 
			                                                        * $i / 276;	
		    }
		  } elseif( ($index & pow(2,$i2*2+1)) != 0) {
		   $sizeuse = $sizeuse*0.2 + $size * pow($layfactor, $i2)*0.8;	
		  }
	    }	
		
	    $color = floor( $sizeuse / 320 * 255);
		$colorlw = ($color & 0b1111);
		$colorhw = ($color >> 4);
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
  for($i=1;$i<=8;$i++) { ?>
EF73_LINESIZE_<?php echo($i); ?>:
<?php
    //$multfactor = 1.005186;
	$multfactor = 1.006486;
    $y = 0;
	$sizeuse = $size;
    do {
      echo( "  dc.l ");
      for($i2 = 0; $i2 < 10; $i2++) {   
        echo( floor( $sizeuse));
        $angle += $anglechange;
		if( ( $i & 1) == 0) {
          $sizeuse *= $multfactor;
		}
        $y ++;
        if($y > 66) break 2;
        if($i2 < 9) echo(", ");
      }
     echo("\n");	
    } while(1);
    if( ( $i & 1) == 0) {
	  $size *= pow($multfactor,134); 	
	}
?>,$fffffff
<?php
  }

  $multfactor = 1.005186;
  $lwcount = 1;
  $sizeodd = 10;
  $sizeeven = $sizeodd;
  for($i=1;$i<=67;$i++) {    
?>
EF73_COLORS<?php echo( $i); ?>
<?php  
		
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
		$colorb = 0;
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	   
		for( $x=0;$x<=7;$x++)
		    if( ( $index & pow(2, $x)) != 0)  { 
		      if( ( $x & 1) == 0) {
			    $colorb = $colorb * 0.2 +  $sizeodd 
				                        * pow( $layfactor, floor( $x/2)) * 0.8;
			  } else {
			    $colorb = $colorb * 0.2 + $sizeeven 
				                        * pow( $layfactor, floor( $x/2)) * 0.8;
			  }
		    }	
		
		$colorr = floor( $colorr);
		$colorg = floor( $colorg);
		$colorb = floor( $colorb);
		$color = ($colorr << 16) + ($colorg << 8) + $colorb;
		$colorlw = ( ( $colorr & 0b1111) << 8)
		                   + ( ( $colorg & 0b1111) << 4) + ( $colorb & 0b1111);
		$colorhw = ( ( $colorr >> 4) << 8)
		                   + ( ( $colorg >> 4) << 4) + ( $colorb >> 4);

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
    $sizeeven *= $multfactor;
  }
?>
  dc.l $fffffff

<?php  
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 10;
  
  for($i=1;$i<=67;$i++) {
	$colorb = 0;
    $sizeuse = $size;
?> 
EF74_COLORS<?php echo( $i); ?>:
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
		for( $x=0;$x<=7;$x++)
		  if( ( $index & pow(2, $x)) != 0)
			$colorb = $colorb * 0.2 +  $size * pow( $layfactor, $x) * 0.8;
		
		$colorr = floor( 0);
		$colorg = floor( 0);
		$colorb = floor( $colorb);
		$color = ($colorr << 16) + ($colorg << 8) + $colorb;
		$colorlw = ( ( $colorr & 0b1111) << 8)
		                   + ( ( $colorg & 0b1111) << 4) + ( $colorb & 0b1111);
		$colorhw = ( ( $colorr >> 4) << 8)
		                   + ( ( $colorg >> 4) << 4) + ( $colorb >> 4);
		//echo($color . " ");				   
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

<?php
  $size = 10;
  for($x=0;$x<8;$x++) { ?>
EF74_LINESIZE_<?php echo($x); ?>:
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
