---
name: upgrade-laravel
description: Upgrade a Laravel project one major at a time (10 → 11 → 12 → 13 by default) with Laravel Shift, Boost and the upgrade-laravel-* skills, with tests, a browser check and my approval before each merge; then Livewire hardening, PHPUnit notices, fresh-machine install, production .env values and the token guard fix. Run it again to continue where the last session stopped.
argument-hint: "[target major, default 13]"
disable-model-invocation: true
---

# Upgrade a Laravel project

Take the project on the current upgrade branch from its Laravel major to the
**target** (`$ARGUMENTS`, default `13`), one major per Laravel Shift, then make
it installable on a fresh machine. The run spans several sessions: Shift takes
minutes to open its PR, and every merge waits for the user's own check. Each
invocation therefore starts by working out where the run stands.

## Rules

- Work and commit on the upgrade branch (its name contains `upgrade`, e.g.
  `laravel-upgrade`). Push it before every `/shift:run`: Shift reads the remote
  branch, not the local one.
- Shift PRs merge into the upgrade branch only. Never push develop, staging or
  master/main, and never merge the upgrade branch into them: that's the
  user's call after the run.
- Commit messages follow the repository's history (usually French,
  `scope : message`).
- Shift's changes stay as they are. When one looks wrong, flag it in the report
  (`shift:review` says the same).
- The reports are in English; UI strings, lang files and seed data stay French.

## Asking

Every question goes through **AskUserQuestion**: what the user must read comes
first in the message (the report), the tool carries the decision, recommended
option first, marked "(Recommended)". The run stops for:

| Point | Question |
|---|---|
| Preflight | anything the project guidelines don't give: admin credentials, the target if `$ARGUMENTS` is unclear |
| Step 1 | Boost refuses the installed 10.x: bump `laravel/framework` within 10.x? |
| Step 2.4 | a fork has no compatibility branch and blocks `composer update` |
| Step 2.6 | Merge Shift PR #n? merge; not yet (stop here, I'll check); problem (the free text says what) |
| Step 5 | production runs a PHP other than 8.3; npm build output that has to change |
| Step 7 | production's `APP_NAME` |

## Where the run stands

On every invocation, before doing anything, establish each item below from the
environment, print it as a checklist (done / to do), and continue at the first
item still to do. "Some of it may already be in place" is normal: an item that
is already true is done, not redone.

1. **Branch**: on the upgrade branch, `git status --porcelain` empty, in sync
   with `origin` (`git fetch` first). Not on one: ask which branch to use.
2. **Project context**: read `.ai/guidelines/project.md` (it must exist; the
   user writes it before the run), `CLAUDE.md`, and the project's memory for
   the test command, the local site URL, admin credentials and anything
   deferred "until the upgrade" (fold those into the matching step).
3. **Boost**: `laravel/boost` in `composer.lock`, `boost.json` present.
4. **Laravel major**: `composer show laravel/framework`. Shift PRs:
   `gh pr list --search "head:shift-" --state all --json number,headRefName,state,title`.
   An open PR means step 2 resumes at 2.4 for that Shift.
5. **Livewire**: `livewire/livewire` in `composer.lock` (step 3 applies).
6. **PHPUnit**: `composer show phpunit/phpunit` and whether the suite prints
   PHPUnit deprecations or notices (step 4).
7. **Fresh machine**: `.gitignore` ignores `/.ai/mcp` rather than `/.ai`;
   `composer.json` has `config.platform.php`. The fresh-copy check of step 5
   is always run again before step 6.
8. **Token guard**: a guard with `'driver' => 'token'` in `config/auth.php`.

## Verify

The same check closes every Shift and the final run. It is done when the suite
is green and every page listed renders, or when each failure is in the report
with its output.

1. `php artisan config:clear && php artisan view:clear`.
2. `php artisan migrate:fresh --seed --env=testing`, then the project's test
   command (`php artisan test --compact` unless the guidelines say otherwise).
3. Browser pass with Claude in Chrome (load the `claude-in-chrome` skill first)
   on the local site: `APP_URL`, or `http://<folder>.test` under Valet. Frontend:
   the home page, each main section from the navigation, one form. Admin: log
   in, the dashboard, one list, one edit form. On every page, check the layout
   (styles and scripts loaded) and the console for errors. List the pages in
   the report.

## Step 1 — Boost

1. `composer require laravel/boost --dev -W`: Composer picks the Boost release
   that supports the installed Laravel. When it refuses because the framework
   is below Boost's floor, ask before updating `laravel/framework` within 10.x.
2. `php artisan boost:install` is interactive: ask the user to run it in their
   own terminal and choose Claude Code and Codex. Wait for their go.
3. Commit what Boost generated that `.gitignore` doesn't exclude, then push.

## Step 2 — One Laravel major

Repeat for each major from the installed one + 1 up to the target. N is the
major being installed.

1. **Run.** Push the branch, then `/shift:run N`.
2. **Read** the `upgrade-laravel-N` skill in full (`upgrade-laravel-11`, `-12`,
   `-13`). Its traps and checklist drive the review below; the Shift PR
   comments name what changed, the skill names what Shift misses.
3. **Wait** for the PR with a background loop, so you're notified when it
   opens:
   ```bash
   for i in $(seq 30); do
     for b in shift-<n> shift-build-<n>; do
       [ "$(gh pr list --head "$b" --json number --jq length)" != 0 ] && exit 0
     done
     sleep 60
   done; exit 1
   ```
   Timed out: tell the user and stop; the next invocation resumes here.
