@echo off

set BUILD_TYPE=Release
set BUILD_DIR=build

set CXX_PATH="d:\msys64\usr\bin\c++.exe"
set C_PATH="d:\msys64\usr\bin\gcc.exe"
set FORT_PATH="d:\msys64\usr\bin\gfortran.exe"
set MAKE_PATH="d:\msys64\usr\bin\make.exe"
set OLDPATH=%PATH%
set PATH="d:\msys64\usr\bin";%PATH%

cmake --version 1>NUL 2>NUL
if errorlevel 1 goto needcmake

if exist %BUILD_DIR% (
	rmdir /Q /S %BUILD_DIR%
)

mkdir %BUILD_DIR%
pushd %BUILD_DIR%
rem cmake -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" ..
cmake -G "Unix Makefiles" -DCMAKE_CXX_COMPILER:FILEPATH=%CXX_PATH% -DCMAKE_C_COMPILER:FILEPATH=%C_PATH% -DCMAKE_Fortran_COMPILER:FILEPATH=%FORT_PATH% -DCMAKE_MAKE_PROGRAM:FILEPATH=%MAKE_PATH% ..
popd
goto end

:needcmake
echo ------------------------------------------------
echo CMAKE is required for building this application.
echo ------------------------------------------------
:end
set PATH=%PATH%