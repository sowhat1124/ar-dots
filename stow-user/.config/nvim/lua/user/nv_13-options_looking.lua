-- # 外觀設定
vim.cmd("syntax on")                     -- 語法高亮
vim.cmd("nohlsearch")                    -- 啟動時清除上次殘留的高亮
vim.cmd("language message zh_TW.UTF-8")
vim.opt.termguicolors = true             --啟動 24 位元真色彩

-- ## 光標設定 (Neovim 推薦做法)
-- n: 一般模式, i: 插入模式, c: 命令行模式, v: 可視模式, r: 取代模式
-- block: 方塊, ver25: 25% 寬度的垂直線, hor20: 20% 高度的橫線
vim.opt.guicursor = {
  "n-v-c:block",           -- 一般、可視、命令行模式用方塊
  "i-ci-ve:ver25",         -- 插入模式用垂直線
  "r-cr:hor20",            -- 取代模式用橫線
  "o:hor50",               -- Operator-pending 模式
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- 設定閃爍頻率
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- ## 顯示設定
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", space = "▫" }
vim.opt.colorcolumn = "80"
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.scrolloff = 3
vim.opt.laststatus = 1
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.showmatch = true          -- 高亮匹配括號
vim.opt.matchtime = 1             -- 匹配閃爍 0.1 秒
