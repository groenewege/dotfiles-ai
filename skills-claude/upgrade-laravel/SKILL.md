---
name: upgrade-laravel
description: Upgrade a Laravel project one major at a time (10 → 11 → 12 → 13 by default) with Laravel Shift, Boost and the upgrade-laravel-* skills, with tests, a browser check and my approval before each merge; then Livewire hardening, PHPUnit notices, fresh-machine install, production .env values and the token guard fix, then a Codex review of the branch. Run it again to continue where the last session stopped.
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
- The remote isn't always called `origin` (one project uses `github`): check
  `git remote -v` and read `origin` below, and in the `shift:*` skills, as that
  remote.

## Asking

Every question goes through **AskUserQuestion**: what the user must read comes
first in the message (the report), the tool carries the decision, recommended
option first, marked "(Recommended)". The run stops for:

| Point | Question |
|---|---|
| Preflight | anything the project guidelines don't give: admin credentials, the target if `$ARGUMENTS` is unclear |
| Step 1 | Boost isn't installed yet and its install moves `laravel/framework` within 10.x: bump it? |
| Step 2.4 | a fork has no compatibility branch and blocks `composer update` |
| Step 2.6 | Merge Shift PR #n? merge; not yet (stop here, I'll check); problem (the free text says what) |
| Step 5 | production runs a PHP other than 8.3; npm build output that has to change |
| Step 7 | production's `.env` `APP_NAME` (or that it isn't set there) |

## Where the run stands

On every invocation, before doing anything, establish each item below from the
environment, print it as a checklist (done / to do), and continue at the first
item still to do. "Some of it may already be in place" is normal: an item that
is already true is done, not redone.

