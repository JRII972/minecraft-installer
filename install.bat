@echo off
setlocal enabledelayedexpansion
echo ========================================
echo Installation des fichiers de configuration Minecraft
echo ========================================
echo.

REM Définir les variables
set "MINECRAFT_CONFIG=%APPDATA%\.minecraft\config"
set "MINECRAFT_MODS=%APPDATA%\.minecraft\mods"
set "MINECRAFT_SHADERPACKS=%APPDATA%\.minecraft\shaderpacks"
set "GITHUB_RAW=https://raw.githubusercontent.com/JRII972/minecraft-installer/main/config"

echo Verification du dossier Minecraft...
if not exist "%APPDATA%\.minecraft" (
    echo ERREUR: Le dossier .minecraft n'existe pas dans %APPDATA%
    echo Veuillez lancer Minecraft au moins une fois avant d'executer ce script.
    pause
    exit /b 1
)

echo Verification de l'installation de NeoForge 1.21.1...
if not exist "%APPDATA%\.minecraft\versions" (
    echo ERREUR: Le dossier versions n'existe pas.
    echo Veuillez installer NeoForge pour Minecraft 1.21.1 avant d'executer ce script.
    pause
    exit /b 1
)

REM Chercher une version NeoForge 1.21.1
set "NEOFORGE_FOUND="
if exist "%APPDATA%\.minecraft\versions\neoforge-21.1.194" (
    set "NEOFORGE_FOUND=1"
)

if not defined NEOFORGE_FOUND (
    echo.
    echo ERREUR: NeoForge 21.1.194 pour Minecraft 1.21.1 n'est pas installe.
    echo.
    echo Installation automatique de NeoForge 21.1.194...
    echo.
    echo IMPORTANT: Fermez completement le launcher Minecraft avant de continuer !
    echo Appuyez sur une touche quand le launcher est ferme...
    pause >nul
    
    echo Telechargement de l'installateur NeoForge...
    if not exist "%TEMP%\neoforge-installer" mkdir "%TEMP%\neoforge-installer"
    powershell -Command "try { Invoke-WebRequest -Uri 'https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.194/neoforge-21.1.194-installer.jar' -OutFile '%TEMP%\neoforge-installer\neoforge-21.1.194-installer.jar' -ErrorAction Stop; Write-Host 'Installateur NeoForge telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de NeoForge: ' $_.Exception.Message -ForegroundColor Red; exit 1 }"
    
    echo.
    echo Lancement de l'installateur NeoForge...
    echo Suivez les instructions dans la fenetre d'installation qui va s'ouvrir.
    echo Choisissez "Install client" et cliquez sur "OK".
    echo.
    start /wait java -jar "%TEMP%\neoforge-installer\neoforge-21.1.194-installer.jar"
    
    echo.
    echo Installation de NeoForge terminee.
    echo Nettoyage des fichiers temporaires...
    del /q "%TEMP%\neoforge-installer\neoforge-21.1.194-installer.jar" 2>nul
    rmdir "%TEMP%\neoforge-installer" 2>nul
    
    echo.
    echo Verification de l'installation...
    REM Re-vérifier la présence de NeoForge
    set "NEOFORGE_FOUND="
    if exist "%APPDATA%\.minecraft\versions\neoforge-21.1.194" (
        set "NEOFORGE_FOUND=1"
    )
    
    if not defined NEOFORGE_FOUND (
        echo ERREUR: L'installation de NeoForge a echoue ou a ete annulee.
        echo Veuillez reinstaller manuellement depuis: https://neoforged.net/
        pause
        exit /b 1
    ) else (
        echo NeoForge 21.1.194 installe avec succes !
    )
) else (
    echo NeoForge 1.21.1 detecte - continuation...
)

echo Creation du dossier config s'il n'existe pas...
if not exist "%MINECRAFT_CONFIG%" (
    mkdir "%MINECRAFT_CONFIG%"
    echo Dossier config cree: %MINECRAFT_CONFIG%
) else (
    echo Dossier config existe deja: %MINECRAFT_CONFIG%
)

