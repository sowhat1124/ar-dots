return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- 每次更新插件時自動更新解析器
    config = function()
      local configs = require("nvim-treesitter.config")

      configs.setup({
        -- 確保安裝的解析器清單
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
        
        -- 啟用同步安裝 (僅在需要時)
        sync_install = false,

        -- 自動安裝缺失的解析器
        auto_install = true,

        highlight = {
          enable = true, -- 核心功能：開啟語法高亮
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true, -- 開啟自動縮排
        },
      })
    end,
  },
}
