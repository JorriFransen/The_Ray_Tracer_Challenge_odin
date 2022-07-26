@echo off

mkdir build

set ODINFLAGS=-debug
set COLLECTION_FLAGS=-collection:raytracer=src -collection:tracy=tracy

set ODINFLAGS=%ODINFLAGS% %COLLECTION_FLAGS%

@echo on

odin build putting_it_together -out:build/putting_it_together.exe %odinflags% && build\putting_it_together.exe

@REM odin test tests %odinflags%

REM  odin build tests --out:build/tests.exe %ODINFLAGS% && build\tests.exe %ODINTEST_FLAGS%

@REM odin build src -out:build/raytracer.exe %ODINFLAGS% && build\raytracer.exe

