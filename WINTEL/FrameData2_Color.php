<?php
  $multfactor = 1.009673;
  $multfactor = 1.010889;
  $multfactor = 1.010300;
    
  
  $lwcount = 1; 
  $size = 10;  
  $colors = array( array( "blue" => 0xff, "green" => 0x8a, "red" => 0xf6),
		               array( "blue" => 0x14, "green" => 0xff, "red" => 0x16));
  $direction = array( 1,-1,1,-1,1,-1,1,-1);
  $counter = 1; 
  for($i=1;$i<=90;$i++) {
    $sizeuse = $size;
	
?>

EF2_COLORS<?php echo( $i); ?>:
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
          if($direction[$x] == -1) {
			 $powerof = 45*($x+1) - $counter; 
          }	else {
			 $powerof = 45*$x + $counter;
          }
		  
		  if( ( $index & pow(2, $x)) != 0)  {
		
            $colorr = $colorr * 0.2 + $colors[$coloridx]["red"] 
			                            * pow($multfactor, $powerof)/ 32 * 0.8;
		    $colorg = $colorg * 0.2 + $colors[$coloridx]["green"]  
			                            * pow($multfactor, $powerof)/ 32 * 0.8;
		    $colorb = $colorb * 0.2 + $colors[$coloridx]["blue"]   
		                                * pow($multfactor, $powerof)/ 32 * 0.8;
		  }
		  $coloridx = abs($coloridx -1);
		}
		
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
    if($i<45) {
	  $size *= $multfactor;
	  $counter++;
	} elseif($i==45) {
        $counter = 1;
        $colors = array_reverse( $colors);
	    for($i2 = 0;$i2<4;$i2++) {
          [$direction[$i2*2],$direction[$i2*2+1]] = [$direction[$i2*2+1],$direction[$i2*2]];
		}
	} else {
      $counter++;
	  $size /= $multfactor;
    }
  }
?>
  dc.l $ffffffff