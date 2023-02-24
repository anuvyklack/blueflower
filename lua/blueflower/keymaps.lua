local ts = require("blueflower.treesitter")
local _local_1_ = require("blueflower.hyperlink")
local open_hyperlink_at_cursor = _local_1_["open-hyperlink-at-cursor"]
local _local_2_ = require("blueflower.config")
local augroup = _local_2_["augroup"]
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap
local P = vim.pretty_print
local function set_keymaps(_3_)
  local _arg_4_ = _3_
  local buf = _arg_4_["buf"]
  return keymap.set("n", "<CR>", open_hyperlink_at_cursor, {buffer = buf})
end
return autocmd("FileType", {pattern = "blueflower", desc = "Set blueflower keymaps", callback = set_keymaps})
