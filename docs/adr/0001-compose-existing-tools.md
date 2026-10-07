# ADR 0001: Compose existing tools instead of a custom engine

Date: 2026-10-07
Status: accepted

## Context

The first version of Atelier was a custom installation and management engine. It became outdated and reimplemented features that mature tools already provide. Atelier has to cover Windows, WSL, Debian, AlmaLinux and macOS. The tooling for this is established: chezmoi manages dotfiles across machines with templates and setup scripts, mise manages runtimes, and each OS has a declarative package format (Brewfile, WinGet configuration, apt and dnf package lists).

## Decision

Atelier is a configuration repository, not a program. chezmoi is the entry point and owns dotfiles and orchestration. Native package formats own system packages. mise owns runtimes and per-user CLI tools. Atelier adds only configuration and the glue scripts chezmoi runs.

## Consequences

Easier: far less code to maintain, upstream tools handle edge cases, and the setup stays useful if Atelier itself stops being maintained.

Harder: Atelier depends on chezmoi and mise staying healthy, package lists must be kept per platform by hand, and the project has less novelty as a portfolio piece.
