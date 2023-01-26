local M = {}
M.setup = function(user_opts)
  vim.filetype.add({extension = {note = "blueflower", bf = "blueflower"}})
  require("blueflower.highlight")
  require("blueflower.autocmd")
  require("blueflower.keymaps")
  return require("blueflower.commands")
end
M.setup_ts_parser = function()
  local ts_parsers = require("nvim-treesitter.parsers")
  local parser_config = ts_parsers.get_parser_configs()
  local ft_to_parser = ts_parsers.filetype_to_parsername
  parser_config.blueflower = {install_info = {url = "https://github.com/anuvyklack/tree-sitter-blueflower", files = {"src/parser.c", "src/scanner.cc"}, branch = "main"}, filetype = "blueflower"}
  ft_to_parser.blueflower = "blueflower"
  return nil
end
return M
