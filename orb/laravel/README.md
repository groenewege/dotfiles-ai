# Amp orb template for Laravel projects

Copy into a Laravel project to make Amp orbs start with PHP, Composer, MySQL
8.4, Node, seeded development and test databases, Laravel Boost, a portal for
the site, and the skills and `AGENTS.md` from this repository. Works on Debian
12 and 13 orbs: the apt sources follow the orb's release.

```bash
cp -R ~/dotfiles-ai/orb/laravel/.agents ~/dotfiles-ai/orb/laravel/.amp <project>/
```

Then set the project's values in `.agents/orb-config`, the only file that
differs between projects. Keep `setup`, `resume` and `sync-ai-config` identical
to this template so updates are a plain copy.

| Setting | Default | Change when |
| --- | --- | --- |
| `PHP_VERSION`, `PHP_EXTENSIONS` | `8.3`, the usual Laravel extensions | the project needs another PHP or extension |
| `MYSQL_SERIES` | `mysql-8.4-lts` | another repo.mysql.com series, such as `mysql-9.7-lts` |
| `DB_NAME`, `DB_TEST_NAME` | `myproject`, `myproject_test` | always; the test name must match `phpunit.xml` |
| `COMPOSER_HTTP_BASIC` | empty | `composer.json` has a private repository: add `"host USER_VAR PASS_VAR"` |
| `FRONTEND_BUILD_SCRIPT` | `build`, else `production` from `package.json` | another npm script, or `""` to skip building |
| `ORB_NOTES` | seeded login and admin path | the project's logins, admin path and other orb hints |

Private Composer repositories: list each host with the names of two Amp
**project** secrets (`.agents/setup` does not receive personal secrets), for
example `COMPOSER_HTTP_BASIC=("satis.filamentexamples.com SATIS_USERNAME SATIS_PASSWORD")`,
then store those secrets in the project. A host whose secrets are missing is
skipped with a warning, so `composer install` fails only if it needs that host.
Setup installs `/usr/local/bin/composer` as a wrapper around the Composer phar
that adds `COMPOSER_AUTH` for those hosts on every call, so `composer require`
works in agent shells too. (A line in `~/.bash_profile` would not: agent shells
are not login shells, and Amp regenerates the dotfiles when it saves a snapshot.)

Also per project:

- `.amp/services.yaml`: the admin portal link and login hint.
- `.gitignore`: if it ignores `/.agents`, replace that line with `/.agents/*`
  plus `!/.agents/setup`, `!/.agents/resume`, `!/.agents/sync-ai-config`,
  `!/.agents/orb-config`, and add `/.amp/*` with `!/.amp/services.yaml`.
- `bootstrap/app.php`: trust the portal proxy only inside an orb:
  `if (env('AMP_ORB')) { $middleware->trustProxies(at: '*'); }`

To update a project that already uses the template, copy `setup`, `resume` and
`sync-ai-config` again; a project from before `orb-config` existed also needs
`orb-config` filled in from the values that were in its `setup`.

Amp settings (once per project):

```bash
amp projects update <namespace/name> --base-branch develop   # Ship then merges into develop
```

The `notion` remote MCP server lives in personal settings (OAuth via
ampcode.com) and works in every project.
