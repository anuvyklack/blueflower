local lua_unpack = unpack
local handles = setmetatable({}, {__mode = "k"})
local function running_3f()
  local thread = coroutine.running()
  return (thread and handles[thread])
end
local Async_T = {}
Async_T.new = function(thread)
  local handle = setmetatable({}, {__index = Async_T})
  do end (handles)[thread] = handle
  return handle
end
Async_T.cancel = function(_1_, thread)
  local _arg_2_ = _1_
  local _current = _arg_2_["_current"]
  if (_current and not _current:is_cancelled()) then
    return _current:cancel(thread)
  else
    return nil
  end
end
Async_T.is_cancelled = function(_4_)
  local _arg_5_ = _4_
  local _current = _arg_5_["_current"]
  if _current then
    return _current:is_cancelled()
  else
    return nil
  end
end
local function Async_T_3f(handle)
  if (handle and (type(handle) == "table") and vim.is_callable(handle.cancel) and vim.is_callable(handle.is_cancelled)) then
    return true
  else
    return nil
  end
end
local function run(func, callback, ...)
  vim.validate({func = {func, "function"}, callback = {callback, "function", true}})
  local thread = coroutine.create(func)
  local handle = Async_T.new(thread)
  local function step(...)
    local _let_8_ = {coroutine.resume(thread, ...)}
    local ok = _let_8_[1]
    local nargs = _let_8_[2]
    local fun = _let_8_[3]
    local ret = _let_8_
    local args = {select(4, lua_unpack(ret, 1, table.maxn(ret)))}
    if not ok then
      print(string.format("The coroutine failed with this message:\n%s\n%s", ret[2], debug.traceback(thread)))
      error(string.format("The coroutine failed with this message:\n%s\n%s", ret[2], debug.traceback(thread)), 0)
    else
    end
    local _10_ = coroutine.status(thread)
    if (_10_ == "dead") then
      if callback then
        return callback(lua_unpack(ret, 4, table.maxn(ret)))
      else
        return nil
      end
    elseif true then
      local _ = _10_
      assert((type(fun) == "function"), "type error :: expected func")
      do end (args)[nargs] = step
      local r = fun(lua_unpack(args, 1, table.maxn(args)))
      if Async_T_3f(r) then
        handle._current = r
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  step(...)
  return handle
end
local function _wait(argc, func, ...)
  vim.validate({argc = {argc, "number"}, func = {func, "function"}})
  local function pfunc(...)
    local args = {...}
    local callback = args[argc]
    local function _14_(...)
      return callback(true, ...)
    end
    args[argc] = _14_
    local function _15_(err)
      return callback(false, err, debug.traceback())
    end
    return xpcall(func, _15_, lua_unpack(args, 1, argc))
  end
  local _let_16_ = {coroutine.yield(argc, pfunc, ...)}
  local ok = _let_16_[1]
  local ret = _let_16_
  if not ok then
    local _let_17_ = ret
    local _ = _let_17_[1]
    local err = _let_17_[2]
    local traceback = _let_17_[3]
    print(string.format("wait: Wrapped function failed: %s\n%s", err, traceback))
    error(string.format("Wrapped function failed: %s\n%s", err, traceback))
  else
  end
  return lua_unpack(ret, 2, table.maxn(ret))
end
local function wait(...)
  local _19_ = type(...)
  if (_19_ == "number") then
    return _wait(...)
  elseif true then
    local _ = _19_
    return _wait(select("#", ...), ...)
  else
    return nil
  end
end
local function create(func, _3fargc, _3fstrict)
  vim.validate({func = {func, "function"}, argc = {_3fargc, "number", true}})
  local argc = (_3fargc or 0)
  local function _21_(...)
    if running_3f() then
      if _3fstrict then
        error("This function must run in a non-async context")
      else
      end
      return func(...)
    else
      local callback = select((argc + 1), ...)
      return run(func, callback, lua_unpack({...}, 1, argc))
    end
  end
  return _21_
end
local function void(func, _3fstrict)
  vim.validate({func = {func, "function"}})
  local function _24_(...)
    if running_3f() then
      if _3fstrict then
        error("This function must run in a non-async context")
      else
      end
      return func(...)
    else
      return run(func, nil, ...)
    end
  end
  return _24_
end
local function wrap(func, argc, _3fstrict)
  vim.validate({argc = {argc, "number"}})
  local function _27_(...)
    if running_3f() then
      return wait(argc, func, ...)
    else
      if _3fstrict then
        error("This function must run in an async context")
      else
      end
      return func(...)
    end
  end
  return _27_
end
local function join(thunks, n, _3finterrupt_check)
  local function run0(finish)
    if (0 == #thunks) then
      return finish()
    else
      local remaining = {select((n + 1), lua_unpack(thunks, 1, table.maxn(thunks)))}
      local to_go = #thunks
      local ret = {}
      local callback
      local function _30_(...)
        table.insert(ret, {...})
        local to_go0 = (to_go - 1)
        if (to_go0 == 0) then
          return finish(ret)
        elseif ((not _3finterrupt_check or _3finterrupt_check()) and (0 < #remaining)) then
          local next_task = table.remove(remaining)
          return next_task(callback)
        else
          return nil
        end
      end
      callback = _30_
      for i = 1, math.min(n, #thunks) do
        local thunk = thunks[i]
        thunk(callback)
      end
      return nil
    end
  end
  if not running_3f() then
    return run0
  else
    return wait(1, false, run0)
  end
end
local function curry(fun, ...)
  local args = {...}
  local nargs = select("#", ...)
  local function _34_(...)
    local other = {...}
    for i = 1, select("#", ...) do
      args[(nargs + i)] = other[i]
    end
    return fun(lua_unpack(args, 1, table.maxn(args)))
  end
  return _34_
end
return {running = running_3f, run = run, wait = wait, create = create, void = void, wrap = wrap, join = join, curry = curry, scheduler = wrap(vim.schedule, 1, false)}
