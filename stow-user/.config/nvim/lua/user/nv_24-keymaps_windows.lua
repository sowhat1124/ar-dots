-- # Windows - Split (視窗分割)
-- 使用 <cmd> 代替 :，配合 silent 效果最乾淨
vim.keymap.set("", "shw", "<cmd>set splitright<CR><cmd>vsplit<CR>", { silent = true })
vim.keymap.set("", "sjw", "<cmd>set splitbelow<CR><cmd>split<CR>", { silent = true })
vim.keymap.set("", "skw", "<cmd>set nosplitbelow<CR><cmd>split<CR>", { silent = true })
vim.keymap.set("", "slw", "<cmd>set nosplitright<CR><cmd>vsplit<CR>", { silent = true })

-- # Windows - Focus (切換視窗焦點)
vim.keymap.set("", "sfh", "<C-w>h", { silent = true })
vim.keymap.set("", "sfj", "<C-w>j", { silent = true })
vim.keymap.set("", "sfk", "<C-w>k", { silent = true })
vim.keymap.set("", "sfl", "<C-w>l", { silent = true })

-- # Windows - Move (移動視窗位置)
vim.keymap.set("", "smh", "<C-w>H", { silent = true })
vim.keymap.set("", "smj", "<C-w>J", { silent = true })
vim.keymap.set("", "smk", "<C-w>K", { silent = true })
vim.keymap.set("", "sml", "<C-w>L", { silent = true })

-- # Windows - Resize (調整視窗大小)
vim.keymap.set("", "srh", "<cmd>vertical resize+5<CR>", { silent = true })
vim.keymap.set("", "srj", "<cmd>res +5<CR>", { silent = true })
vim.keymap.set("", "srl", "<cmd>vertical resize-5<CR>", { silent = true })
vim.keymap.set("", "srk", "<cmd>res -5<CR>", { silent = true })
