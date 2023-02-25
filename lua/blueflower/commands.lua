local async = require("blueflower.async")
local config = require("blueflower.config")
local scandir_async = require("blueflower.files.scandir")
local _local_1_ = require("blueflower.files")
local files = _local_1_["files"]
local get_current_file = _local_1_["get-current-file"]
local _local_2_ = require("blueflower.outline")
local show_outline = _local_2_["show-outline"]
local P = vim.pretty_print
local scandir_wrapper
local function _3_()
  local output = scandir_async(".", {pattern = "init", depth = nil, ["first-found?"] = false, ["add-dirs?"] = false})
  return vim.pretty_print(output)
end
scandir_wrapper = async.void(_3_)
vim.api.nvim_create_user_command("Scandir", scandir_wrapper, {})
local function _4_()
  return P(files)
end
vim.api.nvim_create_user_command("BlueflowerFiles", _4_, {})
return vim.api.nvim_create_user_command("BlueflowerOutline", show_outline, {})
