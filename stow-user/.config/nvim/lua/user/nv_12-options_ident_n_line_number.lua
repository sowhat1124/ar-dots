-- # 縮進設定
vim.opt.shiftwidth = 4     -- 所有的縮進基準都設為 4
vim.opt.softtabstop = -1   -- 自動跟隨 shiftwidth
vim.opt.tabstop = 4        -- 僅定義 Tab 字元的顯示寬度
vim.opt.expandtab = true   -- 使用空格代替 Tab

-- # 行號設定 

-- ## 基礎行號設定 (開啟混合行號)
vim.opt.number = true               -- 顯示行號
vim.opt.relativenumber = true       -- 顯示相對行號

-- ## 行號模式切換自動調整

local number_group = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

-- ### 1. 進入插入模式時：關閉相對行號
vim.api.nvim_create_autocmd("InsertEnter", {
  group = number_group,
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
})

-- ### 2. 離開插入模式時：開啟相對行號
vim.api.nvim_create_autocmd("InsertLeave", {
  group = number_group,
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
})
