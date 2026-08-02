網址：https://xuan02xu.github.io/restaurants/

# 我的口袋名單

一個收藏餐廳＋線上點餐連結的網站。決定不了就按「抽一家」。

## 檔案

| 檔案 | 用途 |
|---|---|
| `index.html` | 可直接部署的完整網站，React 已內嵌，無外部相依 |
| `schema.sql` | 共用模式要用的資料表，貼到 Supabase 執行 |
| `migration.sql` | 已經建過表的話，跑這個補上 hours / menu 欄位 |
| `storage.sql` | 要上傳菜單照片的話，跑這個建 Storage bucket |
| `restaurant-pocket-list.jsx` | 原始碼 |

## 兩種模式

打開 `index.html`，最上面有一段設定：

```js
window.POCKET_CONFIG = {
  supabaseUrl: "https://fqubwaqrrfrbfqqvbjdl.supabase.co",
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdWJ3YXFycmZyYmZxcXZiamRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2MzUxNTksImV4cCI6MjEwMTIxMTE1OX0.3av90ml1mwQsiEoC4TbgIdUCPncO-x3NlEoazZkkS2U",
  table: "restaurants",
  menuBucket: "menus"
};
```
## 共用模式設定（約 5 分鐘）

1. 到 [supabase.com](https://supabase.com) 開一個免費專案。
2. 左側 **SQL Editor** → 貼上 `schema.sql` 的內容 → Run。
3. 左側 **Settings → API**，複製兩個東西：
   - **Project URL**（長得像 `https://abcdefgh.supabase.co`）
   - **anon public** key（很長一串 `eyJ...`）
4. 貼進 `index.html` 的 `POCKET_CONFIG`。
5. 把 `index.html` 丟上 GitHub Pages / Netlify / Cloudflare Pages。
6. 網址傳給大家，就這樣。

## 共用模式設定（約 5 分鐘）

1. 到 supabase.com 開一個免費專案
2. SQL Editor → 依序跑：
   - `schema.sql`（建資料表）
   - `storage.sql`（要上傳菜單照片才需要）
   ※ 如果表已經建過但缺欄位，改跑 `migration.sql`
3. Settings → API 複製 Project URL 跟 anon public key
4. 貼進 index.html 的 POCKET_CONFIG
5. 推上 GitHub Pages
### 菜單

兩種方式：

- **上傳照片** — 表單裡按「上傳菜單照片」，手機可以直接拍。
  上傳前會在瀏覽器端縮到最長邊 1600px 再壓成 JPEG，4MB 的照片通常變成 200～400KB。
  要先跑 `storage.sql` 建 bucket。
- **貼網址** — 圖片連結或菜單網頁都行，不打 `https://` 會自動補。

卡片上會多一顆「菜單」按鈕。**是圖片就直接在頁面上開大圖**（Esc 或點背景關掉）；
是一般網頁才跳出去開新分頁。

**刪照片**：按「移除菜單」或換一張，**儲存之後**舊檔會從 Storage 一併刪掉；
直接按取消不會動到任何東西。刪掉店家時它的照片也會跟著刪。
貼的外部連結（imgur 之類）只會從欄位清掉，不會去碰別人的檔案。
唯一的漏網之魚是「上傳完沒按儲存就關掉表單」，那張會變孤兒檔，
`storage.sql` 註解裡有清理用的 SQL。

容量：免費方案 1GB、每月 5GB 流量。以一張 300KB 估，大概放得下三千張。
`storage.sql` 註解裡有查用量跟清孤兒檔的 SQL。

⚠️ 跟 `restaurants` 表一樣，**拿到網址的人都能上傳**。bucket 有限制
5MB 跟只收 jpeg/png/webp，但擋不了刻意灌檔。

以上三項要跑一次 `migration.sql`。

推上github
cd C:\Users\K\Downloads\files
git add index.html storage.sql README.md
git commit -m "這次更改的東西"
git push