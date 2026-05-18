--require("nv_10-options_basic")
--require("nv_11-options_ident_n_line_number")
--require("nv_12-options_looking")
--require("nv_20-keymaps_default_change")
--require("nv_21-keymaps_navigation")
--require("nv_22-keymaps_helper")
--require("nv_23-keymaps_buffers_n_tabs")
--require("nv_24-keymaps_windows")
--require("nv_30-autocmds")
--require("nv_40-plugins")

-- 在 for-host.lua 中可以這樣寫
local modules = {
    "nv_10-options_basic",
    "nv_11-options_swap_n_backup_n_undo",
    "nv_12-options_ident_n_line_number",
    "nv_13-options_looking",
    "nv_20-keymaps_default_change",
    "nv_21-keymaps_navigation",
    "nv_22-keymaps_helper",
    "nv_23-keymaps_buffers_n_tabs",
    "nv_24-keymaps_windows",
    "nv_25-keymaps_mode_insert",
    "nv_26-keymaps_mode_command",
    "nv_27-keymaps_mode_terminal",
    "nv_30-autocmds_short",
    "nv_31-autocmds_fcitx",
    "nv_40-plugins_lazy",
}

for _, m in ipairs(modules) do
  local status, err = pcall(require, m)
  if not status then
    print("Error loading module: " .. m .. "\n" .. err)
  end
end

--

-- 這裡寫一些 Linux 專用的邏輯
print("Host config loaded successfully!")
