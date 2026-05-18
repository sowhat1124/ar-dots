-- # Terminal Mode
-- ===============
-- 讓 Esc 鍵可以直接跳回 Normal mode，方便切換視窗
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "退出終端輸入模式" })

-- 在終端機模式下也能用快捷鍵切換視窗（不須先按 Esc）
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]])
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]])
