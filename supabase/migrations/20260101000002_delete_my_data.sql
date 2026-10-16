-- BUILD_PLAN.md Section 12: "Delete all my data" must delete the local file
-- and the server rows. This function is the server half. The client deletes
-- its local SQLite file itself (see lib/features/settings/settings_screen.dart
-- `_confirmDelete`).
--
-- security definer so a user can remove their own rows even though RLS would
-- otherwise require a row-by-row delete from the client; the function still
-- only ever touches auth.uid()'s own rows.

create or replace function public.delete_my_data()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then
    raise exception 'delete_my_data must be called by an authenticated user';
  end if;

  delete from public.borrow_events where user_id = caller;
  delete from public.allocations where user_id = caller;
  delete from public.envelope_categories
    where envelope_id in (select id from public.envelopes where user_id = caller);
  delete from public.envelopes where user_id = caller;
  delete from public.txns where user_id = caller;
  delete from public.balance_snapshots where user_id = caller;
  delete from public.obligations where user_id = caller;
  delete from public.income_expectations where user_id = caller;
  delete from public.accounts where user_id = caller;
  delete from public.settings where user_id = caller;
end;
$$;

grant execute on function public.delete_my_data() to authenticated;
