FDOPOSX2 equ 4
FDOPOSY2 equ 94
FDOPOSXDET2 equ 184
FDOPOSYDET2 equ 274
FDOBLSIZE2 equ 364
FRMSIZE2 equ 454

<?php

  $frames = 45;
  $multfactor = 1.010300;
    
  function calcsize( $sizebase, $layer, $frame) {
	
	global $frames, $multfactor;
	
    if( $layer % 2 == 0) {
	  $zoommultiplier = $frame;
	} else {
	  $zoommultiplier = $frames - $frame;
	}
	
	return floor( $sizebase * pow($multfactor, $zoommultiplier));
  }
  
  function calcposx(  $size) {
	return floor( ( 160 - floor( $size/ 2)) / $size + 0.999);
  }

  function calcposy(  $size) {
	return floor( ( 128 - floor( $size / 2)) / $size + 0.999);
  }
  
  $posxcnt = 32;
  $posycnt = 31;
  $layfactor = pow($multfactor,$frames);
  $size = 10;
  
  for($i=0;$i<8;$i++) {
?>

EF2_PATTERNDATA<?php echo($i); ?>: 
<?php
if($i % 2 == 0) {
	echo("  dc.l PTR_CHECKERBOARD_DATA");
} else {
	echo("  dc.l PTR_CHECKERBOARDINV_DATA");
}
?>	
EF2_POSX<?php echo($i); ?>: <?php
   
    $lwcount = 0;
	
    for($i2=0;$i2<$frames;$i2++) {
	  $sizeuse = calcsize( $size, $i, $i2);
	  $posx = calcposx( $sizeuse);
	  if($lwcount == 0) 
	    echo("\n  dc.w ");
	  else
		echo(",");
	
	  echo( $posxcnt - $posx);
	  if(++$lwcount == 10) 
	    $lwcount = 0;
    }
?>

EF2_POSY<?php echo($i); ?>: <?php
   
    $lwcount = 0;
	
    for($i2=0;$i2<$frames;$i2++) {
	  $sizeuse = calcsize( $size, $i, $i2);
	  $posy = calcposy( $sizeuse);
	  if($lwcount == 0) 
	    echo("\n  dc.w ");
	  else
		echo(",");
	
	  echo( floor( $posycnt - $posy));
	  $sizeuse *= $multfactor;
	  if(++$lwcount == 10) 
	    $lwcount = 0;
    }
?>

EF2_POSXDET<?php echo($i); ?>: <?php
   
    $lwcount = 0;
    for($i2=0;$i2<$frames;$i2++) {
	  $sizeuse = calcsize( $size, $i, $i2);
      $posx = calcposx( $sizeuse);
	  $posxdet = $sizeuse - 
	      ( 160 - ($posx - 1) * $sizeuse - floor( $sizeuse / 2));
	  if($lwcount == 0) 
	    echo("\n  dc.w ");
	  else
		echo(",");
	
	  echo( floor( $posxdet));
	  if(++$lwcount == 10) 
	    $lwcount = 0;
    }
?>

EF2_POSYDET<?php echo($i); ?>: <?php
   
    $lwcount = 0;
    for($i2=0;$i2<$frames;$i2++) {
	  $sizeuse = calcsize( $size, $i, $i2);
      $posy = calcposy( $sizeuse);
	  $posydet = $sizeuse - 
	      ( 128 - ($posy - 1) * $sizeuse - floor( $sizeuse / 2));
	  if($lwcount == 0) 
	    echo("\n  dc.w ");
	  else
		echo(",");
	
	  echo( floor( $posydet));
	  if(++$lwcount == 10) 
	    $lwcount = 0;
    }
?>

EF2_SIZE<?php echo($i); ?>: <?php
    $lwcount = 0;
    for($i2=0;$i2<$frames;$i2++) {
	  if($lwcount == 0) 
	    echo("\n  dc.w ");
	  else
		echo(",");
	  $sizeuse = calcsize( $size, $i, $i2);
	  echo( floor( $sizeuse));
	  if(++$lwcount == 10) 
	    $lwcount = 0;
    }

	$size *= $layfactor;
  }
?>