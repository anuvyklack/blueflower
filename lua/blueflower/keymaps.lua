local ts = require("blueflower.treesitter")
local _local_1_ = require("blueflower.hyperlink")
local open_hyperlink_at_cursor = _local_1_["open-hyperlink-at-cursor"]
local _local_2_ = require("blueflower.outline")
local show_outline = _local_2_["show-outline"]
local _local_3_ = require("blueflower.config")
local augroup = _local_3_["augroup"]
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap
local P = vim.pretty_print
local function set_keymaps(_4_)
  local _arg_5_ = _4_
  local bufnr = _arg_5_["buf"]
  keymap.set("n", "<CR>", open_hyperlink_at_cursor, {buffer = bufnr})
  return keymap.set("n", "<Tab>", show_outline, {buffer = bufnr})
end
return autocmd("FileType", {pattern = "blueflower", desc = "Set blueflower keymaps", callback = set_keymaps})
