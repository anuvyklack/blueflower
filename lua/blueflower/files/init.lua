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
local group = vim.api.nvim_create_augroup("blueflower", {clear = true})
local P = vim.pretty_print
local files = {}
local function _6_(_4_)
  local _arg_5_ = _4_
  local bufnr = _arg_5_["buf"]
  do
    local buffer = Buffer:new(bufnr)
    local path = buffer["get-name"](buffer)
    local file = File:new({path = path, buffer = buffer})
    do end (files)[path] = file
    local function _7_()
      local function _8_(content, stat)
        files[path] = File:new({path = path, content = content, stat = stat})
        return nil
      end
      read_file_async(path, vim.schedule_wrap(_8_))
      return true
    end
    autocmd("BufUnload", {buffer = bufnr, group = group, once = true, desc = "Handle blueflower file unloading", callback = _7_})
  end
  return false
end
autocmd("FileType", {pattern = "blueflower", group = group, desc = "Handle blueflower file loading", callback = _6_})
local load_file_async
do
  local function afun(path, _3fcallback)
    do
      local _9_ = files[path]
      if (nil ~= _9_) then
        local file = _9_
        file:refresh()
      elseif (_9_ == nil) then
        local content, stat = read_file_async(path)
        if ("blueflower" == vim.filetype.match({filename = path, contents = content})) then
          files[path] = File:new({path = path, content = content, stat = stat})
        else
        end
      else
      end
    end
    if _3fcallback then
      return _3fcallback()
    else
      return nil
    end
  end
  local afun0 = async.create(afun, 2, true)
  local afun1 = async.wrap(afun0, 2)
  load_file_async = afun1
end
return {files = files, ["load-file-async"] = load_file_async}
