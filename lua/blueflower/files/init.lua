local async = require("blueflower.async")
local _local_1_ = require("blueflower.util")
local class = _local_1_["class"]
local full_path = _local_1_["full-path"]
local notify_error_once = _local_1_["notify-error-once"]
local Buffer = require("blueflower.api-wrappers.buffer")
local _local_2_ = require("blueflower.debug")
local eprint = _local_2_["eprint"]
local File = require("blueflower.files.file")
local _local_3_ = require("blueflower.files.util")
local read_file_async = _local_3_["read-file-async"]
local autocmd = vim.api.nvim_create_autocmd
local _local_4_ = require("blueflower.config")
local augroup = _local_4_["augroup"]
local P = vim.pretty_print
local files = {}
local function _7_(_5_)
  local _arg_6_ = _5_
  local filename = _arg_6_["file"]
  local bufnr = _arg_6_["buf"]
  local buffer = Buffer:new(bufnr)
  local path = buffer["get-name"](buffer)
  if path then
    files[path] = File:new({path = path, buffer = buffer})
    local function _8_()
      do
        local content, stat = read_file_async(path)
        async.scheduler()
        do end (files)[path] = File:new({path = path, content = content, stat = stat})
      end
      return true
    end
    autocmd("BufUnload", {buffer = bufnr, group = augroup, once = true, desc = "Handle blueflower file unloading", callback = async.void(_8_)})
  else
  end
  return false
end
autocmd("FileType", {pattern = "blueflower", group = augroup, desc = "Handle blueflower file loading", callback = _7_})
local load_file_async
local function _10_(path, _3fcallback)
  do
    local _11_ = files[path]
    if (nil ~= _11_) then
      local file = _11_
      file:refresh()
    elseif (_11_ == nil) then
      local content, stat = read_file_async(path)
      if (vim.filetype.match({filename = path, contents = content}) == "blueflower") then
        files[path] = File:new({path = path, content = content, stat = stat})
      else
      end
    else
    end
  end
  if _3fcallback then
    return _3fcallback(files)
  else
    return nil
  end
end
load_file_async = async.wrap(async.create(_10_, 2, true), 2)
return {files = files, ["load-file-async"] = load_file_async}
