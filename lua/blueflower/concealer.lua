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
local function set_icon(buffer, virt_text, line_num, start_col, end_col)
  return buffer["set-extmark"](buffer, namespace, line_num, start_col, {virt_text = virt_text, virt_text_pos = "overlay", hl_mode = "combine", ephemeral = true})
end
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
        set_icon(buffer, virt_text.list, line_num, (end_col - 1), end_col)
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
          set_icon(buffer, vt, line_num, start_col, end_col)
        else
        end
      else
      end
    else
    end
  end
  return nil
end
local function _17_(_, tick)
  local bufnr = nvim_get_current_buf()
  if (ticks[bufnr] == tick) then
    return false
  else
    ticks[bufnr] = tick
    return true
  end
end
local function _19_(_, _0, bufnr, topline, botline)
  local buffer = Buffer(bufnr)
  local function _20_(...)
    local _21_ = ...
    if (_21_ == true) then
      local function _22_(...)
        local _23_ = ...
        if (nil ~= _23_) then
          local file = _23_
          local function _24_(...)
            local _25_ = ...
            if (nil ~= _25_) then
              local icons_positions = _25_
              set_icons(buffer, icons_positions)
              return true
            elseif true then
              local _1 = _25_
              return false
            else
              return nil
            end
          end
          return _24_(file["get-icons-positions"](file, topline, botline))
        elseif true then
          local _1 = _23_
          return false
        else
          return nil
        end
      end
      return _22_(files[buffer["get-name"](buffer)])
    elseif true then
      local _1 = _21_
      return false
    else
      return nil
    end
  end
  return _20_((buffer["get-option"](buffer, "filetype") == "blueflower"))
end
local function _29_(_, _0, bufnr, row)
  local buffer = Buffer(bufnr)
  local file = files[buffer["get-name"](buffer)]
  local icons_positions = file["get-icons-positions"](file, row, (row + 1))
  set_icons(buffer, icons_positions)
  return true
end
return api.nvim_set_decoration_provider(namespace, {on_start = _17_, on_win = _19_, on_line = _29_})
