﻿
SET folderpath=C:\Users\uersu\Documents\GitData\Cbmadness\WINTEL\
php %folderpath%FrameData4.php >%folderpath%FrameData4.i
php %folderpath%FrameData5.php >%folderpath%FrameData5.i
php %folderpath%graphics.php >%folderpath%graphics.s
php %folderpath%FrameData_Color.php >%folderpath%FrameData_Color.i
vasmm68k_mot_win32 -m68020 -nocase -Fhunkexe -o %folderpath%test -nosym %folderpath%main103.s
C:\Users\uersu\Downloads\winuaedemotoolchain5v3\WinUAE\winuae64.exe -f Autostart.uae -s use_gui=no
