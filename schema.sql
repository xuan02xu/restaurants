-- 貼到 Supabase → SQL Editor → Run
-- 建立共用名單的資料表

create table if not exists restaurants (
  id          text primary key,
  name        text not null,
  category    text,
  phone       text,
  note        text,
  links       jsonb not null default '[]'::jsonb,
  hours       jsonb,
  menu        text,
  created_at  timestamptz not null default now()
);

create index if not exists restaurants_created_at_idx
  on restaurants (created_at desc);

alter table restaurants enable row level security;

-- 開放給 anon key：任何拿到網址的人都能讀寫。
-- 適合朋友之間的小名單；若要限制，見 README 的「誰可以改」。
drop policy if exists "read"   on restaurants;
drop policy if exists "insert" on restaurants;
drop policy if exists "update" on restaurants;
drop policy if exists "delete" on restaurants;

create policy "read"   on restaurants for select using (true);
create policy "insert" on restaurants for insert with check (true);
create policy "update" on restaurants for update using (true) with check (true);
create policy "delete" on restaurants for delete using (true);
