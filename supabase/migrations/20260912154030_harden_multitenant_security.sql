-- Final multitenant hardening for the production Back2Me schema.

-- Privileged helpers are APIs, not public functions. Remove PostgreSQL's default
-- PUBLIC execute grant and expose only the calls required by each application role.
revoke execute on function public.current_school_id() from public, anon;
revoke execute on function public.is_school_staff() from public, anon;
revoke execute on function public.is_active_member() from public, anon;
revoke execute on function public.create_found_item(text,text,text,date,text,text,text,text,numeric,text) from public, anon;
revoke execute on function public.submit_claim(uuid,text,text,text,text,date,text) from public;
revoke execute on function public.complete_item_return(uuid) from public, anon;
revoke execute on function public.complete_donation(uuid,uuid) from public, anon;
revoke execute on function public.review_enrollment(uuid,public.account_status,text) from public, anon;
revoke execute on function public.block_school_member(uuid,text) from public, anon;
revoke execute on function public.handle_new_account() from public, anon, authenticated;
grant execute on function public.current_school_id(),public.is_school_staff(),public.is_active_member() to authenticated;
grant execute on function public.create_found_item(text,text,text,date,text,text,text,text,numeric,text) to authenticated;

-- Direct Data API reads must obey the same school boundary as the app views.
drop policy if exists "members read own profile" on public.profiles;
create policy "approved members read school profiles" on public.profiles for select to authenticated
using (id=(select auth.uid()) or (school_id=public.current_school_id() and public.is_active_member()));
create policy "members update own profile" on public.profiles for update to authenticated
using (id=(select auth.uid()) and public.is_active_member())
with check (id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member());

