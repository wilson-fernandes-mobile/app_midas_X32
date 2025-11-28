Passo a Passo Completo - Inno Setup
1️⃣ Baixe e Instale o Inno Setup
Baixe aqui:

https://jrsoftware.org/isdl.php
Baixe a versão "Inno Setup 6.x" (versão mais recente)
Instale normalmente (Next, Next, Finish)


2️⃣ Faça o Build do App
Aguarde a compilação terminar. Você

flutter build windows --release

Aguarde a compilação terminar. Você verá algo como:

✓ Built build\windows\x64\runner\Release\cclmidas.exe

4️⃣ Compile o Instalador
Opção A: Via Interface Gráfica (Mais Fácil)

Abra o Inno Setup Compiler
Clique em File → Open
Selecione o arquivo windows_installer.iss (na raiz do projeto)
Clique em Build → Compile (ou pressione Ctrl+F9)
Aguarde a compilação
Opção B: Via Linha de Comand

o Instalador

build/windows/installer/CCL_Midas_Setup_1.1.1.exe