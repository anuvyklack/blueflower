local uv = vim.loop
local async = require("blueflower.async")
local job = require("blueflower.job")
local scandir_async = require("blueflower.scandir")
local config = require("blueflower.config")
local _local_1_ = require("blueflower.util")
local executable_3f = _local_1_["executable?"]
local has_3f = _local_1_["has?"]
local notify_error = _local_1_["notify-error"]
local await = {fs_open = async.wrap(uv.fs_open, 4), fs_fstat = async.wrap(uv.fs_fstat, 2), fs_read = async.wrap(uv.fs_read, 4), fs_close = async.wrap(uv.fs_close, 2), job = async.wrap(require("blueflower.job"), 1)}
local function read_file(path)
  local function _2_(...)
    local _3_, _4_ = ...
    if (nil ~= _3_) then
      local fd = _3_
      local function _5_(...)
        local _6_, _7_ = ...
        if (nil ~= _6_) then
          local stat = _6_
          local function _8_(...)
            local _9_, _10_ = ...
            if (nil ~= _9_) then
              local data = _9_
              local function _11_(...)
                local _12_, _13_ = ...
                if (_12_ == true) then
                  return data, {mtime = stat.mtime.sec}
                elseif ((_12_ == nil) and (nil ~= _13_)) then
                  local err = _13_
                  return error(err)
                else
                  return nil
                end
              end
              return _11_(uv.fs_close(fd))
            elseif ((_9_ == nil) and (nil ~= _10_)) then
              local err = _10_
              return error(err)
            else
              return nil
            end
          end
          return _8_(uv.fs_read(fd, stat.size))
        elseif ((_6_ == nil) and (nil ~= _7_)) then
          local err = _7_
          return error(err)
        else
          return nil
        end
      end
      return _5_(uv.fs_fstat(fd))
    elseif ((_3_ == nil) and (nil ~= _4_)) then
      local err = _4_
      return error(err)
    else
      return nil
    end
  end
  return _2_(uv.fs_open(path, "r", 292))
end
local read_file_async
local function _18_(path, callback)
  local function _19_(...)
    local _20_, _21_ = ...
    if ((_20_ == nil) and (nil ~= _21_)) then
      local fd = _21_
      local function _22_(...)
        local _23_, _24_ = ...
        if ((_23_ == nil) and (nil ~= _24_)) then
          local stat = _24_
          local function _25_(...)
            local _26_, _27_ = ...
            if ((_26_ == nil) and (nil ~= _27_)) then
              local data = _27_
              local function _28_(...)
                local _29_, _30_ = ...
                if ((_29_ == nil) and (_30_ == true)) then
                  return callback(data, {mtime = stat.mtime.sec})
                elseif (nil ~= _29_) then
                  local err = _29_
                  return error(err)
                else
                  return nil
                end
              end
              return _28_(await.fs_close(fd))
            elseif (nil ~= _26_) then
              local err = _26_
              return error(err)
            else
              return nil
            end
          end
          return _25_(await.fs_read(fd, stat.size, 0))
        elseif (nil ~= _23_) then
          local err = _23_
          return error(err)
        else
          return nil
        end
      end
      return _22_(await.fs_fstat(fd))
    elseif (nil ~= _20_) then
      local err = _20_
      return error(err)
    else
      return nil
    end
  end
  return _19_(await.fs_open(path, "r", 292))
end
read_file_async = async.wrap(async.create(_18_, 2, true), 2)
local find_file_async
local function find_file_async0(path, name, callback)
  local path0 = vim.fn.fnamemodify(path, ":p")
  local _let_35_ = scandir_async(path0, {pattern = name, ["first-found?"] = true})
  local file = _let_35_[1]
  local files = _let_35_
  return callback(file)
end
find_file_async = async.wrap(async.create(find_file_async0, 3, true), 3)
local function xdg_open(target)
  if executable_3f("xdg-open") then
    return job({cmd = "xdg-open", args = {target}})
  elseif executable_3f("open") then
    return job({cmd = "open", args = {target}})
  elseif has_3f("win32") then
    return job({cmd = "start", args = {("\"" .. target .. "\"")}})
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
  local extension = vim.fn.fnamemodify(path, ":e")
  if (config["open-in-external-app"])[extension] then
    return xdg_open(path)
  else
    return open_in_vim(path, _3fline_num)
  end
end
return {["read-file"] = read_file, ["read-file-async"] = read_file_async, ["find-file-async"] = find_file_async, ["open-file"] = open_file, ["xdg-open"] = xdg_open, ["open-in-vim"] = open_in_vim}
