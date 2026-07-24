create extension if not exists pgcrypto;

create table if not exists public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text unique not null,
  created_at timestamptz not null default now()
);

create table if not exists public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  consent_location boolean not null default false,
  created_at timestamptz not null default now(),
  unique(family_id, user_id)
);

create table if not exists public.locations (
  id bigint generated always as identity primary key,
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy double precision,
  speed double precision,
  battery integer,
  is_sharing boolean not null default true,
  recorded_at timestamptz not null default now()
);

create table if not exists public.alerts (
  id bigint generated always as identity primary key,
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('sos','zone','system')),
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.safe_zones (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  name text not null,
  latitude double precision,
  longitude double precision,
  radius_m integer not null default 100,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.locations enable row level security;
alter table public.alerts enable row level security;
alter table public.safe_zones enable row level security;

create or replace function public.is_family_member(target_family uuid)
returns boolean language sql security definer set search_path = public as $$
  select exists(select 1 from public.family_members where family_id = target_family and user_id = auth.uid());
$$;

create policy "family members can read their family" on public.family_members for select using (user_id = auth.uid() or public.is_family_member(family_id));
create policy "users can insert themselves" on public.family_members for insert with check (user_id = auth.uid());
create policy "members can read locations" on public.locations for select using (public.is_family_member(family_id));
create policy "users can write own locations" on public.locations for insert with check (user_id = auth.uid() and public.is_family_member(family_id));
create policy "members can read alerts" on public.alerts for select using (public.is_family_member(family_id));
create policy "members can create alerts" on public.alerts for insert with check (user_id = auth.uid() and public.is_family_member(family_id));
create policy "members can read zones" on public.safe_zones for select using (public.is_family_member(family_id));
create policy "members can manage zones" on public.safe_zones for all using (public.is_family_member(family_id));

alter publication supabase_realtime add table public.locations;
alter publication supabase_realtime add table public.alerts;
alter publication supabase_realtime add table public.family_members;
