
SET folderpath=C:\Users\uersu\Documents\GitData\Cbmadness\WINTEL\
SET usbpath=D:\Transfer\
php %folderpath%FrameData5.php >%folderpath%FrameData5.i
php %folderpath%graphics.php >%folderpath%graphics.i
php %folderpath%FrameData.php >%folderpath%FrameData.i
php %folderpath%FrameData_Color.php >%folderpath%FrameData_Color.i
php %folderpath%FrameData2_Color.php >%folderpath%FrameData2_Color.i
php %folderpath%FrameData3_Color.php >%folderpath%FrameData3_Color.i
php %folderpath%FrameData6.php >%folderpath%FrameData6.i
vasmm68k_mot_win32 -m68020 -nocase -Fhunkexe -o %folderpath%test -nosym %folderpath%main103.s
Shrinkler %folderpath%test %folderpath%cbmadness
del %usbpath%CBMadness.adf
CopyToAdf CBMadness %usbpath%CBMadness.adf -new 
CopyToAdf %folderpath%CBMadness %usbpath%CBMadness.adf
