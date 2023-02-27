local _local_1_ = vim.api
local nvim_buf_get_name = _local_1_["nvim_buf_get_name"]
local nvim_win_set_cursor = _local_1_["nvim_win_set_cursor"]
local async = require("blueflower.async")
local ts = require("blueflower.treesitter")
local scandir_async = require("blueflower.files.scandir")
local _local_2_ = require("blueflower.config")
local os_sep = _local_2_["os-sep"]
local config = _local_2_
local _local_3_ = vim.fn
local getcwd = _local_3_["getcwd"]
local fnamemodify = _local_3_["fnamemodify"]
local _local_4_ = require("blueflower.files.util")
local open_file = _local_4_["open-file"]
local xdg_open = _local_4_["xdg-open"]
local find_and_open_file_async = _local_4_["find-and-open-file-async"]
local _local_5_ = require("blueflower.util")
local notify_error = _local_5_["notify-error"]
local _local_6_ = require("blueflower.files")
local get_current_file = _local_6_["get-current-file"]
local open_link_async = nil
local P = vim.pretty_print
local function process_link_shortcuts(link)
  local new_link = nil
  for shortcut, expand_to in pairs(config.link_abbreviations) do
    if new_link then break end
    local pattern = string.format("^%s:", shortcut)
    local start, stop = link:find(pattern)
    if start then
      new_link = (expand_to .. link:sub((stop + 1)))
    else
    end
  end
  return (new_link or link)
end
local hyperlink_open_file_async
local function hyperlink_open_file_async0(file, callback)
  local file0 = file:gsub("^///", "/")
  if (file0:find("^/") or file0:find("^%./") or file0:find("^~/")) then
    local file1 = fnamemodify(file0, ":p")
    open_file(file1)
    return callback(true)
  else
    return callback(find_and_open_file_async(getcwd(), file0))
  end
end
hyperlink_open_file_async = async.wrap(async.create(hyperlink_open_file_async0, 2, true), 2, true)
local function jump_to_heading(heading)
  local _, level = heading:find("^%*+")
  local title = vim.trim(string.gsub(string.gsub(heading:sub((level + 1)), "\13?\n", " "), "%s+", " "))
  local file = get_current_file()
  local headings = file["get-headings"](file, true)
  local found_title = nil
  for _0, h in ipairs(headings[level]) do
    if found_title then break end
    if (title == h.title) then
      found_title = h
    else
    end
  end
  if not found_title then
    local headings0
    do
      table.remove(headings, level)
      headings0 = vim.tbl_flatten(headings)
    end
    for h in ipairs(headings0) do
      if found_title then break end
      if (title == h.title) then
        found_title = h
      else
      end
    end
  else
  end
  if not found_title then
    return notify_error(("No section with title: " .. title))
  else
    return ts["go-to-node"](found_title.node)
  end
end
local function jump_to_link_definition(target)
  local file = get_current_file()
  local link_def
  do
    local ret_1_auto
    do
      local node = ts["find-parent-node-of-type"](ts["get-node-at-cursor"](), "section")
      local link_definitions = file["get-link-definitions"](file, node)
      ret_1_auto = link_definitions[target]
    end
    if ret_1_auto then
      link_def = ret_1_auto
    else
      local ret_1_auto0 = (file["get-link-definitions"](file))[target]
      if ret_1_auto0 then
        link_def = ret_1_auto0
      else
        link_def = nil
      end
    end
  end
  if link_def then
    local _let_15_ = link_def
    local link = _let_15_["link"]
    local node = _let_15_["node"]
    do
      local _16_ = config.link_definition_behavior
      if (_16_ == "pass") then
        open_link_async(link)
      elseif (_16_ == "stick") then
        ts["go-to-node"](node)
      else
      end
    end
    return true
  else
    return false
  end
