@echo off
setlocal enabledelayedexpansion
color 02
title PROJECT LAZARUS - Gerenciador de Saves

:: Caminhos Base
set "zomboid_raiz=%USERPROFILE%\Zomboid"
set "saves_raiz=%USERPROFILE%\Zomboid\Saves"
set "destino_raiz=%USERPROFILE%\Documents\BackupsZomboid"

:menu_principal
cls
echo ======================================================
echo           PROJECT LAZARUS - MENU PRINCIPAL
echo ======================================================
echo.
echo [1] Fazer Backup (Salvar Progresso)
echo [2] Restaurar Backup (Sobrescrever Save Atual)
echo [3] Abrir pasta de Saves do Jogo (Explorer)
echo [4] Abrir pasta de Backups (Explorer)
echo [5] Sair
echo.
set "op_main="
set /p "op_main=Escolha uma opcao: "

if "%op_main%"=="1" goto menu_categorias_backup
if "%op_main%"=="2" goto menu_categorias_restore
if "%op_main%"=="3" goto abrir_pasta_jogo
if "%op_main%"=="4" goto abrir_pasta_backup
if "%op_main%"=="5" exit
goto menu_principal

:abrir_pasta_jogo
start "" "%zomboid_raiz%"
goto menu_principal

:abrir_pasta_backup
if not exist "%destino_raiz%" mkdir "%destino_raiz%"
start "" "%destino_raiz%"
goto menu_principal

:: --- SEÇÃO DE CATEGORIAS (COMUM) ---
:menu_categorias_backup
set "modo_fluxo=BACKUP"
goto menu_categorias_comum

:menu_categorias_restore
set "modo_fluxo=RESTORE"
goto menu_categorias_comum

:menu_categorias_comum
cls
echo ======================================================
echo          MODO: %modo_fluxo% - CATEGORIA
echo ======================================================
echo.
echo [1] Sandbox
echo [2] Multiplayer
echo [3] Survivor
echo [4] Apocalypse
echo [V] Voltar
echo.
set "cat="
set /p "cat=Escolha a categoria: "

if /i "%cat%"=="V" goto menu_principal
set "sub="
if "%cat%"=="1" set "sub=Sandbox"
if "%cat%"=="2" set "sub=Multiplayer"
if "%cat%"=="3" set "sub=Survivor"
if "%cat%"=="4" set "sub=Apocalypse"

if "%sub%"=="" goto menu_categorias_comum

if "%modo_fluxo%"=="BACKUP" (
    set "caminho_leitura=%saves_raiz%\%sub%"
) else (
    set "caminho_leitura=%destino_raiz%\%sub%"
)

:listar_mundos
cls
echo ======================================================
echo    MODO: %modo_fluxo% - SELECIONE O MUNDO (%sub%)
echo ======================================================
echo.
if not exist "%caminho_leitura%" (
    echo [AVISO] Nao existem dados nesta categoria.
    pause
    goto menu_categorias_comum
)

for /L %%i in (1,1,100) do set "item[%%i]="
set count=0
for /f "delims=" %%a in ('dir /b /ad "%caminho_leitura%" 2^>nul') do (
    set /a count+=1
    set "item[!count!]=%%a"
    echo [!count!] - %%a
)

if %count%==0 (
    echo [AVISO] Pasta vazia.
    pause
    goto menu_categorias_comum
)

echo.
echo [V] Voltar
set /p "esc=Selecione o numero: "
if /i "%esc%"=="V" goto menu_categorias_comum
if not defined item[%esc%] goto listar_mundos

set "mundo_nome=!item[%esc%]!"

if "%modo_fluxo%"=="BACKUP" goto executar_backup
goto listar_datas_restore

:executar_backup
set "d=%date:~6,4%-%date:~3,2%-%date:~0,2%"
set "t=%time:~0,2%-%time:~3,2%"
set "t=%t: =0%"
set "final=%destino_raiz%\%sub%\%mundo_nome%\%d%_%t%"

echo.
echo Criando backup em: "%final%"
mkdir "%final%" 2>nul
xcopy "%saves_raiz%\%sub%\%mundo_nome%" "%final%\" /E /I /Y /Q

echo.
echo BACKUP CONCLUIDO!
pause
goto menu_principal

:listar_datas_restore
cls
echo ======================================================
echo    RESTORE - SELECIONE A DATA DO BACKUP
echo ======================================================
echo.
set "caminho_datas=%destino_raiz%\%sub%\%mundo_nome%"
for /L %%i in (1,1,100) do set "data_bkp[%%i]="
set count=0
for /f "delims=" %%a in ('dir /b /ad "%caminho_datas%" 2^>nul') do (
    set /a count+=1
    set "data_bkp[!count!]=%%a"
    echo [!count!] - %%a
)
echo [V] Voltar
echo.
set /p "esc_d=Qual backup deseja restaurar? "
if /i "%esc_d%"=="V" goto listar_mundos
if not defined data_bkp[%esc_d%] goto listar_datas_restore

set "data_selecionada=!data_bkp[%esc_d%]!"

echo.
echo [PERIGO] Isso vai sobrescrever seu save atual no jogo!
set /p "confirma=Confirmar restauracao de %mundo_nome%? (S/N): "
if /i not "%confirma%"=="S" goto menu_principal

echo Restaurando arquivos...
:: Remove a pasta atual para garantir instalacao limpa
rd /s /q "%saves_raiz%\%sub%\%mundo_nome%" 2>nul
:: Copia os arquivos do backup para a pasta original do jogo
xcopy "%caminho_datas%\%data_selecionada%" "%saves_raiz%\%sub%\%mundo_nome%\" /E /I /Y /Q

echo.
echo RESTAURACAO CONCLUIDA!
pause
goto menu_principal