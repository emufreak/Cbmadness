<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 20;
  $colors = array( array( "blue" => 0x31, "green" => 0xc3, "red" => 0xff),
		               array( "blue" => 0x23, "green" => 0x9b, "red" => 0xff),
					    array( "blue" => 0x1b, "green" => 0x76, "red" => 0xff),
						 array( "blue" => 0x16, "green" => 0x37, "red" => 0xff),
						 array( "blue" => 0x5d, "green" => 0x14, "red" => 0xfc),
						 array( "blue" => 0x97, "green" => 0x0e, "red" => 0xce),
						 array( "blue" => 0xb4, "green" => 0x15, "red" => 0xb0),
						 array( "blue" => 0xd4, "green" => 0x32, "red" => 0xa8),
						 array( "blue" => 0xd9, "green" => 0x34, "red" => 0x8f),
						 array( "blue" => 0xd5, "green" => 0x2c, "red" => 0x71),
						 array( "blue" => 0xd9, "green" => 0x34, "red" => 0x8f),
						 array( "blue" => 0xd4, "green" => 0x32, "red" => 0xa8),
                         array( "blue" => 0xb4, "green" => 0x15, "red" => 0xb0),
                         array( "blue" => 0x97, "green" => 0x0e, "red" => 0xce),
                         array( "blue" => 0x5d, "green" => 0x14, "red" => 0xfc),
                        array( "blue" => 0x16, "green" => 0x37, "red" => 0xff));
  for($i=1;$i<=16;$i++) {
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