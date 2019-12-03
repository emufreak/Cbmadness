
SET folderpath=C:\Users\uersu\Documents\GitData\Cbmadness\WINTEL\
SET usbpath=D:\Transfer\
Shrinkler %folderpath%test %folderpath%cbmadness
del %usbpath%CBMadness.adf
CopyToAdf CBMadness %usbpath%CBMadness.adf -new 
CopyToAdf %folderpath%CBMadness %usbpath%CBMadness.adf
