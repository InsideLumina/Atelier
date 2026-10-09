# Lumina Atelier

Atelier is a public configuration repository that takes a fresh machine to Vannie's working development setup with one command, on Debian and WSL, AlmaLinux, macOS and Windows. It composes existing tools. It is not a program, and it must never grow its own installer engine.

## Read before any work

- @docs/pitch.md defines the problem, the appetite, the rabbit holes, the no-gos and the done condition.
- @docs/adr/0001-compose-existing-tools.md
- @docs/adr/0002-license.md
- @docs/adr/0003-secrets.md
- Read every other file in `docs/adr/` before planning. Later ADRs are not imported here.

## Architecture

- chezmoi is the entry point. `.chezmoiroot` contains `home`, so only `home/` is chezmoi's source state. `docs/`, the README and CI files are never applied to a machine.
- Scripts live in `home/.chezmoiscripts/`. Their prefixes decide when they run (`run_once_`, `run_onchange_`, `before_`, `after_`), and their numeric prefixes decide order within a group.
- Packages are data in `home/.chezmoidata/packages.yaml`: one plain list per platform (`debian`, `rhel`, `darwin`, `windows`). There is no name-mapping layer between platforms, on purpose.
- mise owns runtimes and cross-platform CLI tools through `home/dot_config/mise/config.toml`.
- `.github/workflows/ci.yml` has one job per platform. A platform is done when its job passes.

## Rules

### Documentation comes from Context7, not memory

Every tool-specific fact (file names, flags, template functions, script ordering, installer behavior, CI syntax) must come from Context7 before it is used. Tools change faster than training data, and a wrong flag in a bootstrap script breaks a fresh machine.

1. Resolve the library with Context7, then query the specific topic.
2. Record the library ID and the source page for each fact in the phase report.
3. If Context7 has no answer, say so, mark the item as unverified in the report, and ask Vannie before relying on it.
4. If the Context7 tools are not available in this session, stop and say so. Do not continue from memory.

### Never touch this machine's real setup

- Never run `chezmoi init`, `chezmoi apply` or `chezmoi update` against this computer's home directory. The configuration is untested until CI passes, and this machine is Vannie's daily driver.
- Test only in a disposable container (`docker run --rm ...`) or in CI. Check `docker info` first. If no container runtime is available, say so and rely on CI.
- Read-only commands are allowed: `chezmoi diff`, `chezmoi execute-template`, `chezmoi cat`, always with an explicit `--source` pointing at this repository's `home/`.
- `chezmoi add` writes only into the source state. Use it only when a skill asks for it.

### Empty dotfiles delete their targets

chezmoi treats an empty source file as "this file should not exist" unless it carries the `empty_` prefix. Never leave a placeholder dotfile in `home/`, and never commit one.

### Secrets and work data stay out

ADR 0003 applies to every change. Before each commit, read the staged diff (`git diff --cached`) and look for tokens, keys, passwords, internal hostnames, employer names, work paths and personal email addresses that should not be public. Anything machine-specific or work-related belongs in an untracked local file such as `~/.zshrc.local`, never in the repository.

### Scope

Implement only the steps the current skill lists. No extra files, no abstractions with a single use, no configuration for values that never change, no scaffolding "for later". When something seems missing, propose it in the report instead of adding it. When the documentation contradicts a step, stop and report the contradiction rather than improvising around it.

### Git

- GitHub Flow: one short-lived branch per skill run, named as the skill says. Never commit to `main`.
- One commit per logical step, in Conventional Commits format (`feat:`, `fix:`, `docs:`, `ci:`, `chore:`).
- Never push, open a pull request, merge, create a tag or change GitHub settings without Vannie's explicit confirmation in the current conversation.
- Before the first commit of a session, run `git config user.email`. It must print `56842865+VannieX132@users.noreply.github.com`, Vannie's personal GitHub address. If it prints anything else, stop and tell Vannie. Never change Git configuration (`git config`, `~/.gitconfig` or credential helpers) to fix it yourself, because the wrong value means the per-folder identity setup is broken and committing would publish work under the wrong account.

### Scripts

- POSIX `sh` with `set -eu` unless a step says otherwise. PowerShell only for Windows.
- Scripts must work both as root in a CI container and as a normal user with `sudo`.
- Every script guards its own platform, so it renders to nothing elsewhere.
- Render templates with `chezmoi execute-template` and run `shellcheck` on the rendered output when shellcheck is installed.
- Output is quiet on success. When a script prints status, it uses plain words (`done`, `skipped`, `error`) and never emoji or decorative symbols.

### Writing in the repository

README and docs follow the Lumina voice: impersonal (name the thing as the subject, address the reader as "you" in instructions, no "I" or "we"), US English, sentence case headings, no em dashes, no exclamation marks, no emoji, no hype words. Use the full name "Lumina Atelier" on first mention, then "Atelier". Commands, paths and values go in code formatting.

### ADRs

Michael Nygard's format: title with number, date, status, context, decision, consequences (including the negative ones). Never rewrite an accepted decision. A changed decision gets a new ADR that supersedes the old one, and the old one's status changes to "superseded by ADR NNNN".

## Working process for every phase skill

1. **Orient.** Read the pitch, every ADR, `git status`, `git log --oneline -10` and the current branch. Restate the task in your own words and list anything that does not match what the skill expects.
2. **Research.** Query Context7 for every tool the phase touches. Summarize what you learned, with sources, before planning.
3. **Plan.** Present a numbered plan that maps one-to-one to the skill's steps: files to create or change, commands to run, tests to run. Then stop and wait for Vannie's approval. Do not edit anything before approval.
4. **Implement.** Work step by step. Before each step, say what you are about to do and why in one to three sentences. After each command, say what the result showed. Commit after each logical step.
5. **Verify.** Run every test the skill lists, plus any check the documentation recommends. A step is not done until its check has passed.
6. **Report.** Write the phase report described below, save it, and print it in full.

## Phase report

Save to `.claude/reports/<skill-name>.md` (this folder is gitignored) and print the same text at the end of the session. Use these sections, in this order:

1. **Summary.** Two to four sentences: what changed and whether the phase's done criteria are met.
2. **Changelog.** One entry per file added, changed or removed: the path, what changed, and why, in plain language a beginner can follow.
3. **Decisions and trade-offs.** Every choice made where more than one option existed, with the reason and what was given up.
4. **Documentation consulted.** Each Context7 library ID and source page, and the fact it supported.
5. **Commands and tests run.** Each command, what it checks, and its result (pass or fail, with the relevant output).
6. **Unverified or assumed.** Anything not confirmed by documentation or a test, and anything inferred rather than stated by Vannie.
7. **What Vannie should check.** A numbered list of checks to prove the work does what it should, each with the exact command or place to look and the expected result.
8. **Left for Vannie.** Actions this session deliberately did not take (push, pull request, merge, tag, settings, changes on real machines), in the order to do them.
9. **Tools used.** Every tool used in the session, and notable tools not used.
