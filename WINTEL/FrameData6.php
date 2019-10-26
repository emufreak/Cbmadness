<?php
  $colors = array( array( "blue" => 0xfc, "green" => 0x42, "red" => 0x02),
		               array( "blue" => 0xfc, "green" => 0x7e, "red" => 0x01),
					    array( "blue" => 0xfc, "green" => 0xbd, "red" => 0x01),
						 array( "blue" => 0xbf, "green" => 0xff, "red" => 0x02),
						 array( "blue" => 0x7d, "green" => 0xfe, "red" => 0x01),
						 array( "blue" => 0x05, "green" => 0xfe, "red" => 0x05),
				 array( "blue" => 0x03, "green" => 0xfe, "red" => 0x7d),
						 array( "blue" => 0x00, "green" => 0xfe, "red" => 0xbf),
						 array( "blue" => 0x03, "green" => 0xfe, "red" => 0x7d),
						 array( "blue" => 0x05, "green" => 0xfe, "red" => 0x05),
						  array( "blue" => 0x7d, "green" => 0xfe, "red" => 0x01),
						  array( "blue" => 0xbf, "green" => 0xff, "red" => 0x02),
						  array( "blue" => 0xfc, "green" => 0xbd, "red" => 0x01),
						  array( "blue" => 0xfc, "green" => 0x7e, "red" => 0x01));
  $multfactor = 1.006486;
  //$multfactor = 1.005186;
  $layfactor = pow($multfactor,134);
  $lwcount = 1;
  $size = 20;
  $coltmp = $colors;
  
  for($i=1;$i<=14;$i++) {
    $sizeuse = 20*$layfactor;
?>

EF61_COLORS<?php echo( $i); ?>
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.l ");
	    if($y==1)
		  echo( "0,");
	    
		$colorr = 0;
	    $colorb = 0;
	    $colorg = 0;
		for($i2=0;$i2<=3;$i2++) {
	      if( ( $index & pow( 2,$i2*2)) != 0) {
			if( ( $index & pow(2,$i2*2+1)) == 0) {
			  $colorr = $colorr * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["red"] / 640;
			  $colorg = $colorg * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["green"] / 640;
			  $colorb = $colorb * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["blue"] / 640;
			}
		  } elseif( ($index & pow(2,$i2*2+1)) != 0) {
		    $colorr = $colorr * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["red"] / 640;
			$colorg = $colorg * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["green"] / 640;
			$colorb = $colorb * 0.2 + $sizeuse * pow($layfactor, $i2)*0.8 * $coltmp[10-$i2]["blue"] / 640;
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
		echo("$" . dechex($color));
		//echo($colorhw . "," . $colorlw);
		if($lwcount < 10 && $z < pow( 2,$y-1)) {
		  $lwcount++;
		  echo(",");
		} else {
		  echo("\n");
		  $lwcount = 1;
		}     
      }	 	  
	}
	//print_r( $coltmp);
	$tmp = array_shift($coltmp);
	array_push($coltmp, $tmp);
  }
?>
  dc.l $fffffff
<?php
  $colors = array(     	array( "blue" => 0x05, "green" => 0xfe, "red" => 0x05),
						 array( "blue" => 0x03, "green" => 0xfe, "red" => 0x7d),
						 array( "blue" => 0x00, "green" => 0xfe, "red" => 0xbf),
						 array( "blue" => 0x03, "green" => 0xfe, "red" => 0x7d),
						 array( "blue" => 0x05, "green" => 0xfe, "red" => 0x05),
						  array( "blue" => 0x7d, "green" => 0xfe, "red" => 0x01),
						  array( "blue" => 0xbf, "green" => 0xff, "red" => 0x02),
						  array( "blue" => 0xfc, "green" => 0xbd, "red" => 0x01),
						  array( "blue" => 0xfc, "green" => 0x7e, "red" => 0x01),
						  array( "blue" => 0xfc, "green" => 0x42, "red" => 0x02),
						  array( "blue" => 0xfc, "green" => 0x7e, "red" => 0x01),
						  array( "blue" => 0xfc, "green" => 0xbd, "red" => 0x01),
						  array( "blue" => 0xbf, "green" => 0xff, "red" => 0x02),
						  array( "blue" => 0x7d, "green" => 0xfe, "red" => 0x01));

?>
EF71_COLORS1:
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.l ");
	    if($y==1)
		  echo( "0,");
	    
		$colorr = 0;
	    $colorb = 0;
	    $colorg = 0;
		for($i2=0;$i2<=3;$i2++) {
	      if( ( $index & pow( 2,$i2*2)) != 0) {
			if( ( $index & pow(2,$i2*2+1)) == 0) {
			  $colorr = $colorr * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["red"] / 640;
			  $colorg = $colorg * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["green"] / 640;
			  $colorb = $colorb * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["blue"] / 640;
			}
		  } elseif( ($index & pow(2,$i2*2+1)) != 0) {
		    $colorr = $colorr * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["red"] / 640;
			$colorg = $colorg * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["green"] / 640;
			$colorb = $colorb * 0.2 + $size * pow($layfactor, $i2)*0.8 * $colors[10-$i2]["blue"] / 640;
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
		echo("$" . dechex($color));
		//echo($colorhw . "," . $colorlw);
		if($lwcount < 10 && $z < pow( 2,$y-1)) {
		  $lwcount++;
		  echo(",");
		} else {
		  echo("\n");
		  $lwcount = 1;
		}     
      }	 	  
	}

?>
  dc.l $fffffff
  dcb.l 256*275,0
