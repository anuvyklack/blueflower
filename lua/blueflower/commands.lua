local command = vim.api.nvim_create_user_command
local a = require("blueflower.async")
local scandir = require("blueflower.scandir")
local scandir_wrapper
local function _1_()
  local function _2_()
    local output = scandir(".", {pattern = "scandir", depth = nil, ["add-dirs?"] = false, ["first-found?"] = false})
    return vim.pretty_print(output)
  end
  return a.run(_2_)
end
scandir_wrapper = _1_
return command("Scandir", scandir_wrapper, {})
