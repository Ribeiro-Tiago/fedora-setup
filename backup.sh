#!/bin/bash

EXPORT_DIR="./backups"
TMPFILE=$(mktemp)

# Ensure dialog is installed
if ! command -v dialog &>/dev/null; then
  echo "Installing dialog..."
  sudo dnf install -y dialog jq
fi

mkdir -p "$EXPORT_DIR"

########################################
# Helper: merge or overwrite
########################################
function save_list {
  local FILE="$1"
  local TMP="$2"

  if [ -f "$FILE" ]; then
    dialog --yesno "File $FILE exists. Overwrite (No) or Merge (Yes)?" 8 60
    if [ $? -eq 0 ]; then
      # Merge with duplicates removed
      sort -u "$FILE" "$TMP" -o "$FILE"
  else
    # Overwrite
    mv "$TMP" "$FILE"
  fi
  else
    mv "$TMP" "$FILE"
  fi
}

########################################
# Backup DNF packages
########################################
function backup_dnf {
  TMP=$(mktemp)
  dnf repoquery --userinstalled --qf "%{name} \n" > "$TMP"
  save_list "$EXPORT_DIR/dnf-user.txt" "$TMP"
  echo "DNF packages backed up."
}

########################################
# Backup Flatpak apps
########################################
function backup_flatpak {
  TMP=$(mktemp)
  flatpak list --app --columns=application > "$TMP" 2>/dev/null
  save_list "$EXPORT_DIR/flatpak.txt" "$TMP"
  echo "Flatpak apps backed up."
}

########################################
# Backup enabled repos
########################################
function backup_repos {
  TMP=$(mktemp)
  dnf repolist --enabled | awk 'NR>1 {print $1}' > "$TMP"
  save_list "$EXPORT_DIR/repos.txt" "$TMP"
  echo "Enabled repositories backed up."
}

########################################
# Backup enabled services
########################################
function backup_services {
  TMP=$(mktemp)
  systemctl list-unit-files --state=enabled --no-pager | awk 'NR>1 {print $1}' > "$TMP"
  save_list "$EXPORT_DIR/services.txt" "$TMP"
  echo "Enabled services backed up."
}

########################################
# Backup /etc configuration
########################################
function backup_etc {
  dialog --yesno "Backup /etc configuration?" 8 60
  if [ $? -eq 0 ]; then
    sudo tar --exclude='/etc/ssl/private' \
              --exclude='/etc/pki/private' \
              -czf "$EXPORT_DIR/etc-config.tar.gz" /etc
    echo "/etc configuration backed up."
  fi
}

########################################
# Backup dotfiles
########################################
function backup_dotfiles {
  dialog --yesno "Backup dotfiles (~/.zshrc, ~/.npmrc, etc.)?" 8 60
  if [ $? -eq 0 ]; then
    DOTFILES=(
      ".zshrc"
      ".p10k.zsh"
      ".bashrc"
      ".bash_profile"
      ".profile"
      "alacritty.toml"
    )
    mkdir -p "$EXPORT_DIR/dotfiles"
    for file in "${DOTFILES[@]}"; do
      if [ -e "$HOME/$file" ]; then
        cp -r "$HOME/$file" "$EXPORT_DIR/dotfiles/"
      fi
    done
    echo "Dotfiles backed up."
  fi
}

########################################
# Main menu
########################################
OPTIONS=(
  "1" "Backup DNF packages"
  "2" "Backup Flatpak apps"
  "3" "Backup enabled repos"
  "4" "Backup enabled services"
  "5" "Backup /etc configuration"
  "6" "Backup dotfiles"
  "7" "Exit"
)

while true; do
  CHOICE=$(dialog --clear \
      --title "Fedora Backup Wizard" \
      --menu "Select what to backup:" 20 70 10 \
      "${OPTIONS[@]}" 2>&1 >/dev/tty)

  clear
  case $CHOICE in
    1) backup_dnf ;;
    2) backup_flatpak ;;
    3) backup_repos ;;
    4) backup_services ;;
    5) backup_etc ;;
    6) backup_dotfiles ;;
    7) break ;;
    *) break ;;
  esac
done

clear
echo "Backup complete. Files are in $EXPORT_DIR"