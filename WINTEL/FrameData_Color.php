<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 20;
  $colors = array( array( "blue" => 0x04, "green" => 0xbe, "red" => 0xfe),
		               array( "blue" => 0x01, "green" => 0x7e, "red" => 0xfe),
					    array( "blue" => 0x01, "green" => 0x44, "red" => 0xff),
						 array( "blue" => 0x44, "green" => 0x03, "red" => 0xff),
						 array( "blue" => 0x7c, "green" => 0x01, "red" => 0xfd),
						 array( "blue" => 0xbd, "green" => 0x02, "red" => 0xff),
						 array( "blue" => 0xfe, "green" => 0x02, "red" => 0xbf),
						 array( "blue" => 0xfc, "green" => 0x02, "red" => 0x80),
						 array( "blue" => 0xfe, "green" => 0x02, "red" => 0xbf),
						 array( "blue" => 0xbd, "green" => 0x02, "red" => 0xff),
						 array( "blue" => 0x7c, "green" => 0x01, "red" => 0xfd),
						 array( "blue" => 0x44, "green" => 0x03, "red" => 0xff),
						  array( "blue" => 0x01, "green" => 0x44, "red" => 0xff),
						  array( "blue" => 0x01, "green" => 0x7e, "red" => 0xfe));
  for($i=1;$i<=8;$i++) {
    $sizeuse = $size;
	
?>
EF1_COLORS<?php echo( $i); ?>:
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
            $colorr = $colorr * 0.2 + $colors[7-$x]["red"] * pow($layfactor, $x) 
															    / 11.313 * 0.8;
		    $colorg = $colorg * 0.2 + $colors[7-$x]["green"]  * pow($layfactor, $x) 
		                                                        / 11.313 * 0.8;
		    $colorb = $colorb * 0.2 + $colors[7-$x]["blue"]  * pow($layfactor, $x) 
		                                                        / 11.313 * 0.8;
		  }
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


	$tmp = array_shift($colors);
	array_push($colors, $tmp);
  }
?>
  dc.l $fffffff