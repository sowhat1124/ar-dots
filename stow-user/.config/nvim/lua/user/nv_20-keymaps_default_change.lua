-- # Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- # 按鍵映射 (直接呼叫完整 API)

-- 停用 s, m, n, N
vim.keymap.set("", "s", "<nop>", { silent = true })
vim.keymap.set("", "m", "<nop>", { silent = true })
vim.keymap.set("", "n", "<nop>", { silent = true })
vim.keymap.set("", "N", "<nop>", { silent = true })
vim.keymap.set("", "mmm", "m", { silent = true })
vim.keymap.set("", "sss", "s", { silent = true })

-- Mark / Search
vim.keymap.set("", "'", "`", { silent = true })
vim.keymap.set("", "`", "'", { silent = true })
vim.keymap.set("", "/", "ms/", { silent = true })
vim.keymap.set("", "?", "ms?", { silent = true })

-- 其他常用映射
vim.keymap.set("", "Y", "y$", { silent = true })
vim.keymap.set("v", "$", "$h", { silent = true })
vim.keymap.set("", "x", '"_x', { silent = true })
vim.keymap.set("", "X", 'v$h"_x', { silent = true })
vim.keymap.set("", "k", "gk", { silent = true })
vim.keymap.set("", "j", "gj", { silent = true })
vim.keymap.set("", "=", "n", { silent = true })
vim.keymap.set("", ":", ";", { silent = true })
vim.keymap.set("", ";", ":", { silent = false })
-- vim.keymap.set("", "-", "N", { silent = true })
-- vim.keymap.set("", "_", "-", { silent = true })
