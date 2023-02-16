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
do
  local function afun(path, callback)
    print("read-file-async: enter")
    local function _17_(...)
      local _18_, _19_ = ...
      if ((_18_ == nil) and (nil ~= _19_)) then
        local fd = _19_
        local function _20_(...)
          local _21_, _22_ = ...
          if ((_21_ == nil) and (nil ~= _22_)) then
            local stat = _22_
            local function _23_(...)
              local _24_, _25_ = ...
              if ((_24_ == nil) and (nil ~= _25_)) then
                local data = _25_
                local function _26_(...)
                  local _27_, _28_ = ...
                  if ((_27_ == nil) and (_28_ == true)) then
                    print("read-file-async: exit")
                    return callback(data, {mtime = stat.mtime.sec})
                  elseif (nil ~= _27_) then
                    local err = _27_
                    return eprint(err)
                  else
                    return nil
                  end
                end
                return _26_(await.fs_close(fd))
              elseif (nil ~= _24_) then
                local err = _24_
                return eprint(err)
              else
                return nil
              end
            end
            return _23_(await.fs_read(fd, stat.size, 0))
          elseif (nil ~= _21_) then
            local err = _21_
            return eprint(err)
          else
            return nil
          end
        end
        return _20_(await.fs_fstat(fd))
      elseif (nil ~= _18_) then
        local err = _18_
        return eprint(err)
      else
        return nil
      end
    end
    return _17_(await.fs_open(path, "r", 292))
  end
  local afun0 = async.create(afun, 2, true)
  local afun1 = async.wrap(afun0, 2)
  read_file_async = afun1
end
return {["read-file"] = read_file, ["read-file-async"] = read_file_async}