echo Creation du dossier mods s'il n'existe pas...
if not exist "%MINECRAFT_MODS%" (
    mkdir "%MINECRAFT_MODS%"
    echo Dossier mods cree: %MINECRAFT_MODS%
) else (
    echo Dossier mods existe deja: %MINECRAFT_MODS%
)

echo Creation du dossier shaderpacks s'il n'existe pas...
if not exist "%MINECRAFT_SHADERPACKS%" (
    mkdir "%MINECRAFT_SHADERPACKS%"
    echo Dossier shaderpacks cree: %MINECRAFT_SHADERPACKS%
) else (
    echo Dossier shaderpacks existe deja: %MINECRAFT_SHADERPACKS%
)

REM Vérifier si le dossier mods contient des fichiers
echo.
echo Verification du contenu du dossier mods...
dir /b "%MINECRAFT_MODS%\*.jar" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ATTENTION: Des mods sont deja presents dans le dossier mods.
    echo Les nouveaux mods seront en version 1.21.1 sous NeoForge.
    echo Si les mods precedents ne sont pas compatibles, le jeu ne se lancera pas.
    echo.
    set /p "choice=Acceptez-vous de supprimer les anciens mods? (o/n): "
    if /i "!choice!" neq "o" (
        echo Operation annulee par l'utilisateur.
        pause
        exit /b 0
    )
    echo Suppression des anciens mods...
    del /q "%MINECRAFT_MODS%\*.jar"
    echo Anciens mods supprimes.
) else (
    echo Dossier mods vide, continuation...
)

echo.
echo ========================================
echo Import des fichiers de configuration
echo ========================================
echo.
echo Les fichiers de configuration suivants seront importes:
echo - iris.properties (configuration Iris)
echo - xaerominimap.txt (configuration minimap Xaero)
echo - xaerominimap_entities.json (entites minimap Xaero)
echo - xaeropatreon.txt (desactivation patreon Xaero)
echo - xaeroworldmap.txt (configuration worldmap Xaero)
echo.
set /p "configChoice=Voulez-vous importer les fichiers de configuration? (o/n): "
if /i "!configChoice!" neq "o" (
    echo Import des configurations ignore par l'utilisateur.
    goto :mods_download
)

echo.
echo Telechargement des fichiers de configuration...
echo.

REM Télécharger iris.properties
echo Telechargement de iris.properties...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW%/iris.properties' -OutFile '%MINECRAFT_CONFIG%\iris.properties' -ErrorAction Stop; Write-Host 'iris.properties telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de iris.properties: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger xaerominimap.txt
echo Telechargement de xaerominimap.txt...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW%/xaerominimap.txt' -OutFile '%MINECRAFT_CONFIG%\xaerominimap.txt' -ErrorAction Stop; Write-Host 'xaerominimap.txt telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de xaerominimap.txt: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger xaerominimap_entities.json
echo Telechargement de xaerominimap_entities.json...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW%/xaerominimap_entities.json' -OutFile '%MINECRAFT_CONFIG%\xaerominimap_entities.json' -ErrorAction Stop; Write-Host 'xaerominimap_entities.json telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de xaerominimap_entities.json: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger xaeropatreon.txt
echo Telechargement de xaeropatreon.txt...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW%/xaeropatreon.txt' -OutFile '%MINECRAFT_CONFIG%\xaeropatreon.txt' -ErrorAction Stop; Write-Host 'xaeropatreon.txt telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de xaeropatreon.txt: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger xaeroworldmap.txt
echo Telechargement de xaeroworldmap.txt...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW%/xaeroworldmap.txt' -OutFile '%MINECRAFT_CONFIG%\xaeroworldmap.txt' -ErrorAction Stop; Write-Host 'xaeroworldmap.txt telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de xaeroworldmap.txt: ' $_.Exception.Message -ForegroundColor Red }"

