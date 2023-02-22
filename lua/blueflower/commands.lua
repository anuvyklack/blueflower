local async = require("blueflower.async")
local config = require("blueflower.config")
local scandir_async = require("blueflower.files.scandir")
local _local_1_ = require("blueflower.files")
local get_current_file = _local_1_["get-current-file"]
local P = vim.pretty_print
local scandir_wrapper
local function _2_()
  local output = scandir_async(".", {pattern = "init", depth = nil, ["first-found?"] = false, ["add-dirs?"] = false})
  return vim.pretty_print(output)
end
scandir_wrapper = async.void(_2_)
vim.api.nvim_create_user_command("Scandir", scandir_wrapper, {})
local function _3_()
  local file = get_current_file()
  return file["get-headings"](file)
end
return vim.api.nvim_create_user_command("BlueflowerFiles", _3_, {})