end
local function jump_to_id(target)
  local file = get_current_file()
  local ids = file["get-ids"](file)
  local id_node = ids[target]
  if not id_node then
    return notify_error(("No such id: " .. target))
  else
    local parent = id_node:parent()
    local target_node
    do
      local _19_ = parent:type()
      if (_19_ == "section") then
        target_node = parent
      elseif (_19_ == "list") then
        target_node = (parent:field("list_item"))[1]
      elseif (_19_ == "definition") then
        target_node = (parent:field("term"))[1]
      elseif (_19_ == "tag") then
        target_node = (parent:field("content"))[1]
      else
        target_node = nil
      end
    end
    local row, col = target_node:start()
    return ts["go-to-node"](target_node)
  end
end
local function jump_to_target(target)
  local ret_1_auto
  if target:find("^%*+") then
    jump_to_heading(target)
    ret_1_auto = true
  else
    ret_1_auto = nil
  end
  if ret_1_auto then
    return ret_1_auto
  else
    local ret_1_auto0 = jump_to_link_definition(target)
    if ret_1_auto0 then
      return ret_1_auto0
    else
      local ret_1_auto1 = jump_to_id(target)
      if ret_1_auto1 then
        return ret_1_auto1
      else
        return nil
      end
    end
  end
end
local function _26_(link)
  local link0 = process_link_shortcuts(link)
  local ret_1_auto
  if link0:find("^https?://") then
    xdg_open(link0)
    ret_1_auto = true
  else
    ret_1_auto = nil
  end
  if ret_1_auto then
    return ret_1_auto
  else
    local ret_1_auto0
    do
      local path, fname, target = link0:match("^file:(.-):find:(.-)::(.*)$")
      if (path and fname and target) then
        local function _28_(...)
          local _29_ = ...
          if (_29_ == true) then
            return jump_to_target(target)
          elseif true then
            local __63_auto = _29_
            return ...
          else
            return nil
          end
        end
        _28_(find_and_open_file_async(path, fname))
        ret_1_auto0 = true
      else
        ret_1_auto0 = nil
      end
    end
    if ret_1_auto0 then
      return ret_1_auto0
    else
      local ret_1_auto1
      do
        local path, fname = link0:match("^file:(.-):find:(.*)$")
        if (path and fname) then
          find_and_open_file_async(path, fname)
          ret_1_auto1 = true
        else
          ret_1_auto1 = nil
        end
      end
      if ret_1_auto1 then
        return ret_1_auto1
      else
        local ret_1_auto2
        do
          local fname, target = link0:match("^file:(.-)::(.*)$")
          if (fname and target) then
            local function _33_(...)
              local _34_ = ...
              if (_34_ == true) then
                return jump_to_target(target)
              elseif true then
                local __63_auto = _34_
                return ...
              else
                return nil
              end
            end
            _33_(hyperlink_open_file_async(fname))
            ret_1_auto2 = true
          else
            ret_1_auto2 = nil
          end
        end
        if ret_1_auto2 then
          return ret_1_auto2
        else
          local ret_1_auto3
          do
            local fname = link0:match("^file:(.*)$")
            if fname then
              hyperlink_open_file_async(fname)
              ret_1_auto3 = true
            else
              ret_1_auto3 = nil
            end
          end
          if ret_1_auto3 then
            return ret_1_auto3
          else
            local ret_1_auto4 = jump_to_target(link0)
            if ret_1_auto4 then
              return ret_1_auto4
            else
              return nil
            end
          end
        end
      end
    end
  end
end
open_link_async = async.void(_26_, true)
local function open_hyperlink_at_cursor()
  local node = ts["find-parent-node-of-type"](ts["get-node-at-cursor"](), {"link", "short_link", "link_definition"})
  if node then
    local lines
    do
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for _, line in ipairs(ts["get-node-text"]((node:field("target"))[1])) do
        local val_19_auto = vim.trim(line)
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      lines = tbl_17_auto
    end
    local link = table.concat(lines, " ")
    return open_link_async(link)
  else
    return nil
  end
end
return {["open-hyperlink-at-cursor"] = open_hyperlink_at_cursor}
