local data_dir = vim.fn.stdpath("data")

-- 自動創建目錄（如果不存在）
local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

ensure_dir(data_dir .. "/backup")
ensure_dir(data_dir .. "/swap")
ensure_dir(data_dir .. "/undo")

-- 設定路徑（注意末尾的 //）
vim.opt.backupdir = data_dir .. "/backup//"
vim.opt.directory = data_dir .. "/swap//"
vim.opt.undodir = data_dir .. "/undo//"

-- 開啟功能
vim.opt.backup = true
vim.opt.swapfile = true
-- vim.opt.updatecount = 5
-- vim.opt.updatetime = 100
vim.opt.undofile = true