<?php
  $size = 20;
  for($i=1;$i<=8;$i++) { ?>
EF73_LINESIZE_<?php echo($i); ?>:
<?php
	//$multfactor = 1.006486;
	//$multfactor = 1.005186;
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

  function calcef73colors( $coloridx1, $coloridx2, $intnewcolor, $intall, 
                                                                   $colorret) {
			
	global $colors;	
	
	//echo "TEST: " . $intnewcolor;
	
    $colorr1 = $colors[ $coloridx1]["red"] * (1.0000 - $intnewcolor);
	$colorr2 = $colors[ $coloridx2]["red"] * $intnewcolor;
    //echo "TESTr: " .  $colors[ $coloridx2]["red"];	
	$colorret["red"] = $colorret["red"] * 0.2 
	                             + ( $colorr1 + $colorr2) * 0.8 * $intall;
				
	$colorg1 = $colors[ $coloridx1]["green"] * (1.0000 - $intnewcolor);
	//echo "TEST: " . $colorg2
	$colorg2 = $colors[ $coloridx2]["green"] * $intnewcolor;
	//echo "TESTg: " .  $colors[ $coloridx2]["green"]	;
	$colorret["green"] = $colorret["green"] * 0.2 
	                             + ( $colorg1 + $colorg2) * 0.8 * $intall;
	
	$colorb1 = $colors[ $coloridx1]["blue"] * (1.0000 - $intnewcolor);
	$colorb2 = $colors[ $coloridx2]["blue"] * $intnewcolor;
	
	$colorret["blue"] = $colorret["blue"] * 0.2 
	                             + ( $colorb1 + $colorb2) * 0.8 * $intall;
					
	return $colorret;
  }

  //$multfactor = 1.005186;
  $lwcount = 1;
  $sizeodd = 20;
  $sizeeven = $sizeodd;
  $layfactor = pow($multfactor,67*2);
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
		  echo("  dc.l ");
	    if($y==1)
		  echo( "0,");
	    $colorarr = array( "blue" => 0x0, "green" => 0x0, "red" => 0x0);
		for( $x=0;$x<=7;$x++)
		    if( ( $index & pow(2, $x)) != 0)  { 
		      if( ( $x & 1) == 0) {
			    $colorarr = calcef73colors( 10-floor( $x/2), 13-$x, $i/67, 
			                   $sizeodd * pow( $layfactor, floor( $x/2))/640 , $colorarr);														 
			  } else {
				$colorarr = calcef73colors( 10-floor( $x/2), 13-$x, $i/67, 
					             $sizeeven*pow( $layfactor, floor( $x/2))/640, $colorarr);
			  }
		    } 
		$colorr = floor( $colorarr["red"]);
		$colorg = floor( $colorarr["green"]);
		$colorb = floor( $colorarr["blue"]);
		$color = ($colorr << 16) + ($colorg << 8) + $colorb;
		//echo $color;
		$colorlw = ( ( $colorr & 0b1111) << 8)
		                   + ( ( $colorg & 0b1111) << 4) + ( $colorb & 0b1111);
		$colorhw = ( ( $colorr >> 4) << 8)
		                   + ( ( $colorg >> 4) << 4) + ( $colorb >> 4);

		//echo($colorhw . "," . $colorlw);
		echo("$" . dechex($color));
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
  //$multfactor = 1.006486;
  //$multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 20;
						
  for($i=1;$i<=14;$i++) {
    $sizeuse = $size;	
?>
EF74_COLORS<?php echo( $i); ?>:
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.l ");
	    if($y==1)
		  echo( "0,");
	    
		$colorr = 0;
		$colorg = 0;
		$colorb = 0;
		
		for( $x=0;$x<=7;$x++) {		  
		  if( ( $index & pow(2, $x)) != 0)  {
			
            $colorr = $colorr * 0.2 + $colors[13-$x]["red"] * pow($layfactor, $x) 
															    / (11.3137*2) * 0.8;
		    $colorg = $colorg * 0.2 + $colors[13-$x]["green"]  * pow($layfactor, $x) 
		                                                        / (11.3137*2) * 0.8;
		    $colorb = $colorb * 0.2 + $colors[13-$x]["blue"]  * pow($layfactor, $x) 
		                                                        / (11.3137*2) * 0.8;
		  }
		}		
		
		//165.6
        //e76100  ff6b00
	    $colorr = floor( $colorr);
		$colorg = floor( $colorg);
		$colorb = floor( $colorb);
		$color = ($colorr << 16) + ($colorg << 8) + $colorb;	
		$colorlw = ( ( $colorr & 0b1111) << 8)
		                   + ( ( $colorg & 0b1111) << 4) + ( $colorb & 0b1111);
		$colorhw = ( ( $colorr >> 4) << 8)
		                   + ( ( $colorg >> 4) << 4) + ( $colorb >> 4);
						   
		echo("$" . dechex($color));
		//
		//echo($colorhw . "," . $colorlw);
		if($lwcount < 10 && $z < pow( 2,$y-1)) {
		  $lwcount++;
		  echo(",");
		} else {
		  echo("\n");
		  $lwcount = 1;
		}     
      }	 	  
	}


	$tmp = array_shift($colors);
	array_push($colors, $tmp);
  }
?>
  dc.l $fffffff

<?php
  $size = 20;
  for($x=0;$x<8;$x++) { ?>
EF74_LINESIZE_<?php echo($x); ?>:
<?php
    //$multfactor = 1.006486;
	//$multfactor = 1.005186;
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
