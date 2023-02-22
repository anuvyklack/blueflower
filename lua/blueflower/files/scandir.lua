local uv = vim.loop
local a = require("blueflower.async")
local _local_1_ = require("blueflower.debug")
local eprint = _local_1_["eprint"]
local _local_2_ = require("blueflower.config")
local os_sep = _local_2_["os-sep"]
local empty_3f = vim.tbl_isempty
local await = {fs_access = a.wrap(uv.fs_access, 3, true), fs_scandir = a.wrap(uv.fs_scandir, 2, true)}
local P = vim.pretty_print
local impl_depth_first_async = nil
local impl_breadth_first_async = nil
local scandir_async
local function _3_(path, _3fopts, callback)
  local path0
  if (path:sub(#path) ~= "/") then
    path0 = (path .. os_sep)
  else
    path0 = path
  end
  local spec = (_3fopts or {})
  if spec.pattern then
    local _let_5_ = spec
    local pattern = _let_5_["pattern"]
    local first_found_3f = _let_5_["first-found?"]
    local pattern0 = vim.pesc(pattern)
    local pattern_fn
    do
      local _6_ = type(pattern0)
      if (_6_ == "function") then
        pattern_fn = pattern0
      elseif (_6_ == "string") then
        local function _7_(entry)
          return entry:match(pattern0)
        end
        pattern_fn = _7_
      elseif (_6_ == "table") then
        local function _8_(entry)
          local found_3f = false
          for _, pat in ipairs(pattern0) do
            if found_3f then break end
            if entry:match(pat) then
              found_3f = true
            else
            end
          end
          return found_3f
        end
        pattern_fn = _8_
      else
        pattern_fn = nil
      end
    end
    local function _11_(entry)
      if pattern_fn(entry) then
        if first_found_3f then
          spec["found?"] = true
        else
        end
        return true
      else
        return nil
      end
    end
    spec["match-pattern?"] = _11_
  else
  end
  spec["base-path"] = path0
  spec.output = {}
  if (spec.type == "depth") then
    impl_depth_first_async(nil, 1, spec)
  else
    spec.queue = {}
    impl_breadth_first_async(nil, 1, spec)
    while not empty_3f(spec.queue) do
      local next_dir = table.remove(spec.queue, 1)
      impl_breadth_first_async(next_dir, 2, spec)
    end
  end
  return callback(spec.output)
end
scandir_async = a.wrap(a.create(_3_, 3), 3, true)
local function _18_(current_dir, level, _16_, callback)
  local _arg_17_ = _16_
  local base_path = _arg_17_["base-path"]
  local output = _arg_17_["output"]
  local match_pattern_3f = _arg_17_["match-pattern?"]
  local depth = _arg_17_["depth"]
  local add_dirs_3f = _arg_17_["add-dirs?"]
  local hidden_3f = _arg_17_["hidden?"]
  local spec = _arg_17_
  local full_path
  if current_dir then
    full_path = (base_path .. os_sep .. current_dir)
  else
    full_path = base_path
  end
  local function _20_(...)
    local _21_, _22_ = ...
    if ((_21_ == nil) and (_22_ == true)) then
      local function _23_(...)
        local _24_, _25_ = ...
        if ((_24_ == nil) and (nil ~= _25_)) then
          local fd = _25_
          local traverse_dir
          local function _26_()
            return uv.fs_scandir_next(fd)
          end
          traverse_dir = _26_
          for name, type_ in traverse_dir do
            if spec["found?"] then break end
            if (hidden_3f or (name:sub(1, 1) ~= ".")) then
              local entry = ((current_dir or "") .. os_sep .. name)
              local _27_ = type_
              if (_27_ == "directory") then
                if ((name ~= ".git") and add_dirs_3f and match_pattern_3f(entry)) then
                  table.insert(output, (base_path .. entry .. os_sep))
                else
                end
                if (not spec["found?"] and (not depth or (level < depth))) then
                  impl_depth_first_async(entry, (level + 1), spec)
                else
                end
              elseif true then
                local _ = _27_
                if match_pattern_3f(entry) then
                  table.insert(output, (base_path .. entry))
                else
                end
              else
              end
            else
            end
          end
          return nil
        elseif (nil ~= _24_) then
          local err = _24_
          return print(err)
        elseif ((_24_ == nil) and (_25_ == false)) then
          return print(string.format("%s directory is not accessible by the current user!", current_dir))
        else
          return nil
        end
      end
      return _23_(await.fs_scandir(full_path))
    elseif (nil ~= _21_) then
      local err = _21_
      return print(err)
    elseif ((_21_ == nil) and (_22_ == false)) then
      return print(string.format("%s directory is not accessible by the current user!", current_dir))
    else
      return nil
    end
  end
  _20_(await.fs_access(full_path, "X"))
  return callback()
end
impl_depth_first_async = a.wrap(a.create(_18_, 4), 4, true)
local function _37_(current_dir, level, _35_, callback)
  local _arg_36_ = _35_
  local base_path = _arg_36_["base-path"]
  local queue = _arg_36_["queue"]
  local output = _arg_36_["output"]
  local match_pattern_3f = _arg_36_["match-pattern?"]
  local depth = _arg_36_["depth"]
  local add_dirs_3f = _arg_36_["add-dirs?"]
  local hidden_3f = _arg_36_["hidden?"]
  local spec = _arg_36_
  local full_path
  if current_dir then
    full_path = (base_path .. current_dir)
  else
    full_path = base_path
  end
  local function _39_(...)
    local _40_, _41_ = ...
    if ((_40_ == nil) and (_41_ == true)) then
      local function _42_(...)
        local _43_, _44_ = ...
        if ((_43_ == nil) and (nil ~= _44_)) then
          local fd = _44_
          local traverse_dir
          local function _45_()
            return uv.fs_scandir_next(fd)
          end
          traverse_dir = _45_
          for name, type_ in traverse_dir do
            if spec["found?"] then break end
            if (hidden_3f or (name:sub(1, 1) ~= ".")) then
              local entry
              if current_dir then
                entry = (current_dir .. os_sep .. name)
              else
                entry = name
              end
              local _47_ = type_
              if (_47_ == "directory") then
                if ((name ~= ".git") and add_dirs_3f and (not match_pattern_3f or match_pattern_3f(entry))) then
                  table.insert(output, (base_path .. entry .. os_sep))
                else
                end
                if (not depth or (level < depth)) then
                  table.insert(queue, entry)
                else
                end
              elseif true then
                local _ = _47_
                if (not match_pattern_3f or match_pattern_3f(entry)) then
                  table.insert(output, (base_path .. entry))
                else
                end
              else
              end
            else
            end
          end
          return nil
        elseif (nil ~= _43_) then
          local err = _43_
          return print(err)
        elseif ((_43_ == nil) and (_44_ == false)) then
          return print(string.format("%s directory is not accessible by the current user!", current_dir))
        else
          return nil
        end
      end
      return _42_(await.fs_scandir(full_path))
    elseif (nil ~= _40_) then
      local err = _40_
      return print(err)
    elseif ((_40_ == nil) and (_41_ == false)) then
      return print(string.format("%s directory is not accessible by the current user!", current_dir))
    else
      return nil
    end
  end
  _39_(await.fs_access(full_path, "X"))
  return callback()
end
impl_breadth_first_async = a.wrap(a.create(_37_, 4), 4, true)
return scandir_async
