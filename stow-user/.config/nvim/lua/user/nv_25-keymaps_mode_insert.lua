-- # Insert Mode (Emacs Style)
-- ============================--

vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<M-b>', '<C-o>B')
vim.keymap.set('i', '<M-f>', '<Esc>Ea')
vim.keymap.set('i', '<C-h>', '<Backspace>')
vim.keymap.set('i', '<C-d>', '<Del>')
vim.keymap.set('i', '<C-w>', '<Esc>dBcl')
vim.keymap.set('i', '<C-u>', '<Esc>d0cl')
vim.keymap.set('i', '<C-k>', '<Esc>lc$')

-- # Editing
-- 快速跳轉標籤與暫存器操作
vim.keymap.set('i', ',,', '<++>')
vim.keymap.set('i', ',f', '<Esc>/<++><CR>:nohlsearch<CR>"_c4l', { buffer = true })
vim.keymap.set('i', '<C-r><C-r>', '<C-r>+')
