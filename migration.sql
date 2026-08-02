-- 一次補上 hours 與 menu 兩個欄位，並強制 PostgREST 重讀 schema
-- Supabase → SQL Editor → New query → 全部貼上 → Run
-- 既有資料不受影響（新欄位會是 NULL）

alter table public.restaurants add column if not exists hours jsonb;
alter table public.restaurants add column if not exists menu  text;

-- 這行是重點：沒有它，PostgREST 會繼續回
-- {"code":"PGRST204","message":"Could not find the 'hours' column ..."}
notify pgrst, 'reload schema';

-- 跑完等 5～10 秒再回網頁按重試。
-- 驗證欄位真的建好了：
--   select column_name, data_type from information_schema.columns
--   where table_schema='public' and table_name='restaurants' order by ordinal_position;

-- hours 格式：key 是星期（0=週日 … 6=週六），值是當天的時段陣列。
-- 空陣列＝當天公休；整欄 NULL＝沒填營業時間。
-- close 比 open 早代表跨夜；24:00 代表午夜。
-- {
--   "0": [],
--   "1": [{"open":"11:00","close":"14:00"},{"open":"17:00","close":"24:00"}],
--   "5": [{"open":"18:00","close":"02:00"}]
-- }
