-- 1. 準備 lazy.nvim 的安裝路徑 (標準資料夾路徑)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 2. 如果路徑不存在，則自動從 GitHub Clone (Bootstrap)
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- 3. 將 lazypath 加入 Neovim 的 runtime path
vim.opt.rtp:prepend(lazypath)

-- 4. 設定 Leader Key (這通常建議放在 nv_20 或 nv_10 裡，但 lazy.nvim 要求必須在 setup 之前執行)
-- 如果你之前的設定檔沒設，這裡補上
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 5. 執行 lazy.nvim 初始化
require("lazy").setup({
  spec = {
    -- 在這裡直接定義你的插件
    { "nvim-lua/plenary.nvim" }, -- 許多插件的依賴

    -- import
    { import = "user.nv_41-plugins_treesitter" },

    -- 範例：安裝檔案瀏覽器
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("nvim-tree").setup()
      end
    },
  },

    -- 範例：安裝一個外觀主題
    -- {
    --   "folke/tokyonight.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     vim.cmd([[colorscheme tokyonight]])
    --   end
    -- },
  -- 其他設定
  -- install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true }, -- 自動檢查更新
})
