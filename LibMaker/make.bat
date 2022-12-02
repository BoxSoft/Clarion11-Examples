@if '%3'=='' echo off

rem format
rem make [all|debug|release] [clean|version]
rem doing 'make' is the same as 'make debug'
rem all does a debug build and then a release build
rem clean will remove all generated files but not do a build
rem version will bump the version number before doing a build

if '%2'=='' (set bType=none) else set bType=%2
if '%1'=='release' (set clwBuildType=release) else set clwBuildType=debug

pushd ..\..\..

:build

echo Making %clwBuildType% LibMaker

call ..\..\setver
call delfile1 libmaker.exe

if '%2'=='clean' goto good

clamake /qy /s%clwBuildType% libmaker > "%c7Dir%\logs\LibMaker.log

del *.$$$ 2> nul

set badfile=
call isthere1 LibMaker.exe

if '%badfile%'=='' goto good
echo look in logs\LibMaker.log for errors
popd
exit /b 1

:good

if '%1'=='all' (
 if '%clwBuildType%'=='debug' (
 set clwBuildType=release
 goto build
)
)

popd
exit /b 0
