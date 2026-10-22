#!/usr/bin/env bash
# Oh My Zsh setup for one user (run as that user, NOT root):  bash setup_zsh.sh
# Needs (installed once by root):  apt install -y zsh git curl fzf zoxide eza bat
#
# You get:
#   - Powerlevel10k prompt (git status, conda env, exit codes, timing)
#   - Autosuggestions from history (press → to accept)
#   - Syntax highlighting while typing (red = command not found)
#   - Extra completions + case-insensitive, menu-style tab completion
#   - ↑/↓ searches history for what you've already typed
#   - fzf: Ctrl+R fuzzy history, Ctrl+T fuzzy file picker, Alt+C fuzzy cd
#   - zoxide: `z proj` jumps to your most-used matching folder
#   - sudo (Esc Esc adds sudo), extract (`x file.tar.gz`), colored man pages
#   - conda + ~/.local/bin (Claude Code) on PATH
set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Run as your normal user, not root."; exit 1; }
command -v zsh >/dev/null || { echo "zsh missing. As root: apt install -y zsh git curl fzf zoxide eza bat"; exit 1; }
command -v git >/dev/null || { echo "git missing. As root: apt install -y git"; exit 1; }

ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM="$ZSH_DIR/custom"

clone_or_update () {  # $1 = repo URL, $2 = target dir
  if [[ -d $2/.git ]]; then git -C "$2" pull --quiet --ff-only
  else git clone --quiet --depth=1 "$1" "$2"; fi
}

echo "== Oh My Zsh =="
clone_or_update https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"

echo "== Theme and plugins =="
clone_or_update https://github.com/romkatv/powerlevel10k.git          "$CUSTOM/themes/powerlevel10k"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git  "$CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting"
clone_or_update https://github.com/zsh-users/zsh-completions.git      "$CUSTOM/plugins/zsh-completions"
clone_or_update https://github.com/zsh-users/zsh-history-substring-search.git "$CUSTOM/plugins/zsh-history-substring-search"

echo "== ~/.zshrc =="
[[ -f $HOME/.zshrc ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%F-%H%M)"

cat > "$HOME/.zshrc" <<'ZSHRC'
# ---- Powerlevel10k instant prompt (keep at the top) -------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- PATH and conda ---------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
[[ -f /opt/miniforge3/etc/profile.d/conda.sh ]] && source /opt/miniforge3/etc/profile.d/conda.sh

# ---- Oh My Zsh --------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_UPDATE=false
zstyle ':omz:update' mode reminder        # ask before updating, never surprise
COMPLETION_WAITING_DOTS=true

plugins=(git sudo extract colored-man-pages)
(( $+commands[fzf] ))    && plugins+=(fzf)
(( $+commands[zoxide] )) && plugins+=(zoxide)
# Order matters: syntax highlighting, then history search, both last
plugins+=(zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)

fpath+=("$ZSH/custom/plugins/zsh-completions/src")
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

source "$ZSH/oh-my-zsh.sh"

# ---- History ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS \
       HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY

# ↑/↓ search history for what is already typed
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
[[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down

# ---- Completion -------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ---- Quality of life --------------------------------------------------------
setopt AUTO_CD            # type a folder name to cd into it
setopt INTERACTIVE_COMMENTS
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --git --group-directories-first'
  alias la='eza -lah --git --group-directories-first'
  alias lt='eza --tree --level=2'
else
  alias ll='ls -lh'; alias la='ls -lah'
fi
(( $+commands[batcat] )) && alias cat='batcat --paging=never --style=plain'
alias ca='conda activate'
alias cdx='conda deactivate'
alias df='df -h'
alias du1='du -h --max-depth=1 | sort -h'

# ---- Powerlevel10k config (run `p10k configure` to change) -------------------
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
ZSHRC

echo
echo "Done. Next:"
echo "  1. Make zsh your login shell:   chsh -s \$(command -v zsh)"
echo "  2. Log out and back in; the Powerlevel10k wizard starts the first time."
