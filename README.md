# Fedora setup

This repository contains scripts to **backup your Fedora system** and **restore it on a new machine**.

It includes:

- DNF packages
- Flatpak apps
- Enabled repositories
- Enabled services
- `/etc` configuration
- User dotfiles (`~/.config`, `~/.local`, `.bashrc`, `.zshrc`, etc.)

---

## 1. Requirements

Install required tools:

`sudo dnf install -y dialog jq flatpak`

---

## 2. Backup Your Current System

1. Copy `backup.sh` to your Fedora machine.
2. Make it executable: `chmod +x backup.sh`
3. Run the backup script: `./backup.sh`

- A **menu will appear** allowing you to select which components to backup.
- For each TXT or archive file, you can **overwrite or merge** with existing backups.
- Backup files are stored in `backups/`.

Files created:

backups/  
├── dnf-packages.txt  
├── flatpak.txt  
├── repos.txt  
├── services.txt  
├── etc-config.tar.gz  
└── dotfiles/  

---

## 3. Restore System on a New Machine

1. Copy `restore.sh` and the folder `./backups` to the new Fedora system.
2. Make the restore script executable: `chmod +x restore.sh`
3. Run the script:`./restore.sh`

- The wizard provides **interactive menus** for DNF packages, Flatpaks, services, dotfiles, and `/etc`.
- **All packages are pre-selected by default**, you can toggle which ones to install.
- The script will automatically **enable repositories** if required.
- DNF will handle dependencies automatically.

---

## Notes

- Restoring `/etc` overwrites system configuration — use with caution.
- Dotfiles overwrite your current files in your home directory.
- This setup can be extended to include `/opt` programs or additional manual binaries.
- Scripts are **idempotent** — you can run multiple times safely.

---

## Suggested Workflow

1. **Backup** old machine: `./backup.sh`
2. Copy `backups/` to new machine along with `restore.sh`.
3. **Restore** on new machine: ./restore.sh`
4. Enjoy your replicated Fedora environment!
