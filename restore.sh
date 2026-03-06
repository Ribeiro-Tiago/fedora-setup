#!/bin/bash

EXPORT_DIR="./backups"

# Ensure dialog exists
if ! command -v dialog &>/dev/null; then
  echo "Installing dialog and jq..."
  sudo dnf install -y dialog jq
fi

TMPFILE=$(mktemp)

########################################
# Utility Functions
########################################

function check_file {
  if [ ! -f "$1" ]; then
    echo "File $1 not found. Skipping."
    return 1
  fi
  return 0
}

function enable_repos {
  check_file "$EXPORT_DIR/repos.txt" || return
  echo "Enabling repositories..."
  grep -E '^[a-zA-Z0-9]' "$EXPORT_DIR/repos.txt" | awk '{print $1}' | while read repo; do
    if ! dnf repolist --enabled | grep -q "$repo"; then
      echo "Enabling repo: $repo"
      sudo dnf config-manager --set-enabled "$repo" 2>/dev/null
    fi
  done
}

########################################
# Interactive DNF Packages
########################################

function select_packages {
  check_file "$EXPORT_DIR/dnf-user.txt" || return
  local PKGS=()
  while read pkg; do
    PKGS+=("$pkg" "$pkg" "on")
  done < "$EXPORT_DIR/dnf-user.txt"

  dialog --checklist \
  "Select DNF packages to install (use SPACE to toggle, ENTER to confirm):" \
  25 80 20 \
  "${PKGS[@]}" 2> "$TMPFILE"
}

function install_packages {
  local CHOICES
  CHOICES=$(cat "$TMPFILE")
  [ -z "$CHOICES" ] && return
  echo "Installing DNF packages..."
  sudo dnf install -y $CHOICES
}

########################################
# Interactive Flatpak Packages
########################################

function select_flatpaks {
  check_file "$EXPORT_DIR/flatpak.txt" || return
  local FP=()
  while read pkg; do
    FP+=("$pkg" "$pkg" "on")
  done < "$EXPORT_DIR/flatpak.txt"

  dialog --checklist \
  "Select Flatpak apps to install:" \
  25 80 20 \
  "${FP[@]}" 2> "$TMPFILE"
}

function install_flatpaks {
  local CHOICES
  CHOICES=$(cat "$TMPFILE")
  [ -z "$CHOICES" ] && return
  echo "Installing Flatpak apps..."
  for app in $CHOICES; do
    flatpak install -y flathub "$app"
  done
}

########################################
# Interactive Services
########################################

function enable_services {
  check_file "$EXPORT_DIR/services.txt" || return
  local SVC=()
  awk '{print $1}' "$EXPORT_DIR/services.txt" | while read svc; do
    SVC+=("$svc" "$svc" "on")
  done

  dialog --checklist \
  "Select systemd services to enable:" \
  25 80 20 \
  "${SVC[@]}" 2> "$TMPFILE"

  for svc in $(cat "$TMPFILE"); do
    sudo systemctl enable "$svc"
  done
}

########################################
# Restore /etc Configuration
########################################

function restore_etc {
  check_file "$EXPORT_DIR/etc-config.tar.gz" || return
  dialog --yesno "Restore /etc configuration? (will overwrite existing configs)" 8 60
  if [ $? -eq 0 ]; then
    echo "Restoring /etc..."
    sudo tar -xzf "$EXPORT_DIR/etc-config.tar.gz" -C /
  fi
}

########################################
# Restore Dotfiles
########################################

function restore_dotfiles {
  [ ! -d "$EXPORT_DIR/dotfiles" ] && return
  dialog --yesno "Restore your dotfiles (~/.config, ~/.local, etc.)?" 8 60
  if [ $? -eq 0 ]; then
    cp -r "$EXPORT_DIR/dotfiles/"* "$HOME/"
  fi
}

########################################
# Main Menu (TUI Categories)
########################################

function main_menu {
  OPTIONS=(
    "1" "DNF Packages"
    "2" "Flatpak Apps"
    "3" "Enable Services"
    "4" "Restore /etc"
    "5" "Restore Dotfiles"
    "6" "Exit"
  )

  while true; do
    CHOICE=$(dialog --clear \
    --title "Fedora Setup Wizard" \
    --menu "Select category to configure:" 20 70 10 \
    "${OPTIONS[@]}" 2>&1 >/dev/tty)

    clear
    case $CHOICE in
      1)
        select_packages
        install_packages
        ;;
      2)
        select_flatpaks
        install_flatpaks
        ;;
      3)
        enable_services
        ;;
      4)
        restore_etc
        ;;
      5)
        restore_dotfiles
        ;;
      6)
        break
        ;;
      *)
        break
        ;;
    esac
  done
}

########################################
# Script Start
########################################

clear
echo "Starting Fedora Setup Wizard..."
enable_repos
main_menu
clear
echo "Fedora setup wizard complete!"