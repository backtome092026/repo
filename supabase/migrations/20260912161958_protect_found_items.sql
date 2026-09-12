revoke select on public.public_items from anon;
revoke select on public.items from anon;
drop policy if exists "public reads safe item records" on public.items;
drop policy if exists "members read safe or staff school items" on public.items;
create policy "active members read school items" on public.items for select to authenticated
using(school_id=public.current_school_id() and public.is_active_member() and (status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED','RETURNED') or public.is_school_staff()));

drop policy if exists "anyone submits claims" on public.claims;
create policy "active members submit school claims" on public.claims for insert to authenticated
with check(school_id=public.current_school_id() and public.is_active_member() and exists(select 1 from public.items item where item.id=item_id and item.school_id=public.current_school_id() and item.status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED')));

create or replace function public.submit_claim(p_item_id uuid,p_student_name text,p_student_email text,p_contact_info text,p_identifying_details text,p_lost_date date,p_lost_location text) returns uuid language plpgsql security definer set search_path=public as $$
declare v_id uuid;v_school uuid:=public.current_school_id();
begin
  if (select auth.uid()) is null or not public.is_active_member() then raise exception 'Approved account required';end if;
  if not exists(select 1 from items where id=p_item_id and school_id=v_school and status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED')) then raise exception 'Item unavailable';end if;
  insert into claims(item_id,school_id,student_name,student_email,contact_info,identifying_details,lost_date,lost_location) values(p_item_id,v_school,p_student_name,p_student_email,p_contact_info,p_identifying_details,p_lost_date,p_lost_location) returning id into v_id;
  update items set status='CLAIM_PENDING',updated_at=now() where id=p_item_id and school_id=v_school and status='FOUND';
  insert into item_events(item_id,event_type,performed_by,metadata) values(p_item_id,'CLAIM_SUBMITTED',(select auth.uid()),jsonb_build_object('claim_id',v_id));
  return v_id;
end$$;
revoke execute on function public.submit_claim(uuid,text,text,text,text,date,text) from public,anon;
grant execute on function public.submit_claim(uuid,text,text,text,text,date,text) to authenticated;
