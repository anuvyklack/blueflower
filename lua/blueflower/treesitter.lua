local ts_utils = require("nvim-treesitter.ts_utils")
local parsers = require("nvim-treesitter.parsers")
local Buffer = require("blueflower/api-wrappers/buffer")
local function get_node_at_cursor()
  return ts_utils.get_node_at_cursor(vim.api.nvim_get_current_win())
end
local function impl_find_parent_node_any_of_types(node, types)
  if types[node:type()] then
    return node
  else
    local parent = node:parent()
    if parent then
      return impl_find_parent_node_any_of_types(parent, types)
    else
      return nil
    end
  end
end
local function impl_find_parent_node_of_type(node, node_type)
  if (node:type() == node_type) then
    return node
  else
    local parent = node:parent()
    if parent then
      return impl_find_parent_node_of_type(parent, node_type)
    else
      return nil
    end
  end
end
local function find_parent_node_of_type(node, node_type)
  local _5_ = type(node_type)
  if (_5_ == "table") then
    local function _6_()
      local tbl_14_auto = {}
      for _, ntype in ipairs(node_type) do
        local _7_, _8_ = ntype, true
        if ((nil ~= _7_) and (nil ~= _8_)) then
          local k_15_auto = _7_
          local v_16_auto = _8_
          tbl_14_auto[k_15_auto] = v_16_auto
        else
        end
      end
      return tbl_14_auto
    end
    return impl_find_parent_node_any_of_types(node, _6_())
  elseif (_5_ == "string") then
    return impl_find_parent_node_of_type(node, node_type)
  else
    return nil
  end
end
local function get_node_text(node)
  local buffer = Buffer()
  return buffer["get-text"](buffer, node:range())
end
return {["get-node-at-cursor"] = get_node_at_cursor, ["find-parent-node-of-type"] = find_parent_node_of_type, ["get-node-text"] = get_node_text}
