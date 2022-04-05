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
readonly OS_AGENT="os-agent_1.2.2_linux_aarch64.deb"
readonly OS_AGENT_PATH="https://github.com/home-assistant/os-agent/releases/download/1.2.2/"
readonly HA_INSTALLER="homeassistant-supervised.deb"
readonly HA_INSTALLER_PATH="https://github.com/home-assistant/supervised-installer/releases/latest/download/"
readonly REQUIREMENTS=(
  apparmor-utils
  apt-transport-https
  avahi-daemon
  ca-certificates
  curl
  dbus
  jq
  network-manager
  socat
  software-properties-common
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
  apt-get --allow-releaseinfo-change update
  apt-get install software-properties-common
  apt-get update
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
# Prepare upgrade
# ------------------------------------------------------------------------------
prepare_upgrade() {
  echo ""
  echo "Updating APT packages list and upgrading..."
  echo ""
  sudo apt update
  sudo apt upgrade -y
  echo ""
  echo "Ensure all requirements are installed..."
  echo ""
  sudo apt install gcc-8-base
}

# ------------------------------------------------------------------------------
# Replace Debian 10 Repositories With Debian 11 Ones
# ------------------------------------------------------------------------------
config_sources_list() {
  sudo rm /etc/apt/sources.list
  {
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free";
    echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free";
    echo "deb http://security.debian.org/debian-security bullseye-security main";
    echo "deb http://ftp.debian.org/debian bullseye-backports main contrib non-free";
  } >> "/etc/apt/sources.list"
}

# ------------------------------------------------------------------------------
# Upgrade final
# ------------------------------------------------------------------------------
upgrade_final() {
  echo ""
  echo "Upgrade to Debian 11..."
  echo ""
  sudo apt update
  sudo apt full-upgrade
  sudo systemctl enable systemd-resolved
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
  install_hassio
  prepare_upgrade
  config_sources_list
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
