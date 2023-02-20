local async = require("blueflower.async")
local ts = require("blueflower.treesitter")
local get_node_text = vim.treesitter.query.get_node_text
local scandir_async = require("blueflower.scandir")
local _local_1_ = require("blueflower.config")
local os_sep = _local_1_["os-sep"]
local config = _local_1_
local _local_2_ = vim.fn
local getcwd = _local_2_["getcwd"]
local fnamemodify = _local_2_["fnamemodify"]
local _local_3_ = require("blueflower.files.util")
local open_file = _local_3_["open-file"]
local open_in_vim = _local_3_["open-in-vim"]
local find_file_async = _local_3_["find-file-async"]
local _local_4_ = require("blueflower.util")
local notify_error = _local_4_["notify-error"]
local P = vim.pretty_print
local get_file_path_async
local function get_file_path_async0(name, callback)
  if name:find("^///") then
    return callback(name:sub(3))
  elseif (name:find("^/") or name:find("^./") or name:fine("^~/")) then
    return callback(fnamemodify(name, ":p"))
  else
    local _5_
    do
      local _let_6_ = scandir_async(getcwd(), {pattern = name, ["first-found?"] = true})
      local file = _let_6_[1]
      _5_ = callback(file)
    end
    if _5_ then
      return callback(find_file_async(getcwd(), name))
    else
      return nil
    end
  end
end
get_file_path_async = async.wrap(async.create(get_file_path_async0, 2, true), 2)
local function process_link_shortcuts(link)
  local new_link = nil
  for shortcut, expand_to in pairs(config.link_shortcuts) do
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
local open_hyperlink_at_cursor_async
local function open_hyperlink_at_cursor_async0()
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
    local link0 = process_link_shortcuts(link)
    local ret_1_auto
    do
      local fname, target = link0:match("^file:(.-)::(.*)$")
      if fname then
        open_in_vim(get_file_path_async(fname))
        ret_1_auto = true
      else
        ret_1_auto = nil
      end
    end
    if ret_1_auto then
      return ret_1_auto
    else
      local ret_1_auto0
      do
        local path, fname = link0:match("^file:(.-):find:(.*)$")
        if (path and fname) then
          local file = find_file_async(path, fname)
          async.scheduler()
          if file then
            open_file(file)
          else
            notify_error(string.format("No file found! Path: \"%s\" File: \"%s\"", path, fname))
          end
        else
        end
        ret_1_auto0 = (path or fname)
      end
      if ret_1_auto0 then
        return ret_1_auto0
      else
        local ret_1_auto1
        do
          local fname = link0:match("^file:(.*)$")
          if fname then
            do
              local path = get_file_path_async(fname)
              async.scheduler()
              open_file(vim.uri_from_fname(path))
            end
            ret_1_auto1 = true
          else
            ret_1_auto1 = nil
          end
        end
        if ret_1_auto1 then
          return ret_1_auto1
        else
          local ret_1_auto2
          if link0:find("^https?://") then
            __fnl_global__xdg_2dopen(link0)
            ret_1_auto2 = true
          else
            ret_1_auto2 = nil
          end
          if ret_1_auto2 then
            return ret_1_auto2
          else
            local ret_1_auto3
            do
              local title = link0:match("^%**")
              if title then
                ret_1_auto3 = true
              else
                ret_1_auto3 = nil
              end
            end
            if ret_1_auto3 then
              return ret_1_auto3
            else
              return nil
            end
          end
        end
      end
    end
  else
    return nil
  end
end
open_hyperlink_at_cursor_async = async.void(open_hyperlink_at_cursor_async0)
return {["open-hyperlink-at-cursor-async"] = open_hyperlink_at_cursor_async}
