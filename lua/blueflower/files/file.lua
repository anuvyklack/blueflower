local uv = vim.loop
local _local_1_ = require("blueflower.util")
local class = _local_1_["class"]
local _local_2_ = require("blueflower.files.util")
local read_file = _local_2_["read-file"]
local _local_3_ = require("vim.treesitter.query")
local parse_query = _local_3_["parse_query"]
local get_node_text = _local_3_["get_node_text"]
local LanguageTree = require("vim.treesitter.languagetree")
local _local_4_ = vim.treesitter.query
local get_node_text0 = _local_4_["get_node_text"]
local query_cache = {}
local P = vim.pretty_print
local File = class()
File.initialize = function(self, _5_)
  local _arg_6_ = _5_
  local path = _arg_6_["path"]
  local buffer = _arg_6_["buffer"]
  local content = _arg_6_["content"]
  local stat = _arg_6_["stat"]
  self.path = path
  if buffer then
    self.bufnr = buffer.id
    self.buffer = buffer
    self.tsparser = vim.treesitter.get_parser(buffer.id, "blueflower")
    local _set_7_ = (self.tsparser):parse()
    self.tstree = _set_7_[1]
    return nil
  elseif content then
    do
      local tsparser = LanguageTree.new(content, "blueflower")
      local _let_8_ = tsparser:parse()
      local tstree = _let_8_[1]
      self.tstree = tstree
    end
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
    local _set_10_ = (self.tsparser):parse()
    self.tstree = _set_10_[1]
    return nil
  else
    local _13_
    do
      local _11_, _12_ = uv.fs_stat(self.path)
      if ((_11_ == nil) and (nil ~= _12_)) then
        local err = _12_
        _13_ = error(err)
      elseif ((_G.type(_11_) == "table") and (nil ~= (_11_).mtime)) then
        local mtime = (_11_).mtime
        _13_ = (mtime ~= self.mtime)
      else
        _13_ = nil
      end
    end
    if _13_ then
      local content, stat = read_file(self.path)
      do
        local tsparser = LanguageTree.new(content, "blueflower")
        local _let_17_ = tsparser:parse()
        local tstree = _let_17_[1]
        self.tstree = tstree
      end
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
File["parse-query"] = function(self, query)
  local query0 = query:gsub("\n?%s", " ")
  local ts_query
  local function _19_()
    local ts_query0 = parse_query("blueflower", query0)
    do end (query_cache)[query0] = ts_query0
    return ts_query0
  end
  ts_query = (query_cache[query0] or _19_())
  return ts_query
end
File["get-ids"] = function(self)
  self:refresh()
  local output = {}
  local source = (self.bufnr or self.content)
  local root = (self.tstree):root()
  local query = "(directive\n                 (name) @name\n                 (#eq? @name \"id\")\n                 (content) @content) @id"
  local ts_query = self["parse-query"](self, query)
  for _, _20_, _0 in ts_query:iter_matches(root, source) do
    local _each_21_ = _20_
    local _1 = _each_21_[1]
    local content_node = _each_21_[2]
    local id_node = _each_21_[3]
    local id_text = get_node_text0(content_node, source, {concat = true})
    do end (output)[id_text] = id_node
  end
  return output
end
File["get-headings"] = function(self)
  self:refresh()
  local output = {}
  local source = (self.bufnr or self.content)
  local root = (self.tstree):root()
  local query = "(heading) @heading"
  local ts_query = self["parse-query"](self, query)
  for _, _22_, _0 in ts_query:iter_matches(root, source) do
    local _each_23_ = _22_
    local h_node = _each_23_[1]
    local _let_24_ = h_node:field("level")
    local level_node = _let_24_[1]
    local _1, start, _2, stop = level_node:range()
    local level = (stop - start)
    if not output[level] then
      output[level] = {}
    else
    end
    local _26_
    do
      local _let_27_ = h_node:field("title")
      local title_node = _let_27_[1]
      _26_ = vim.trim(string.gsub(string.gsub(get_node_text0(title_node, source, {concat = true}), "\13?\n", " "), "%s+", " "))
    end
    table.insert(output[level], {level = level, title = _26_, node = h_node})
  end
  return output
end
return File
