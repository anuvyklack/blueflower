local _local_1_ = vim.api
local nvim_get_current_buf = _local_1_["nvim_get_current_buf"]
local nvim_win_get_cursor = _local_1_["nvim_win_get_cursor"]
local api = _local_1_
local Buffer = require("blueflower/api-wrappers/buffer")
local _local_2_ = require("blueflower.files")
local files = _local_2_["files"]
local get_current_file = _local_2_["get-current-file"]
local config = require("blueflower.config")
local namespace = api.nvim_create_namespace("blueflower-icons")
local ticks = {}
local P = vim.pretty_print
local virt_text
local _3_
do
  local tbl_14_auto = {}
  for _, status in ipairs({"done", "cancelled", "urgent", "uncertain", "half"}) do
    local _4_, _5_ = nil, nil
    do
      local icon = config.icons.checkbox[status]
      if icon then
        local text = ("[" .. icon .. "]")
        _4_, _5_ = status, {{text}}
      else
        _4_, _5_ = nil
      end
    end
    if ((nil ~= _4_) and (nil ~= _5_)) then
      local k_15_auto = _4_
      local v_16_auto = _5_
      tbl_14_auto[k_15_auto] = v_16_auto
    else
    end
  end
  _3_ = tbl_14_auto
end
virt_text = {list = {{config.icons.list, "Macro"}}, checkbox = _3_}
local function set_icon(buffer, virt_text0, line_num, column)
  return buffer["set-extmark"](buffer, namespace, line_num, column, {virt_text = virt_text0, virt_text_pos = "overlay", virt_text_hide = true, hl_mode = "combine", ephemeral = true})
end
local function set_icons(buffer, icons_positions)
  local _let_8_ = nvim_win_get_cursor(0)
  local cursor_line = _let_8_[1]
  local cursor_line0 = (cursor_line - 1)
  for _, _9_ in ipairs(icons_positions) do
    local _each_10_ = _9_
    local type = _each_10_["type"]
    local text = _each_10_["text"]
    local line_num = _each_10_["line-num"]
    local start_col = _each_10_["start-col"]
    local end_col = _each_10_["end-col"]
    if (config.concealcursor or (cursor_line0 ~= line_num)) then
      local _11_ = type
      if (_11_ == "list_token") then
        set_icon(buffer, virt_text.list, line_num, (end_col - 1))
      elseif (_11_ == "checkbox") then
        local vt
        do
          local _12_ = text
          if (_12_ == "[x]") then
            vt = virt_text.checkbox.done
          elseif (_12_ == "[-]") then
            vt = virt_text.checkbox.pending
          elseif (_12_ == "[+]") then
            vt = virt_text.checkbox.half
          elseif (_12_ == "[!]") then
            vt = virt_text.checkbox.urgent
          elseif (_12_ == "[?]") then
            vt = virt_text.checkbox.uncertain
          elseif (_12_ == "[_]") then
            vt = virt_text.checkbox.cancelled
          else
            vt = nil
          end
        end
        if vt then
          set_icon(buffer, vt, line_num, start_col)
        else
        end
      else
      end
    else
    end
  end
  return nil
end
local function set_heading_background_highlight(buffer, heading_node)
  P(heading_node:type())
  local _let_17_ = heading_node:field("level")
  local level_node = _let_17_[1]
  local _, start, _0, stop = level_node:range()
  local level
  do
    local lvl = ((stop - start) % 6)
    if (lvl == 0) then
      level = 1
    else
      level = lvl
    end
  end
  local hl_group = string.format("@bf.H%s.background", level)
  local start_line, _1, end_line, _2 = heading_node:range()
  return buffer["set-extmark"](buffer, namespace, start_line, 0, {hl_group = hl_group, end_row = end_line, end_col = 0, hl_eol = true, hl_mode = "combine", ephemeral = true})
end
local set_headings_highlight
if config.highlight_headings_background then
  local function _19_(file)
    local buffer = file.buffer
    local headings = file["get-headings"](file)
    for _, _20_ in ipairs(headings) do
      local _each_21_ = _20_
      local node = _each_21_["node"]
      set_heading_background_highlight(buffer, node)
    end
    return nil
  end
  set_headings_highlight = _19_
else
  local function _22_()
  end
  set_headings_highlight = _22_
end
local set_heading_highlight_for_row
if config.highlight_headings_background then
  local function _24_(file, line_num)
    local node = file["get-named-descendant-for-range"](file, line_num, 0, (line_num + 1), 0)
    local _25_ = node:type()
    if (_25_ == "heading") then
      return set_heading_background_highlight(file.buffer, node)
    else
      return nil
    end
  end
  set_heading_highlight_for_row = _24_
else
  local function _27_()
  end
  set_heading_highlight_for_row = _27_
end
local function _29_(_, tick)
  local bufnr = nvim_get_current_buf()
  if (ticks[bufnr] == tick) then
    return false
  else
    ticks[bufnr] = tick
    return true
  end
end
local function _31_(_, _0, bufnr, topline, botline)
  local buffer = Buffer(bufnr)
  local function _32_(...)
    local _33_ = ...
    if (_33_ == true) then
      local function _34_(...)
        local _35_ = ...
        if (nil ~= _35_) then
          local file = _35_
          do
            local _36_ = file["get-icons-positions"](file, topline, botline)
            if (_36_ ~= nil) then
              set_icons(buffer, _36_)
            else
            end
          end
          set_headings_highlight(file)
          return true
        elseif true then
          local _1 = _35_
          return false
        else
          return nil
        end
      end
      return _34_(files[buffer["get-name"](buffer)])
    elseif true then
      local _1 = _33_
      return false
    else
      return nil
    end
  end
  return _32_((buffer["get-option"](buffer, "filetype") == "blueflower"))
end
local function _40_(_, _0, bufnr, row)
  local buffer = Buffer(bufnr)
  local file = files[buffer["get-name"](buffer)]
  local icons_positions = file["get-icons-positions"](file, row, (row + 1))
  set_icons(buffer, icons_positions)
  set_heading_highlight_for_row(file, row)
  return true
end
return api.nvim_set_decoration_provider(namespace, {on_start = _29_, on_win = _31_, on_line = _40_})
