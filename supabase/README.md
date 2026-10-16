# Baon — Supabase migrations

BUILD_PLAN.md Sections 11 and 17. These migrations set up the optional cloud
sync backend. The app works fully offline with no Supabase project at all
(BUILD_PLAN.md Section 3); this only matters once a user taps
**"Back up my data."**

## Files

- `20260101000000_initial_schema.sql` — tables mirroring `lib/data/db/tables.dart`.
- `20260101000001_row_level_security.sql` — RLS, `auth.uid() = user_id` on every table.
- `20260101000002_delete_my_data.sql` — the server half of "Delete all my data".

## Applying

This repository has not been linked to a live Supabase project. To apply
these migrations:

```
supabase init          # if this folder is not already a Supabase project
supabase link --project-ref <your-project-ref>
supabase db push
```

Then, in the Supabase dashboard:

1. Enable email/password auth (and Google sign-in, if wanted).
2. Confirm Row Level Security shows **enabled** on every table under
   Database → Tables.
3. Grant `execute` on `public.delete_my_data()` to the `authenticated` role
   (the migration already does this; verify it under Database → Functions).

## What is not included

- Storage buckets for the AI model file (BUILD_PLAN.md Section 17 says to
  host it on Hugging Face or Supabase Storage). Not needed until Tier 2
  ships.
- A sync client. `lib/sync/` is a placeholder directory; the outbox queue
  described in Section 11 (per-row `updated_at`, last-write-wins, soft
  delete) is not implemented, since it needs a live project and real device
  pair to test against.
