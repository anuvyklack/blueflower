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
  local spec = (_3fopts or {})
  if spec.pattern then
    local _let_4_ = spec
    local pattern = _let_4_["pattern"]
    local first_found_3f = _let_4_["first-found?"]
    local pattern_fn
    do
      local _5_ = type(pattern)
      if (_5_ == "function") then
        pattern_fn = pattern
      elseif (_5_ == "string") then
        local function _6_(entry)
          return entry:match(pattern)
        end
        pattern_fn = _6_
      elseif (_5_ == "table") then
        local function _7_(entry)
          local found_3f = false
          for _, pat in ipairs(pattern) do
            if found_3f then break end
            if entry:match(pat) then
              found_3f = true
            else
            end
          end
          return found_3f
        end
        pattern_fn = _7_
      else
        pattern_fn = nil
      end
    end
    local function _10_(entry)
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
    spec["match-pattern?"] = _10_
  else
  end
  spec["base-path"] = path
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
local function _17_(current_dir, level, _15_, callback)
  local _arg_16_ = _15_
  local base_path = _arg_16_["base-path"]
  local output = _arg_16_["output"]
  local match_pattern_3f = _arg_16_["match-pattern?"]
  local depth = _arg_16_["depth"]
  local add_dirs_3f = _arg_16_["add-dirs?"]
  local hidden_3f = _arg_16_["hidden?"]
  local spec = _arg_16_
  local full_path
  if current_dir then
    full_path = (base_path .. os_sep .. current_dir)
  else
    full_path = base_path
  end
  local function _19_(...)
    local _20_, _21_ = ...
    if ((_20_ == nil) and (_21_ == true)) then
      local function _22_(...)
        local _23_, _24_ = ...
        if ((_23_ == nil) and (nil ~= _24_)) then
          local fd = _24_
          local traverse_dir
          local function _25_()
            return uv.fs_scandir_next(fd)
          end
          traverse_dir = _25_
          for name, type_ in traverse_dir do
            if spec["found?"] then break end
            if (hidden_3f or (name:sub(1, 1) ~= ".")) then
              local entry = ((current_dir or "") .. os_sep .. name)
              local _26_ = type_
              if (_26_ == "directory") then
                if ((name ~= ".git") and add_dirs_3f and match_pattern_3f(entry)) then
                  table.insert(output, (base_path .. entry .. os_sep))
                else
                end
                if (not spec["found?"] and (not depth or (level < depth))) then
                  impl_depth_first_async(entry, (level + 1), spec)
                else
                end
              elseif true then
                local _ = _26_
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
        elseif (nil ~= _23_) then
          local err = _23_
          return print(err)
        elseif ((_23_ == nil) and (_24_ == false)) then
          return print(string.format("%s directory is not accessible by the current user!", current_dir))
        else
          return nil
        end
      end
      return _22_(await.fs_scandir(full_path))
    elseif (nil ~= _20_) then
      local err = _20_
      return print(err)
    elseif ((_20_ == nil) and (_21_ == false)) then
      return print(string.format("%s directory is not accessible by the current user!", current_dir))
    else
      return nil
    end
  end
  _19_(await.fs_access(full_path, "X"))
  return callback()
end
impl_depth_first_async = a.wrap(a.create(_17_, 4), 4, true)
local function _36_(current_dir, level, _34_, callback)
  local _arg_35_ = _34_
  local base_path = _arg_35_["base-path"]
  local queue = _arg_35_["queue"]
  local output = _arg_35_["output"]
  local match_pattern_3f = _arg_35_["match-pattern?"]
  local depth = _arg_35_["depth"]
  local add_dirs_3f = _arg_35_["add-dirs?"]
  local hidden_3f = _arg_35_["hidden?"]
  local spec = _arg_35_
  local full_path
  if current_dir then
    full_path = (base_path .. os_sep .. current_dir)
  else
    full_path = base_path
  end
  local function _38_(...)
    local _39_, _40_ = ...
    if ((_39_ == nil) and (_40_ == true)) then
      local function _41_(...)
        local _42_, _43_ = ...
        if ((_42_ == nil) and (nil ~= _43_)) then
          local fd = _43_
          local traverse_dir
          local function _44_()
            return uv.fs_scandir_next(fd)
          end
          traverse_dir = _44_
          for name, type_ in traverse_dir do
            if spec["found?"] then break end
            if (hidden_3f or (name:sub(1, 1) ~= ".")) then
              local entry = ((current_dir or "") .. os_sep .. name)
              local _45_ = type_
              if (_45_ == "directory") then
                if ((name ~= ".git") and add_dirs_3f and match_pattern_3f(entry)) then
                  table.insert(output, (base_path .. entry .. os_sep))
                else
                end
                if (not depth or (level < depth)) then
                  table.insert(queue, entry)
                else
                end
              elseif true then
                local _ = _45_
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
        elseif (nil ~= _42_) then
          local err = _42_
          return print(err)
        elseif ((_42_ == nil) and (_43_ == false)) then
          return print(string.format("%s directory is not accessible by the current user!", current_dir))
        else
          return nil
        end
      end
      return _41_(await.fs_scandir(full_path))
    elseif (nil ~= _39_) then
      local err = _39_
      return print(err)
    elseif ((_39_ == nil) and (_40_ == false)) then
      return print(string.format("%s directory is not accessible by the current user!", current_dir))
    else
      return nil
    end
  end
  _38_(await.fs_access(full_path, "X"))
  return callback()
end
impl_breadth_first_async = a.wrap(a.create(_36_, 4), 4, true)
return scandir_async
