local handles = setmetatable({}, {__mode = "k"})
local function running_3f()
  local thread = coroutine.running()
  if (thread and handles[thread]) then
    return true
  else
    return nil
  end
end
local Async_T = {}
do
  Async_T.new = function(thread)
    local handle = setmetatable({}, {__index = Async_T})
    do end (handles)[thread] = handle
    return handle
  end
  Async_T.cancel = function(_2_, thread)
    local _arg_3_ = _2_
    local cur = _arg_3_["_current"]
    if (cur and not cur:is_cancelled()) then
      return cur:cancel(thread)
    else
      return nil
    end
  end
  Async_T.is_cancelled = function(_5_)
    local _arg_6_ = _5_
    local cur = _arg_6_["_current"]
    if cur then
      return cur:is_cancelled()
    else
      return nil
    end
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
    local _let_9_ = {coroutine.resume(thread, ...)}
    local ok = _let_9_[1]
    local nargs = _let_9_[2]
    local fun = _let_9_[3]
    local ret = _let_9_
    local args = {select(4, unpack(ret))}
    if not ok then
      error(string.format("The coroutine failed with this message:\n%s\n%s", ret[2], debug.traceback(thread)))
    else
    end
    local _11_ = coroutine.status(thread)
    if (_11_ == "dead") then
      if callback then
        return callback(unpack(ret, 4, table.maxn(ret)))
      else
        return nil
      end
    elseif true then
      local _ = _11_
      assert((type(fun) == "function"), "type error :: expected func")
      do end (args)[nargs] = step
      local r = fun(unpack(args))
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
    local function _15_(...)
      return callback(true, ...)
    end
    args[argc] = _15_
    local function _16_(err)
      return callback(false, err, debug.traceback())
    end
    return xpcall(func, _16_, unpack(args, 1, argc))
  end
  local _let_17_ = {coroutine.yield(argc, pfunc, ...)}
  local ok = _let_17_[1]
  local ret = _let_17_
  if not ok then
    local _let_18_ = ret
    local _ = _let_18_[1]
    local err = _let_18_[2]
    local traceback = _let_18_[3]
    error(string.format("Wrapped function failed: %s\n%s", err, traceback))
  else
  end
  return unpack(ret, 2, table.maxn(ret))
end
local function wait(...)
  local _20_ = type(...)
  if (_20_ == "number") then
    return _wait(...)
  elseif true then
    local _ = _20_
    return _wait(select("#", ...), ...)
  else
    return nil
  end
end
local function create(func, _3fargc, _3fstrict)
  vim.validate({func = {func, "function"}, argc = {_3fargc, "number", true}})
  local argc = (_3fargc or 0)
  local function _22_(...)
    if running_3f() then
      if _3fstrict then
        error("This function must run in a non-async context")
      else
      end
      return func(...)
    else
      local callback = select((argc + 1), ...)
      return run(func, callback, unpack({...}, 1, argc))
    end
  end
  return _22_
end
local function void(func, _3fstrict)
  vim.validate({func = {func, "function"}})
  local function _25_(...)
    if running_3f() then
      if _3fstrict then
        error("This function must run in a non-async context")
      else
      end
      func(...)
      return run(func, nil, ...)
    else
      return nil
    end
  end
  return _25_
end
local function wrap(func, argc, _3fstrict)
  vim.validate({argc = {argc, "number"}})
  local function _28_(...)
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
  return _28_
end
local function join(thunks, n, _3finterrupt_check)
  local function run0(finish)
    if (0 == #thunks) then
      return finish()
    else
      local remaining = {select((n + 1), unpack(thunks))}
      local to_go = #thunks
      local ret = {}
      local callback
      local function _31_(...)
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
      callback = _31_
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
return {running = running_3f, run = run, wait = wait, create = create, void = void, wrap = wrap, curry = curry, scheduler = wrap(vim.schedule, 1, false)}
