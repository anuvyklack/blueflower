 local api = vim.api
 local _local_1_ = require("blueflower.util") local class = _local_1_["class"]
 local Buffer = class()

 Buffer.initialize = function(self, input)



 do local _2_ = type(input) if (_2_ == "number") then
 self.id = input elseif (_2_ == "string") then
 self.id = vim.fn.bufnr(input) elseif (_2_ == "nil") then
 self.id = api.nvim_get_current_buf() else end end


 local function _4_(_, opt)
 return api.nvim_buf_get_option(self.id, opt) end
 local function _5_(_, opt, value)
 return api.nvim_buf_set_option(self.id, opt, value) end self.bo = setmetatable({}, {__index = _4_, __newindex = _5_}) return nil end

 Buffer.__eq = function(_, l, r)
 return (l.id == r.id) end

 Buffer["get-name"] = function(self)

 return api.nvim_buf_get_name(self.id) end

 Buffer.delete = function(self, _6_) local _arg_7_ = _6_ local force = _arg_7_["force"] local unload = _arg_7_["unload"]
 return api.nvim_buf_delete(self.id, {force = (force or false), unload = (unload or false)}) end


 Buffer["loaded?"] = function(self)
 return api.nvim_buf_is_loaded(self.id) end

 Buffer["get-var"] = function(self, name)
 return vim.api.nvim_buf_get_var(self.id, name) end

 Buffer["set-var"] = function(self, name, value)
 return vim.api.nvim_buf_set_var(self.id, name, value) end

 Buffer["get-option"] = function(self, name)
 return api.nvim_buf_get_option(self.id, name) end

 Buffer["set-option"] = function(self, name, value)
 return api.nvim_buf_set_option(self.id, name, value) end

 Buffer["line-count"] = function(self)
 return api.nvim_buf_line_count(self.id) end

 Buffer["get-text"] = function(self, start_row, start_col, end_row, end_col)
 return api.nvim_buf_get_text(self.id, start_row, start_col, end_row, end_col, {}) end




 Buffer["get-lines"] = function(self, start, _end, _3fstrict_indexing)
 return api.nvim_buf_get_lines(self.id, start, _end, (_3fstrict_indexing or false)) end

 Buffer["set-lines"] = function(_8_, start, _end, lines, _3fstrict_indexing) local _arg_9_ = _8_ local id = _arg_9_["id"]










 return api.nvim_buf_set_lines(id, start, _end, (_3fstrict_indexing or false), lines) end





 Buffer["add-higlight"] = function(self, ns_id, hl_group, line, col_start, col_end)













 return api.nvim_buf_add_highlight(self.id, ns_id, hl_group, line, col_start, col_end) end






 return Buffer
