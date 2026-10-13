# ADR 0004: Shell configuration shared between bash and zsh

Date: 2026-10-09
Status: accepted

## Context

Atelier has to give the same interactive shell setup on Debian, WSL, AlmaLinux and macOS. Vannie uses zsh on macOS, while bash is the default shell on the Linux targets. The existing zsh configuration mixes portable settings (aliases, environment variables, `PATH`) with zsh-only features (plugins, history options, keybindings, completion). It loads three zsh plugins from Homebrew. Oh My Zsh is installed on the current machine but the configuration does not use it.

The prompt is drawn by Starship, which supports both shells from one configuration file.

## Decision

- One POSIX file, `~/.config/shell/common.sh`, holds aliases, environment variables, `PATH` and the mise activation. Both `.bashrc` and `.zshrc` source it.
- zsh-only settings (plugins, history, options, keybindings, completion) stay in `.zshrc`.
- `.bashrc` starts from the distribution's stock file and appends Atelier's lines, so distro defaults such as Debian's completion setup are kept.
- Starship draws the prompt in both shells from one `~/.config/starship.toml`. Starship and the other cross-platform CLI tools (`bat`, `fd`, `eza`, `fzf`, `zoxide`, `neovim`) are installed through mise, not the per-OS package lists, so every platform has one install path and the original binary names.
- zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`) are fetched by chezmoi's external-files mechanism and sourced directly. No plugin manager and no Oh My Zsh.
- Every tool activation line is guarded by a "command exists" check, so a shell still opens when a tool is missing.
- Each rc file ends by sourcing an untracked local file (`~/.zshrc.local`, `~/.bashrc.local`) if it exists. Machine-specific and work-related settings go there.
- zsh is installed on the Linux targets as well as macOS. Atelier does not change the login shell.

## Alternatives considered

- **A zsh plugin manager or Oh My Zsh.** Rejected: it adds a second update mechanism next to chezmoi, and Oh My Zsh's auto-update would drift from chezmoi's source state. Three plugins do not need a manager.
- **Separate per-shell files with duplicated aliases.** Rejected: every alias would have to be changed in two places, and the two shells would drift.
- **A native shell per OS (bash only on Linux, zsh only on macOS).** Rejected: it is simpler and closer to platform defaults, but Linux sessions, WSL above all, would lose autosuggestions, syntax highlighting, substring history search and zsh completion.

## Consequences

Easier: aliases and environment are changed in one place, both shells look the same, and a missing tool never breaks shell startup.

Harder: `common.sh` must stay POSIX, so zsh-only syntax cannot be used there. The plugins track their `master` branches with a weekly refresh, so an upstream change can arrive without review. Tools installed through mise are absent until mise has run, and their aliases are skipped until then. zsh and its plugins are installed on Linux even when bash stays the login shell.
