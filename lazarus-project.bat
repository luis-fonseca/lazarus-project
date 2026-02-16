@echo off
:: Desativa a exibição dos comandos no terminal, mostrando apenas os resultados.

setlocal enabledelayedexpansion
:: Permite que variáveis dentro de laços (como o FOR) sejam atualizadas em tempo real usando ! !.

color 02

title PROJECT LAZARUS - v0.1
:: Define o título da janela do Prompt de Comando.

:: ======================================================
:: DEFINIÇÃO DE CAMINHOS
:: ======================================================
set "zomboid_raiz=%USERPROFILE%\Zomboid"
:: Pasta principal do Zomboid no perfil do usuário.

set "saves_raiz=%USERPROFILE%\Zomboid\Saves"
:: Pasta onde o jogo separa os saves por categorias.

set "destino_raiz=%USERPROFILE%\Documents\BackupsZomboid"
:: Pasta nos "Meus Documentos" onde guardaremos as cópias.

:menu_principal
cls
:: Limpa a tela para manter o visual organizado.

echo ======================================================
echo           GERENCIADOR DE BACKUPS ZOMBOID
echo ======================================================
echo.
echo [1] Fazer Backup (Sandbox, Multiplayer, etc.)
echo [2] Abrir pasta de Saves do Jogo (Explorer)
echo [3] Abrir pasta de Backups (Explorer)
echo [4] Sair
echo.

set "op_main="
:: Limpa a variável da opção antes de ler o teclado.

set /p "op_main=Escolha uma opcao: "
:: 'set /p' faz o script parar e esperar que o usuário digite algo.

:: Redirecionamento baseado na escolha:
if "%op_main%"=="1" goto menu_categorias
if "%op_main%"=="2" goto abrir_saves
if "%op_main%"=="3" goto abrir_backup
if "%op_main%"=="4" exit
goto menu_principal
:: Se nada válido for digitado, volta para o menu.

:abrir_saves
start "" "%zomboid_raiz%"
:: 'start' abre uma pasta ou programa. O "" vazio é necessário para nomes com espaços.
goto menu_principal

:abrir_backup
if not exist "%destino_raiz%" mkdir "%destino_raiz%"
:: Verifica se a pasta de backup existe; se não, cria.
start "" "%destino_raiz%"
goto menu_principal

:menu_categorias
cls
echo ======================================================
echo          SELECIONE A CATEGORIA DO SAVE
echo ======================================================
echo.
echo [1] Sandbox (Mundos Personalizados)
echo [2] Multiplayer (Servidores)
echo [3] Survivor (Modo Sobrevivente)
echo [4] Apocalypse (Modo Apocalipse)
echo [V] Voltar
echo.

set "cat="
set /p "cat=Escolha a categoria: "

if /i "%cat%"=="V" goto menu_principal
:: '/i' faz a comparação ignorar se é 'v' ou 'V'.

:: Define qual subpasta procurar dentro de \Saves\
set "subpasta="
if "%cat%"=="1" set "subpasta=Sandbox"
if "%cat%"=="2" set "subpasta=Multiplayer"
if "%cat%"=="3" set "subpasta=Survivor"
if "%cat%"=="4" set "subpasta=Apocalypse"

if "%subpasta%"=="" (
    echo Opcao invalida.
    timeout /t 2 >nul
    goto menu_categorias
)

set "caminho_busca=%saves_raiz%\%subpasta%"

:: Verifica se a categoria escolhida realmente tem saves criados
if not exist "%caminho_busca%" (
    echo.
    echo [AVISO] Nao existem saves na categoria %subpasta%.
    pause
    goto menu_categorias
)

:selecao_mundo
cls
echo ======================================================
echo           LISTANDO MUNDOS EM: %subpasta%
echo ======================================================
echo.

:: Limpa a memória das variáveis de mundo anteriores
for /L %%i in (1,1,100) do set "mundo[%%i]="

set count=0
:: O comando 'for' abaixo lista apenas pastas (/ad) dentro do caminho de busca.
for /f "delims=" %%a in ('dir /b /ad "%caminho_busca%" 2^>nul') do (
    set /a count+=1
    set "mundo[!count!]=%%a"
    echo [!count!] - %%a
)

echo.
echo [V] Voltar
set "esc_mundo="
set /p "esc_mundo=Selecione o numero do mundo: "

if /i "%esc_mundo%"=="V" goto menu_categorias

:: Verifica se o número digitado corresponde a um mundo da lista
if not defined mundo[%esc_mundo%] (
    echo Opcao Invalida!
    timeout /t 2 >nul
    goto selecao_mundo
)

set "nome_mundo=!mundo[%esc_mundo%]!"

:: ======================================================
:: CRIAÇÃO DO CARIMBO DE DATA E HORA
:: ======================================================
set "d=%date:~6,4%-%date:~3,2%-%date:~0,2%"
:: Pega o ano, mês e dia da variável do sistema %date%.

set "t=%time:~0,2%-%time:~3,2%"
:: Pega hora e minutos da variável %time%.

set "t=%t: =0%"
:: Se a hora for menor que 10 (ex: 9:00), o Windows coloca um espaço. Isso troca o espaço por 0.

set "dh=%d%_%t%"

:: Define o caminho final onde os arquivos serão colados
set "caminho_final=%destino_raiz%\%subpasta%\%nome_mundo%\%dh%"

echo.
echo Criando backup de: "%nome_mundo%"...

:: Cria a pasta de destino (incluindo as pastas pai, se necessário)
if not exist "%caminho_final%" mkdir "%caminho_final%"

:: O comando XCOPY faz a cópia:
:: /E - Copia pastas e subpastas (inclusive vazias).
:: /I - Se o destino não existir, assume que é uma pasta.
:: /Y - Sobrescreve sem perguntar (embora a pasta seja nova).
:: /Q - Modo silencioso (não lista cada arquivo copiado).
xcopy "%caminho_busca%\%nome_mundo%" "%caminho_final%\" /E /I /Y /Q

echo.
echo ======================================================
echo    BACKUP CONCLUIDO COM SUCESSO!
echo ======================================================
pause
goto menu_principal