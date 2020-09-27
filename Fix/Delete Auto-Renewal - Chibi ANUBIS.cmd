@ECHO OFF
TITLE Delete Auto-Renewal - Chibi ANUBIS
COLOR F0
MODE CON: COLS=70 LINES=20
::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
CLS
pushd "%~dp0"

:SARIA
ECHO.
set /p answer=Do you want delete the Auto-Renewal ? (Y/N)
if /i "%answer:~,1%" EQU "Y" goto AutoRenewal
if /i "%answer:~,1%" EQU "N" exit
echo Please type Y for Yes or N for No
goto SARIA

:AutoRenewal
ECHO.
ECHO Wait...
SET OutPutXML=%ProgramData%\IDM\AutoRenewal
if exist "%OutPutXML%" rd /S "%OutPutXML%" /Q & ECHO AutoRenewal folder deleted.

schtasks /query /TN "Check IDM Activation" >NUL 2>&1
if "%ERRORLEVEL%"=="0" schtasks /delete /f /tn "\Check IDM Activation" >NUL 2>&1 && ECHO Scheduled task removed.

SET ARCH64=%programfiles(x86)%\Internet Download Manager
SET ARCH86=%programfiles%\Internet Download Manager
if exist "%ARCH64%" SET IDMDirectory=%ARCH64%& goto StartupIDM
if exist "%ARCH86%" SET IDMDirectory=%ARCH86%& goto StartupIDM
goto NoIDMFolder

:StartupIDM
ECHO Internet Download Manager startup : Enable & REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run /v IDMan /t REG_BINARY /d 02 /f > nul

cls
echo =================================
echo =      Auto-Renewal Deleted     =
echo =                               =
echo =                               =
echo =     IDM startup was been      =
echo =       added by default        =
echo =================================
echo Press any key to exit.
pause>nul
exit

:NoIDMFolder
cls
echo =================================
echo =      Auto-Renewal Deleted     =
echo =                               =
echo =                               =
echo =    IDM folder was not found   =
echo =   Maybe was been uninstalled  =
echo =================================
echo Press any key to exit.
pause>nul
exit
