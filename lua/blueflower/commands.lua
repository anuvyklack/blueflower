local a = require("blueflower.async")
local scandir_async = require("blueflower.scandir")
local _local_1_ = require("blueflower.files")
local files = _local_1_["files"]
local P = vim.pretty_print
local scandir_wrapper
local function _2_()
  local output = scandir_async(".", {pattern = "init", depth = nil, ["add-dirs?"] = false, ["first-found?"] = false})
  return vim.pretty_print(output)
end
scandir_wrapper = a.void(_2_)
vim.api.nvim_create_user_command("Scandir", scandir_wrapper, {})
local function _3_()
  return P(files)
end
return vim.api.nvim_create_user_command("BlueflowerFiles", _3_, {})
