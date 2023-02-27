local _local_1_ = vim.api
local nvim_create_buf = _local_1_["nvim_create_buf"]
local Window = require("blueflower.api-wrappers.window")
local Buffer = require("blueflower.api-wrappers.buffer")
local _local_2_ = require("blueflower.files")
local get_current_file = _local_2_["get-current-file"]
local _local_3_ = require("blueflower.treesitter")
local go_to_node = _local_3_["go-to-node"]
local P = vim.pretty_print
local function show_outline()
  local n = 0
  local lines = {}
  local links = {}
  local window = Window()
  local curbuf = Buffer()
  local buffer = Buffer(nvim_create_buf(false, true))
  local file = get_current_file()
  local headings = file["get-headings"](file)
  for _, _4_ in ipairs(headings) do
    local _each_5_ = _4_
    local node = _each_5_["node"]
    local text = file["get-node-text"](file, node, false)
    for _0, line in ipairs(text) do
      local i
      do
        n = (n + 1)
        i = n
      end
      lines[i] = line
      links[i] = node
    end
  end
  buffer["set-lines"](buffer, 0, 1, lines)
  buffer["set-name"](buffer, "[Outline]")
  buffer.bo.bufhidden = "wipe"
  buffer.bo.filetype = "blueflower"
  buffer.bo.modifiable = false
  local function _6_()
    local _let_7_ = window["get-cursor"](window)
    local lnum = _let_7_[1]
    local node = links[lnum]
    window["set-buffer"](window, curbuf)
    go_to_node(node)
    return vim.cmd("normal! zv")
  end
  vim.keymap.set("n", "<CR>", _6_, {buffer = buffer.id})
  local function _8_()
    return window["set-buffer"](window, curbuf)
  end
  vim.keymap.set("n", "<Esc>", _8_, {buffer = buffer.id})
  local function _9_()
    return window["set-buffer"](window, curbuf)
  end
  vim.keymap.set("n", "<Tab>", _9_, {buffer = buffer.id})
  return window["set-buffer"](window, buffer)
end
return {["show-outline"] = show_outline}
