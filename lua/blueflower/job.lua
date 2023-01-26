local uv = vim.loop()
local _local_1_ = require("blueflower.debug")
local eprint = _local_1_["eprint"]
local function close_pipes(...)
  for i = select("#", ...) do
    local pipe = select(i, ...)
    if (pipe and not pipe:is_closing()) then
      pipe:close()
    else
    end
  end
  return nil
end
local function write_to_pipe(pipe, data)
  local _3_ = type(data)
  if (_3_ == "table") then
    for _, str in ipairs(data) do
      pipe:write(str)
      pipe:write("\n")
    end
    return nil
  elseif (_3_ == "string") then
    return pipe:write(data)
  else
    return nil
  end
end
local function read_from_pipe(pipe, output)
  local function _5_(err, data)
    if err then
      eprint(err)
    else
    end
    if data then
      local data0 = data:gsub("\13", "")
      return table.insert(output, data0)
    else
      return nil
    end
  end
  return pipe:read_start(_5_)
end
local function run_job(_8_, callback)
  local _arg_9_ = _8_
  local cmd = _arg_9_["cmd"]
  local args = _arg_9_["args"]
  local cwd = _arg_9_["cwd"]
  local input = _arg_9_["input"]
  local spec = _arg_9_
  local stdout_data = {}
  local stderr_data = {}
  local stdin
  if input then
    stdin = uv.new_pipe()
  else
    stdin = nil
  end
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local handle, pid = nil, nil
  local function _11_(code, signal)
    handle:close()
    stdout:read_stop()
    stderr:read_stop()
    close_pipes(stdin, stdout, stderr)
    local _12_
    if (0 < #stdout_data) then
      _12_ = stdout_data
    else
      _12_ = nil
    end
    local function _14_()
      if (0 < #stderr_data) then
        return stderr_data
      else
        return nil
      end
    end
    return callback(code, signal, _12_, _14_())
  end
  handle, pid = uv.spawn(cmd, {args = args, stdio = {stdin, stdout, stderr}, cwd = cwd}, _11_)
  if not handle then
    close_pipes(stdin, stdout, stderr)
    error(debug.traceback(("Failed to spawn process: " .. vim.inspect(spec))))
  else
  end
  read_from_pipe(stdout, stderr_data)
  read_from_pipe(stderr, stderr_data)
  return write_to_pipe(stdin, input)
end
return {["run-job"] = run_job}
