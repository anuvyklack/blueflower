local uv = vim.loop
local a = require("blueflower.async")
local _local_1_ = require("blueflower.debug")
local eprint = _local_1_["eprint"]
local os_sep = "/"
local await = {fs_access = a.wrap(uv.fs_access, 3, true), fs_scandir = a.wrap(uv.fs_scandir, 2, true)}
local function scandir(path, _3fopts, callback)
  local found_3f = false
  local _let_2_ = (_3fopts or {})
  local pattern = _let_2_["pattern"]
  local depth = _let_2_["depth"]
  local add_dirs_3f = _let_2_["add-dirs?"]
  local first_found_3f = _let_2_["first-found?"]
  local hidden_3f = _let_2_["hidden?"]
  local output = {}
  local check_pattern
  do
    local _3_ = type(pattern)
    if (_3_ == "string") then
      local function _4_(entry)
        return entry:match(pattern)
      end
      check_pattern = _4_
    elseif (_3_ == "table") then
      local function _5_(entry)
        local found_3f0 = false
        for _, pat in ipairs(pattern) do
          if found_3f0 then break end
          if entry:match(pat) then
            found_3f0 = true
          else
          end
        end
        return found_3f0
      end
      check_pattern = _5_
    elseif (_3_ == "function") then
      check_pattern = pattern
    elseif (_3_ == "nil") then
      local function _7_()
        return true
      end
      check_pattern = _7_
    else
      check_pattern = nil
    end
  end
  local match_pattern_3f
  local function _9_(entry)
    if check_pattern(entry) then
      if first_found_3f then
        found_3f = true
        return nil
      else
        return nil
      end
    else
      return true
    end
  end
  match_pattern_3f = _9_
  local parse_dir_async = nil
  local function parse_dir(current_dir, level, callback0)
    local function _12_(...)
      local _13_, _14_ = ...
      if ((_13_ == nil) and (_14_ == true)) then
        local function _15_(...)
          local _16_, _17_ = ...
          if ((_16_ == nil) and (nil ~= _17_)) then
            local fd = _17_
            local traverse_dir
            local function _18_()
              return uv.fs_scandir_next(fd)
            end
            traverse_dir = _18_
            for name, type_ in traverse_dir do
              if found_3f then break end
              if (hidden_3f or (name:sub(1, 1) ~= ".")) then
                local entry = (current_dir .. os_sep .. name)
                local _19_ = type_
                if (_19_ == "directory") then
                  if ((name ~= ".git") and add_dirs_3f and match_pattern_3f(entry)) then
                    table.insert(output, (entry .. os_sep))
                  else
                  end
                  if (not found_3f and (not depth or (level < depth))) then
                    parse_dir_async(entry, (level + 1))
                  else
                  end
                elseif true then
                  local _ = _19_
                  if match_pattern_3f(entry) then
                    table.insert(output, entry)
                  else
                  end
                else
                end
              else
              end
            end
            return nil
          elseif (nil ~= _16_) then
            local err = _16_
            return eprint(err)
          elseif ((_16_ == nil) and (_17_ == false)) then
            return print(string.format("%s directory is not accessible by the current user!", path))
          else
            return nil
          end
        end
        return _15_(await.fs_scandir(current_dir))
      elseif (nil ~= _13_) then
        local err = _13_
        return eprint(err)
      elseif ((_13_ == nil) and (_14_ == false)) then
        return print(string.format("%s directory is not accessible by the current user!", path))
      else
        return nil
      end
    end
    _12_(await.fs_access(current_dir, "X"))
    return callback0()
  end
  parse_dir_async = a.create(parse_dir, 3)
  parse_dir_async = a.wrap(parse_dir_async, 3, true)
  parse_dir_async(path, 1)
  return callback(output)
end
local scandir0 = a.create(scandir, 3, true)
local scandir1 = a.wrap(scandir0, 3, true)
return scandir1
