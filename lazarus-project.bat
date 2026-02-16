@echo off
:: Desativa a exibição dos comandos, mostrando apenas as saídas no terminal
setlocal enabledelayedexpansion
:: Permite que variáveis dentro de laços (como o FOR) sejam atualizadas em tempo real usando !var!
color 02
:: Define a cor do terminal para fundo preto e letras verdes (estilo terminal antigo)
title PROJECT LAZARUS - Gerenciador de Saves
:: Define o nome da janela do prompt

:: --- DETECÇÃO DE IDIOMA ---
:: Busca o código do idioma (ex: pt-BR) diretamente no registro do Windows para automatizar a tradução
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v LocaleName ^| findstr "LocaleName"') do set "lang=%%a"

:: Define as Strings baseadas no idioma (Bloco IF para Português, Bloco ELSE para Inglês/Outros)
:: Nota: Se alterar "INGLES" para "pt-BR", o script funcionará nativamente no seu sistema
if /i "%lang%"=="pt-BR" (
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
    :: Strings em Inglês para sistemas internacionais
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

:: Caminhos Base (Diretórios padrão do Project Zomboid e pasta de destino nos Documentos)
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

:: Lógica de redirecionamento do menu principal
if "%op_main%"=="1" goto menu_categorias_backup
if "%op_main%"=="2" goto menu_categorias_restore
if "%op_main%"=="3" goto abrir_pasta_jogo
if "%op_main%"=="4" goto abrir_pasta_backup
if "%op_main%"=="5" exit
goto menu_principal

:abrir_pasta_jogo
:: Tenta abrir a pasta raiz do jogo. Se não existir, exibe erro e espera 5 segundos.
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
:: Tenta abrir a pasta de backups. Se não existir, avisa o usuário.
if exist "%destino_raiz%" (
    start "" "%destino_raiz%"
) else (
    echo.
    echo %txt_warn_bkp%
    timeout /t 5 >nul
)
goto menu_principal

:: --- SEÇÃO DE CATEGORIAS (Define se o fluxo é de Backup ou Restauração) ---
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
:: Mapeamento das subpastas do jogo
set "sub="
if "%cat%"=="1" set "sub=Sandbox"
if "%cat%"=="2" set "sub=Multiplayer"
if "%cat%"=="3" set "sub=Survivor"
if "%cat%"=="4" set "sub=Apocalypse"

if "%sub%"=="" goto menu_categorias_comum

:: Define de onde ler os arquivos (se do jogo para backup ou da pasta de backup para restore)
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
:: Verifica se a categoria escolhida tem alguma pasta
if not exist "%caminho_leitura%" (
    echo %txt_no_data%
    pause
    goto menu_categorias_comum
)

:: Limpa o índice de itens e lista as pastas numericamente
for /L %%i in (1,1,100) do set "item[%%i]="
set count=0
for /f "delims=" %%a in ('dir /b /ad "%caminho_leitura%" 2^>nul') do (
    set /a count+=1
    set "item[!count!]=%%a"
    echo [!count!] - %%a
)

:: Tratamento para pastas vazias
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

:: Direciona para a execução final baseada no modo
if "%modo_fluxo%"=="BACKUP" goto executar_backup
goto listar_datas_restore

:executar_backup
:: Gera o carimbo de tempo (Ano-Mês-Dia_Hora-Minuto)
set "d=%date:~6,4%-%date:~3,2%-%date:~0,2%"
set "t=%time:~0,2%-%time:~3,2%"
set "t=%t: =0%"
set "dh=%d%_%t%"
set "final=%destino_raiz%\%sub%\%mundo_nome%\%dh%"

echo.
echo %txt_creating% "%final%"
mkdir "%final%" 2>nul
:: Copia todos os arquivos e subpastas (/E), mantendo a estrutura
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
:: Lista as datas disponíveis dentro da pasta de backup do mundo selecionado
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

:: Aviso de segurança crítico antes de apagar o save atual
echo.
echo %txt_danger%
set /p "confirma=%txt_confirm% %mundo_nome%? (S/N): "
if /i not "%confirma%"=="S" goto menu_principal

echo %txt_restoring%
:: rd apaga a pasta atual para evitar conflitos de arquivos antigos com o backup
rd /s /q "%saves_raiz%\%sub%\%mundo_nome%" 2>nul
:: xcopy restaura os arquivos da data escolhida para o diretório do jogo
xcopy "%caminho_datas%\%data_selecionada%" "%saves_raiz%\%sub%\%mundo_nome%\" /E /I /Y /Q

echo.
echo %txt_res_ok%
pause
goto menu_principal