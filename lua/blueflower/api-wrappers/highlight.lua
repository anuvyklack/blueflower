local api = vim.api
local format = string.format
local M = {}
M.get = function(name)
  local ok_3f, hl = pcall(api.nvim_get_hl_by_name, name, vim.o.termguicolors)
  if ok_3f then
    hl.fg = hl.foreground
    hl.bg = hl.background
    hl.sp = hl.special
    hl.foreground = nil
    hl.background = nil
    hl.special = nil
    return hl
  else
    return nil
  end
end
M.set = function(name, hl_spec)
  return api.nvim_set_hl(0, name, hl_spec)
end
M["set-in-namespace"] = function(ns_id, name, hl_spec)
  return api.nvim_set_hl(ns_id, name, hl_spec)
end
M["activate-namespace"] = function(ns_id)
  return api.nvim_set_hl_ns(ns_id)
end
return M
