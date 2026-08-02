-- 菜單照片：建立 Storage bucket 與權限
-- Supabase → SQL Editor → New query → 全部貼上 → Run
-- 跑完到 Storage 分頁應該會看到一個叫 menus 的 bucket

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'menus', 'menus', true, 5242880,
  array['image/jpeg','image/png','image/webp']
)
on conflict (id) do update set
  public             = true,
  file_size_limit    = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

-- 任何人都能看菜單、任何人都能上傳（跟 restaurants 表同樣的信任模型）
drop policy if exists "menu read"   on storage.objects;
drop policy if exists "menu insert" on storage.objects;
drop policy if exists "menu update" on storage.objects;

create policy "menu read"   on storage.objects for select using (bucket_id = 'menus');
create policy "menu insert" on storage.objects for insert with check (bucket_id = 'menus');
create policy "menu update" on storage.objects for update using (bucket_id = 'menus') with check (bucket_id = 'menus');

-- file_size_limit 是 5MB，但程式上傳前會先把照片縮到最長邊 1600px、
-- 壓成 JPEG，手機拍的照片通常會降到 200～400KB。
-- 免費方案有 1GB 容量、每月 5GB 流量。

-- 想看用掉多少：
--   select count(*), pg_size_pretty(sum((metadata->>'size')::bigint))
--   from storage.objects where bucket_id = 'menus';

-- 刪掉店家時圖片不會跟著刪（會變成孤兒檔）。要清理：
--   delete from storage.objects
--   where bucket_id = 'menus'
--     and not exists (
--       select 1 from restaurants r
--       where r.menu like '%' || storage.objects.name
--     );
