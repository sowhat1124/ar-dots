-- ## Command Mode (Emacs Style)
-- ============================

-- 游標移動
vim.keymap.set('c', '<C-a>', '<Home>')        -- 移至行首
vim.keymap.set('c', '<C-e>', '<End>')         -- 移至行尾
vim.keymap.set('c', '<C-b>', '<Left>')        -- 向前移一個字元
vim.keymap.set('c', '<C-f>', '<Right>')       -- 向後移一個字元
vim.keymap.set('c', '<M-b>', '<S-Left>')      -- 向前移一個單字 (Alt-b)
vim.keymap.set('c', '<M-f>', '<S-Right>')     -- 向後移一個單字 (Alt-f)

-- 刪除與剪下 (Editing / Killing)
vim.keymap.set('c', '<C-h>', '<Backspace>')   -- 刪除游標前的字元
vim.keymap.set('c', '<C-d>', '<Del>')         -- 刪除游標後的字元
vim.keymap.set('c', '<M-d>', [[<C-f>dw<C-c>q:]], { remap = true }) -- 刪除游標後的單字 (Alt-d)
vim.keymap.set('c', '<C-w>', '<C-w>')         -- 刪除游標前的單字 (Vim 內建已支援)
vim.keymap.set('c', '<C-u>', '<C-u>')         -- 刪除整行至行首 (Vim 內建已支援)
vim.keymap.set('c', '<C-k>', [[<C-f>D<C-c>q:]], { remap = true })  -- 刪除至行尾 (Kill to end)

-- 其他功能
vim.keymap.set('c', '<C-n>', '<Down>')        -- 下一個歷史指令
vim.keymap.set('c', '<C-p>', '<Up>')          -- 上一個歷史指令
vim.keymap.set('c', '<C-y>', '<C-r>"')        -- 貼上最後刪除的文字 (Yank)
vim.keymap.set('c', '<C-r><C-r>', '<C-r>+', { desc = "貼上系統剪貼簿" })
