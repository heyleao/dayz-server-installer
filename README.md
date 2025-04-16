# Script de Instalação e Configuração do Servidor DayZ

Este script Bash automatiza a instalação e configuração de um servidor dedicado DayZ em sistemas Linux, com suporte opcional para mods. Ele abrange diversas etapas, como a detecção do usuário, instalação de dependências, download do SteamCMD, instalação do servidor (com ou sem mods), criação de um script de atualização e configuração de um serviço systemd para facilitar o gerenciamento do servidor.

---

## Visão Geral

O script executa as seguintes tarefas:
- **Detecção do Usuário:** Verifica se o script está sendo executado com privilégios de sudo e identifica o usuário original.
- **Solicitação de Credenciais do Steam:** Pede o login do Steam para autenticação no SteamCMD.
- **Instalação de Dependências:** Detecta a distribuição Linux (Debian, Red Hat ou Arch) e instala os pacotes necessários.
- **Instalação do SteamCMD:** Baixa e extrai o SteamCMD na pasta do usuário.
- **Instalação do Servidor DayZ:** Permite a instalação com ou sem mods. Se a opção de mods for selecionada, o script solicita os IDs dos mods e os instala.
- **Criação do Script de Atualização:** Gera um script que facilita futuras atualizações do servidor.
- **Configuração do Serviço systemd:** Cria e configura um serviço systemd para o DayZ, permitindo o gerenciamento do servidor (iniciar, parar e reiniciar).
- **Ajuste de Permissões:** Define as permissões corretas para os diretórios utilizados.

---

## Pré-Requisitos

- **Sistema Operacional:** Distribuição Linux compatível (Debian/Ubuntu, Red Hat/CentOS ou Arch Linux). Outras distribuições podem necessitar de adaptações.
- **Permissões:** Acesso root ou privilégios sudo para instalação de pacotes e criação/alteração de diretórios e arquivos.
- **Internet:** Conexão ativa para download de dependências, SteamCMD e arquivos do DayZ.
- **Conta Steam:** Uma conta Steam válida para login no SteamCMD.

---

## Dependências Instalação

O script instala diferentes pacotes dependendo da distribuição Linux:

- **Debian/Ubuntu:**  
  - Atualiza os repositórios com `apt-get update`
  - Instala: `lib32gcc-s1` e `curl`

- **Red Hat/CentOS:**  
  - Instala: `glibc.i686`, `libstdc++.i686` e `curl`

- **Arch Linux:**  
  - Sincroniza os repositórios com `pacman -Syy`
  - Instala: `glibc`, `lib32-glibc` e `curl`

Se a distribuição não for suportada, o script encerra com uma mensagem de erro.

---

## Como Utilizar

1. **Preparação:**
   - Certifique-se de ter acesso root ou privilégios sudo.
   - Transfira o script para o seu sistema Linux e dê permissão de execução:
     ```bash
     chmod +x nome_do_script.sh
     ```

2. **Execução do Script:**
   - Execute o script:
     ```bash
     ./nome_do_script.sh
     ```

3. **Interação com o Script:**
   - **Detecção do Usuário:** O script automaticamente detecta o usuário (ou usuário original via sudo).
   - **Login do Steam:** Será solicitado que você informe o login do Steam para autenticação no SteamCMD.
   - **Instalação com ou sem Mods:**  
     - O script perguntará se você deseja instalar o servidor DayZ com mods.
     - Caso opte por instalar com mods, insira os IDs dos mods separados por vírgula (exemplo: `1559212036,1564026768`).

4. **Finalização:**
   - Após concluir as etapas, o script configura um serviço systemd e ajusta as permissões dos arquivos e diretórios criados.
   - Para iniciar o servidor, utilize o comando:
     ```bash
     sudo systemctl start dayz-server
     ```
   - Para visualizar os logs do servidor:
     ```bash
     tail -f /var/log/dayz-server/output.log
     ```

---

## Estrutura do Script

### Principais Funções

- **detectar_usuario_linux:**  
  Detecta o usuário que está executando o script, considerando o uso do `sudo`.

- **solicitar_usuario_steam:**  
  Solicita o login do Steam, que será usado para autenticação no SteamCMD.

- **instalar_dependencias:**  
  Verifica a distribuição Linux e instala os pacotes necessários (dependências) para o funcionamento correto do servidor.

- **instalar_steamcmd:**  
  Cria o diretório para o SteamCMD e baixa a ferramenta usando `curl` e `tar`.

- **instalar_servidor_dayz:**  
  Instala o servidor DayZ. Caso seja escolhida a instalação com mods, processa os IDs dos mods informados, realiza o download e cria links simbólicos para os diretórios dos mods.

- **criar_script_atualizacao:**  
  Gera um script de atualização que utiliza o SteamCMD para atualizar o servidor DayZ facilmente.

- **configurar_systemd:**  
  Cria um arquivo de serviço para o systemd, configurando os parâmetros necessários para iniciar e gerenciar o servidor DayZ automaticamente.

- **ajustar_permissoes:**  
  Ajusta a propriedade e as permissões dos diretórios de instalação para garantir que o usuário configurado possa operar o servidor corretamente.

### Sequência de Execução

1. Detecta o usuário original (via `detectar_usuario_linux`).
2. Solicita as credenciais do Steam (via `solicitar_usuario_steam`).
3. Instala as dependências conforme a distribuição (via `instalar_dependencias`).
4. Instala o SteamCMD (via `instalar_steamcmd`).
5. Instala o servidor DayZ, com a opção de incluir mods (via `instalar_servidor_dayz`).
6. Cria um script de atualização (via `criar_script_atualizacao`).
7. Configura o serviço systemd (via `configurar_systemd`).
8. Ajusta as permissões dos diretórios (via `ajustar_permissoes`).

---

## Observações Adicionais

- **Personalização:**  
  É possível modificar os diretórios, parâmetros de instalação e configuração do serviço systemd conforme as necessidades do ambiente.

- **Suporte a Outras Distribuições:**  
  O script atualmente suporta apenas Debian/Ubuntu, Red Hat/CentOS e Arch Linux. Para outras distribuições, adapte os comandos de instalação de dependências.

- **Segurança:**  
  Garanta que as permissões e a propriedade dos diretórios estejam corretamente configuradas para evitar problemas de segurança.

- **Testes:**  
  Execute o script em um ambiente de testes antes de utilizar em produção, especialmente se forem feitas modificações no script.

---

## Licença

Distribua e modifique este script conforme necessário. Se desejar, adicione termos de licença específicos ao ambiente de sua organização.

---

## Contato

Para dúvidas, sugestões ou suporte, entre em contato com o mantenedor do script ou com a equipe responsável pelo ambiente do servidor.

---
