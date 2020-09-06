call configure_forcepad.cmd Debug
call configure_forcepad.cmd Release

rem start /D"." /WAIT cmd.exe /C configure_forcepad.cmd Debug
rem start /D"." /WAIT cmd.exe /C configure_forcepad.cmd Release