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
readonly OS_VERSION_FROM="Armbian-unofficial 25.05.0-trunk bookworm"
readonly OS_VERSION_TO="Debian GNU\/Linux 12 (bookworm)"
readonly OS_AGENT="os-agent_1.7.2_linux_aarch64.deb"
readonly OS_AGENT_PATH="https://github.com/home-assistant/os-agent/releases/download/1.7.2/"
readonly HA_INSTALLER="homeassistant-supervised.deb"
readonly HA_INSTALLER_PATH="https://github.com/home-assistant/supervised-installer/releases/latest/download/"

# ==============================================================================
# SCRIPT LOGIC
# ==============================================================================

# ------------------------------------------------------------------------------
# Ensures the hostname of the Pi is correct.
# ------------------------------------------------------------------------------
update_hostname() {

  old_hostname=$(< /etc/hostname)
  if [[ "${old_hostname}" != "${HOSTNAME}" ]]; then
    sed -i "s/${old_hostname}/${HOSTNAME}/g" /etc/hostname
    sed -i "s/${old_hostname}/${HOSTNAME}/g" /etc/hosts
    hostname "${HOSTNAME}"
    echo ""
    echo "O nome do host será alterado na próxima reinicialização para: ${HOSTNAME}"
    echo ""
  fi
    
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
    
    # Atualizo somente na primeira linha -> 1s
    sed -i "1s/${OS_VERSION_FROM}/${OS_VERSION_TO}/g" /etc/os-release
    
}

# ------------------------------------------------------------------------------
# Installs dependences
# ------------------------------------------------------------------------------
install_dependences() {
  echo ""
  echo "Instalando dependencias..."
  echo ""
  
  apt-get update
  
  apt install \
  jq \
  wget \
  curl \
  network-manager \
  udisks2 -y \
  libglib2.0-bin \
  dbus \
  lsb-release \
  apparmor -y \
  systemd-journal-remote -y \
  cifs-utils -y \
  smbclient -y \
  systemd-timesyncd \
  bluez \
  systemd-resolved -y
}

# ------------------------------------------------------------------------------
# Installs the Docker engine
# ------------------------------------------------------------------------------
install_docker() {
  echo ""
  echo "Instalando Docker..."
  echo ""
  
  curl -fsSL get.docker.com | sh
}

# ------------------------------------------------------------------------------
# Install os-agents
# ------------------------------------------------------------------------------
install_osagents() {
  echo ""
  echo "Instalando os agentes de instalação do Homeassistant..."
  echo ""
  
#  wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb
#  sudo dpkg -i os-agent_1.6.0_linux_aarch64.deb

  wget "${OS_AGENT_PATH}${OS_AGENT}"
  dpkg -i "${OS_AGENT}"
  
  gdbus introspect --system --dest io.hass.os --object-path /io/hass/os
  systemctl status haos-agent --no-pager

}

# ------------------------------------------------------------------------------
# Installs and starts Home Assistant
# ------------------------------------------------------------------------------
install_hassio() {
  echo ""
  echo "Instalando o Home Assistant..."
  echo ""
  
  apt-get update
  
  wget "${HA_INSTALLER_PATH}${HA_INSTALLER}"
  dpkg -i --ignore-depends=systemd-resolved "${HA_INSTALLER}"

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
  update_hostname
  update_armbian
  repair_apparmor_and_cgroups
  update_operating_system
  install_dependences
  install_docker
  install_osagents
  install_hassio

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
