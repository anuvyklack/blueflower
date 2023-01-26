local augroup = "blueflower"
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap
local ts = require("blueflower/treesitter")
local _local_1_ = require("blueflower/hyperlink")
local open_hyperlink_at_cursor = _local_1_["open-hyperlink-at-cursor"]
local P = vim.pretty_print
local function set_keymaps()
  return keymap.set("n", "<CR>", open_hyperlink_at_cursor)
end
return autocmd("FileType", {pattern = "blueflower", desc = "Set blueflower keymaps", callback = set_keymaps})
