# Shared by bash and zsh: PATH, environment and aliases. Keep this file POSIX sh.
# Sourced by ~/.bashrc and ~/.zshrc. Machine-specific settings go in ~/.bashrc.local
# or ~/.zshrc.local, never here.

# --- PATH ----------------------------------------------------------------------
case ":${PATH}:" in
	*":$HOME/.local/bin:"*) ;;
	*) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# mise first, so the checks below can see the tools it installs
if command -v mise >/dev/null 2>&1; then
	if [ -n "${ZSH_VERSION-}" ]; then
		eval "$(mise activate zsh)"
	else
		eval "$(mise activate bash)"
	fi
fi

# --- Environment -------------------------------------------------------------
if command -v zed >/dev/null 2>&1; then
	export EDITOR="zed --wait"
else
	export EDITOR="nvim"
fi
export VISUAL="$EDITOR"
export PAGER="less"

# bat renders man pages and backs the `cat` alias below
export BAT_THEME="base16"
if command -v bat >/dev/null 2>&1; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# eza colours, Lumina dark roles as 24-bit codes. `reset` drops eza's per-file-type
# colours; every column eza still colours on its own is set below, so nothing falls back
# to the terminal's ANSI palette. Names in ink, directories in strong violet, executables
# in violet (runnable, as in the syntax highlighting), broken links in rose.
primary="38;2;237;236;240" secondary="38;2;164;163;171" disabled="38;2;110;109;119"
accent="38;2;173;129;254" accent_strong="38;2;232;222;255" danger="38;2;253;125;139"
EZA_COLORS="reset:di=1;${accent_strong}:ex=${accent}:fi=${primary}:bu=${primary}"
EZA_COLORS="${EZA_COLORS}:ln=${secondary}:or=${danger}:da=${secondary}:sn=${secondary}:sb=${secondary}"
EZA_COLORS="${EZA_COLORS}:uu=${secondary}:uR=${secondary}:un=${secondary}:gu=${secondary}:gR=${secondary}:gn=${secondary}"
EZA_COLORS="${EZA_COLORS}:ur=${secondary}:uw=${secondary}:ux=${secondary}:ue=${secondary}:gr=${secondary}:gw=${secondary}"
EZA_COLORS="${EZA_COLORS}:gx=${secondary}:tr=${secondary}:tw=${secondary}:tx=${secondary}:su=${secondary}:sf=${secondary}"
EZA_COLORS="${EZA_COLORS}:xa=${secondary}:xx=${disabled}"
EZA_COLORS="${EZA_COLORS}:ga=${secondary}:gm=${secondary}:gd=${secondary}:gv=${secondary}:gt=${secondary}"
EZA_COLORS="${EZA_COLORS}:gi=${disabled}:gc=${danger}"
export EZA_COLORS
unset primary secondary disabled accent accent_strong danger

# fzf, used by zoxide's `cdi` and plain `fzf`
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
# Lumina dark roles. Matches in violet; the current row on the shared row hover;
# multi-selected rows on the chosen-row wash. ASCII marks instead of fzf's default
# block glyphs.
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded --info=inline
  --pointer='>' --marker='+'
  --color=fg:#edecf0,bg:-1,gutter:-1,hl:#ad81fe,query:#edecf0
  --color=fg+:#edecf0,bg+:#2d2b36,hl+:#e8deff
  --color=selected-fg:#e8deff,selected-bg:#271a40
  --color=prompt:#ad81fe,pointer:#ad81fe,marker:#ad81fe
  --color=info:#a4a3ab,spinner:#a4a3ab,header:#a4a3ab,border:#474650"

# --- Aliases -----------------------------------------------------------------
alias path='printf "%s\n" "$PATH" | tr : "\n"' # PATH, one entry per line
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias grep="grep --color=auto"
alias ...="cd ../.."
alias ....="cd ../../.."

# Only replace core commands when the tool exists, so a missing tool never breaks ls or cat.
# la, ll and lt build on ls (bash and zsh expand aliases inside aliases), so the shared
# flags live once.
# --classify=always: in eza 0.23.5 the bare flag (auto) printed no marks even in a terminal.
# Side effect: piped ls output carries the marks too, so use `command ls` in pipes.
if command -v eza >/dev/null 2>&1; then
	alias ls="eza --icons --classify=always --group-directories-first --sort=extension"
	alias la="ls -a"
	alias ll="ls -al --header --git"
	alias lt="ls --tree --level=2"
fi
if command -v bat >/dev/null 2>&1; then
	alias cat="bat --paging=never"
fi
alias rg="rg --smart-case"

alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph --decorate --all"
alias ga="git add"
alias gaa="git add --all"
alias gcm="git commit -m"
alias gsw="git switch"
alias gswc="git switch -c"
alias gpl="git pull"
alias gps="git push"
alias gpsf="git push --force-with-lease"
