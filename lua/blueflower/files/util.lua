local uv = vim.loop
local async = require("blueflower.async")
local job = require("blueflower.job")
local scandir_async = require("blueflower.files.scandir")
local config = require("blueflower.config")
local _local_1_ = require("blueflower.util")
local executable_3f = _local_1_["executable?"]
local has_3f = _local_1_["has?"]
local notify_error = _local_1_["notify-error"]
local _local_2_ = vim.fn
local fnamemodify = _local_2_["fnamemodify"]
local await = {fs_open = async.wrap(uv.fs_open, 4), fs_fstat = async.wrap(uv.fs_fstat, 2), fs_read = async.wrap(uv.fs_read, 4), fs_close = async.wrap(uv.fs_close, 2), job = async.wrap(require("blueflower.job"), 1)}
local function read_file(path)
  local function _3_(...)
    local _4_, _5_ = ...
    if (nil ~= _4_) then
      local fd = _4_
      local function _6_(...)
        local _7_, _8_ = ...
        if (nil ~= _7_) then
          local stat = _7_
          local function _9_(...)
            local _10_, _11_ = ...
            if (nil ~= _10_) then
              local data = _10_
              local function _12_(...)
                local _13_, _14_ = ...
                if (_13_ == true) then
                  return data, {mtime = stat.mtime.sec}
                elseif ((_13_ == nil) and (nil ~= _14_)) then
                  local err = _14_
                  return error(err)
                else
                  return nil
                end
              end
              return _12_(uv.fs_close(fd))
            elseif ((_10_ == nil) and (nil ~= _11_)) then
              local err = _11_
              return error(err)
            else
              return nil
            end
          end
          return _9_(uv.fs_read(fd, stat.size))
        elseif ((_7_ == nil) and (nil ~= _8_)) then
          local err = _8_
          return error(err)
        else
          return nil
        end
      end
      return _6_(uv.fs_fstat(fd))
    elseif ((_4_ == nil) and (nil ~= _5_)) then
      local err = _5_
      return error(err)
    else
      return nil
    end
  end
  return _3_(uv.fs_open(path, "r", 292))
end
local read_file_async
local function _19_(path, callback)
  local function _20_(...)
    local _21_, _22_ = ...
    if ((_21_ == nil) and (nil ~= _22_)) then
      local fd = _22_
      local function _23_(...)
        local _24_, _25_ = ...
        if ((_24_ == nil) and (nil ~= _25_)) then
          local stat = _25_
          local function _26_(...)
            local _27_, _28_ = ...
            if ((_27_ == nil) and (nil ~= _28_)) then
              local data = _28_
              local function _29_(...)
                local _30_, _31_ = ...
                if ((_30_ == nil) and (_31_ == true)) then
                  return callback(data, {mtime = stat.mtime.sec})
                elseif (nil ~= _30_) then
                  local err = _30_
                  return error(err)
                else
                  return nil
                end
              end
              return _29_(await.fs_close(fd))
            elseif (nil ~= _27_) then
              local err = _27_
              return error(err)
            else
              return nil
            end
          end
          return _26_(await.fs_read(fd, stat.size, 0))
        elseif (nil ~= _24_) then
          local err = _24_
          return error(err)
        else
          return nil
        end
      end
      return _23_(await.fs_fstat(fd))
    elseif (nil ~= _21_) then
      local err = _21_
      return error(err)
    else
      return nil
    end
  end
  return _20_(await.fs_open(path, "r", 292))
end
read_file_async = async.wrap(async.create(_19_, 2, true), 2)
local function xdg_open(target)
  if executable_3f("xdg-open") then
    return job({cmd = "xdg-open", args = {target}})
  elseif executable_3f("open") then
    return job({cmd = "open", args = {target}})
  elseif has_3f("win32") then
    return job({cmd = "start", args = {target}})
  else
    return nil
  end
end
local function open_in_vim(path, _3fline_num)
  if _3fline_num then
    vim.cmd(string.format("edit +%d %s", _3fline_num, path))
    return vim.cmd("normal! zv")
  else
    return vim.cmd(string.format("edit %s", path))
  end
end
local function open_file(path, _3fline_num)
  local extension = fnamemodify(path, ":e")
  if (config["open-in-external-app"])[extension] then
    return xdg_open(path)
  else
    return open_in_vim(path, _3fline_num)
  end
end
local ui_select_file_async
local function ui_select_file_async0(files, callback)
  local function _39_(_241)
    return fnamemodify(_241, ":~:.")
  end
  return vim.ui.select(files, {prompt = "Choose the file", format_item = _39_}, callback)
end
ui_select_file_async = async.wrap(ui_select_file_async0, 2)
local find_file_async
local function find_file_async0(path, fname, callback)
  P("find-file-async: enter")
  local path0 = fnamemodify(path, ":p")
  local files = scandir_async(path0, {pattern = fname})
  local file
  do
    local _40_ = #files
    if (_40_ == 0) then
      async.scheduler()
      notify_error(string.format("No file found! Path: \"%s\" File: \"%s\"", path0, fname))
      file = nil
    elseif (_40_ == 1) then
      file = files[1]
    elseif true then
      local _ = _40_
      file = ui_select_file_async(files)
    else
      file = nil
    end
  end
  return callback(file)
end
find_file_async = async.wrap(async.create(find_file_async0, 3, true), 3)
local find_and_open_file_async
local function find_and_open_file_async0(path, fname, callback)
  P("find-and-open-file-async: enter")
  local _42_ = find_file_async(path, fname)
  if (nil ~= _42_) then
    local file = _42_
    async.scheduler()
    open_file(file)
    return callback(true)
  elseif (_42_ == nil) then
    return callback(false)
  else
    return nil
  end
end
find_and_open_file_async = async.wrap(async.create(find_and_open_file_async0, 3, true), 3)
return {["read-file"] = read_file, ["read-file-async"] = read_file_async, ["open-file"] = open_file, ["xdg-open"] = xdg_open, ["open-in-vim"] = open_in_vim, ["find-file-async"] = find_file_async, ["find-and-open-file-async"] = find_and_open_file_async}
