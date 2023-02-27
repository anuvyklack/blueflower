local uv = vim.loop
local _local_1_ = require("blueflower.util")
local class = _local_1_["class"]
local _local_2_ = require("blueflower.files.util")
local read_file = _local_2_["read-file"]
local LanguageTree = require("vim.treesitter.languagetree")
local _local_3_ = vim.treesitter.query
local parse_query = _local_3_["parse_query"]
local get_node_text = _local_3_["get_node_text"]
local query_cache = {}
local P = vim.pretty_print
local File = class()
File.initialize = function(self, _4_)
  local _arg_5_ = _4_
  local path = _arg_5_["path"]
  local buffer = _arg_5_["buffer"]
  local content = _arg_5_["content"]
  local stat = _arg_5_["stat"]
  self.path = path
  if buffer then
    self.bufnr = buffer.id
    self.buffer = buffer
    self.tsparser = vim.treesitter.get_parser(buffer.id, "blueflower")
    local _set_6_ = (self.tsparser):parse()
    self.tstree = _set_6_[1]
    return nil
  elseif content then
    do
      local tsparser = LanguageTree.new(content, "blueflower")
      local _let_7_ = tsparser:parse()
      local tstree = _let_7_[1]
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
    local _set_9_ = (self.tsparser):parse()
    self.tstree = _set_9_[1]
    return nil
  else
    local _12_
    do
      local _10_, _11_ = uv.fs_stat(self.path)
      if ((_10_ == nil) and (nil ~= _11_)) then
        local err = _11_
        _12_ = error(err)
      elseif ((_G.type(_10_) == "table") and (nil ~= (_10_).mtime)) then
        local mtime = (_10_).mtime
        _12_ = (mtime ~= self.mtime)
      else
        _12_ = nil
      end
    end
    if _12_ then
      local content, stat = read_file(self.path)
      do
        local tsparser = LanguageTree.new(content, "blueflower")
        local _let_16_ = tsparser:parse()
        local tstree = _let_16_[1]
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
File["get-node-text"] = function(self, node, concat_3f)
  return get_node_text(node, (self.bufnr or self.content), {concat = (concat_3f or false)})
end
File["parse-query"] = function(self, query)
  local query0 = query:gsub("\n?%s", " ")
  local ts_query
  local function _18_()
    local ts_query0 = parse_query("blueflower", query0)
    do end (query_cache)[query0] = ts_query0
    return ts_query0
  end
  ts_query = (query_cache[query0] or _18_())
  return ts_query
end
File["get-ids"] = function(self)
  self:refresh()
  local output = {}
  local source = (self.bufnr or self.content)
  local root = (self.tstree):root()
  local query = "(directive\n                 (name) @name\n                 (#eq? @name \"id\")\n                 (content) @content) @id"
  local ts_query = self["parse-query"](self, query)
  for _, _19_, _0 in ts_query:iter_matches(root, source) do
    local _each_20_ = _19_
    local _1 = _each_20_[1]
    local content_node = _each_20_[2]
    local id_node = _each_20_[3]
    local id_text = self["get-node-text"](self, content_node, "concat")
    do end (output)[id_text] = id_node
  end
  return output
end
File["get-link-definitions"] = function(self, _3fnode)
  self:refresh()
  local output = {}
  local query = "(link_definition\n                 (label) @label\n                 (target) @target) @link-definition"
  local ts_query = self["parse-query"](self, query)
  local source = (self.bufnr or self.content)
  local node = (_3fnode or (self.tstree):root())
  for _, _21_, _0 in ts_query:iter_matches(node, source) do
    local _each_22_ = _21_
    local label_node = _each_22_[1]
    local target_node = _each_22_[2]
    local link_def_node = _each_22_[3]
    local label = self["get-node-text"](self, label_node, "concat")
    local link = self["get-node-text"](self, target_node, "concat")
    do end (output)[label] = {link = link, node = link_def_node}
  end
  return output
end
File["get-headings"] = function(self, sort_3f)
  self:refresh()
  local output = {}
  local source = (self.bufnr or self.content)
  local root = (self.tstree):root()
  local query = "(heading) @heading"
  local ts_query = self["parse-query"](self, query)
  for _, h_node, _0 in ts_query:iter_captures(root, source) do
    local _let_23_ = h_node:field("level")
    local level_node = _let_23_[1]
    local _1, start, _2, stop = level_node:range()
    local level = (stop - start)
    local entry
    local _24_
    do
      local _let_25_ = h_node:field("title")
      local title_node = _let_25_[1]
      _24_ = vim.trim(string.gsub(string.gsub(self["get-node-text"](self, title_node, "concat"), "\13?\n", " "), "%s+", " "))
    end
    entry = {level = level, title = _24_, node = h_node}
    if sort_3f then
      if not output[level] then
        output[level] = {}
      else
      end
      table.insert(output[level], entry)
    else
      table.insert(output, entry)
    end
  end
  return output
end
File["get-icons-positions"] = function(self, first_row, last_row)
  self:refresh()
  local icons_positions = {}
  local source = (self.bufnr or self.content)
  local root = (self.tstree):root()
  local query = "(list_item\n                 level: (token) @list_token)\n               (list_item\n                 checkbox: (checkbox) @checkbox\n                 (#not-eq? @checkbox \"[ ]\"))"
  local ts_query = self["parse-query"](self, query)
  for id, node, _ in ts_query:iter_captures(root, source, first_row, last_row) do
    local name = ts_query.captures[id]
    if not vim.startswith(name, "_") then
      local start_row, start_col, end_row, end_col = node:range()
      table.insert(icons_positions, {type = name, text = self["get-node-text"](self, node, true), ["line-num"] = start_row, ["start-col"] = start_col, ["end-col"] = end_col})
    else
    end
  end
  return icons_positions
end
File["get-named-descendant-for-range"] = function(self, start_row, start_col, end_row, end_col)
  self:refresh()
  local root = (self.tstree):root()
  return root:named_descendant_for_range(start_row, start_col, end_row, end_col)
end
return File
