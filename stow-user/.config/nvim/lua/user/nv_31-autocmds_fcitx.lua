-- # Fcitx5 輸入法自動切換
local input_toggle = 1

-- 切換為英文
local function fcitx2en()
  local status = tonumber(io.popen("fcitx5-remote"):read("*all"))
  if status == 2 then
    input_toggle = 1
    os.execute("fcitx5-remote -c")
  end
end

-- 切換為中文 (如果你需要 InsertEnter 時恢復，可使用此函式)
local function fcitx2zh()
  local status = tonumber(io.popen("fcitx5-remote"):read("*all"))
  if status ~= 2 and input_toggle == 1 then
    os.execute("fcitx5-remote -o")
    input_toggle = 0
  end
end

-- 設定 Timeout
vim.opt.ttimeoutlen = 150

-- 建立 Autocmd
local fcitx_group = vim.api.nvim_create_augroup("Fcitx5AutoSwitch", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = fcitx_group,
  pattern = "*",
  callback = fcitx2en,
})

-- (選填) 如果希望進入插入模式自動恢復之前的輸入狀態，取消下方註解
vim.api.nvim_create_autocmd("InsertEnter", {
  group = fcitx_group,
  pattern = "*",
  callback = fcitx2zh,
})
