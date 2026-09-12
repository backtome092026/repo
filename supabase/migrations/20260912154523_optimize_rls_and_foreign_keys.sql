-- Advisor-driven indexes for the remaining foreign-key lookup paths.
create index if not exists claims_reviewed_by_idx on public.claims(reviewed_by) where reviewed_by is not null;
create index if not exists enrollment_requests_reviewed_by_idx on public.enrollment_requests(reviewed_by) where reviewed_by is not null;
create index if not exists item_events_performed_by_idx on public.item_events(performed_by) where performed_by is not null;
create index if not exists parent_student_links_student_idx on public.parent_student_links(student_id);
create index if not exists safety_reports_assigned_to_idx on public.safety_reports(assigned_to) where assigned_to is not null;
create index if not exists staff_invites_created_by_idx on public.staff_invites(created_by);
create index if not exists timeline_posts_author_idx on public.timeline_posts(author_id);

-- One SELECT policy per role/action avoids repeatedly evaluating permissive policies.
drop policy if exists "public reads safe item records" on public.items;
drop policy if exists "staff reads school items" on public.items;
drop policy if exists "staff manages school items" on public.items;
create policy "public reads safe item records" on public.items for select to anon
using(status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED','RETURNED'));
create policy "members read safe or staff school items" on public.items for select to authenticated
using(status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED','RETURNED') or (school_id=public.current_school_id() and public.is_school_staff()));
create policy "staff inserts school items" on public.items for insert to authenticated
with check(school_id=public.current_school_id() and public.is_school_staff());
create policy "staff updates school items" on public.items for update to authenticated
using(school_id=public.current_school_id() and public.is_school_staff())
with check(school_id=public.current_school_id() and public.is_school_staff());
create policy "staff deletes school items" on public.items for delete to authenticated
using(school_id=public.current_school_id() and public.is_school_staff());

drop policy if exists "school reads visible timelines" on public.timeline_posts;
drop policy if exists "staff reads all school timelines" on public.timeline_posts;
create policy "members read school timelines" on public.timeline_posts for select to authenticated
using(school_id=public.current_school_id() and public.is_active_member() and ((not is_hidden and moderation_status='APPROVED') or public.is_school_staff()));

-- Cache auth.uid() once per statement and tighten relationship checks to the current school.
drop policy if exists "active students request donations" on public.donation_requests;
create policy "active students request donations" on public.donation_requests for insert to authenticated
with check(requester_id=(select auth.uid()) and public.is_active_member() and exists(select 1 from public.donations d where d.id=donation_id and d.school_id=public.current_school_id() and d.status in ('AVAILABLE','RESERVED')));
drop policy if exists "requests visible to participants" on public.donation_requests;
create policy "requests visible to participants" on public.donation_requests for select to authenticated
using(requester_id=(select auth.uid()) or exists(select 1 from public.donations d where d.id=donation_id and d.school_id=public.current_school_id() and (d.donor_id=(select auth.uid()) or public.is_school_staff())));
drop policy if exists "donors review requests" on public.donation_requests;
create policy "donors review requests" on public.donation_requests for update to authenticated
using(exists(select 1 from public.donations d where d.id=donation_id and d.school_id=public.current_school_id() and (d.donor_id=(select auth.uid()) or public.is_school_staff())))
with check(exists(select 1 from public.donations d where d.id=donation_id and d.school_id=public.current_school_id() and (d.donor_id=(select auth.uid()) or public.is_school_staff())));

drop policy if exists "active students create donations" on public.donations;
create policy "active students create donations" on public.donations for insert to authenticated
with check(donor_id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member());
drop policy if exists "active students create deeds" on public.good_deeds;
create policy "active students create deeds" on public.good_deeds for insert to authenticated
with check(student_id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member());
drop policy if exists "active students propose innovations" on public.innovations;
create policy "active students propose innovations" on public.innovations for insert to authenticated
with check(student_id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member());

drop policy if exists "active students react" on public.good_deed_reactions;
create policy "active students react" on public.good_deed_reactions for insert to authenticated
with check(student_id=(select auth.uid()) and public.is_active_member() and exists(select 1 from public.good_deeds g where g.id=deed_id and g.school_id=public.current_school_id() and g.moderation_status='APPROVED'));
drop policy if exists "students change reaction" on public.good_deed_reactions;
create policy "students change reaction" on public.good_deed_reactions for update to authenticated
using(student_id=(select auth.uid())) with check(student_id=(select auth.uid()));
drop policy if exists "students remove reaction" on public.good_deed_reactions;
create policy "students remove reaction" on public.good_deed_reactions for delete to authenticated
using(student_id=(select auth.uid()));

drop policy if exists "active students join teams" on public.innovation_members;
create policy "active students join teams" on public.innovation_members for insert to authenticated
with check(student_id=(select auth.uid()) and public.is_active_member() and exists(select 1 from public.innovations i where i.id=innovation_id and i.school_id=public.current_school_id() and i.moderation_status='APPROVED'));
drop policy if exists "leaders review members" on public.innovation_members;
create policy "leaders review members" on public.innovation_members for update to authenticated
using(exists(select 1 from public.innovations i where i.id=innovation_id and i.school_id=public.current_school_id() and (i.student_id=(select auth.uid()) or public.is_school_staff())))
with check(exists(select 1 from public.innovations i where i.id=innovation_id and i.school_id=public.current_school_id() and (i.student_id=(select auth.uid()) or public.is_school_staff())));

drop policy if exists "student sees own enrollment" on public.enrollment_requests;
create policy "student sees own enrollment" on public.enrollment_requests for select to authenticated
using(student_id=(select auth.uid()) or (school_id=public.current_school_id() and public.is_school_staff()));
drop policy if exists "families see links" on public.parent_student_links;
create policy "families see links" on public.parent_student_links for select to authenticated
using(parent_id=(select auth.uid()) or student_id=(select auth.uid()) or (public.is_school_staff() and exists(select 1 from public.profiles p where p.id=student_id and p.school_id=public.current_school_id())));
drop policy if exists "active members report" on public.safety_reports;
create policy "active members report" on public.safety_reports for insert to authenticated
with check(reporter_id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member());
drop policy if exists "reporters see own reports" on public.safety_reports;
create policy "reporters see own reports" on public.safety_reports for select to authenticated
using(reporter_id=(select auth.uid()) or (school_id=public.current_school_id() and public.is_school_staff()));

drop policy if exists "admins create invites" on public.staff_invites;
create policy "admins create invites" on public.staff_invites for insert to authenticated
with check(school_id=public.current_school_id() and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin' and p.account_status='APPROVED' and not p.is_blocked));
drop policy if exists "admins revoke invites" on public.staff_invites;
create policy "admins revoke invites" on public.staff_invites for delete to authenticated
using(school_id=public.current_school_id() and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin' and p.account_status='APPROVED' and not p.is_blocked));

drop policy if exists "authors delete posts" on public.timeline_posts;
create policy "authors delete posts" on public.timeline_posts for delete to authenticated
using(school_id=public.current_school_id() and (author_id=(select auth.uid()) or profile_id=(select auth.uid()) or public.is_school_staff()));
drop policy if exists "members write enabled walls" on public.timeline_posts;
create policy "members write enabled walls" on public.timeline_posts for insert to authenticated
with check(author_id=(select auth.uid()) and school_id=public.current_school_id() and public.is_active_member() and exists(select 1 from public.profiles p where p.id=profile_id and p.school_id=public.current_school_id() and (p.wall_enabled or p.id=(select auth.uid()))));
