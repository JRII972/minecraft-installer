@echo off
setlocal
set "TEMP_DIR=%TEMP%\yuzu_installer_temp"
set "YUZU_DIR=C:\Yuzu"
set "APPDATA_YUZU=%APPDATA%\yuzu"
set "KEYS_DIR=%APPDATA_YUZU%\keys"
set "GAME_ZIP_PATH=%USERPROFILE%\Downloads\games.zip"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\Yuzu.lnk"
set "YUZU_EXE=%YUZU_DIR%\yuzu.exe"

REM Créer le dossier temporaire
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

REM Demander à l'utilisateur de télécharger game.zip depuis OneDrive
set "ONEDRIVE_GAME_URL=https://1drv.ms/u/c/a4053beb9b5e1042/EQQUtT8AABJOvM8zHuRrYKMBrLvH0NfRJFUYwDa9-ROg8w?e=HyubUc"
echo Veuillez télécharger le fichier game.zip depuis le lien suivant et le placer dans votre dossier Téléchargements :
echo fait entre pour ouvrir
pause

echo %ONEDRIVE_GAME_URL%

start "" "%ONEDRIVE_GAME_URL%"

echo Téléchargements des autres fichier en attendant
REM Télécharger les fichiers zip depuis GitHub
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/yuzu-windows-msvc-20240304-537296095.zip' -OutFile '%TEMP_DIR%\yuzu.zip'"
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/ProdKeys.net-v20.0.1.zip' -OutFile '%TEMP_DIR%\prodkey.zip'"
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/JRII972/minecraft-installer/main/config.zip' -OutFile '%TEMP_DIR%\config.zip'"

echo Le téléchargement du fichier game est il fini ? (Entrer quand fini)
pause



REM Extraire Yuzu dans C:\Yuzu
if not exist "%YUZU_DIR%" mkdir "%YUZU_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\yuzu.zip' -DestinationPath '%YUZU_DIR%' -Force"

REM Extraire et copier prodKey dans %appdata%\yuzu\keys
if not exist "%KEYS_DIR%" mkdir "%KEYS_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\prodkey.zip' -DestinationPath '%KEYS_DIR%' -Force"

REM Extraire et copier config.zip dans %appdata%\yuzu\config
if not exist "%APPDATA_YUZU%" mkdir "%APPDATA_YUZU%"
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\config.zip' -DestinationPath '%APPDATA_YUZU%' -Force"

REM Extraire game.zip depuis Téléchargements dans C:\Yuzu\game
echo Sélectionnez le fichier game.zip à extraire dans C:\Yuzu\game.

REM Créer le dossier des jeux si nécessaire
if not exist "%YUZU_DIR%" mkdir "%YUZU_DIR%"

REM Utiliser PowerShell pour sélectionner et extraire directement le fichier
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd = New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter = 'ZIP Files (*.zip)|*.zip'; $ofd.Title = 'Sélectionnez le fichier game.zip'; if ($ofd.ShowDialog() -eq 'OK') { Write-Host ('Extraction de ' + $ofd.FileName + ' vers %YUZU_DIR%...'); Expand-Archive -Path $ofd.FileName -DestinationPath '%YUZU_DIR%' -Force; Write-Host 'Extraction terminée!' } else { Write-Host 'Aucun fichier sélectionné.' }"

REM Ouvrir le dossier des jeux pour vérification
start "" "%YUZU_DIR%"

REM Supprimer les fichiers temporaires
rd /s /q "%TEMP_DIR%"


REM Créer un raccourci Yuzu sur le bureau
if exist "%YUZU_EXE%" (
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Yuzu.lnk'); $Shortcut.TargetPath = '%YUZU_EXE%'; $Shortcut.Save(); Write-Output 'Raccourci créé avec succès'"
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
