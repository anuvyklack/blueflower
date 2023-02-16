local uv = vim.loop
local _local_1_ = require("blueflower.util")
local class = _local_1_["class"]
local _local_2_ = require("blueflower.files.util")
local read_file = _local_2_["read-file"]
local LanguageTree = require("vim.treesitter.languagetree")
local P = vim.pretty_print
local File = class()
File.initialize = function(self, _3_)
  local _arg_4_ = _3_
  local path = _arg_4_["path"]
  local buffer = _arg_4_["buffer"]
  local content = _arg_4_["content"]
  local stat = _arg_4_["stat"]
  self.path = path
  if buffer then
    self.buffer = buffer
    self.tsparser = vim.treesitter.get_parser(buffer.id, "blueflower")
    self.tstree = (self.tsparser):parse()[1]
    return nil
  elseif content then
    self.tstree = (LanguageTree.new(content, "blueflower"):parse())[1]
    do
      local lines = vim.split(content, "\n")
      table.remove(lines)
      self.content = lines
    end
    self.mtime = stat.mtime
    return nil
  else
    return nil
  end
end
File.refresh = function(self)
  if self.buffer then
    assert((function(tgt, m, ...) return tgt[m](tgt, ...) end)(self.buffer, "loaded?"), "Buffer is not loaded!")
    self.tstree = (self.tsparser):parse()[1]
    return nil
  else
    local _8_
    do
      local _6_, _7_ = uv.fs_stat(self.path)
      if ((_6_ == nil) and (nil ~= _7_)) then
        local err = _7_
        _8_ = error(err)
      elseif ((_G.type(_6_) == "table") and (nil ~= (_6_).mtime)) then
        local mtime = (_6_).mtime
        _8_ = (mtime ~= self.mtime)
      else
        _8_ = nil
      end
    end
    if _8_ then
      local content, stat = read_file(self.path)
      self.tstree = (LanguageTree.new(content, "blueflower", {}):parse())[1]
      do
        local lines = vim.split(content, "\n")
        table.remove(lines)
        self.content = lines
      end
      self.mtime = stat.mtime
      return nil
    else
      return nil
    end
  end
end
return File
