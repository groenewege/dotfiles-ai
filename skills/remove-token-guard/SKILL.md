---
name: remove-token-guard
description: Security hardening for GHSA-f9x3-7vq9-cph6. Removes Laravel's leftover `token` auth guard (and the scaffolding `/api/user` route) from a project, with a test, in one commit. Safe on any Laravel version; stops without changes when something actually uses the guard.
disable-model-invocation: true
---

# Remove the `token` guard (GHSA-f9x3-7vq9-cph6)

Laravel's `token` auth driver lets a non-string `api_token`
(`{"api_token":[0]}`, `?api_token[]=0`) match any user on MySQL/MariaDB. It is
fixed in Laravel 12.68.0+ and 13.29.0+. These projects never use the guard: it
is leftover scaffolding, so it goes whatever the Laravel version.

Reports are in English; the commit message is the French one in step 7.

## 1. Versions

- `composer show laravel/framework` on the current branch, and
  `git show origin/master:composer.lock` (search `"name": "laravel/framework"`)
  for production, which may run another version than develop.
- When the project is being upgraded to Laravel 13 (an `upgrade` branch), the
  lock must end at 13.29.0 or later, and this work is part of the upgrade:
  commit on the upgrade branch.

## 2. Affected?

Open `config/auth.php`. When no guard uses `'driver' => 'token'` (or the file
doesn't exist), report "not affected" with the versions from step 1 and stop.

## 3. Unused?

Search `app/`, `routes/`, `bootstrap/`, `config/`, `resources/` and `database/`
for `auth:api`, `auth('api')`, `guard('api')`, `shouldUse('api')`,
`'guard' => 'api'`, `authGuard('api')`, `api_token` and `TokenGuard`, and
`.env` / `.env.example` for `AUTH_GUARD=api`.

Stop and report, changing nothing, when anything other than the default
scaffolding route `Route::middleware('auth:api')->get('/user', ...)` uses the
guard, or when a migration or the users table has an `api_token` column
(`php artisan db:table users` or the migrations).

## 4. Remove the route and the guard together

Removing only the guard makes `auth:api` throw "Auth guard [api] is not
defined", so both changes go in the same commit.

- **API routes** are registered by `routes/api.php` and, in Laravel 11+, by the
  `api:` line of `withRouting()` in `bootstrap/app.php`. When the default
  `/user` route exists, remove it. Keep the file and its header comment, and
  drop the now unused `use Illuminate\Http\Request;`.
- **The guard**: remove the `api` entry from `guards` in `config/auth.php`.
  When it was the only entry, drop the `guards` key: Laravel's default `web`
  guard still applies. Delete `config/auth.php` only when nothing else remains
  in it; keep any `providers` override (e.g. a custom user model).

The two shapes seen so far: a Laravel 10 project with both the `/user` route
and the guard, and a Laravel 13 project with the guard only and no API routes.

## 5. Test

Add `tests/Feature/ApiTokenGuardTest.php` in the style of the sibling feature
tests: PHPUnit or Pest, the same attributes or annotations, the same traits.

- Assert that `config('auth.guards.api')` is null.
- When API routes are registered, also assert that `GET /api/user` returns 404
  with no token, with JSON `{"api_token": [0]}`, and with `{"api_token": 0}`.
  When the tests disable exception handling, expect `NotFoundHttpException`
  instead.

## 6. Verify

1. Run the new test.
2. `php artisan migrate:fresh --seed --env=testing`, then the full suite.
3. `php artisan route:list --path=api` doesn't list `api/user`, and
   `php artisan config:show auth.guards` still shows `web`. `--path` matches
   anywhere in the URI, so it also lists routes such as
   `depressif/depistage-rapide/{uuid}`: check that none of them starts with
   `api/` rather than expecting an empty list.

Done when all three hold; report failures with their output.

## 7. Commit

Commit on `develop`, or on the upgrade branch when the project is being
upgraded, with the message:

```
sécurité : suppression du guard api token (GHSA-f9x3-7vq9-cph6)
```

Don't push to staging or main/master. Report the versions from step 1, what was
removed, and the test result.
