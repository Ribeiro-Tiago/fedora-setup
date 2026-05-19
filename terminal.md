## Alacritty

### Installation 

[Done via Discover](appstream://org.alacritty.alacritty)

### Make default terminal 

Available as a system terminal

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
sudo update-alternatives --config x-terminal-emulator
```

“Open in Terminal” behavior (file manager)

```bash
gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
```

### Configs

Append to `~/.zshrc`

```bash
##############################
#   Alacritty Keybindings    #
##############################

# 1️⃣ Use Emacs keybindings
bindkey -e

# 2️⃣ Smarter word boundaries
autoload -Uz select-word-style
select-word-style bash       # treats / . - as separators
zstyle ':zle:*' word-chars ''

# 3️⃣ Cursor movement (word by word)
bindkey '^[[1;5D' backward-word   # Ctrl + Left
bindkey '^[[1;5C' forward-word    # Ctrl + Right

# 4️⃣ Backspace / Delete single character
bindkey '^?' backward-delete-char # Backspace
bindkey '^H' backward-delete-char # Alt Backspace compatibility
bindkey '^[[3~' delete-char       # Delete key

# 5️⃣ Word deletion
# Ctrl + Backspace → delete previous word
bindkey '^H' backward-kill-word

# Ctrl + Delete → delete next word
bindkey '^[[3;5~' kill-word

# 6️⃣ Optional: home/end to line start/end
bindkey '^[[H' beginning-of-line   # Home
bindkey '^[[F' end-of-line         # End

#################################
#   END Alacritty Keybindings   #
#################################
``` 