REM Emerald_ETOC.bat
REM Victoria Morris 2024-10-29
REM 
REM Batch file to process data from Emerald for ETOC
REM 
@ECHO OFF
SETLOCAL enableextensions enabledelayedexpansion
ECHO.
ECHO ========================================
ECHO    Emerald data processing for ETOC
ECHO ========================================
ECHO.
SET copycmd=/Y
REM ================================================================================
IF NOT EXIST Output MKDIR /S /Q Output 2>nul
:CheckForNewInput
FOR %%a IN (Input\*.zip) DO SET /a countzip+=1
IF !countzip!==0 GOTO NoInput
ECHO !countzip! zip archives
CD Input
ECHO Unzipping archives ...
FOR %%a IN (*.zip) DO (
	..\Scripts\7z.exe e -y "%%a" 1>nul
)
FOR %%a IN (*.xml) DO SET /a countxml+=1
IF !countxml!==0 GOTO NoInput
ECHO !countxml! XML files
ECHO Removing DOCTYPE declaration ...
	FOR %%a IN (*.xml) DO (
	sed -i -r "s/..DOCTYPE[^<>]*?>//g" "%%a"
)
ECHO Transforming to ETOC format ...
FOR %%a IN (*.xml) DO (
	java -jar ..\Scripts\saxon.jar -xsl:..\Scripts\nlm2etoc_v0-1.xsl -s:"%%a" -o:..\Output\%%~na.txt
)
CD ..
ECHO Merging output files
CD Output
CAT *.txt >> "..\Emerald_ETOC_%date:/=-%.txt"
CD ..
GOTO ENDLOCAL
REM ================================================================================
:NoInput
ECHO ERROR: No input files were found
ECHO Transformation cancelled
ECHO ----------------------------------------
GOTO ENDLOCAL
:ENDLOCAL
ENDLOCAL
:END
ECHO.
ECHO END OF TRANSFORMATION
ECHO ----------------------------------------
PAUSE
::End of batch file