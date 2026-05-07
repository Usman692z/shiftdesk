-- ──────────────────────────────────────────────
-- ShiftDesk — Supabase Schema
-- Run this in your Supabase SQL editor at:
-- https://supabase.com → Project → SQL Editor
-- ──────────────────────────────────────────────

-- 1. AGENTS
create table if not exists agents (
  id          text primary key,
  name        text not null,
  dept        text,
  role        text,
  type        text default 'regular',
  country     text default 'Pakistan',
  timezone    text default 'Asia/Karachi',
  shift_start text default '09:00',
  pw          text,
  created_at  timestamptz default now()
);

-- 2. SHIFT STATUS  (one row per agent per day, upserted on check-in/out)
create table if not exists shift_status (
  id             uuid default gen_random_uuid() primary key,
  date           text not null,
  agent_id       text references agents(id) on delete cascade,
  agent_name     text,
  dept           text,
  online         boolean default false,
  check_in       text,
  check_in_ts    bigint,
  check_out      text,
  check_out_ts   bigint,
  total_duration text default '',
  shift_num      int  default 1,
  updated_at     timestamptz default now(),
  unique(date, agent_id)
);

-- 3. TASKS
create table if not exists tasks (
  id          uuid default gen_random_uuid() primary key,
  date        text,
  time        text,
  agent_id    text references agents(id) on delete cascade,
  agent_name  text,
  dept        text,
  task        text,
  priority    text default 'Normal',
  assigned_by text,
  done        boolean default false,
  created_at  timestamptz default now()
);

-- 4. ACTIVITY LOGS
create table if not exists activity_logs (
  id         uuid default gen_random_uuid() primary key,
  date       text,
  time       text,
  agent_id   text,
  agent_name text,
  dept       text,
  action     text,
  detail     text,
  created_at timestamptz default now()
);

-- 5. ACTIVITY TRACKING  (real-time ping, one row per agent per day)
create table if not exists activity_tracking (
  id                   uuid default gen_random_uuid() primary key,
  date                 text not null,
  agent_id             text references agents(id) on delete cascade,
  agent_name           text,
  dept                 text,
  time                 text,
  last_seen            bigint,
  activity_status      text default 'offline',
  total_active_minutes int  default 0,
  updated_at           timestamptz default now(),
  unique(date, agent_id)
);

-- ──────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- The app uses the anon key (public), so we allow
-- full access for now.  Tighten with auth later.
-- ──────────────────────────────────────────────
alter table agents           enable row level security;
alter table shift_status     enable row level security;
alter table tasks            enable row level security;
alter table activity_logs    enable row level security;
alter table activity_tracking enable row level security;

create policy "public_all" on agents            for all using (true) with check (true);
create policy "public_all" on shift_status      for all using (true) with check (true);
create policy "public_all" on tasks             for all using (true) with check (true);
create policy "public_all" on activity_logs     for all using (true) with check (true);
create policy "public_all" on activity_tracking for all using (true) with check (true);

-- ──────────────────────────────────────────────
-- SEED: Default agents  (matches the hardcoded
-- array in the original index.html)
-- ──────────────────────────────────────────────
insert into agents (id, name, dept, role, type, country, timezone, shift_start, pw) values
  ('RJY', 'Radwan Jamal Yassin',   'Corporate', 'Data + Renewals + Rectifications',         'senior',  'KSA',      'Asia/Riyadh', '09:00', 'MTIzNA=='),
  ('MB',  'Muhammad Baksh',        'Corporate', 'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('NJD', 'Nida Javaid Dar',       'Corporate', 'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('SA',  'Sadia Asif',            'Corporate', 'Corporate QA',                             'qa',      'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('MK',  'Muhammad Kamran',       'Corporate', 'Corporate Senior',                         'senior',  'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('SD',  'SUMAN David',           'Retail',    'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('RR',  'Rafia Rauf',            'Retail',    'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('AR',  'Abdul Rehman',          'Retail',    'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('MF',  'Muhammad Farhan',       'Retail',    'Support Manager - Retail',                 'manager', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('SUM', 'Suman',                 'Retail',    'Retail QA',                                'qa',      'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('MR',  'Muhammad Raja',         'Reseller',  'Data + Renewals + Rectifications (KSA)',   'senior',  'KSA',      'Asia/Riyadh', '09:00', 'MTIzNA=='),
  ('MHU', 'Muhammad Hafiz Usman',  'Reseller',  'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA=='),
  ('AA',  'Areeeba Arshad',        'Reseller',  'Data + Renewals + Rectifications',         'regular', 'Pakistan', 'Asia/Karachi','09:00', 'MTIzNA==')
on conflict (id) do nothing;
