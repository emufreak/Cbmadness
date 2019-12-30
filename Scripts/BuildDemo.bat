
SET folderpath=C:\Users\uersu\Documents\GitData\Cbmadness\WINTEL\
SET usbpath=D:\Transfer\
Shrinkler -e 1600 -i 9 -l 9 -a 40 -o %folderpath%test %folderpath%cbmadness 
del %usbpath%CBMadness.adf
CopyToAdf CBMadness %usbpath%CBMadness.adf -new 
CopyToAdf %folderpath%CBMadness %usbpath%CBMadness.adf
