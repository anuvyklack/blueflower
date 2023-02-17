local async = require("blueflower.async")
local ts = require("blueflower.treesitter")
local get_node_text = vim.treesitter.query.get_node_text
local scandir_async = require("blueflower.scandir")
local _local_1_ = require("blueflower.config")
local os_sep = _local_1_["os-sep"]
local _local_2_ = vim.fn
local getcwd = _local_2_["getcwd"]
local fnamemodify = _local_2_["fnamemodify"]
local P = vim.pretty_print
local find_hyperlink_file_async
local function _3_(name, callback)
  if (name:find("^/") or name:find("^./")) then
    return callback(fnamemodify(name, ":p"))
  else
    return callback(scandir_async(getcwd(), {pattern = name, ["first-found?"] = true}))
  end
end
find_hyperlink_file_async = async.wrap(async.create(_3_, 2, true), 2)
local function open_file(path, _3fline_num)
  if _3fline_num then
    vim.cmd(string.format("edit +%d %s", _3fline_num, path))
    return vim.cmd("normal! zv")
  else
    return vim.cmd(string.format("edit %s", path))
  end
end
local open_hyperlink_at_cursor_async
local function _6_()
  local node = ts["find-parent-node-of-type"](ts["get-node-at-cursor"](), {"link", "short_link", "link_definition"})
  if node then
    local link
    local _7_
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
      _7_ = tbl_17_auto
    end
    link = table.concat(_7_, " ")
    P(link)
    local ret_1_auto
    do
      local file, target = link:match("^file:(.-)::(.*)$")
      if file then
        P("^file:")
        P(find_hyperlink_file_async(file))
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
        local file = link:match("^file:(.*)$")
        if file then
          P("^file:")
          P(find_hyperlink_file_async(file))
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
          local title = link:match("^%**")
          if title then
            P("title")
            ret_1_auto1 = true
          else
            ret_1_auto1 = nil
          end
        end
        if ret_1_auto1 then
          return ret_1_auto1
        else
          return nil
        end
      end
    end
  else
    return nil
  end
end
open_hyperlink_at_cursor_async = async.void(_6_)
return {["open-hyperlink-at-cursor-async"] = open_hyperlink_at_cursor_async}
