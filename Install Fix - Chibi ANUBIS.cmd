@ECHO off
TITLE IDM Activator v2.5 - Chibi ANUBIS
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
SET ActivatorName=comctl32.dll
SET ARCH64=%programfiles(x86)%\Internet Download Manager
SET ARCH86=%programfiles%\Internet Download Manager
if exist "%ARCH64%" SET IDMDirectory=%ARCH64%& goto QuestionFix
if exist "%ARCH86%" SET IDMDirectory=%ARCH86%& goto QuestionFix
goto CheckInstallError

:QuestionFix
:loop
ECHO.
set /p answer=Do you want use [M]anual or [A]uto Update ?
if /i "%answer:~,1%" EQU "M" SET FixDirectory=Fix\IDM_Activator_NoUpdate& goto InstallFix
if /i "%answer:~,1%" EQU "A" SET FixDirectory=Fix\IDM_Activator& goto InstallFix
echo Please type M for Manual or A for Auto
goto loop

:InstallFix
ECHO.
ECHO Wait...
if not exist "%FixDirectory%\%ActivatorName%" goto CheckActivatorError
tasklist /FI "IMAGENAME eq IDMan.exe" 2>NUL | find /I /N "IDMan.exe">NUL
if "%ERRORLEVEL%"=="0" ECHO Internet Download Manager : Shutdown & TASKKILL /f /im IDMan.exe > nul
if exist "%IDMDirectory%\IDMan.exe.Local" rd /S "%IDMDirectory%\IDMan.exe.Local" /Q
SET Target=%WinDir%\WinSxS\x86_microsoft.windows.common-controls_*
FOR /D %%G IN ("%Target%") do set CurrDirName=%%~nxG
xcopy "%FixDirectory%\%ActivatorName%" "%IDMDirectory%\IDMan.exe.Local\%CurrDirName%\" /v /y > nul
if exist "%IDMDirectory%\IDMan.exe.Local\%CurrDirName%\%ActivatorName%" echo Fix copied.
if not exist "%IDMDirectory%\IDMan.exe.Local\%CurrDirName%\%ActivatorName%" echo Fix not found.
attrib +r "%IDMDirectory%\IDMan.exe.Local"
attrib +r "%IDMDirectory%\IDMan.exe.Local\*.*" /d /s

cls
echo =================================
echo =  ActVer v1.8 - Chibi ANUBIS   =
echo =            ALL OK             =
echo =                               =
echo =      IDM was activated        =
echo =         successfully          =
echo =================================
ECHO.
ECHO Internet Download Manager : Restart
ECHO Wait...
schtasks /create /f /tn "\StartIDM" /sc HOURLY /ru "%USERNAME%" /tr "\"%IDMDirectory%\IDMan.exe\"/onboot" > nul
schtasks /run /i /tn "\StartIDM" > nul
timeout /t 2 > nul
schtasks /delete /f /tn "\StartIDM" > nul

:SARIA
ECHO.
set /p answer=Do you want create a Auto-Renewal Activation in login ? (Y/N)
if /i "%answer:~,1%" EQU "Y" goto AutoRenewal
if /i "%answer:~,1%" EQU "N" exit
echo Please type Y for Yes or N for No
goto SARIA

:CheckInstallError
cls
echo =================================
echo =      Detection ERROR of       =
echo =   Internet Download Manager   =
echo =                               =
echo =   The directory is not here   =
echo =       Install IDM first       =
echo =================================
echo Press any key to exit.
pause>nul
exit

:CheckActivatorError
cls
echo =================================
echo =      Detection ERROR of       =
echo =       %ActivatorName%         =
echo =                               =
echo =   Check if you have the Fix   =
echo =       folder or your AV       =
echo =================================
echo Press any key to exit.
pause>nul
exit

:AutoRenewal
ECHO.
ECHO Wait...
SET OutPutXML=%ProgramData%\IDM\AutoRenewal
if not exist "%OutPutXML%" mkdir "%OutPutXML%"
for /f %%i in ('wmic useraccount where name^="%username%" get sid ^| findstr ^S\-d*') do set SID=%%i
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2%T%ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo ^<?xml version="1.0" encoding="UTF-16"?^> > "%OutPutXML%\IDM_Auto-Renewal.xml"
echo ^<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^<RegistrationInfo^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Date^>%ldt%^</Date^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Author^>Chibi ANUBIS^</Author^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Description^>Check if Internet Download Manager was always Lifetime Activated after a Windows Update.^</Description^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<URI^>\IDM_Auto-Renewal^</URI^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^</RegistrationInfo^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^<Triggers^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<LogonTrigger^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<Enabled^>true^</Enabled^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<UserId^>%USERDOMAIN%\%USERNAME%^</UserId^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^</LogonTrigger^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^</Triggers^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^<Principals^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Principal id="Author"^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<UserId^>%SID%^</UserId^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<LogonType^>InteractiveToken^</LogonType^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<RunLevel^>HighestAvailable^</RunLevel^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^</Principal^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^</Principals^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^<Settings^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<StopIfGoingOnBatteries^>true^</StopIfGoingOnBatteries^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<StartWhenAvailable^>false^</StartWhenAvailable^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<RunOnlyIfNetworkAvailable^>false^</RunOnlyIfNetworkAvailable^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<IdleSettings^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<StopOnIdleEnd^>true^</StopOnIdleEnd^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<RestartOnIdle^>false^</RestartOnIdle^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^</IdleSettings^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Enabled^>true^</Enabled^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Hidden^>false^</Hidden^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<RunOnlyIfIdle^>false^</RunOnlyIfIdle^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<DisallowStartOnRemoteAppSession^>false^</DisallowStartOnRemoteAppSession^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<UseUnifiedSchedulingEngine^>true^</UseUnifiedSchedulingEngine^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<WakeToRun^>false^</WakeToRun^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<ExecutionTimeLimit^>PT72H^</ExecutionTimeLimit^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Priority^>7^</Priority^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^</Settings^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^<Actions Context="Author"^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^<Exec^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<Command^>cmd.exe^</Command^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo       ^<Arguments^>/c start /min "Elevated command prompt" "%OutPutXML%\ActivateIDM.cmd"^</Arguments^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo     ^</Exec^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo   ^</Actions^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"
echo ^</Task^> >> "%OutPutXML%\IDM_Auto-Renewal.xml"

