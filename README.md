# Lumina Atelier

A quiet, familiar room on a fresh machine.

Configuration that takes a fresh machine to a working development setup with one command.

## What it does

Atelier is a configuration repository for [chezmoi](https://www.chezmoi.io). It installs system packages, installs runtimes and command-line tools through [mise](https://mise.jdx.dev), and writes shell, prompt and Git configuration into the home directory. It has no installer of its own: chezmoi, mise and the system package manager do the work.

Atelier works today on Debian, including Debian on WSL, and on AlmaLinux 9. macOS and Windows are planned.

## Before you run it

When it runs, Atelier:

- Replaces these files in your home directory: `~/.bashrc`, `~/.zshrc`, `~/.gitconfig`, `~/.config/shell/common.sh`, `~/.config/starship.toml` and `~/.config/mise/config.toml`. Back up any of them you want to keep.
- Downloads three zsh plugins into `~/.local/share/zsh/plugins`.
- Installs system packages through `sudo` when you are not root. On Debian, it installs `ripgrep`, `zsh` and `bsdextrautils` with `apt-get`. On AlmaLinux, it first enables the EPEL and CRB repositories for the whole system, then installs `ripgrep`, `zsh` and `util-linux` with `dnf`.
- Installs mise into `~/.local/bin`, then uses mise to install Node.js, Starship, `bat`, `fd`, `eza`, `fzf`, `zoxide` and Neovim.
- Does not change your login shell.
- Does not handle secrets yet. Which password manager will supply them is still an open decision; see [ADR 0003](docs/adr/0003-secrets.md).

## Install

You need `curl` and `git`, plus `sudo` if you are not root.

On Debian:

```sh
sudo apt-get install -y curl git
```

On AlmaLinux, `curl` is already installed:

```sh
sudo dnf install -y git
```

### Cautious path

The cautious path lets you read every change before chezmoi modifies any of your existing files. First, install chezmoi into `~/.local/bin` and clone Atelier without applying it. chezmoi asks for the name and email address to put in `~/.gitconfig`.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init https://github.com/InsideLumina/Atelier.git
```

Next, show every file and script chezmoi would change. Most of the output is the zsh plugins' own files, which are all new.

```sh
"$HOME/.local/bin/chezmoi" diff
```

When the diff looks right, apply it:

```sh
"$HOME/.local/bin/chezmoi" apply
```

### One-line path

This single command installs chezmoi, clones Atelier and applies it immediately:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/InsideLumina/Atelier.git
```

Whichever path you take, open a new terminal afterward so the new shell configuration loads. From then on `~/.local/bin` is on your `PATH`, so you can run `chezmoi` without the full path.

## Updating

```sh
chezmoi update
```

This pulls the latest changes from GitHub and applies them. chezmoi rewrites any file whose source changed, and downloads the zsh plugins again at most once a week. The script that enables extra repositories runs once per machine, and again only if the script itself changes. The package script runs again only when the package list changes, and the mise script runs again only when the mise configuration changes. chezmoi asks for your name and email address only once, during the first `init`.

## Local overrides

`~/.zshrc` and `~/.bashrc` end by loading `~/.zshrc.local` and `~/.bashrc.local` if those files exist. Atelier never creates or tracks them, so they are the place for settings that belong to one machine. That includes work-specific aliases, extra `PATH` entries and proxy variables. Secrets do not belong in them; see [ADR 0003](docs/adr/0003-secrets.md).

## How the repository is organized

- `home/` is what chezmoi applies. The `.chezmoiroot` file points chezmoi at it, so nothing outside `home/` is applied to a machine.
- `home/.chezmoidata/packages.yaml` lists system packages for each platform.
- `home/.chezmoiscripts/` holds the scripts that enable extra package repositories, install packages and run mise.
- `home/dot_config/mise/config.toml` lists the runtimes and tools mise installs.
- `.github/workflows/ci.yml` applies Atelier in clean Debian and AlmaLinux containers on every push and checks the result.
- [`docs/pitch.md`](docs/pitch.md) describes the problem and the scope, and [`docs/adr/`](docs/adr/) records the design decisions.

## How Atelier is built

Atelier is planned and reviewed by its author, [VannieX132](https://github.com/VannieX132), and implemented with Claude Code following the rules in [`CLAUDE.md`](CLAUDE.md).

## License

MIT. See [`LICENSE`](LICENSE).
