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

## Communication

- Write to me in English, even when the project is French. The UI, lang files,
  seeded data and other user-facing copy stay in French.
