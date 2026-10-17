# The gate: go or plan

Every item is either **go** (built without a plan) or **plan** (its plan is
approved before any code is written). Decide after reading the code the item
will touch. A brief that sounds small can land on a migration, and a brief that
sounds big can be a single Blade view.

## Plan triggers

Any one of these makes the item a **plan** item:

- **An open question** in the brief, or a line "Before implementing, give your
  opinion on …". The question is asked in the preflight, whatever the item's
  size.
- **Schema or data:** a migration, a column change, a backfill, a data fix, or
  anything that deletes or overwrites existing records.
- **Dependencies:** a new composer or npm package, or a version bump.
- **Access:** authentication, policies, gates, roles, permissions,
  impersonation, tenant scoping.
- **Outbound effects:** mail, notifications, SMS, webhooks, calls to external
  APIs, anything that reaches a real person or a third party.
- **Runtime and deploy:** config files, `.env` keys, queues, the scheduler,
  deploy or build scripts, the frontend toolchain.
- **Breadth:** more than about six files, or more than one area (admin and
  public site and an import, for example).
- **An unstated adaptation:** the item is "like X" and building it means
  adapting X in ways the brief does not spell out.

With no trigger, the item is **go**. Write one line saying why ("one Filament
form field and its test, no migration").

## Overrides

`plan first` in the arguments makes every item a plan item. `no plan` makes
every item go, except that open questions and destructive data changes are
still asked.

## During the run

The gate holds only as long as the item stays the size it was judged. A go item
whose build needs a trigger (the builder finds a migration is required, or a
policy has to change) becomes **blocked** with that finding as its question. It
is never quietly widened.
