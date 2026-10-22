# zsh setup for Linux servers

One script that sets up a productive zsh shell for a single user on Debian/Ubuntu: Oh My Zsh, the Powerlevel10k prompt, autosuggestions, syntax highlighting, fuzzy search, and sensible history and completion defaults. Conda and `~/.local/bin` stay on the PATH.

## Features

| Keys / command | Does |
| --- | --- |
| type, then `→` | Accept the grey suggestion from history |
| `↑` / `↓` after typing | Search history for commands starting with that text |
| `Tab` | Menu completion, case-insensitive |
| `Ctrl+R` | Fuzzy-search all history (fzf) |
| `Ctrl+T` / `Alt+C` | Fuzzy-pick a file / fuzzy `cd` |
| `z proj` | Jump to your most-used folder matching "proj" (zoxide) |
| `Esc Esc` | Put `sudo` in front of the current command |
| `x file.tar.gz` | Extract any archive type |
| `ll`, `la`, `lt` | Listings with git status and a tree view (eza) |
| `ca env` / `cdx` | `conda activate` / `conda deactivate` |

Commands show green when valid and red when not found. The prompt shows git branch and status, the active conda env, failed exit codes, and the duration of slow commands.

## Install

### 1. Install packages (as root, once per server)

```bash
apt install -y zsh git curl fzf zoxide eza bat
```

`fzf`, `zoxide`, `eza` and `bat` are optional; their plugins and aliases turn on only if installed.

### 2. Run the script (as your normal user)

```bash
bash setup_zsh.sh
chsh -s $(command -v zsh)
```

Log out and back in. The Powerlevel10k wizard starts on first login; rerun it any time with `p10k configure`. An existing `~/.zshrc` is backed up as `~/.zshrc.bak.<date>`.

### 3. Install the prompt font (on your Mac)

Powerlevel10k needs the **MesloLGS NF** font to show icons; without it you see empty boxes.

```bash
cd ~/Library/Fonts
for f in "Regular" "Bold" "Italic" "Bold%20Italic"; do
  curl -fsSLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${f}.ttf"
done
```

Restart Positron (or your terminal app) afterwards.

### 4. Use the font in Positron

Press `Cmd+Shift+P`, choose **Preferences: Open User Settings (JSON)**, and add:

```json
"terminal.integrated.fontFamily": "MesloLGS NF"
```

Open a new terminal to see the change. For Mac Terminal: **Settings → Profiles → Text → Font → MesloLGS NF**.

## Notes

- Re-running `setup_zsh.sh` updates Oh My Zsh and the plugins, and rewrites `~/.zshrc` (with a backup).
- Conda is loaded from `/opt/miniforge3`. Change that path in `~/.zshrc` if your conda lives elsewhere.
- To go back to bash: `chsh -s /bin/bash`.

## Credits

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) · [Powerlevel10k](https://github.com/romkatv/powerlevel10k) · [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) · [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) · [zsh-completions](https://github.com/zsh-users/zsh-completions) · [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
