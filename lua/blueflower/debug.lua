local debug_mode = true
local messages = {}
local function eprint(msg)
  local level = 1
  local info = debug.getinfo((level + 2), "Sl")
  if info then
    local msg0 = string.format("(ERROR) %s(%d):\n%s", info.short_src, info.currentline, msg)
    table.insert(messages, msg0)
    if debug_mode then
      return error(msg0)
    else
      return nil
    end
  else
    return nil
  end
end
return {["debug-mode"] = debug_mode, messages = messages, eprint = eprint}
