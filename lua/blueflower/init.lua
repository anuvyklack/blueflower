local M = {}
M.setup = function(user_opts)
  do
    local config = require("blueflower.config")
    config:setup(user_opts)
  end
  vim.filetype.add({extension = {note = "blueflower", bf = "blueflower"}})
  require("blueflower.highlight")
  require("blueflower.autocmd")
  require("blueflower.keymaps")
  require("blueflower.commands")
  return require("blueflower.concealer")
end
M.setup_ts_parser = function()
  local _let_1_ = require("nvim-treesitter.parsers")
  local get_parser_configs = _let_1_["get_parser_configs"]
  local filetype_to_parsername = _let_1_["filetype_to_parsername"]
  local parser_config = get_parser_configs()
  parser_config.blueflower = {install_info = {url = "https://github.com/anuvyklack/tree-sitter-blueflower", files = {"src/parser.c", "src/scanner.cc"}, branch = "main"}, filetype = "blueflower"}
  filetype_to_parsername.blueflower = "blueflower"
  return nil
end
return M
