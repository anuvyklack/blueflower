local function class(parent)
  local mt = {__index = parent}
  local class0 = setmetatable({}, mt)
  class0.__index = class0
  class0.new = function(_, ...)
    local obj = setmetatable({}, class0)
    if (type(class0.initialize) == "function") then
      obj:initialize(...)
    else
    end
    return obj
  end
  mt.__call = class0.new
  return class0
end
local function notify_error_once(message)
  return vim.notify_once(message, vim.log.levels.ERROR, {title = "Blueflower:"})
end
local function notify_error(message)
  return vim.notify(("[Blueflower] " .. message), vim.log.levels.ERROR)
end
local function notify_warning(message)
  return vim.notify(("[Blueflower] " .. message), vim.log.levels.WARN)
end
local function merge_table_deep_21(into, from)
  for key, value in pairs(from) do
    local _2_ = type(value)
    if (_2_ == "table") then
      into[key] = merge_table_deep_21(into[key], value)
    elseif true then
      local _ = _2_
      into[key] = from[key]
    else
    end
  end
  return into
end
local function make_set_from_list(list)
  local set_ = {}
  for i = 1, #list do
    set_[list[i]] = true
  end
  return set_
end
local function full_path(path)
  return vim.fn.fnamemodify(path, ":p")
end
local function executable_3f(name)
  return (0 < vim.fn.executable(name))
end
local function has_3f(feature)
  return (1 == vim.fn.has(feature))
end
return {class = class, ["merge-table-deep!"] = merge_table_deep_21, ["make-set-from-list"] = make_set_from_list, ["notify-warning"] = notify_warning, ["notify-error"] = notify_error, ["notify-error-once"] = notify_error_once, ["full-path"] = full_path, ["executable?"] = executable_3f, ["has?"] = has_3f}
