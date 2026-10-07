# Atelier pitch

Status: accepted, October 2026

## Problem

Setting up a new machine takes hours of remembering what was installed and how it was configured. I work across Windows, WSL, Debian at home, AlmaLinux at work and macOS, so the same setup has to be rebuilt by hand on every platform. The previous version of Atelier tried to solve this with a custom installation and management engine, which went stale and duplicated what existing tools already do.

## Appetite

Four weekends, with weekday work as optional slack rather than planned time. If the work does not fit, scope gets cut, not the deadline.

## Solution

Atelier composes existing tools instead of implementing an installer:

- chezmoi is the single entry point. One command installs it, clones this repo and applies everything. Templates branch on OS and distro family where configs differ.
- System packages use each platform's native format: a Brewfile on macOS, a WinGet configuration file on Windows, and plain package lists for apt (Debian) and dnf (AlmaLinux), installed by chezmoi `run_onchange_` scripts.
- mise installs language runtimes and CLI tools that are not worth packaging per platform.
- CI runs the one-command install on every target (Debian, AlmaLinux, macOS, Windows) and fails if a smoke check does not pass.

Build order: Debian/WSL first, then AlmaLinux, then macOS, then Windows. Each platform is done when its CI job is green.

## Rabbit holes

- Package names differ between apt and dnf, and some tools need EPEL on AlmaLinux. Keep two plain lists; do not build a name-mapping layer.
- WSL and native Linux may need different configs. Detect WSL in chezmoi templates instead of keeping a separate profile.
- Windows CI may not have winget available on hosted runners. If it does not, test the Windows side with chezmoi and mise only and run the WinGet configuration by hand.
- Secrets must never be committed. See ADR 0003.

## No-gos

- No custom installer engine and no package abstraction layer.
- No GUI.
- No drift detection in this cycle.
- No support for platforms I do not use myself.
- No employer-specific configuration or credentials in the public repo.

## Done means

On each of the four platforms, one documented command takes a fresh machine to my working setup, and CI proves it on every push.
