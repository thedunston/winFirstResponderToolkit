@echo off
REM This script will collect volatile information from a Windows system.
REM Author: Duane Dunston, thedunston@gmail.com

:TKT
cls
set /p TKTNUM=What is the report number? (e.g. 0001):
ECHO You entered: "%TKTNUM%"
set/p CHKTKT=Is this correct? (y/n)
If /i "%CHKTKT%"=="n" goto :TKT
cls

:USR
set /p USRNAME=Enter the userID authenticated at the time of the incident (e.g. gnugro):
ECHO You entered: "%USRNAME%"
set /p USR=Is this correct? (y/n)
If /i "%USR%"=="n" goto :USR
cls

REM :ARCHI
REM set /p AR=Enter the architecture (32 or 64-bit):
REM ECHO You entered: "%AR%"
REM set /p AR=Is this correct? (y/n)
REM If /i "%AR%"=="n" goto :ARCHI
REM cls

REM Create location to save results
mkdir %TKTNUM%-%COMPUTERNAME%-Results

REM Results directory
set rstDir=%TKTNUM%-%COMPUTERNAME%-Results\%COMPUTERNAME%-

REM Variable when calling Powershell commands
set PSHELL="C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
set PEXPORT="| export-csv -Notypeinformation -Path"

echo Gathering Process List
%PSHELL% -Command "ps | select Name, ID, Path | export-csv -Notypeinformation -Path %rstDir%processListing.csv"

echo Gathering Network Ports
CALL :RUNCMD ".\t_cports /scomma", "networkSockets.csv"

echo Gathering Recently Executed Programs
CALL :RUNCMD ".\t_winprefetchview.exe /scomma", "prefetch.csv"

echo Getting Commandline Arguments
CALL :RUNCMD "wmic path WIN32_PROCESS get Caption, ProcessID,Commandline /format:csv >","output.csv"

REM MEMORY DUMP TOOL COULD GO HERE

echo Getting File Share information
CALL :RUNCMD "c:\windows\system32\net.exe sessions >", "netSessions.txt"

echo Getting Netbios Information
CALL :RUNCMD "c:\windows\system32\nbtstat.exe -S >", "nbtstatS.txt"
CALL :RUNCMD "c:\windows\system32\nbtstat.exe -c >", "nbtStatC.txt"

echo Gathering DNS Cache
%PSHELL% -Command "Get-DnsClientCache | export-csv -Notypeinformation -Path  %rstDir%dnscache.csv"

echo Gathering Network information
%PSHELL% -Command "get-WmiObject -class Win32_NetworkAdapterConfiguration | select DefaultIPGateway, IPAddress, DNSHostName, IPEnabled, DHCPServer, DNSServerSearchOrder | export-csv -Notypeinformation -Path  %rstDir%networkinfo.csv"

echo Getting ARP Cache
CALL :RUNCMD "c:\windows\system32\arp.exe -a >", "arpCache.txt"

echo Getting Registered Services
CALL :RUNCMD ".\t_serviwin.exe /scomma services", "services.csv"

echo Getting Logged on Sessions
CALL :RUNCMD ".\t_logonsessions.exe /accepteula -p >", "loggedon.txt"

echo Getting Autoruns
CALL :RUNCMD ".\t_autorunsc64.exe /accepteula -a * -c >" "autoruns.txt"

echo Getting System Information
CALL :RUNCMD ".\t_psinfo /accepteula -s -d -h >", "loggedon.txt"

echo Getting USB Device Information
CALL :RUNCMD ".\t_usbdeview.exe /scomma", "usbdevices.txt"

echo Getting executable filetype association
CALL :RUNCMD "ftype exefile >", "ftype.txt"

echo Getting Host File information
CALL :RUNCMD "type C:\windows\System32\Drivers\etc\hosts  >", "hostFiles.txt"

echo Getting Network Statistics
CALL :RUNCMD "c:\windows\system32\netstat.exe -s >", "netstat_s.txt"

echo Getting Audit policy
CALL :RUNCMD "c:\windows\system32\net.exe accounts >", "net_accounts.txt"

echo Getting User Account Information
REM CALL :RUNCMD %PSHELL%, "Get-Wmiobject -class Win32_Account", %PEXPORT%, net_accounts.csv

echo Getting Browser History Listing
CALL :RUNCMD "t_BrowsingHistoryView.exe /scomma", "browse.csv"

echo Getting Firewall Configuration
CALL :RUNCMD "netsh firewall show config >", "firewallConfig.txt"

echo ************** These may take a while to run **************

REM echo Getting Process Handle Information
REM CALL :RUNCMD ".\t_handle.exe /accepteula -a -u >", "handles.txt"

REM echo Getting DLLs for Processes
REM CALL :RUNCMD ".\t_listdlls.exe /accepteula >", "listdlls.txt"

REM FOR YOU TODO: echo Gather service details, ensure you get the full path of the executable it calls.

REM FOR YOU TODO: echo Gather open files. OpenFilesView

echo Collecting file metadata under user home directory
CALL :RUNCMD ".\t_goBodyFile.exe -body -directory C:\Users\%USERNAME% -output", "%USERNAME%-body.txt"

REM :GETBROWSER
REM FOR YOU TODO: Update xcopy to use robocopy

REM ECHO Copying IE artifacts
REM c:\windows\system32\xcopy.exe "C:\Users\%USRNAME%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*" "%TKTNUM%-%COMPUTERNAME%-Results\browsers\internet_explorer" /EHYCI

REM ECHO Copying Firefox artifacts
REM c:\windows\system32\xcopy.exe "C:\Users\%USRNAME%\AppData\Local\Mozilla\Firefox\Profiles\*.*" "%TKTNUM%-%COMPUTERNAME%-Results\browsers\firefox" /EHYCI

REM ECHO Copying Chrome artifacts
REM c:\windows\system32\xcopy.exe "C:\Users\%USRNAME%\AppData\Local\Google\Chrome\*.*" "%COMPUTERNAME%-Results\browsers\chrome" /EHYCI
REM EXIT /B 0

.\7z\7za a r %TKTNUM%-%COMPUTERNAME%-Results\

.\t_sendIR.exe -f %TKTNUM%-%COMPUTERNAME%-Results.7z

REM Collect your Anti-virus logs when you return to your organization.

echo Exiting... 
EXIT /B %ERRORLEVEL%

REM Runs the system command using powershell or cmd.exe.
:RUNCMD
if "%~1"=="powershell" ( goto :RUNPSHELL 
) else (
goto :RUNTOOL
)

:RUNTOOL
%~1 "%TKTNUM%-%COMPUTERNAME%-Results\%COMPUTERNAME%-%~2"
EXIT /B 0

:RUNPSHELL
%~1 "%~2 %~3 %TKTNUM%-%COMPUTERNAME%-Results\%COMPUTERNAME%-%~4"
EXIT /B 0
