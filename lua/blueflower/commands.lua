local async = require("blueflower.async")
local config = require("blueflower.config")
local scandir_async = require("blueflower.scandir")
local _local_1_ = require("blueflower.files")
local files = _local_1_["files"]
local P = vim.pretty_print
local scandir_wrapper
local function _2_()
  local output = scandir_async(".", {pattern = "init", depth = nil, ["add-dirs?"] = false, ["first-found?"] = false})
  return vim.pretty_print(output)
end
scandir_wrapper = async.void(_2_)
vim.api.nvim_create_user_command("Scandir", scandir_wrapper, {})
local function _3_()
  return P(files)
end
vim.api.nvim_create_user_command("BlueflowerFiles", _3_, {})
local uv = vim.loop
local set_timeout_async
local function set_timeout_async0(timeout, callback)
  print("set-timeout-async: enter")
  local timer = uv.new_timer()
  local function _4_()
    timer:stop()
    timer:close()
    return callback()
  end
  timer:start(timeout, 0, _4_)
  return timer
end
set_timeout_async = async.wrap(set_timeout_async0, 2)
local bomb
local function bomb0()
  print("bomb: enter")
  set_timeout_async(400)
  return error("bomb")
end
bomb = async.wrap(async.void(bomb0), 0)
local bomb_wrapper
local function bomb_wrapper0()
  print("bomb-wrapper: enter")
  return bomb()
end
bomb_wrapper = async.void(bomb_wrapper0)
return vim.api.nvim_create_user_command("BlueflowerBomb", bomb_wrapper, {})
