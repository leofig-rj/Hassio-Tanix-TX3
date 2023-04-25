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
readonly HOSTNAME="armhassio"
readonly OS_AGENT="os-agent_1.5.1_linux_aarch64.deb"
readonly OS_AGENT_PATH="https://github.com/home-assistant/os-agent/releases/download/1.5.1/"
readonly HA_INSTALLER="homeassistant-supervised.deb"
readonly HA_INSTALLER_PATH="https://github.com/home-assistant/supervised-installer/releases/latest/download/"
readonly REQUIREMENTS=(
  apparmor
  udisks2
  socat
  apt-transport-https
  ca-certificates
  curl
  dbus
  jq
  libglib2.0-bin
  lsb-release
  network-manager
  software-properties-common
  wget
  systemd-journal-remote -y
)

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
    echo "Hostname will be changed on next reboot: ${HOSTNAME}"
    echo ""
  fi
}

# ------------------------------------------------------------------------------
# Installs all required software packages and tools
# ------------------------------------------------------------------------------
install_requirements() {
  echo ""
  echo "Updating APT packages list..."
  echo ""
  echo ""
  echo "Ensure all requirements are installed..."
  echo ""
  apt-get install -y "${REQUIREMENTS[@]}"
}

# ------------------------------------------------------------------------------
# Installs the Docker engine
# ------------------------------------------------------------------------------
install_docker() {
  echo ""
  echo "Installing Docker..."
  echo ""
  curl -fsSL https://get.docker.com | sh
}

# ------------------------------------------------------------------------------
# Configure hosts to avoid error installing Hass.io
# ------------------------------------------------------------------------------
config_hosts() {
  {
    echo "140.82.121.34 ghcr.io";
    echo "185.199.108.154 pkg-containers.githubusercontent.com";
  } >> "/etc/hosts"
}

# ------------------------------------------------------------------------------
# Installs and starts Hass.io
# ------------------------------------------------------------------------------
install_hassio() {
  echo ""
  echo "Installing Home Assistant..."
  echo ""
  apt-get update
  apt-get install udisks2 wget -y
  wget "${OS_AGENT_PATH}${OS_AGENT}"
  dpkg -i "${OS_AGENT}"
  wget "${HA_INSTALLER_PATH}${HA_INSTALLER}"
  dpkg -i "${HA_INSTALLER}"
}

# ------------------------------------------------------------------------------
# Configure network-manager to disable random MAC-address on Wi-Fi
# ------------------------------------------------------------------------------
config_network_manager() {
  {
    echo -e "\n[device]";
    echo "wifi.scan-rand-mac-address=no";
    echo -e "\n[connection]";
    echo "wifi.clone-mac-address=preserve";
  } >> "/etc/NetworkManager/NetworkManager.conf"
}

# ------------------------------------------------------------------------------
# Upgrade final
# ------------------------------------------------------------------------------
upgrade_final() {
  echo ""
  echo "Upgrade..."
  echo ""
  sudo apt update
  sudo apt upgrade -y
}

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
  # Are we root?
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    echo "Please try again after running:"
    echo "  sudo su"
    exit 1
  fi

  # Install ALL THE THINGS!
  update_hostname
  install_requirements
  config_network_manager
  install_docker
  config_hosts
  install_hassio
  upgrade_final

  # Friendly closing message
  ip_addr=$(hostname -I | cut -d ' ' -f1)
  echo "======================================================================="
  echo "Hass.io is now installing Home Assistant."
  echo "This process may take up to 20 minutes. Please visit:"
  echo "http://${HOSTNAME}.local:8123/ in your browser and wait"
  echo "for Home Assistant to load."
  echo "If the previous URL does not work, please try http://${ip_addr}:8123/"

  exit 0
}
main
