# Amp orb template for Laravel projects

Copy into a Laravel project to make Amp orbs start with PHP 8.3, Composer,
MySQL 8.0, Node, seeded development and test databases, Laravel Boost, a
portal for the site, and the skills and `AGENTS.md` from this repository.

```bash
cp -R ~/dotfiles-ai/orb/laravel/.agents ~/dotfiles-ai/orb/laravel/.amp <project>/
```

Then adapt per project:

- `.agents/setup`: `DB_NAME`, `DB_TEST_NAME` (must match `phpunit.xml`), the PHP
  extensions, and the Satis host in `composer_auth_json` and the profile export.
  Drop the Satis parts if the project has no private Composer repository.
- `.agents/sync-ai-config`: the orb notes (database names, seeded logins, admin path).
- `.amp/services.yaml`: the admin portal link and login hint.
- `.gitignore`: if it ignores `/.agents`, replace that line with
  `/.agents/*` plus `!/.agents/setup`, `!/.agents/resume`, `!/.agents/sync-ai-config`,
  and add `/.amp/*` with `!/.amp/services.yaml`.
- `bootstrap/app.php`: trust the portal proxy only inside an orb:
  `if (env('AMP_ORB')) { $middleware->trustProxies(at: '*'); }`

Amp settings (once per project):

```bash
amp projects update <namespace/name> --base-branch develop --ship-behavior push-to-branch
```

Store `SATIS_USERNAME` and `SATIS_PASSWORD` as **project** secrets: `.agents/setup`
does not receive personal secrets. The `notion` remote MCP server lives in personal
settings (OAuth via ampcode.com) and works in every project.