1. **Branch**: on the upgrade branch, `git status --porcelain` empty (an
   untracked `upgrade-review-report.html` from step 9 doesn't count), in sync
   with `origin` (`git fetch` first). Not on one: ask which branch to use.
2. **Project context**: read `.ai/guidelines/project.md` (it must exist; the
   user writes it before the run), `CLAUDE.md`, and the project's memory for
   the test command, the local site URL, admin credentials and anything
   deferred "until the upgrade" (fold those into the matching step).
3. **Boost**: `laravel/boost` in `composer.lock`, `boost.json` present, and
   none of step 1.3's files tracked (`git ls-files` on that list is empty).
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
9. **Codex review**: `upgrade-review-report.html` in the project root, newer
   than the branch's last commit.

## Verify

The same check closes every Shift and the final run. It is done when the suite
is green and every page listed renders, or when each failure is in the report
with its output.

1. `php artisan config:clear && php artisan view:clear`.
2. `php artisan migrate:fresh --seed --env=testing`, then the project's test
   command (`php artisan test --compact` unless the guidelines say otherwise).
   On Laravel 10, Collision 6 has no `--compact` ("Unknown option"): run plain
   `php artisan test` until the Laravel 11 Shift is merged.
3. Browser pass with Claude in Chrome (load the `claude-in-chrome` skill first)
   on the local site: `APP_URL`, or `http://<folder>.test` under Valet. Frontend:
   the home page, each main section from the navigation, one form. Admin: log
   in, the dashboard, one list, one edit form. On every page, check the layout
   (styles and scripts loaded) and the console for errors. List the pages in
   the report.
   - A JavaScript `fetch()` sweep over the URLs is quicker than visiting each
     page. Claude in Chrome withholds a script result that contains a URL with
     a query string (`[BLOCKED: Cookie/query string data]`), so check search
     pages by typing into the search box instead.
   - Search showing no results isn't necessarily a regression: a local `.env`
     with `SCOUT_DRIVER=null` returns nothing for every query. Check `.env`
     before debugging Scout.

## Step 1 — Boost

Only install Boost when it isn't installed yet. When `laravel/boost` is already
in `composer.lock`, skip 1 (don't require, update or reinstall it); when
`boost.json` exists too, skip 2 as well. Step 3 always applies.

1. `composer require laravel/boost --dev -W`: Composer picks the Boost release
   that supports the installed Laravel. On Laravel 10 (and 11), Composer 2.9+
   refuses every framework release over security advisories ("not loaded,
   because they are affected by security advisories"), so add `--no-blocking`
   to this one command. Run it with `--dry-run` first: when the plan upgrades
   `laravel/framework` (Boost's floor is above the installed 10.x), ask before
   running it for real.
2. `php artisan boost:install` is interactive: ask the user to run it in their
   own terminal and choose Claude Code and Codex. Wait for their go.
3. Boost's generated files stay out of git. Append the lines of this list
   that `.gitignore` lacks (newline-safely, as in `upgrade-laravel-11`):
   ```
   /.agents
   /.ai/mcp
   /.claude
   /.codex
   /.cursor
   /.junie
   .mcp.json
   AGENTS.md
   CLAUDE.md
   boost.json
   opencode.json
   ```
   `git rm --cached` any of them that is already tracked (the files stay on
   disk). `git check-ignore -v .ai/guidelines/project.md` prints nothing. Commit
   `.gitignore`, `composer.*` and `.ai/guidelines/`, then push.

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
   While it waits, run the fork branch check of 2.4 on the current
   `composer.json`, so a fork that blocks major N is asked about before the
   PR opens.
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
   pushes and merges the PR into the upgrade branch. Right after the push,
   GitHub reports the PR as `UNKNOWN` mergeability and `gh pr merge` fails with
   "Pull Request is not mergeable": poll `gh pr view <n> --json mergeable`
   until it reads `MERGEABLE`, then merge. Right after the previous Shift's
   merge, `gh pr merge` can also fail with "Base branch was modified" while
   the PR reads `MERGEABLE`/`CLEAN`. That's transient: confirm with
   `git fetch` that the base has no commit you haven't seen, wait a few
   seconds and merge again. Confirm `gh pr view <n> --json state` reads
   `MERGED` before checking out the upgrade branch. Then
   `git checkout <upgrade branch> && git pull`.
8. **Refresh Boost** so the guidelines describe the new versions:
   `php artisan boost:update` (it reuses `boost.json`). When Shift moved Boost
   to a new major, or `boost:update` doesn't exist, the user runs
   `php artisan boost:install` again (Claude Code and Codex). Commit and push,
   applying step 1.3's rule to the folders the new major adds.

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
major at a time from the installed major, each through steps 2.1 and 2.3–2.7.
The Laravel 12 Shift already moves PHPUnit to 11 and the Laravel 13 Shift
keeps it there, so after step 2 this is usually `PU12` alone. It converts the
doc-comment metadata (`/** @test */` → `#[Test]`) and bumps the constraint;
run `composer update phpunit/phpunit -W`, then `vendor/bin/phpunit
--migrate-configuration` (delete `phpunit.xml.bak`), since the Shift leaves
`phpunit.xml` on the old schema. A Pest 4 project already runs PHPUnit 12.

Done when the suite output has no PHPUnit deprecation or notice and
`phpunit.xml` names the installed major's schema.

## Step 5 — Fresh-machine install

A clone on another machine must install and build without changing anything.

1. **`.gitignore`**: `/.ai` becomes `/.ai/mcp`, so the Boost guidelines are
   committed. `git check-ignore -v .ai/guidelines/project.md` prints nothing;
   commit `.ai/guidelines/`.
2. **PHP**: pin the platform so another machine resolves the same packages:
   `"config": { "platform": { "php": "8.3.1" } }` and `"php": "^8.3"` in
   `require`, unless production runs another PHP (ask). Pin a patch release:
   `"8.3"` means exactly 8.3.0, which some packages exclude
   (`algolia/algoliasearch-client-php` 4.x requires `>=8.1 !=8.3.0`), and
   `composer update --lock` then fails. Then `composer update --lock`; when
   locked packages require a newer PHP (Symfony 8 needs 8.4),
   `composer update <those packages> -W` and Verify.
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

1. Ask whether production's `.env` sets `APP_NAME`, and to what. Master's
   formulas read `env('APP_NAME', 'laravel')`, not `config('app.name')`. An app
   whose name lives only in `config/app.php` (`'name' => env('APP_NAME', 'Acme')`)
   derived `laravel_*` in production, whatever the config file says. Offer the
   local `.env` value and "not set in `.env`" as options, and suggest checking
   with `grep APP_NAME .env` on the server.
2. Compute the values with master's formulas (`git show origin/master:config/cache.php`,
   `config/database.php`, `config/session.php`), usually, with `laravel` as
   `<APP_NAME>` when `.env` doesn't set it:
   ```bash
   php artisan tinker --execute '$s = Illuminate\Support\Str::slug("<APP_NAME>", "_");
   echo "CACHE_PREFIX={$s}_cache_\nREDIS_PREFIX={$s}_database_\nSESSION_COOKIE={$s}_session\n";'
   ```
3. Compare the drivers. Once Shift removes a config file, the framework's own
   default applies wherever production's `.env` doesn't set the variable, and
   those defaults differ from the old skeleton's. For each of `session.driver`,
   `queue.default`, `database.default`, `mail.default` and `cache.default`,
   compare master's fallback (`git show origin/master:config/<file>.php`) with
   `vendor/laravel/framework/config/<file>.php`. On Laravel 13 the framework
   uses `database` for sessions, queue and cache, `sqlite` for the database and
   `log` for mail, where master usually had `file`, `sync`, `mysql` and `smtp`.
   A production `.env` that never set these then fails on every request
   (missing `sessions` table) or stops sending mail. Pin each one that differs.
4. Show one block of lines to add to production's `.env`: the three values
   above, the drivers from 3, the variables Shift's PR comments asked to set,
   and the production values from the env table in `upgrade-laravel-11`
   (e.g. `LOG_STACK`). Mark which ones replace an old name (`CACHE_DRIVER` →
   `CACHE_STORE`).

## Step 8 — Token guard

1. `composer show laravel/framework` is at 13.29.0 or later on a Laravel 13
   target (the release that fixes GHSA-f9x3-7vq9-cph6). Below it:
   `composer update laravel/framework -W`, Verify, commit.
2. Read `~/.claude/skills/remove-token-guard/SKILL.md` and follow it on the
   upgrade branch.

## Step 9 — Codex review

Once steps 1–8 are done and pushed, a Codex agent runs the
`review-laravel-upgrade` skill on the upgrade branch, apart from this session.
Its prompt: `$review-laravel-upgrade Review the <upgrade branch> branch.`

- **In Herdr** (`HERDR_ENV=1`): load the `herdr` skill and follow "Start and
  coordinate an agent": a sibling pane with `--no-focus` in the project folder,
  `herdr agent start upgrade-review --kind codex`, then `herdr agent prompt
  upgrade-review '<prompt>' --wait` as a background Bash command, so you're
  notified when it settles. `blocked` means Codex is waiting for the user in
  that pane: say so.
- **Anywhere else** (a plain terminal, the desktop app): run it as a
  background Bash command, so you're notified when it exits:
  ```bash
  codex exec -s workspace-write -c sandbox_workspace_write.network_access=true \
    -C "$PWD" -o <scratchpad>/upgrade-review.md '<prompt>'
  ```
  The network setting is what lets the review run the suite. `codex exec`
  always runs with approval `never` (a `-c approval_policy` override is
  ignored), so the allow-list in `~/.codex/rules/default.rules` (`php artisan`,
  `mysql -h 127.0.0.1`, `composer audit`, …) doesn't apply: that list only
  takes effect in an interactive session, where Codex may request escalation.
  The default `workspace-write` sandbox has no network, and macOS's sandbox
  then blocks TCP connections to MySQL on `127.0.0.1:3306`. Every test, and
  `migrate:fresh`, fails with `SQLSTATE[HY000] [2002] Operation not
  permitted`, and `composer audit` / `outdated` can't resolve DNS. With
  network on, the sandbox still limits writes to the project, `/tmp` and
  `$TMPDIR`. The Herdr route is interactive and uses the rules, so it needs
  nothing extra.
- `codex` not installed or not logged in: say so in the hand-off and skip.
- When the report says the tests "stopped before assertions" with that
  `Operation not permitted` error, the sandbox blocked the database, not the
  code: say so, and point to your own green run from step 6.

Don't wait for it: give the hand-off right away. When it finishes, tell the
user it's done and where the report is (`upgrade-review-report.html`). Don't
implement, fix or commit anything it recommends; the findings are the user's
to act on.

## Hand-off

End the run with:

- the commits made on the upgrade branch (`git log --oneline <base>..HEAD`);
- the production `.env` block from step 7;
- the manual checks still to do (PDF output, mail, cron jobs, anything the
  tests and the browser pass didn't reach);
- that the Codex review of step 9 is running, and where its report will be;
- a reminder that merging into develop, and deploying, is the user's call.