:mods_download
echo.
echo ========================================
echo Options d'installation des shaders
echo ========================================
echo.
echo Voulez-vous installer le support des shaders?
echo - Mod Iris NeoForge (support des shaders)
echo - Shader pack BSL v10.0 (shader)
echo.
set /p "shaderChoice=Installer le support des shaders? (o/n): "

echo.
echo ========================================
echo Telechargement des mods (version 1.21.1 NeoForge)...
echo ========================================
echo.

REM Télécharger Sodium NeoForge
echo Telechargement de Sodium NeoForge...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdn.modrinth.com/data/AANobbMI/versions/Pb3OXVqC/sodium-neoforge-0.6.13%%2Bmc1.21.1.jar' -OutFile '%MINECRAFT_MODS%\sodium-neoforge-0.6.13+mc1.21.1.jar' -ErrorAction Stop; Write-Host 'Sodium NeoForge telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de Sodium: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger Iris NeoForge si l'utilisateur a choisi les shaders
if /i "!shaderChoice!" equ "o" (
    echo Telechargement de Iris NeoForge...
    powershell -Command "try { Invoke-WebRequest -Uri 'https://cdn.modrinth.com/data/YL57xq9U/versions/t3ruzodq/iris-neoforge-1.8.12%%2Bmc1.21.1.jar' -OutFile '%MINECRAFT_MODS%\iris-neoforge-1.8.12+mc1.21.1.jar' -ErrorAction Stop; Write-Host 'Iris NeoForge telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de Iris: ' $_.Exception.Message -ForegroundColor Red }"
) else (
    echo Installation d'Iris ignoree - shaders non souhaites.
)

REM Télécharger AutoModpack
echo Telechargement de AutoModpack...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdn.modrinth.com/data/k68glP2e/versions/OUWzgiPf/automodpack-mc1.21.1-neoforge-4.0.0-beta38.jar' -OutFile '%MINECRAFT_MODS%\automodpack-mc1.21.1-neoforge-4.0.0-beta38.jar' -ErrorAction Stop; Write-Host 'AutoModpack telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement de AutoModpack: ' $_.Exception.Message -ForegroundColor Red }"

REM Télécharger le shader pack BSL si l'utilisateur a choisi les shaders
if /i "!shaderChoice!" equ "o" (
    echo.
    echo Telechargement du shader pack BSL v10.0...
    powershell -Command "try { Invoke-WebRequest -Uri 'https://cdn.modrinth.com/data/Q1vvjJYV/versions/jRn8y2VF/BSL_v10.0.zip' -OutFile '%MINECRAFT_SHADERPACKS%\BSL_v10.0.zip' -ErrorAction Stop; Write-Host 'Shader pack BSL v10.0 telecharge avec succes' -ForegroundColor Green } catch { Write-Host 'Erreur lors du telechargement du shader BSL: ' $_.Exception.Message -ForegroundColor Red }"
)

echo.
echo ========================================
echo Installation terminee !
echo.
if /i "!configChoice!" equ "o" (
    echo Les fichiers de configuration ont ete installes dans:
    echo %MINECRAFT_CONFIG%
    echo.
) else (
    echo Import des fichiers de configuration ignore.
    echo.
)
echo Les mods suivants ont ete installes dans:
echo %MINECRAFT_MODS%
echo - Sodium NeoForge 0.6.13 (amelioration des performances)
if /i "!shaderChoice!" equ "o" (
    echo - Iris NeoForge 1.8.12 (support des shaders)
)
echo - AutoModpack 4.0.0-beta38 (gestion automatique des modpacks)
echo.
if /i "!shaderChoice!" equ "o" (
    echo Shader pack installe dans:
    echo %MINECRAFT_SHADERPACKS%
    echo - BSL v10.0 (shader populaire et optimise)
    echo.
)
echo Version cible: Minecraft 1.21.1 avec NeoForge
echo.
echo Vous pouvez maintenant lancer Minecraft.
echo ========================================
echo.
pause