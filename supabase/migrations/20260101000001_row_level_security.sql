-- Row Level Security. BUILD_PLAN.md Section 11: enable RLS on every table.
-- Policy: auth.uid() = user_id.
--
-- `categories` is the one shared, read-only reference table and is
-- intentionally left without a `user_id` column, so it gets a read-only
-- policy open to any authenticated user instead.

alter table public.accounts enable row level security;
alter table public.balance_snapshots enable row level security;
alter table public.txns enable row level security;
alter table public.obligations enable row level security;
alter table public.income_expectations enable row level security;
alter table public.envelopes enable row level security;
alter table public.envelope_categories enable row level security;
alter table public.allocations enable row level security;
alter table public.borrow_events enable row level security;
alter table public.settings enable row level security;
alter table public.categories enable row level security;

create policy "categories are readable by any authenticated user"
  on public.categories for select
  to authenticated
  using (true);

create policy "own accounts only"
  on public.accounts for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own balance snapshots only"
  on public.balance_snapshots for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own transactions only"
  on public.txns for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own obligations only"
  on public.obligations for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own income expectations only"
  on public.income_expectations for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own envelopes only"
  on public.envelopes for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- envelope_categories has no user_id of its own; ownership is inherited
-- from the parent envelope, matching how the local schema routes categories.
create policy "envelope categories follow the parent envelope's owner"
  on public.envelope_categories for all
  to authenticated
  using (
    exists (
      select 1 from public.envelopes e
      where e.id = envelope_categories.envelope_id
        and e.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.envelopes e
      where e.id = envelope_categories.envelope_id
        and e.user_id = auth.uid()
    )
  );

create policy "own allocations only"
  on public.allocations for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own borrow events only"
  on public.borrow_events for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own settings only"
  on public.settings for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