4. **Review** with `/shift:review <n>`, applying `upgrade-laravel-N` as its
   checklist. Before `composer update` and again before its merge question,
   check the **forked packages**:
   - The user's forks of abandoned packages: single-table-inheritance,
     rutorika-sortable, baum, zurb-foundation, laravel-fullcalendar,
     social-share, Googlmapper, html (`laravelcollective/html`). The `vcs`
     entries in `composer.json` `repositories` are the source of truth.
   - For each, `git ls-remote --heads <url>` and pin the package to
     `dev-lN-compatibility` when that branch exists, including packages pinned
     to `dev-master`.
   - Shift sometimes rewrites a fork's `dev-*` constraint to a Packagist semver
     that the `vcs` repository can't satisfy: put the fork branch back.
   - After `composer update`, confirm `vendor/<package>` holds the fork's code
     (`composer show <package>` names the branch and commit).
   - No compatibility branch and the package blocks the update: stop and ask.
     Fork work happens in the fork's own repository.
5. **Verify** (above).
6. **Gate.** Report: what Shift changed, what you fixed and why, the forks and
   their branches, env vars Shift asks to set (keep them for step 7), the test
   result, the pages checked. Then ask "Merge Shift PR #n?". "Not yet" ends the
   session; the next invocation asks again.
7. **Merge** with `shift:review`'s own merge procedure, which commits leftovers,
   pushes and merges the PR into the upgrade branch. Then
   `git checkout <upgrade branch> && git pull`.
8. **Refresh Boost** so the guidelines describe the new versions:
   `php artisan boost:update` (it reuses `boost.json`). When Shift moved Boost
   to a new major, or `boost:update` doesn't exist, the user runs
   `php artisan boost:install` again (Claude Code and Codex). Commit and push.

Done when `composer show laravel/framework` reports the target major, every
Shift PR is merged, and Boost is refreshed.

## Step 3 — Livewire hardening

Only when `livewire/livewire` is installed. Apply `laravel-conventions` ("Lock
server-set Livewire properties") and the `upgrade-laravel-13` section "Harden
Public (Unauthenticated) Livewire / Filament Components Against Property
Tampering".

Done when every component reachable from a guest route
(`php artisan route:list --except-vendor`) is listed in the report with each
public property classified as form state, `#[Locked]` or `#[Computed]`, and each
locked property has a test asserting the tamper exception. Verify, then commit.

## Step 4 — PHPUnit notices

When the suite prints PHPUnit deprecations or notices (e.g. `Metadata found in
doc-comment`) and `phpunit/phpunit` is below 12, run the PHPUnit Shifts one
major at a time (`PU11` from PHPUnit 10, then `PU12`), each through steps
2.1 and 2.3–2.7. A Pest 4 project already runs PHPUnit 12.

Done when the suite output has no PHPUnit deprecation or notice.

## Step 5 — Fresh-machine install

A clone on another machine must install and build without changing anything.

1. **`.gitignore`**: `/.ai` becomes `/.ai/mcp`, so the Boost guidelines are
   committed. `git check-ignore -v .ai/guidelines/project.md` prints nothing;
   commit `.ai/guidelines/`.
2. **PHP**: pin the platform so another machine resolves the same packages:
   `"config": { "platform": { "php": "8.3" } }` and `"php": "^8.3"` in
   `require`, unless production runs another PHP (ask). Then
   `composer update --lock`; when locked packages require a newer PHP
   (Symfony 8 needs 8.4), `composer update <those packages> -W` and Verify.
3. **npm**: follow the `upgrade-laravel-frontend` skill, step 4 "Repair the
   current tools". Its step 2 question is already answered: keep the current
   asset tooling. Committed build output (`public/css`, `public/js`,
   `mix-manifest.json`, `public/build`) stays as it is: `git restore` it after
   every build, unless the user agrees to commit a rebuild.
4. **Fresh copy**: in a scratchpad copy holding tracked files only (as in
   `upgrade-laravel-frontend` step 5), run `composer install --no-scripts
   --no-interaction`, then `npm ci` and the project's build script.

Done when the fresh copy installs and builds, and `git status` in the project
shows only the intended `.gitignore`, `composer.*` and `package*.json` changes.
Commit.

## Step 6 — Final check

Verify. Commit anything still open on the upgrade branch and push it.

## Step 7 — Production `.env`

Laravel 13 derives the default cache prefix, Redis prefix and session cookie
differently (see `upgrade-laravel-13`), so production pins the values Laravel 12
derived.

1. Ask for production's `APP_NAME`; offer the local `.env` value as one option.
2. Compute the values with master's formulas (`git show origin/master:config/cache.php`,
   `config/database.php`, `config/session.php`), usually:
   ```bash
   php artisan tinker --execute '$s = Illuminate\Support\Str::slug("<APP_NAME>", "_");
   echo "CACHE_PREFIX={$s}_cache_\nREDIS_PREFIX={$s}_database_\nSESSION_COOKIE={$s}_session\n";'
   ```
3. Show one block of lines to add to production's `.env`: these three, the
   variables Shift's PR comments asked to set, and the production values from
   the env table in `upgrade-laravel-11` (e.g. `LOG_STACK`). Mark which ones
   replace an old name (`CACHE_DRIVER` → `CACHE_STORE`).

## Step 8 — Token guard

1. `composer show laravel/framework` is at 13.29.0 or later on a Laravel 13
   target (the release that fixes GHSA-f9x3-7vq9-cph6). Below it:
   `composer update laravel/framework -W`, Verify, commit.
2. Read `~/.claude/skills/remove-token-guard/SKILL.md` and follow it on the
   upgrade branch.

## Hand-off

End the run with:

- the commits made on the upgrade branch (`git log --oneline <base>..HEAD`);
- the production `.env` block from step 7;
- the manual checks still to do (PDF output, mail, cron jobs, anything the
  tests and the browser pass didn't reach);
- an offer to run `review-laravel-upgrade` before the branch is merged;
- a reminder that merging into develop, and deploying, is the user's call.
