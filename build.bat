@echo off

mkdir build

set ODINFLAGS=-debug

REM odin build src -out:build/raytracer.exe %ODINFLAGS% && build\raytracer.exe
REM odin build src/putting_it_together_CH01 -out:build/putting_it_together_CH01.exe %ODINFLAGS%

REM odin test tests
odin build tests --out:build/tests.exe %ODINFLAGS% && build\tests.exe
