local api = vim.api
local Buffer = require("blueflower/api-wrappers/buffer")
local Window
do
  local class = (require("blueflower.util")).class
  Window = class()
end
Window.initialize = function(self, _3fwinid)
  if (not _3fwinid or (_3fwinid == 0)) then
    self.id = api.nvim_get_current_win()
  else
    self.id = _3fwinid
  end
  local function _2_(_, opt)
    return api.nvim_win_get_option(self.id, opt)
  end
  local function _3_(_, opt, value)
    return api.nvim_win_set_option(self.id, opt, value)
  end
  self.wo = setmetatable({}, {__index = _2_, __newindex = _3_})
  return nil
end
Window.__eq = function(l, r)
  return (l.id == r.id)
end
Window.close = function(_4_, _3fforce)
  local _arg_5_ = _4_
  local id = _arg_5_["id"]
  return api.nvim_win_close(id, (_3fforce or false))
end
Window["get-buffer"] = function(_6_)
  local _arg_7_ = _6_
  local id = _arg_7_["id"]
  return Buffer:new(api.nvim_win_get_buf(id))
end
Window["valide?"] = function(_8_)
  local _arg_9_ = _8_
  local id = _arg_9_["id"]
  return api.nvim_win_is_valid(id)
end
Window["get-type"] = function(_10_)
  local _arg_11_ = _10_
  local id = _arg_11_["id"]
  return vim.fn.win_gettype(id)
end
Window["floating?"] = function(self)
  return (self["get-type"](self) == "popup")
end
Window["set-buffer"] = function(self, buffer)
  local function _13_()
    local _12_ = type(buffer)
    if (_12_ == "table") then
      return buffer.id
    elseif true then
      local _ = _12_
      return buffer
    else
      return nil
    end
  end
  return api.nvim_win_set_buf(self.id, _13_())
end
Window["get-option"] = function(_15_, name)
  local _arg_16_ = _15_
  local id = _arg_16_["id"]
  return api.nvim_win_get_option(id, name)
end
Window["set-option"] = function(_17_, name, value)
  local _arg_18_ = _17_
  local id = _arg_18_["id"]
  return api.nvim_win_set_option(id, name, value)
end
Window["get-text-offset"] = function(_19_)
  local _arg_20_ = _19_
  local id = _arg_20_["id"]
  return vim.fn.getwininfo(id)[1].textoff
end
Window["get-width"] = function(_21_)
  local _arg_22_ = _21_
  local id = _arg_22_["id"]
  return api.nvim_win_get_width(id)
end
Window["get-height"] = function(_23_)
  local _arg_24_ = _23_
  local id = _arg_24_["id"]
  return api.nvim_win_get_height(id)
end
Window["set-width"] = function(_25_, width)
  local _arg_26_ = _25_
  local id = _arg_26_["id"]
  return api.nvim_win_set_width(id, width)
end
Window["set-height"] = function(_27_, height)
  local _arg_28_ = _27_
  local id = _arg_28_["id"]
  return api.nvim_win_set_height(id, height)
end
Window["get-cursor"] = function(_29_)
  local _arg_30_ = _29_
  local id = _arg_30_["id"]
  return api.nvim_win_get_cursor(id)
end
Window["set-cursor"] = function(_31_, pos)
  local _arg_32_ = _31_
  local id = _arg_32_["id"]
  return api.nvim_win_set_cursor(id, pos)
end
Window["set-highglight-namespace"] = function(self, ns_id)
  return api.nvim_win_set_hl_ns(self.id, ns_id)
end
return Window
