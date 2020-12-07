rmdir /s/q ..\PakTemp
mkdir ..\PakTemp
CScript zip.vbs . ..\PakTemp\2ePlayerOption.zip
ren ..\PakTemp\2ePlayerOption.zip 2ePlayerOption.ext
xcopy /s/y ..\PakTemp\2ePlayerOption.ext "C:\Users\drplo\SmiteWorks\Fantasy Grounds\extensions\"
pause

