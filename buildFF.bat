set COMPILEDIR=%CD%

del mod.ff

xcopy shock ..\..\raw\shock /SY
xcopy images ..\..\raw\images /SY
xcopy materials ..\..\raw\materials /SY
xcopy material_properties ..\..\raw\material_properties /SY
xcopy sound ..\..\raw\sound /SY
xcopy soundaliases ..\..\raw\soundaliases /SY
xcopy fx ..\..\raw\fx /SY
xcopy mp ..\..\raw\mp /SY
xcopy weapons\mp ..\..\raw\weapons\mp /SY
xcopy xanim ..\..\raw\xanim /SY
xcopy xmodel ..\..\raw\xmodel /SY
xcopy xmodelparts ..\..\raw\xmodelparts /SY
xcopy xmodelsurfs ..\..\raw\xmodelsurfs /SY
xcopy ui ..\..\raw\ui /SY
xcopy ui_mp ..\..\raw\ui_mp /SY
xcopy english ..\..\raw\english /SY
xcopy vision ..\..\raw\vision /SY
xcopy animtrees ..\..\raw\animtrees /SYI > NUL
xcopy maps ..\..\raw\maps /SY
xcopy surf ..\..\raw\surf /SY
xcopy mod.csv ..\..\zone_source /SY

cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod

cd %COMPILEDIR%

copy ..\..\zone\english\mod.ff

PAUSE