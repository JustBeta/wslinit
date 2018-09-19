@echo off
:: Start daemon Windows Subsystem Linux (WSL)
setlocal EnableDelayedExpansion
::caractere europeen
chcp 28591 > nul
::caratere internnational
::chcp 65001 > nul 
::set path=%path%;%~dp0
set init=3
set func=init
 
::set char=10
::cmd /c exit !char!
::set cr=!=exitcodeAscii!

echo Start daemon Windows Subsystem Linux (WSL).

if '%1' == '' goto main
if '%1' == '-h' goto help
if '%1' == '--help' goto help
if '%1' == '-s' set func=status
if '%1' == '--status' set func=status
if '%2' == '-s' set func=status
if '%2' == '--status' set func=status

if '%1' NEQ '' (

  if %1 GEQ 0 (
     if %1 LEQ 5 (
       set init=%1
     )
  )
rem  if '%1' EQU '0' (set init=%1)
)

:main
  echo init %init%

  ::echo init %1
  set rc=etc\rc%init%.d

  set sw=HKEY_CURRENT_USER
  set u=Software\Microsoft\Windows\CurrentVersion\Lxss

  ::echo "%sw%\%u% %k%"
  FOR /F "skip=2 tokens=2,*" %%A IN ('REG.exe query "%sw%\%x%%u%" /v "DefaultDistribution"') DO set "DefaultDistribution=%%B"
  ::echo "%sw%\%u%\%DefaultDistribution%"

  FOR /F "skip=2 tokens=2,*" %%A IN ('REG.exe query "%sw%\%u%\%DefaultDistribution%" /v "BasePath"') DO set "BasePath=%%B"
  ::echo %BasePath%\rootfs\%rc%

  type %BasePath%\rootfs\etc\sudoers | find "%sudo ALL=NOPASSWD:/usr/sbin/service" > nul
  if %errorlevel% EQU 1 (
    echo add sudo service
    echo ajouter '%%sudo ALL=NOPASSWD:/usr/sbin/service' dans le fichier sudoers de votre distribution (sans les quotes^)
    rem echo %cr%%%sudo ALL=NOPASSWD:/usr/sbin/service%cr% >> %BasePath%\rootfs\etc\sudoers
    goto end
  )

  ::net stop LxssManager && net start LxssManager
  ::%sudo ALL=NOPASSWD:/usr/sbin/service

  sc query LxssManager | find "RUNNING" > nul
  if %errorlevel% EQU 1 (
    net start LxssManager > nul
  )

  if %func%==status goto status
  goto init
goto end

:init

  tasklist | find "bash" > nul
  if %errorlevel% EQU 1 (
    rem start cmd /k wsl
    echo CreateObject("Wscript.Shell"^).Run "%SystemRoot%\system32\wsl.exe", 0, False > %~dp0\bash.vbs
    cscript /b %~dp0\bash.vbs
    del  %~dp0\bash.vbs
  )

  ::dir /b %BasePath%\rootfs\%rc%\K*
  FOR /f "tokens=*" %%G IN ('dir /b %BasePath%\rootfs\%rc%\K*') DO (
    set servicestart=%%G
    set service=!servicestart:~3! 
    rem bash -c 'sudo service !service! stop'
    wsl sudo service !service! stop
  )

  ::dir /b %BasePath%\rootfs\%rc%\S*
  FOR /f "tokens=*" %%G IN ('dir /b %BasePath%\rootfs\%rc%\S*') DO (
    set servicestart=%%G
    set service=!servicestart:~3! 
    rem bash -c 'sudo service !service! start'
    wsl sudo service !service! start
  )
goto end

:status
  ::dir /b %BasePath%\rootfs\%rc%\S*
  FOR /f "tokens=*" %%G IN ('dir /b %BasePath%\rootfs\%rc%\S*') DO (
    set servicestart=%%G
    set service=!servicestart:~3! 
    rem bash -c 'sudo service !service! status'
    wsl sudo service !service! status
  )
goto end

:help
  echo.
  echo %0 permet le demarrage des daemon WSL (Windows Subsytem Linux)
  echo.
  echo usage:
  echo   %0 [level] [-s] [--status]
  echo   %0 [-h] [--help]
  echo   [level] = un entier de 0 a 5 qui defini l'init du WSL
  echo   [-s] [--status] = etat des daemons de l'init choisi
  echo   [-h] [--help]   = cet aide.
  echo par défaut, la valeur de l'init est %init%
  echo.

:end
endlocal

::https://docs.microsoft.com/fr-fr/windows/wsl/about
::https://blogs.msdn.microsoft.com/commandline/2017/10/11/whats-new-in-wsl-in-windows-10-fall-creators-update/
::https://blogs.msdn.microsoft.com/commandline/learn-about-windows-console-and-windows-subsystem-for-linux-wsl/
::https://blogs.msdn.microsoft.com/wsl/2016/11/08/225/