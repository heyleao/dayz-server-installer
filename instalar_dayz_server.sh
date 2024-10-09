#!/bin/bash

# Função para detectar o usuário original (que não seja root)
function detectar_usuario_linux() {
  if [ "$SUDO_USER" ]; then
    your_username=$SUDO_USER
  else
    your_username=$(whoami)
  fi
  echo "Usuário detectado: $your_username"
}

# Função para solicitar as credenciais de login do Steam
function solicitar_usuario_steam() {
  echo "Digite o login do Steam:"
  read -r your_login
}

# Função para instalar dependências conforme a distribuição Linux
function instalar_dependencias() {
  echo "Instalando dependências..."
  if [ -f /etc/debian_version ]; then
    sudo apt-get update && sudo apt-get install -y lib32gcc-s1 curl
  elif [ -f /etc/redhat-release ]; then
    sudo yum install -y glibc.i686 libstdc++.i686 curl
  elif [ -f /etc/arch-release ]; then
    sudo pacman -Syy glibc lib32-glibc curl
  else
    echo "Distribuição Linux não suportada."
    exit 1
  fi
}

# Função para baixar e instalar o SteamCMD
function instalar_steamcmd() {
  echo "Instalando SteamCMD..."
  sudo -u $your_username mkdir -p /home/$your_username/servers/steamcmd && cd /home/$your_username/servers/steamcmd || exit
  sudo -u $your_username curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo -u $your_username tar zxvf -
}

# Função para baixar e instalar o servidor DayZ (com ou sem mods)
function instalar_servidor_dayz() {
  echo "Deseja instalar o servidor DayZ com mods? (s/n)"
  read -r com_mods

  if [ "$com_mods" == "s" ]; then
    echo "Digite os IDs dos mods separados por vírgula (exemplo: 1559212036,1564026768):"
    read -r mods_input

    # Converter a lista de mods em um array
    IFS=',' read -r -a mods_array <<< "$mods_input"

    echo "Instalando servidor DayZ com mods..."
    mod_install_cmd="sudo -u $your_username /home/$your_username/servers/steamcmd/steamcmd.sh +force_install_dir /home/$your_username/servers/dayz-server/ +login $your_login +app_update 223350"

    # Adicionar o comando para cada mod fornecido
    for mod_id in "${mods_array[@]}"; do
      mod_install_cmd+=" +workshop_download_item 221100 $mod_id"
    done

    mod_install_cmd+=" +quit"
    
    # Executar o comando de instalação dos mods
    eval "$mod_install_cmd"

    # Criar links simbólicos para os mods
    for mod_id in "${mods_array[@]}"; do
      sudo -u $your_username ln -s /home/$your_username/servers/dayz-server/steamapps/workshop/content/221100/$mod_id /home/$your_username/servers/dayz-server/$mod_id
      sudo -u $your_username ln -s /home/$your_username/servers/dayz-server/steamapps/workshop/content/221100/$mod_id/keys/* /home/$your_username/servers/dayz-server/keys/
    done
  else
    echo "Instalando servidor DayZ sem mods..."
    sudo -u $your_username /home/$your_username/servers/steamcmd/steamcmd.sh +force_install_dir /home/$your_username/servers/dayz-server/ +login "$your_login" +app_update 223350 +quit
  fi
}

# Função para criar o script de atualização do servidor
function criar_script_atualizacao() {
  echo "Criando script de atualização..."
  cat <<EOL >/home/$your_username/servers/dayz-server/update.sh
#!/bin/bash
/home/$your_username/servers/steamcmd/steamcmd.sh +force_install_dir /home/$your_username/servers/dayz-server/ +login $your_login +app_update 223350 +quit
EOL
  sudo chmod +x /home/$your_username/servers/dayz-server/update.sh
}

# Função para configurar o serviço systemd para o servidor DayZ
function configurar_systemd() {
  echo "Configurando serviço DayZ no systemd..."

  # Criar diretório de logs
  sudo mkdir -p /var/log/dayz-server
  sudo chown "$your_username":users /var/log/dayz-server

  cat <<EOL | sudo tee /etc/systemd/system/dayz-server.service
[Unit]
Description=DayZ Dedicated Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
ExecStartPre=/home/$your_username/servers/dayz-server/update.sh
ExecStart=/home/$your_username/servers/dayz-server/DayZServer -config=serverDZ.cfg -port=2301 "-mod=$(IFS=';'; echo "${mods_array[*]}")" -BEpath=battleye -profiles=profiles -dologs -adminlog -netlog -freezecheck
WorkingDirectory=/home/$your_username/servers/dayz-server/
LimitNOFILE=100000
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s INT \$MAINPID
User=$your_username
Group=users
Restart=on-failure
RestartSec=5s
StandardOutput=append:/var/log/dayz-server/output.log
StandardError=append:/var/log/dayz-server/error.log

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable dayz-server
  echo "Serviço DayZ configurado com sucesso."
}

# Função para ajustar permissões do diretório do servidor
function ajustar_permissoes() {
  echo "Ajustando permissões para o usuário $your_username..."
  sudo chown -R "$your_username":users /home/"$your_username"/servers
  sudo chmod -R 755 /home/"$your_username"/servers
}

# Função principal
function main() {
  detectar_usuario_linux
  solicitar_usuario_steam
  instalar_dependencias
  instalar_steamcmd
  instalar_servidor_dayz
  criar_script_atualizacao
  configurar_systemd
  ajustar_permissoes
  echo "Servidor DayZ configurado com sucesso!"
  echo "Você pode iniciar o servidor com o comando: sudo systemctl start dayz-server"
  echo "Use 'tail -f /var/log/dayz-server/output.log' para acompanhar os logs do servidor."
}

# Executar a função principal
main
