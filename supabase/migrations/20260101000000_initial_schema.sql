-- Baon initial schema. BUILD_PLAN.md Section 11.
--
-- Mirrors lib/data/db/tables.dart. The local SQLite database is the source
-- of truth (Section 3); this schema exists only for the optional "Back up my
-- data" sync path. Every table carries the same shape as its local twin so
-- the sync outbox can map a row one-to-one.
--
-- Money stays INTEGER centavos here too. Never change a money column to
-- numeric or float.

create extension if not exists "pgcrypto";

create table if not exists public.accounts (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  provider_key text not null,
  label text not null,
  role text not null check (role in ('spending', 'savings', 'buffer')),
  include_in_spendable boolean not null default true,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.balance_snapshots (
  id text primary key,
  account_id text not null references public.accounts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  balance_cents bigint not null,
  source text not null check (source in ('manual', 'notification', 'derived')),
  captured_at timestamptz not null,
  note text
);

create table if not exists public.categories (
  key text primary key,
  display_name text not null,
  is_essential boolean not null,
  icon text not null,
  sort_order integer not null
);

create table if not exists public.txns (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  account_id text not null references public.accounts (id) on delete cascade,
  amount_cents bigint not null check (amount_cents >= 0),
  direction text not null check (direction in ('in', 'out')),
  category_key text not null references public.categories (key),
  merchant_raw text,
  note text,
  occurred_at timestamptz not null,
  source text not null check (source in ('manual', 'notification', 'reconciled')),
  category_confidence real not null default 0,
  user_corrected boolean not null default false,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.obligations (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  label text not null,
  amount_cents bigint not null check (amount_cents >= 0),
  cadence text not null check (cadence in ('once', 'weekly', 'monthly', 'none')),
  next_due_on date not null,
  category_key text not null references public.categories (key),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.income_expectations (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  label text not null,
  amount_cents bigint not null check (amount_cents >= 0),
  cadence text not null check (cadence in ('once', 'weekly', 'monthly', 'none')),
  next_expected_on date not null,
  confidence text not null check (confidence in ('certain', 'likely', 'unsure')),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.envelopes (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  label text not null,
  shape text not null check (shape in ('steady', 'episodic', 'reserve')),
  refill_cents bigint not null check (refill_cents >= 0),
  refill_cadence text not null check (refill_cadence in ('once', 'weekly', 'monthly', 'none')),
  refill_anchor text not null default '',
  allow_borrow_from jsonb not null default '[]'::jsonb,
  priority integer not null default 5,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.envelope_categories (
  envelope_id text not null references public.envelopes (id) on delete cascade,
  category_key text not null references public.categories (key),
  primary key (envelope_id, category_key)
);

create table if not exists public.allocations (
  id text primary key,
  envelope_id text not null references public.envelopes (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  balance_cents bigint not null,
  period_start date not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.borrow_events (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  from_envelope_id text not null references public.envelopes (id) on delete cascade,
  to_envelope_id text not null references public.envelopes (id) on delete cascade,
  amount_cents bigint not null check (amount_cents >= 0),
  occurred_at timestamptz not null,
  repaid_at timestamptz
);

create table if not exists public.settings (
  user_id uuid not null references auth.users (id) on delete cascade,
  key text not null,
  value text not null,
  primary key (user_id, key)
);

-- BUILD_PLAN.md Section 15 seed categories. Kept identical to
-- lib/data/db/seed.dart so a fresh cloud account and a fresh local
-- install always agree.
insert into public.categories (key, display_name, is_essential, icon, sort_order)
values
  ('transport', 'Transport', true, 'directions_bus', 10),
  ('food_daily', 'Everyday food', true, 'restaurant', 20),
  ('food_delivery', 'Food delivery', false, 'delivery_dining', 30),
  ('groceries', 'Groceries', true, 'shopping_basket', 40),
  ('dates_leisure', 'Dates and leisure', false, 'favorite', 50),
  ('load_data', 'Load and data', true, 'signal_cellular_alt', 60),
  ('school', 'School', true, 'school', 70),
  ('health', 'Health', true, 'medical_services', 80),
  ('shopping', 'Shopping', false, 'shopping_bag', 90),
  ('fees', 'Fees', false, 'receipt_long', 100),
  ('transfer_internal', 'Transfer between my accounts', false, 'swap_horiz', 110),
  ('savings_in', 'Money into savings', false, 'savings', 120),
  ('income', 'Income', false, 'payments', 130),
  ('other', 'Unaccounted', false, 'help_outline', 140)
on conflict (key) do nothing;

create index if not exists idx_txn_account_occurred on public.txns (account_id, occurred_at);
create index if not exists idx_txn_user on public.txns (user_id);
create index if not exists idx_snapshot_account_captured on public.balance_snapshots (account_id, captured_at desc);
create index if not exists idx_allocation_envelope on public.allocations (envelope_id);
create index if not exists idx_envelope_user on public.envelopes (user_id);
