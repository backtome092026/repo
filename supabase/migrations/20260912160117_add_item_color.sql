alter table public.items add column color text;

alter table public.items add constraint items_color_not_blank
check (color is null or btrim(color) <> '') not valid;
alter table public.items validate constraint items_color_not_blank;

create or replace view public.public_items with (security_invoker=true) as
select id,item_number,category,subcategory,description,photo_url,found_date,
       found_location,public_location,condition,estimated_value,status,created_at,color
from public.items
where status in ('FOUND','CLAIM_PENDING','CLAIM_APPROVED','RETURNED');

grant select on public.public_items to anon,authenticated;

create or replace function public.create_found_item(
  p_category text,p_subcategory text,p_description text,p_found_date date,
  p_found_location text,p_public_location text,p_storage_location text,
  p_condition text,p_estimated_value numeric,p_internal_notes text,p_color text
) returns uuid
language plpgsql security definer set search_path=public
as $$
declare
  v_id uuid;
  v_school uuid:=public.current_school_id();
  v_number text;
begin
  if not public.is_school_staff() then raise exception 'Unauthorized'; end if;
  if nullif(btrim(p_color),'') is null then raise exception 'Color is required'; end if;
  v_number:='B2M-'||extract(year from current_date)::int||'-'||lpad(nextval('item_number_seq')::text,4,'0');
  insert into items(school_id,item_number,category,color,subcategory,description,found_date,found_location,public_location,storage_location,condition,estimated_value,internal_notes,created_by)
  values(v_school,v_number,btrim(p_category),btrim(p_color),p_subcategory,btrim(p_description),p_found_date,btrim(p_found_location),btrim(p_public_location),p_storage_location,p_condition,p_estimated_value,p_internal_notes,auth.uid())
  returning id into v_id;
  insert into item_events(item_id,event_type,performed_by) values(v_id,'FOUND',auth.uid());
  return v_id;
end
$$;

revoke execute on function public.create_found_item(text,text,text,date,text,text,text,text,numeric,text,text) from public,anon;
grant execute on function public.create_found_item(text,text,text,date,text,text,text,text,numeric,text,text) to authenticated;
