# ADR 0003: Secrets stay in a password manager

Date: 2026-10-07
Status: accepted

## Context

The repository is public. Some configs need secrets (tokens, SSH keys, work credentials). A leaked secret in a public dotfiles repo is the most common way these projects cause real harm.

## Decision

No secret is ever committed, encrypted or not. chezmoi templates read secrets from a password manager at apply time through chezmoi's built-in integration.

Which password manager to use is a separate decision, recorded in its own ADR once the secrets Atelier needs are known and before the first template that reads a secret is written.

## Consequences

Easier: the repo stays safe to publish and secrets rotate in one place.

Harder: a fresh machine needs the password manager CLI signed in before the first full apply, and CI must run with secret-dependent templates skipped.
