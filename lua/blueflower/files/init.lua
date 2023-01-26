local uv = vim.loop
local LanguageTree = require("vim.treesitter.languagetree")
local _local_1_ = require("blueflower.util")
local class = _local_1_["class"]
local notify_error_once = _local_1_["notify-error-once"]
local Buffer = require("blueflower.api-wrappers.buffer")
local _local_2_ = require("blueflower.debug")
local eprint = _local_2_["eprint"]
local a = require("blueflower.async")
local await = {fs_open = a.wrap(uv.fs_open, 4), fs_fstat = a.wrap(uv.fs_fstat, 2), fs_read = a.wrap(uv.fs_read, 4), fs_close = a.wrap(uv.fs_close, 2)}
local files = {}
local File = class()
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
                  return data, stat
                elseif ((_13_ == nil) and (nil ~= _14_)) then
                  local err = _14_
                  return error(err)
                else
                  return nil
                end
              end
              return _12_(fs_close(fd))
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
  return _3_(uv.fs_open(path))
end
local function read_file_async(path, callback)
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
                  return callback(data, stat)
                elseif (nil ~= _29_) then
                  local err = _29_
                  return eprint(err)
                else
                  return nil
                end
              end
              return _28_(await.fs_close(fd))
            elseif (nil ~= _26_) then
              local err = _26_
              return eprint(err)
            else
              return nil
            end
          end
          return _25_(await.fs_read(fd, stat.size, 0))
        elseif (nil ~= _23_) then
          local err = _23_
          return eprint(err)
        else
          return nil
        end
      end
      return _22_(await.fs_fstat(fd))
    elseif (nil ~= _20_) then
      local err = _20_
      return eprint(err)
    else
      return nil
    end
  end
  return _19_(await.fs_open(path, "r", 292))
end
local read_file_async0 = a.create(read_file, 2, true)
await["read-file"] = a.wrap(read_file_async0, 2, true)
local function load_file_async(path, _3fcallback)
  do
    local _35_ = files[path]
    if (nil ~= _35_) then
      local file = _35_
      file:refresh()
    elseif (_35_ == nil) then
      local _36_ = vim.fn.bufnr(path)
      if (_36_ == -1) then
        local file_content, file_stat = await["read-file"](path)
        if (vim.filetype.match({filename = path, contents = content}) == "blueflower") then
          files[path] = File:new({path = path, ["file-content"] = file_content, ["file-stat"] = file_stat})
        else
        end
      elseif (nil ~= _36_) then
        local bufnr = _36_
        local buffer = Buffer:new(bufnr)
        if (buffer["get-option"](buffer, "filetype") == "blueflower") then
          files[path] = File:new({path = path, buffer = buffer})
        else
        end
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
local load_file_async0 = a.create(load_file_async, 2, true)
File.initialize = function(self, _42_)
  local _arg_43_ = _42_
  local path = _arg_43_["path"]
  local buffer = _arg_43_["buffer"]
  local file_content = _arg_43_["file-content"]
  local file_stat = _arg_43_["file-stat"]
  self.path = path
  if buffer then
    self.buffer = buffer
    self.tsparser = vim.treesitter.get_parser(buffer.id, "blueflower")
    self.tstree = (self.tsparser):parse()[1]
    return nil
  else
    self.tstree = (tsparser:parse(LanguageTree:new(file_content, "blueflower", {})))[1]
    self.content = table.remove(vim.split(file_content, "\n"))
    self.mtime = file_stat.mtime.sec
    return nil
  end
end
File.refresh = function(self)
  if (self.buffer and (function(tgt, m, ...) return tgt[m](tgt, ...) end)(self.buffer, "loaded?")) then
    self.tstree = (self.tsparser):parse()[1]
    return nil
  else
    local function _45_()
      if self.buffer then
        self.buffer = nil
        self.tsparser = nil
        return true
      else
        return nil
      end
    end
    local function _47_()
      local _48_, _49_ = uv.fs_stat(self.path)
      if ((_48_ == nil) and (nil ~= _49_)) then
        local err = _49_
        return error(err)
      else
        local function _50_()
          local mtime = (_48_).mtime
          return (mtime.sec ~= self.mtime)
        end
        if (((_G.type(_48_) == "table") and (nil ~= (_48_).mtime)) and _50_()) then
          local mtime = (_48_).mtime
          return true
        else
          return nil
        end
      end
    end
    if (_45_() or _47_()) then
      local content, stat = read_file(self.path)
      self.tstree = (tsparser:parse(LanguageTree:new(content, "blueflower", {})))[1]
      self.content = table.remove(vim.split(content, "\n"))
      self.mtime = stat.mtime.sec
      return nil
    else
      return nil
    end
  end
end
return {files = files, ["load-file-async"] = load_file_async0}
