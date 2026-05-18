-- # 基礎設定
vim.opt.clipboard = 'unnamedplus'
vim.opt.mouse = 'a'
vim.opt.belloff = "all"
-- 預設 belloff 為 "all"，即關閉所有提示音，若要確保關閉可再寫一次

-- # 搜尋設定
vim.opt.hlsearch = true
vim.opt.incsearch = true    -- 增量搜尋
vim.opt.ignorecase = true   -- 忽略大小寫
vim.opt.smartcase = true    -- 智慧大小寫

-- # 代碼折疊
vim.opt.foldmethod = "syntax" -- 使用語法進行折疊
vim.opt.foldlevel = 2         -- 預設展開到第 2 層

-- # 操作與自動化
vim.opt.autowrite = true
vim.opt.confirm = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.hidden = true              -- 允許隱藏緩衝區
vim.opt.autochdir = true           -- 自動切換工作目錄
vim.opt.textwidth = 0              -- 關閉自動換行

-- # 補全設定
vim.opt.wildmenu = true
vim.opt.wildmode = { "list:longest", "full" }
vim.opt.shortmess:append("I") -- 隱藏啟動畫面
vim.opt.shortmess:remove("t") -- 恢復預設的截斷行為

-- # 檔案編碼偵測
vim.opt.fileencodings = { "ucs-bom", "utf-8", "gb18030", "big5", "cp936", "euc-jp", "euc-kr", "latin1" }

