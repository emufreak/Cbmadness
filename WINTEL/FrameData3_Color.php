<?php
 
  $colstart = array( "blue" => 0x00, "green" => 0x6b, "red" => 0xff);
  //$colend =  array( "blue" => 0xff, "green" => 0x53, "red" => 0x2a);
  $colend = $colstart;
 for($i=0;$i<2;$i++) {
	$numcolors = 4; 
	$col = $colstart;
    for($i2=0;$i2<$numcolors;$i2++) {
      $colors[$i2+$i*$numcolors] = $col;
	  $col["blue"] = floor( $colstart["blue"]*($numcolors-$i2-1)/$numcolors 
										 + $colend["blue"]*($i2+1)/$numcolors);
	  $col["green"] = floor( $colstart["green"]*($numcolors-$i2-1)/$numcolors 
										+ $colend["green"]*($i2+1)/$numcolors);
	  $col["red"] = floor( $colstart["red"]*($numcolors-$i2-1)/$numcolors 
	               + $colend["red"]*($i2+1)/$numcolors);

    }
	$tmp = $colend;
	$colend = $colstart;
	$colstart = $tmp;	
  }
  
  $colors2 = array_reverse($colors);
  
  for($i=1;$i<=14;$i++) {
    $sizeuse = $size;
	
?>

EF3_COLORS<?php echo( $i); ?>:
<?php  
    $multfactor = 1.01278;
    $layfactor = pow($multfactor,39);
    $lwcount = 1;
    $size = 20;  
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
		
		if( (( $index & 128) != 0 && $i <= 7) ||
        	(($index & 128) == 0 && $i >= 8)) {	
          $colorr = 255;
		  $colorg = 255;
		  $colorb = 255;		
		  for( $x=0;$x<=6;$x++)
		    if( ( $index & pow(2, $x)) != 0)  { 
              $colorr = $colorr * 0.2 + ( ~$colors[6-$x]["red"] & 0xff) * pow($layfactor, $x)
				/ 19.52 * 0.8 + ( 1 - floor( pow( $layfactor, $x) * 100) / 100 / 19.52)*0xff*0.8;
		      $colorg = $colorg * 0.2 + ( ~$colors[6-$x]["green"] & 0xff) * pow($layfactor, $x) 
			   / 19.52 * 0.8 +( 1 - floor( pow($layfactor, $x) * 100) / 100 / 19.52)*0xff*0.8;
		      $colorb = $colorb * 0.2 +  ( ~$colors[6-$x]["blue"] & 0xff) * pow($layfactor, $x) 
			   / 19.52 * 0.8 + ( 1 - floor( pow( $layfactor, $x) * 100) / 100 / 19.52)*0xff*0.8;
		    }
        } 
		else {
		  for( $x=0;$x<=6;$x++) 		  
		    if( ( $index & pow(2, $x)) != 0)  {            
              $colorr = $colorr * 0.2 + $colors[6-$x]["red"] * pow($layfactor, $x) 
															    / 19.52 * 0.8 ;
		      $colorg = $colorg * 0.2 + $colors[6-$x]["green"] * pow($layfactor, $x) 
															    / 19.52 * 0.8;
		      $colorb = $colorb * 0.2 + $colors[6-$x]["blue"] * pow($layfactor, $x) 
															   / 19.52 * 0.8;
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
	$tmp = array_pop($colors2);
	array_unshift($colors2, $tmp);
	$tmp = array_pop($colors);
	array_unshift($colors, $tmp);
	
  }
?>
  dc.l $ffffffff