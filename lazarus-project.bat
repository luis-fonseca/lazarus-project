@echo off
setlocal enabledelayedexpansion
color 02
title PROJECT LAZARUS - Gerenciador de Saves

:: --- DETECÇÃO DE IDIOMA ---
:: Busca o código do idioma no registro do Windows
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v LocaleName ^| findstr "LocaleName"') do set "lang=%%a"

:: Define as Strings baseadas no idioma (PT-BR vs Internacional)
if /i "%lang%"=="INGLES" (
    set "txt_menu=MENU PRINCIPAL"
    set "txt_opt1=[1] Fazer Backup (Salvar Progresso)"
    set "txt_opt2=[2] Restaurar Backup (Sobrescrever Save Atual)"
    set "txt_opt3=[3] Abrir pasta de Saves do Jogo (Explorer)"
    set "txt_opt4=[4] Abrir pasta de Backups (Explorer)"
    set "txt_opt5=[5] Sair"
    set "txt_choice=Escolha uma opcao: "
    set "txt_err_game=[ERRO] A pasta de saves do jogo nao foi encontrada em:"
    set "txt_warn_bkp=[AVISO] A pasta de backups ainda nao existe. Ela sera criada automaticamente."
    set "txt_cat_title=MODO: %modo_fluxo% - CATEGORIA"
    set "txt_cat_choice=Escolha a categoria: "
    set "txt_back=[V] Voltar"
    set "txt_list_world=MODO: %modo_fluxo% - SELECIONE O MUNDO"
    set "txt_no_data=[AVISO] Nao existem dados nesta categoria."
    set "txt_empty=[AVISO] Pasta vazia."
    set "txt_sel_num=Selecione o numero: "
    set "txt_creating=Criando backup em: "
    set "txt_bkp_ok=BACKUP CONCLUIDO!"
    set "txt_sel_date=RESTORE - SELECIONE A DATA DO BACKUP"
    set "txt_which_bkp=Qual backup deseja restaurar? "
    set "txt_danger=[PERIGO] Isso vai sobrescrever seu save atual no jogo!"
    set "txt_confirm=Confirmar restauracao de "
    set "txt_restoring=Restaurando arquivos..."
    set "txt_res_ok=RESTAURACAO CONCLUIDA!"
) else (
    set "txt_menu=MAIN MENU"
    set "txt_opt1=[1] Backup (Save Progress)"
    set "txt_opt2=[2] Restore Backup (Overwrite Current Save)"
    set "txt_opt3=[3] Open Game Saves Folder (Explorer)"
    set "txt_opt4=[4] Open Backups Folder (Explorer)"
    set "txt_opt5=[5] Exit"
    set "txt_choice=Choose an option: "
    set "txt_err_game=[ERROR] Game save folder not found at:"
    set "txt_warn_bkp=[WARNING] Backup folder does not exist yet. It will be created automatically."
    set "txt_cat_title=MODE: %modo_fluxo% - CATEGORY"
    set "txt_cat_choice=Choose category: "
    set "txt_back=[V] Back"
    set "txt_list_world=MODE: %modo_fluxo% - SELECT WORLD"
    set "txt_no_data=[WARNING] No data found in this category."
    set "txt_empty=[WARNING] Empty folder."
    set "txt_sel_num=Select number: "
    set "txt_creating=Creating backup at: "
    set "txt_bkp_ok=BACKUP COMPLETED!"
    set "txt_sel_date=RESTORE - SELECT BACKUP DATE"
    set "txt_which_bkp=Which backup do you want to restore? "
    set "txt_danger=[DANGER] This will overwrite your current game save!"
    set "txt_confirm=Confirm restoration of "
    set "txt_restoring=Restoring files..."
    set "txt_res_ok=RESTORATION COMPLETED!"
)

:: Caminhos Base
set "zomboid_raiz=%USERPROFILE%\Zomboid"
set "saves_raiz=%USERPROFILE%\Zomboid\Saves"
set "destino_raiz=%USERPROFILE%\Documents\BackupsZomboid"

:menu_principal
cls
echo ======================================================
echo           PROJECT LAZARUS - %txt_menu%
echo ======================================================
echo.
echo %txt_opt1%
echo %txt_opt2%
echo %txt_opt3%
echo %txt_opt4%
echo %txt_opt5%
echo.
set "op_main="
set /p "op_main=%txt_choice%"

if "%op_main%"=="1" goto menu_categorias_backup
if "%op_main%"=="2" goto menu_categorias_restore
if "%op_main%"=="3" goto abrir_pasta_jogo
if "%op_main%"=="4" goto abrir_pasta_backup
if "%op_main%"=="5" exit
goto menu_principal

:abrir_pasta_jogo
if exist "%zomboid_raiz%" (
    start "" "%zomboid_raiz%"
) else (
    echo.
    echo %txt_err_game%
    echo "%zomboid_raiz%"
    timeout /t 5 >nul
)
goto menu_principal

:abrir_pasta_backup
if exist "%destino_raiz%" (
    start "" "%destino_raiz%"
) else (
    echo.
    echo %txt_warn_bkp%
    timeout /t 5 >nul
)
goto menu_principal

:menu_categorias_backup
set "modo_fluxo=BACKUP"
goto menu_categorias_comum

:menu_categorias_restore
set "modo_fluxo=RESTORE"
goto menu_categorias_comum

:menu_categorias_comum
cls
echo ======================================================
echo           %txt_cat_title%
echo ======================================================
echo.
echo [1] Sandbox      
echo [2] Multiplayer
echo [3] Survivor
echo [4] Apocalypse
echo %txt_back%
echo.
set "cat="
set /p "cat=%txt_cat_choice%"

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
echo     %txt_list_world% (%sub%)
echo ======================================================
echo.
if not exist "%caminho_leitura%" (
    echo %txt_no_data%
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
    echo %txt_empty%
    pause
    goto menu_categorias_comum
)

echo.
echo %txt_back%
set /p "esc=%txt_sel_num%"
if /i "%esc%"=="V" goto menu_categorias_comum
if not defined item[%esc%] goto listar_mundos

set "mundo_nome=!item[%esc%]!"

if "%modo_fluxo%"=="BACKUP" goto executar_backup
goto listar_datas_restore

:executar_backup
set "d=%date:~6,4%-%date:~3,2%-%date:~0,2%"
set "t=%time:~0,2%-%time:~3,2%"
set "t=%t: =0%"
set "dh=%d%_%t%"
set "final=%destino_raiz%\%sub%\%mundo_nome%\%dh%"

echo.
echo %txt_creating% "%final%"
mkdir "%final%" 2>nul
xcopy "%saves_raiz%\%sub%\%mundo_nome%" "%final%\" /E /I /Y /Q

echo.
echo %txt_bkp_ok%
pause
goto menu_principal

:listar_datas_restore
cls
echo ======================================================
echo     %txt_sel_date%
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
echo %txt_back%
echo.
set /p "esc_d=%txt_which_bkp%"
if /i "%esc_d%"=="V" goto listar_mundos
if not defined data_bkp[%esc_d%] goto listar_datas_restore

set "data_selecionada=!data_bkp[%esc_d%]!"

echo.
echo %txt_danger%
set /p "confirma=%txt_confirm% %mundo_nome%? (S/N): "
if /i not "%confirma%"=="S" goto menu_principal

echo %txt_restoring%
rd /s /q "%saves_raiz%\%sub%\%mundo_nome%" 2>nul
xcopy "%caminho_datas%\%data_selecionada%" "%saves_raiz%\%sub%\%mundo_nome%\" /E /I /Y /Q

echo.
echo %txt_res_ok%
pause
goto menu_principal