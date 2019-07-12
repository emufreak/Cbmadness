
SET folderpath=C:\Users\uersu\Documents\GitData\Cbmadness\WINTEL\
SET usbpath=E:\Transfer\
php %folderpath%FrameData4.php >%folderpath%FrameData4.i
php %folderpath%graphics.php >%folderpath%graphics.i
vasmm68k_mot_win32 -nocase -Fhunkexe -o %folderpath%test -nosym %folderpath%main103.s
Shrinkler %folderpath%test %folderpath%cbmadness
del %usbpath%CBMadness.adf
CopyToAdf CBMadness %usbpath%CBMadness.adf -new
CopyToAdf %folderpath%CBMadness %usbpath%CBMadness.adf
