#######################################################################
#######################################################################
##                                                                   ##
## THIS SCRIPT SHOULD ONLY BE RUN ON A TANIX TX3 BOX RUNNING ARMBIAN ##
##                                                                   ##
#######################################################################
#######################################################################
set -o errexit  # Exit script when a command exits with non-zero status
set -o errtrace # Exit on error inside any functions or sub-shells
set -o nounset  # Exit script on use of an undefined variable
set -o pipefail # Return exit status of the last command in the pipe that failed

# ==============================================================================
# GLOBALS
# ==============================================================================
readonly HOSTNAME="homeassistant"

# ==============================================================================
# SCRIPT LOGIC
# ==============================================================================

# ------------------------------------------------------------------------------
# Ensures the hostname of the Pi is correct.
# ------------------------------------------------------------------------------
update_hostname() {
    hostname
    sudo hostname homeassistant
    hostname "${HOSTNAME}"
    
    echo ""
    echo "O nome do host será alterado na próxima reinicialização para: ${HOSTNAME}"
    echo ""

}

# ------------------------------------------------------------------------------
# Repair apparmor and cgroups
# ------------------------------------------------------------------------------
repair_apparmor_and_cgroups() {
    echo ""
    echo "Resolvendo os alertas de apparmor e cgroups"
    echo ""
    
  if ! grep -q "cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=false apparmor=1 security=apparmor" "/boot/uEnv.txt"; then
    sed -i 's/APPEND.*/& cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=false apparmor=1 security=apparmor/g' /boot/uEnv.txt
  fi
}



# ------------------------------------------------------------------------------
# Armbian update
# ------------------------------------------------------------------------------
update_armbian() {
    echo ""
    echo "Atualizando armbian"
    echo ""
    
    armbian-update
}

# ------------------------------------------------------------------------------
# change operating system
# ------------------------------------------------------------------------------
update_operating_system() {
    echo ""
    echo "Resolvendo o alerta de sistema incompatível..."
    echo ""
    
    sed -i 's#Armbian 24.02.0-trunk Bullseye#Debian GNU/Linux 12 (bullseye)#g'  /etc/os-release
#    sed -i 's#Armbian 23.08.0-trunk Bullseye#Debian GNU/Linux 11 (bullseye)#g'  /etc/os-release
#    sed -i 's#Armbian 23.02.0-trunk Bullseye#Debian GNU/Linux 11 (bullseye)#g'  /etc/os-release
#    sed -i 's/Armbian 23.02.0-trunk Bullseye/Debian GNU/Linux 11 (bullseye)/g' etc/os-release
}

# ------------------------------------------------------------------------------
# Installs dependences
# ------------------------------------------------------------------------------
install_dependences() {
  echo ""
  echo "Instalando dependencias..."
  echo ""
  
  apt install \
  apparmor \
  jq \
  wget \
  curl \
  udisks2 \
  libglib2.0-bin \
  network-manager \
  dbus \
  lsb-release \
  systemd-journal-remote -y
  smbclient -y
#  systemd-resolved -y
}

# ------------------------------------------------------------------------------
# Installs the Docker engine
# ------------------------------------------------------------------------------
install_docker() {
  echo ""
  echo "Instalando Docker..."
  echo ""
  
#  curl -fsSL https://get.docker.com | sh
  curl -fsSL get.docker.com | sh
}

# ------------------------------------------------------------------------------
# Install os-agents
# ------------------------------------------------------------------------------
install_osagents() {
  echo ""
  echo "Instalando os agentes de instalação do Homeassistant..."
  echo ""
  
#  wget https://github.com/home-assistant/os-agent/releases/download/1.4.1/os-agent_1.4.1_linux_aarch64.deb
  wget https://github.com/home-assistant/os-agent/releases/download/1.5.1/os-agent_1.5.1_linux_aarch64.deb
  sudo dpkg -i os-agent_1.5.1_linux_aarch64.deb
#  wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb
#  sudo dpkg -i os-agent_1.6.0_linux_aarch64.deb
  gdbus introspect --system --dest io.hass.os --object-path /io/hass/os
  systemctl status haos-agent --no-pager

#  wget https://github.com/home-assistant/os-agent/releases/download/1.4.1/os-agent_1.4.1_linux_aarch64.deb
#  sudo dpkg -i os-agent_1.4.1_linux_aarch64.deb
#  gdbus introspect --system --dest io.hass.os --object-path /io/hass/os
}

# ------------------------------------------------------------------------------
# Installs and starts Home Assistant
# ------------------------------------------------------------------------------
install_hassio() {
  echo ""
  echo "Instalando o Home Assistant..."
  echo ""
  
#  apt-get update
#  apt-get install udisks2 wget -y
#  wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
#  sudo dpkg -i homeassistant-supervised.deb

  apt-get update
  wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
  sudo dpkg -i --ignore-depends=systemd-resolved homeassistant-supervised.deb

}

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
  # Are we root?
  if [[ $EUID -ne 0 ]]; then
    echo "Este script tem que ser executado com o user root."
    echo "Faça login com o user root e tente novamente:"
    echo "  sudo su"
    exit 1
  fi

  # Install ALL THE THINGS!
  #update_hostname
  update_armbian
  #repair_apparmor_and_cgroups
  #update_operating_system
  #install_dependences
  #install_docker
  #install_osagents
  #install_hassio

  # Friendly closing message
  ip_addr=$(hostname -I | cut -d ' ' -f1)
  echo "======================================================================="
  echo "Agora está instalando o Home Assistant."
  echo "Este processo demora em torno de 20 minutes. Abra o seguinte link:"
  echo "http://${HOSTNAME}.local:8123/ no seu browser"
  echo "para carregar o home assistant."
  echo "Se o link acima não funcionar, tente o seguinte link http://${ip_addr}:8123/"
  echo "Aproveite o seu home assistant :)"

  exit 0
}
main
