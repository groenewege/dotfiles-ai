## Git safety

Everywhere:

- Never set ALLOW_PROTECTED_PUSH.
- Never bypass Git hooks.
- Never run deployment commands without approval.

Projects in `~/Sites` (client sites): I work on `develop` (and feature
branches). `staging` and `main`/`master` deploy automatically when pushed, so
I rarely work on them directly.

- You may commit and push to feature branches and develop.
- Never push to main or master.
- Ask before pushing to staging: it deploys.
- Leave merges to main or master to the developer.

Projects in `~/Code` (my own tools and dotfiles; nothing deploys): you may
commit, merge and push to any branch, main included.

## The Mac

The Mac (macOS) is my primary development machine: Laravel Valet and several
PHP versions from Homebrew, MySQL, and the Git that ships with macOS. Keeping it
working matters more than any new tool. This section does not apply to the
Omarchy laptop.

- Never install, upgrade or remove Homebrew packages without asking. That
  includes PHP, Valet, MySQL and Git.
- Before proposing a new tool, check what installing it would change:
  `brew install --dry-run <formula>`. Installing one formula can upgrade shared
  dependencies (openssl, icu4c and the like) that PHP and MySQL are linked
  against. If it would upgrade anything already installed, say so and don't
  install it.
- Check that a tool works with the versions already installed before
  recommending it. Example: Worktrunk waits until macOS ships a newer Git.
- Prefer what is already installed, then project-local dependencies (composer,
  npm), then a standalone binary in `~/.local/bin`.

## Communication

- Write to me in English, even when the project is French. The UI, lang files,
  seeded data and other user-facing copy stay in French.
