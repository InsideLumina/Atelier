# Atelier

Configuration that takes a fresh machine to a working development setup with one command.

## What it does

Lumina Atelier is a configuration repository for [chezmoi](https://www.chezmoi.io). It installs system packages, installs runtimes and command-line tools through [mise](https://mise.jdx.dev), and writes shell, prompt and Git configuration into the home directory. It has no installer of its own: chezmoi, mise and the system package manager do the work.

Atelier works today on Debian, including Debian on WSL. AlmaLinux, macOS and Windows are planned.

## Before you run it

Atelier changes the machine it runs on in these ways:

- It replaces these files in your home directory: `~/.bashrc`, `~/.zshrc`, `~/.gitconfig`, `~/.config/shell/common.sh`, `~/.config/starship.toml` and `~/.config/mise/config.toml`. Back up any of them you want to keep.
- It downloads three zsh plugins into `~/.local/share/zsh/plugins`.
- It installs `ripgrep`, `zsh` and `bsdextrautils` with `apt-get`, through `sudo` when you are not root.
- It installs mise into `~/.local/bin`, then uses mise to install Node.js, Starship, `bat`, `fd`, `eza`, `fzf`, `zoxide` and Neovim.
- It does not change your login shell.

## Install

You need `curl` and `git`, plus `sudo` if you are not root:

```sh
sudo apt-get install -y curl git
```

### Cautious path

The cautious path lets you read every change before anything is written. First, install chezmoi into `~/.local/bin` and clone Atelier without applying it. chezmoi asks for the name and email address to put in `~/.gitconfig`.

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

Whichever path you take, open a new terminal afterwards so the new shell configuration loads. From then on `~/.local/bin` is on your `PATH`, so you can run `chezmoi` without the full path.

## Updating

```sh
chezmoi update
```

This pulls the latest changes from GitHub and applies them. Changed files are rewritten. The package script runs again only when the package list changes, and the mise script runs again only when the mise configuration changes. The zsh plugins are downloaded again at most once a week. Your name and email address are asked for only once.

## Local overrides

`~/.zshrc` and `~/.bashrc` end by loading `~/.zshrc.local` and `~/.bashrc.local` if those files exist. Atelier never creates or tracks them, so they are the place for settings that belong to one machine, such as work-specific aliases, extra `PATH` entries or proxy variables. Secrets do not belong in them; see [ADR 0003](docs/adr/0003-secrets.md).

## How the repository is organized

- `home/` is what chezmoi applies. The `.chezmoiroot` file points chezmoi at it, so nothing outside `home/` is ever written to a machine.
- `home/.chezmoidata/packages.yaml` lists system packages for each platform.
- `home/.chezmoiscripts/` holds the scripts that install packages and run mise.
- `home/dot_config/mise/config.toml` lists the runtimes and tools mise installs.
- `.github/workflows/ci.yml` applies Atelier in a clean container on every push and checks the result.
- [`docs/pitch.md`](docs/pitch.md) describes the problem and the scope, and [`docs/adr/`](docs/adr/) records the design decisions.

## How Atelier is built

Atelier is planned and reviewed by its author, [VannieX132](https://github.com/VannieX132), and implemented with Claude Code following the rules in [`CLAUDE.md`](CLAUDE.md).

## License

MIT. See [`LICENSE`](LICENSE).
