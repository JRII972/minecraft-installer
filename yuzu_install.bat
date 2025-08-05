@echo off
setlocal
set "TEMP_DIR=%TEMP%\yuzu_installer_temp"
set "YUZU_DIR=C:\Yuzu"
set "APPDATA_YUZU=%APPDATA%\yuzu"
set "KEYS_DIR=%APPDATA_YUZU%\keys"
set "CONFIG_DIR=%APPDATA_YUZU%\config"
set "GAME_DIR=%YUZU_DIR%\game"

REM Créer le dossier temporaire
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"


REM Télécharger les fichiers zip depuis GitHub
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/yuzu-windows-msvc-20240304-537296095.zip' -OutFile '%TEMP_DIR%\yuzu.zip'"
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/ProdKeys.net-v20.0.1.zip' -OutFile '%TEMP_DIR%\prodkey.zip'"
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/config.zip' -OutFile '%TEMP_DIR%\config.zip'"

REM Demander à l'utilisateur de télécharger game.zip depuis OneDrive
set "ONEDRIVE_GAME_URL=https://onedrive.live.com/download?cid=VOTRE_CID&resid=VOTRE_RESID"
echo Veuillez télécharger le fichier game.zip depuis le lien suivant et le placer dans votre dossier Téléchargements :
echo %ONEDRIVE_GAME_URL%
start "" "%ONEDRIVE_GAME_URL%"
pause


REM Définir le chemin du game.zip dans Téléchargements
set "USER_DOWNLOADS=%USERPROFILE%\Downloads"
set "GAME_ZIP_PATH=%USER_DOWNLOADS%\game.zip"

REM Extraire Yuzu dans C:\Yuzu
if not exist "%YUZU_DIR%" mkdir "%YUZU_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\yuzu.zip' -DestinationPath '%YUZU_DIR%' -Force"

REM Extraire et copier prodKey dans %appdata%\yuzu\keys
if not exist "%KEYS_DIR%" mkdir "%KEYS_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\prodkey.zip' -DestinationPath '%KEYS_DIR%' -Force"

REM Extraire et copier config.zip dans %appdata%\yuzu\config
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\config.zip' -DestinationPath '%CONFIG_DIR%' -Force"

REM Extraire game.zip depuis Téléchargements dans C:\Yuzu\game
if exist "%GAME_ZIP_PATH%" (
    if not exist "%GAME_DIR%" mkdir "%GAME_DIR%"
    powershell -Command "Expand-Archive -Path '%GAME_ZIP_PATH%' -DestinationPath '%GAME_DIR%' -Force"
)

REM Supprimer les fichiers temporaires
rd /s /q "%TEMP_DIR%"


REM Créer un raccourci Yuzu sur le bureau
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\Yuzu.lnk"
set "YUZU_EXE=%YUZU_DIR%\yuzu.exe"
if exist "%YUZU_EXE%" (
    powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT_PATH%');$s.TargetPath='%YUZU_EXE%';$s.Save()"
    echo Un raccourci Yuzu a été créé sur le bureau.
) else (
    echo Attention : yuzu.exe introuvable dans %YUZU_DIR%. Le raccourci n'a pas été créé.
)

echo Installation terminée !
pause

REM Lancer Yuzu
if exist "%YUZU_EXE%" (
    start "Yuzu" "%YUZU_EXE%"
)
