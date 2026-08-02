# 我的口袋名單

一個收藏餐廳＋線上點餐連結的網站。決定不了就按「抽一家」。

## 檔案

| 檔案 | 用途 |
|---|---|
| `index.html` | 可直接部署的完整網站，React 已內嵌，無外部相依 |
| `schema.sql` | 共用模式要用的資料表，貼到 Supabase 執行 |
| `migration.sql` | 已經建過表的話，跑這個補上 hours / menu 欄位 |
| `restaurant-pocket-list.jsx` | 原始碼 |

## 兩種模式

打開 `index.html`，最上面有一段設定：

```js
window.POCKET_CONFIG = {
  supabaseUrl: "",
  supabaseKey: "",
  table: "restaurants"
};
```

- **留空** → 單機模式。資料存在各自瀏覽器的 `localStorage`，可用「分享名單」把整份名單包進網址傳給別人。
- **填上** → 共用模式。**大家看到同一份，有人加店所有人都看得到。**

## 共用模式設定（約 5 分鐘）

1. 到 [supabase.com](https://supabase.com) 開一個免費專案。
2. 左側 **SQL Editor** → 貼上 `schema.sql` 的內容 → Run。
3. 左側 **Settings → API**，複製兩個東西：
   - **Project URL**（長得像 `https://abcdefgh.supabase.co`）
   - **anon public** key（很長一串 `eyJ...`）
4. 貼進 `index.html` 的 `POCKET_CONFIG`。
5. 把 `index.html` 丟上 GitHub Pages / Netlify / Cloudflare Pages。
6. 網址傳給大家，就這樣。

### 同步行為

- 你新增／編輯／刪除 → 立刻送到資料庫。
- 別人的變更 → **每 10 秒**拉一次，切回這個分頁時也會立刻拉。
- 表頭有狀態燈：綠＝已同步（附最後更新時間）、黃＝同步中、紅＝連不上（附 HTTP 錯誤碼，可按重試）。
- 送出失敗會跳提示並重新拉回伺服器的狀態，畫面不會停在假的成功。

### 營業時間

每家店可以設定一週七天的營業時段，一天能放多段（午餐、晚餐分開），
把某天的時段全部移掉就是公休。時間用**小時 0–24 ＋ 分鐘**兩個下拉選單，
沒有 AM/PM。`24:00` 代表午夜；選了 24 時分鐘會自動鎖成 00。
營業到隔天凌晨照實填（例如 `18:00–02:00`），跨夜跟跨週都會判斷正確。

- 篩選列有「現在有開」，按下去只留營業中的店。
- 「抽一家」只會抽現在有開的；全部打烊時會提示，不會硬抽一家給你。
- **沒填營業時間的店一律照常顯示。** 不知道它關了沒，就不該替你把它藏起來。
- 卡片上刻意不顯示「營業中／已打烊」標籤，維持畫面乾淨。想要的話跟我說，加一個開關就好。

### 分類

沒有預設分類，自己打。名單裡用過的分類會自動變成快選按鈕，
也會自動出現在篩選列。**沒有店在用的分類會自己消失**，不需要另外刪除——
要「刪掉」一個分類，把還在用它的店改成別的分類或留空就行。

### 菜單

每家店可以貼一個菜單連結（照片或網頁都行，網址不打 `https://` 會自動補）。
有填的話卡片上會多一顆「菜單」按鈕。

以上三項要跑一次 `migration.sql`。

### 「最愛」是個人的

⭐ 只存在自己的瀏覽器，不會同步。你標最愛不會影響別人的畫面。
店家資料（名稱、分類、電話、備註、點餐連結）才是共用的。

### 誰可以改

anon key 會出現在網頁原始碼裡，**任何拿到網址的人都能新增和刪除**。
朋友群組用夠了。要收緊的話有兩條路：

- **只讀給外人**：把 `insert / update / delete` 三條 policy 拿掉，改用 Supabase Auth 登入後才給寫。
- **加一道密碼**：在 policy 裡檢查自訂 header，或改走 Edge Function。

要走哪一條跟我說，我改。

## 部署

```bash
mkdir pocket-list && cd pocket-list && git init
cp /path/to/index.html .
git add . && git commit -m "init" && git branch -M main
git remote add origin git@github.com:<你的帳號>/pocket-list.git
git push -u origin main
```
Repo → **Settings → Pages → Source 選 `main` / `root`**，
網址就是 `https://<你的帳號>.github.io/pocket-list/`。

## 改程式後重新打包

```bash
npm i esbuild react react-dom lucide-react
npx esbuild src/main.jsx --bundle --minify --format=iife --target=es2019 \
  --define:process.env.NODE_ENV='"production"' --outfile=bundle.js
```
再把 `bundle.js` 塞回 `index.html` 最後那個 `<script>`。

## 已知限制

- 同一筆資料兩個人同時改 → 後送出的蓋掉先送出的（last-write-wins），沒有衝突提示。
- 10 秒輪詢不是即時。要真即時得接 Supabase Realtime（websocket）。
- 沒有刪除的復原機制。
