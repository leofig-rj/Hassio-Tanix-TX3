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
# SCRIPT LOGIC
# ==============================================================================

# ------------------------------------------------------------------------------
# Initial preparations
# ------------------------------------------------------------------------------
initial_preparations() {
  echo ""
  echo "Updating APT packages list and upgrading..."
  echo ""
  apt-get --allow-releaseinfo-change update
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
  echo ""
  echo "Replacing Debian 10 Repositories With Debian 11 Ones..."
  echo ""
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
  echo "sudo apt full-upgrade -y"
  echo "sudo systemctl enable systemd-resolved"
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
  initial_preparations
  config_sources_list
  upgrade_final

  # Friendly closing message
  echo "======================================================================="
  echo "Debian 11 installed."
  echo "Verify the currently installed Debian version by reviewing below:"
  
  cat /etc/os-release
  
  exit 0
}
main