create policy "admins update school" on public.schools for update to authenticated
using (id=public.current_school_id() and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin' and p.account_status='APPROVED' and not p.is_blocked))
with check (id=public.current_school_id());

drop policy if exists "approved donations visible" on public.donations;
create policy "school donations visible" on public.donations for select to authenticated
using (school_id=public.current_school_id() and public.is_active_member() and (moderation_status='APPROVED' or donor_id=(select auth.uid()) or public.is_school_staff()));
drop policy if exists "donors manage donations" on public.donations;
create policy "donors manage school donations" on public.donations for update to authenticated
using (school_id=public.current_school_id() and (donor_id=(select auth.uid()) or public.is_school_staff()))
with check (school_id=public.current_school_id() and (donor_id=(select auth.uid()) or public.is_school_staff()));

drop policy if exists "approved deeds visible" on public.good_deeds;
create policy "school deeds visible" on public.good_deeds for select to authenticated
using (school_id=public.current_school_id() and public.is_active_member() and (moderation_status='APPROVED' or student_id=(select auth.uid()) or public.is_school_staff()));
drop policy if exists "owners edit deeds" on public.good_deeds;
create policy "owners edit school deeds" on public.good_deeds for update to authenticated
using (school_id=public.current_school_id() and (student_id=(select auth.uid()) or public.is_school_staff()))
with check (school_id=public.current_school_id() and (student_id=(select auth.uid()) or public.is_school_staff()));

drop policy if exists "approved innovations visible" on public.innovations;
create policy "school innovations visible" on public.innovations for select to authenticated
using (school_id=public.current_school_id() and public.is_active_member() and (moderation_status='APPROVED' or student_id=(select auth.uid()) or public.is_school_staff()));
drop policy if exists "owners manage innovations" on public.innovations;
create policy "owners manage school innovations" on public.innovations for update to authenticated
using (school_id=public.current_school_id() and (student_id=(select auth.uid()) or public.is_school_staff()))
with check (school_id=public.current_school_id() and (student_id=(select auth.uid()) or public.is_school_staff()));

drop policy if exists "reactions visible" on public.good_deed_reactions;
create policy "school reactions visible" on public.good_deed_reactions for select to authenticated
using (exists(select 1 from public.good_deeds g where g.id=deed_id and g.school_id=public.current_school_id()) and public.is_active_member());
drop policy if exists "members visible" on public.innovation_members;
create policy "school innovation members visible" on public.innovation_members for select to authenticated
using (exists(select 1 from public.innovations i where i.id=innovation_id and i.school_id=public.current_school_id()) and public.is_active_member());

create policy "staff reads all school timelines" on public.timeline_posts for select to authenticated
using (school_id=public.current_school_id() and public.is_school_staff());

-- UPDATE policies explicitly constrain the resulting row as well as the source row.
drop policy if exists "staff updates school claims" on public.claims;
create policy "staff updates school claims" on public.claims for update to authenticated
using (school_id=public.current_school_id() and public.is_school_staff())
with check (school_id=public.current_school_id() and public.is_school_staff());
drop policy if exists "admins update school settings" on public.school_settings;
create policy "admins update school settings" on public.school_settings for update to authenticated
using (school_id=public.current_school_id() and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin' and p.account_status='APPROVED' and not p.is_blocked))
with check (school_id=public.current_school_id());
drop policy if exists "staff reviews enrollment" on public.enrollment_requests;
create policy "staff reviews enrollment" on public.enrollment_requests for update to authenticated
using (school_id=public.current_school_id() and public.is_school_staff())
with check (school_id=public.current_school_id() and public.is_school_staff());
drop policy if exists "staff moderates timelines" on public.timeline_posts;
create policy "staff moderates timelines" on public.timeline_posts for update to authenticated
using (school_id=public.current_school_id() and public.is_school_staff())
with check (school_id=public.current_school_id() and public.is_school_staff());
drop policy if exists "staff resolves reports" on public.safety_reports;
create policy "staff resolves reports" on public.safety_reports for update to authenticated
using (school_id=public.current_school_id() and public.is_school_staff())
with check (school_id=public.current_school_id() and public.is_school_staff());

-- Views now rely on RLS instead of silently bypassing it.
alter view public.school_directory set (security_invoker=true);
alter view public.profile_directory set (security_invoker=true);
alter view public.timeline_feed set (security_invoker=true);
alter view public.public_donations set (security_invoker=true);
alter view public.good_deeds_feed set (security_invoker=true);
alter view public.innovation_board set (security_invoker=true);
alter view public.return_leaderboard set (security_invoker=true);
alter view public.donation_leaderboard set (security_invoker=true);
alter view public.kindness_leaderboard set (security_invoker=true);
revoke all on public.public_donations,public.good_deeds_feed,public.innovation_board,public.return_leaderboard,public.donation_leaderboard,public.kindness_leaderboard from anon;
grant select(id,name,slug,logo_url) on public.schools to anon;
drop policy if exists "public school directory" on public.schools;
create policy "public school directory" on public.schools for select to anon using(is_active);

-- Index foreign-key columns used by authorization joins and operational screens.
create index if not exists profiles_school_idx on public.profiles(school_id);
create index if not exists items_created_by_idx on public.items(created_by);
create index if not exists items_finder_idx on public.items(finder_student_id) where finder_student_id is not null;
create index if not exists claims_item_idx on public.claims(item_id);
create index if not exists donations_donor_idx on public.donations(donor_id);
create index if not exists donations_recipient_idx on public.donations(recipient_id) where recipient_id is not null;
create index if not exists donation_requests_requester_idx on public.donation_requests(requester_id);
create index if not exists good_deeds_student_idx on public.good_deeds(student_id);
create index if not exists good_deed_reactions_student_idx on public.good_deed_reactions(student_id);
create index if not exists innovations_student_idx on public.innovations(student_id);
create index if not exists innovation_members_student_idx on public.innovation_members(student_id);
create index if not exists staff_invites_school_idx on public.staff_invites(school_id);
create index if not exists timeline_school_author_idx on public.timeline_posts(school_id,author_id,created_at desc);
create index if not exists safety_reports_reporter_idx on public.safety_reports(reporter_id);
create index if not exists safety_reports_target_idx on public.safety_reports(target_user_id) where target_user_id is not null;
