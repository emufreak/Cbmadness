<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 20;
  $colors = array( array( "blue" => 0x2a, "green" => 0x53, "red" => 0xff),
		               array( "blue" => 0xff, "green" => 0x6b, "red" => 0x00));
  for($i=1;$i<=2;$i++) {
    $sizeuse = $size;
	
?>

EF3_COLORS<?php echo( $i); ?>:
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
		
		$coloridx = 0;
		for( $x=0;$x<=7;$x++) {		  
		  if( ( $index & pow(2, $x)) != 0)  {
            $colorr = $colorr * 0.2 + $colors[$coloridx]["red"] * pow($layfactor, $x) 
															    / 11.313 * 0.8;
		    $colorg = $colorg * 0.2 + $colors[$coloridx]["green"]  * pow($layfactor, $x) 
		                                                        / 11.313 * 0.8;
		    $colorb = $colorb * 0.2 + $colors[$coloridx]["blue"]  * pow($layfactor, $x) 
		                                                        / 11.313 * 0.8;
		  }
		  $coloridx = abs($coloridx -1);
		}
		
		
		
		//165.6
        //e76100  ff6b00
	    $colorr = floor( $colorr);
		$colorg = floor( $colorg);
		$colorb = floor( $colorb);
		$color = ($colorr << 16) + ($colorg << 8) + $colorb;
		
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
    $size *= $multfactor;
	$colors = array_reverse( $colors);
  }
?>
  dc.l $fffffff