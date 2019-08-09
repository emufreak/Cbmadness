<?php
  $multfactor = 1.006486;
  $multfactor = 1.005186;
  $layfactor = pow($multfactor,67);
  $lwcount = 1;
  $size = 20;
  //for($i=1;$i<=67;$i++) {
 //   $sizeuse = $size;
?>
EF1_COLORS<?php echo( $i); ?>:
<?php    
    $index = 0;
    for($y=1;$y<=8;$y++) {
      for($z=1;$z<=pow( 2,$y-1);$z++) {
        $index++;		
	    if($lwcount == 1) 
		  echo("  dc.w ");
	    if($y==1)
		  echo( "0,0,");
	    
		$colorr = 0;
		$colorg = 0;
		$colorb = 0;
		if( ($index & 1) != 0)  {
          $colorr = $colorr * 0.2 + 0x2a * pow($layfactor, 0) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x53 * pow($layfactor, 0) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0xff * pow($layfactor, 0) / 320 * 0.8;
		}
		if( ($index & 2) != 0) {
		  $colorr = $colorr * 0.2 + 0xff * pow($layfactor, 1) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x6b * pow($layfactor, 1) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0x00 * pow($layfactor, 1) / 320 * 0.8;
        }		  
        if( ($index & 4) != 0) {
          $colorr = $colorr * 0.2 + 0x2a* pow($layfactor, 2) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x53 * pow($layfactor, 2) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0xff * pow($layfactor, 2) / 320 * 0.8;
		}
	    if( ($index & 8) != 0) {
          $colorr = $colorr * 0.2 + 0xff* pow($layfactor, 3) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x6b * pow($layfactor, 3) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0x00 * pow($layfactor, 3) / 320 * 0.8;
		}
        if( ($index & 16) != 0) {
          $colorr = $colorr * 0.2 + 0x2a * pow($layfactor, 4) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x53 * pow($layfactor, 4) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0xff * pow($layfactor, 4) / 320 * 0.8;
		}
	    if( ($index & 32) != 0) {
          $colorr = $colorr * 0.2 + 0xff * pow($layfactor, 5) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x6b * pow($layfactor, 5) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0x00 * pow($layfactor, 5) / 320 * 0.8;
		}
        if( ($index & 64) != 0) {
          $colorr = $colorr * 0.2 + 0x2a * pow($layfactor, 6) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x53 * pow($layfactor, 6) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0xff * pow($layfactor, 6) / 320 * 0.8;
		}
	    if( ($index & 128) != 0) {
          $colorr = $colorr * 0.2 + 0xff * pow($layfactor, 7) / 320 * 0.8;
		  $colorg = $colorg * 0.2 + 0x6b * pow($layfactor, 7) / 320 * 0.8;
		  $colorb = $colorb * 0.2 + 0x00 * pow($layfactor, 7) / 320 * 0.8;
		}
		//2141c6  2a53ff
        //e76100  ff6b00
	    //$colorr = floor( $colorr * $size);
		//$colorg = floor( $colorg * $size);
		//$colorb = floor( $colorb * $size);
		
		//$colorlw = ($colorr & 0b1111) * 256 + ($colorg & 0b1111) * 16 +  ($colorb & 0b1111);
		//$colorhw = ($colorr >> 4) * 256 + ($colorg >> 4) * 16 +  ($colorb >> 4);
	    //$colorhw = $colorhw + ($colorhw << 4) + ($colorhw << 8);
	    //$colorlw = $colorlw + ($colorlw << 4) + ($colorlw << 8);
		echo($colorr . "," . $colorg . "," . $colorb . ",");
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
  //}
?>
  dc.l $fffffff