local _local_1_ = require("blueflower.files")
local files = _local_1_["files"]
local load_file_async = _local_1_["load-file-async"]
local _local_2_ = require("blueflower.util")
local full_path = _local_2_["full-path"]
local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("blueflower", {clear = true})
local P = vim.pretty_print
local function _5_(_3_)
  local _arg_4_ = _3_
  local file = _arg_4_["file"]
  local bufnr = _arg_4_["buf"]
  local function _6_()
    return P(files)
  end
  load_file_async(full_path(file), _6_)
  return false
end
return autocmd("FileType", {pattern = "blueflower", group = group, callback = _5_})
