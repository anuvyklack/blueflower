local uv = vim.loop
local async = require("blueflower.async")
local await = {fs_open = async.wrap(uv.fs_open, 4), fs_fstat = async.wrap(uv.fs_fstat, 2), fs_read = async.wrap(uv.fs_read, 4), fs_close = async.wrap(uv.fs_close, 2)}
local function read_file(path)
  local function _1_(...)
    local _2_, _3_ = ...
    if (nil ~= _2_) then
      local fd = _2_
      local function _4_(...)
        local _5_, _6_ = ...
        if (nil ~= _5_) then
          local stat = _5_
          local function _7_(...)
            local _8_, _9_ = ...
            if (nil ~= _8_) then
              local data = _8_
              local function _10_(...)
                local _11_, _12_ = ...
                if (_11_ == true) then
                  return data, {mtime = stat.mtime.sec}
                elseif ((_11_ == nil) and (nil ~= _12_)) then
                  local err = _12_
                  return error(err)
                else
                  return nil
                end
              end
              return _10_(uv.fs_close(fd))
            elseif ((_8_ == nil) and (nil ~= _9_)) then
              local err = _9_
              return error(err)
            else
              return nil
            end
          end
          return _7_(uv.fs_read(fd, stat.size))
        elseif ((_5_ == nil) and (nil ~= _6_)) then
          local err = _6_
          return error(err)
        else
          return nil
        end
      end
      return _4_(uv.fs_fstat(fd))
    elseif ((_2_ == nil) and (nil ~= _3_)) then
      local err = _3_
      return error(err)
    else
      return nil
    end
  end
  return _1_(uv.fs_open(path, "r", 292))
end
local read_file_async
local function _17_(path, callback)
  print("read-file-async: enter")
  local function _18_(...)
    local _19_, _20_ = ...
    if ((_19_ == nil) and (nil ~= _20_)) then
      local fd = _20_
      local function _21_(...)
        local _22_, _23_ = ...
        if ((_22_ == nil) and (nil ~= _23_)) then
          local stat = _23_
          local function _24_(...)
            local _25_, _26_ = ...
            if ((_25_ == nil) and (nil ~= _26_)) then
              local data = _26_
              local function _27_(...)
                local _28_, _29_ = ...
                if ((_28_ == nil) and (_29_ == true)) then
                  print("read-file-async: exit")
                  return callback(data, {mtime = stat.mtime.sec})
                elseif (nil ~= _28_) then
                  local err = _28_
                  return eprint(err)
                else
                  return nil
                end
              end
              return _27_(await.fs_close(fd))
            elseif (nil ~= _25_) then
              local err = _25_
              return eprint(err)
            else
              return nil
            end
          end
          return _24_(await.fs_read(fd, stat.size, 0))
        elseif (nil ~= _22_) then
          local err = _22_
          return eprint(err)
        else
          return nil
        end
      end
      return _21_(await.fs_fstat(fd))
    elseif (nil ~= _19_) then
      local err = _19_
      return eprint(err)
    else
      return nil
    end
  end
  return _18_(await.fs_open(path, "r", 292))
end
read_file_async = async.wrap(async.create(_17_, 2, true), 2)
return {["read-file"] = read_file, ["read-file-async"] = read_file_async}
