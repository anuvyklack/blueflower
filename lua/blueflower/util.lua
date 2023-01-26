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
  return vim.notify(message, vim.log.levels.ERROR, {title = "Blueflower:"})
end
local function full_path(path)
  return vim.fn.fnamemodify(path, ":p")
end
return {class = class, ["notify-error"] = notify_error, ["notify-error-once"] = notify_error_once, ["full-path"] = full_path}