schtasks /query /TN "Check IDM Activation" >NUL 2>&1
if "%ERRORLEVEL%"=="0" schtasks /delete /f /tn "\Check IDM Activation" >NUL 2>&1
if "%ERRORLEVEL%"=="1" if exist "%OutPutXML%\IDM_Auto-Renewal.xml" schtasks.exe /Create /XML "%OutPutXML%\IDM_Auto-Renewal.xml" /tn "Check IDM Activation" >NUL 2>&1

schtasks /query /TN "Check IDM Activation" >NUL 2>&1
if "%ERRORLEVEL%"=="1" if exist "%OutPutXML%\IDM_Auto-Renewal.xml" schtasks.exe /Create /XML "%OutPutXML%\IDM_Auto-Renewal.xml" /tn "Check IDM Activation" >NUL 2>&1

schtasks /query /TN "Check IDM Activation" >NUL 2>&1
if "%ERRORLEVEL%"=="0" ECHO AutoRenewal scheduled task created
if "%ERRORLEVEL%"=="1" ECHO AutoRenewal scheduled task ERROR

xcopy "%FixDirectory%\%ActivatorName%" "%OutPutXML%\" /v /y > nul
if exist "%OutPutXML%\%ActivatorName%" echo Fix copied in AutoRenewal folder.
if not exist "%OutPutXML%\%ActivatorName%" echo Fix not found in AutoRenewal folder.
ECHO Internet Download Manager startup : Disable & REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run /v IDMan /t REG_BINARY /d 03 /f > nul

call :export IDMACTIVATION > "%OutPutXML%\ActivateIDM.cmd"

cls
echo =================================
echo =      Auto-Renewal Created     =
echo =          Successfully         =
echo =                               =
echo =   Internet Download Manager   =
echo =     can be auto-activated     =
echo =================================
echo Press any key to exit.
pause>nul
exit

:IDMACTIVATION:[
@ECHO OFF
TITLE IDM Activator v2.5 - Chibi ANUBIS
COLOR F0
MODE CON: COLS=70 LINES=20

CLS
pushd "%~dp0"
SET ActivatorName=comctl32.dll
SET ARCH64=%programfiles(x86)%\Internet Download Manager
SET ARCH86=%programfiles%\Internet Download Manager
if exist "%ARCH64%" SET IDMDirectory=%ARCH64%& goto CheckAfterUpdate
if exist "%ARCH86%" SET IDMDirectory=%ARCH86%& goto CheckAfterUpdate
exit

:CheckAfterUpdate
ECHO.
ECHO Wait...
SET Target=%WinDir%\WinSxS\x86_microsoft.windows.common-controls_*
SET Spoted=%IDMDirectory%\IDMan.exe.Local\x86_microsoft.windows.common-controls_*
FOR /D %%G IN ("%Target%") do set CurrTargetName=%%~nxG
FOR /D %%G IN ("%Spoted%") do set CurrSpotedName=%%~nxG
if not "%CurrTargetName%"=="%CurrSpotedName%" goto InstallFix
goto RunIDM

:InstallFix
if not exist "%ActivatorName%" exit
if exist "%IDMDirectory%\IDMan.exe.Local" rd /S "%IDMDirectory%\IDMan.exe.Local" /Q
xcopy "%ActivatorName%" "%IDMDirectory%\IDMan.exe.Local\%CurrTargetName%\" /v /y > nul
if exist "%IDMDirectory%\IDMan.exe.Local\%CurrTargetName%\%ActivatorName%" echo Fix copied.
if not exist "%IDMDirectory%\IDMan.exe.Local\%CurrTargetName%\%ActivatorName%" echo Fix not found.
attrib +r "%IDMDirectory%\IDMan.exe.Local"
attrib +r "%IDMDirectory%\IDMan.exe.Local\*.*" /d /s

:RunIDM
cls
echo =================================
echo =  ActVer v1.8 - Chibi ANUBIS   =
echo =            ALL OK             =
echo =                               =
echo =      IDM was activated        =
echo =         successfully          =
echo =================================
ECHO.
ECHO Internet Download Manager : Running
ECHO Wait...
schtasks /create /f /tn "\StartIDM" /sc HOURLY /ru "%USERNAME%" /tr "\"%IDMDirectory%\IDMan.exe\"/onboot" > nul
schtasks /run /i /tn "\StartIDM" > nul
timeout /t 2 > nul
schtasks /delete /f /tn "\StartIDM" > nul
exit
:IDMACTIVATION:]

:export usage: call :export NAME
setlocal enabledelayedexpansion || Prints all text between lines starting with :NAME:[ and :NAME:] - A pure batch snippet by AveYo
set [=&for /f "delims=:" %%s in ('findstr/nbrc:":%~1:\[" /c:":%~1:\]" "%~f0"') do if defined [ (set/a ]=%%s-3) else set/a [=%%s-1
<"%~fs0" ((for /l %%i in (0 1 %[%) do set /p =)&for /l %%i in (%[% 1 %]%) do (set txt=&set /p txt=&echo(!txt!)) &endlocal &exit/b


