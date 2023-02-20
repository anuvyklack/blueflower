local _local_1_ = require("blueflower.util")
local merge_table_deep_21 = _local_1_["merge-table-deep!"]
local make_set_from_list = _local_1_["make-set-from-list"]
local initialized = false
local Config = {}
local config = {["os-sep"] = "/", augroup = vim.api.nvim_create_augroup("blueflower", {clear = true}), open_in_external_app = {"pdf", "png", "jpeg", "jpg", "doc", "docx"}, link_shortcuts = {}}
Config.setup = function(self, _3finput)
  if not initialized then
    merge_table_deep_21(self, (_3finput or {}))
    self["open-in-external-app"] = make_set_from_list(self.open_in_external_app)
    initialized = true
    return nil
  else
    return nil
  end
end
return setmetatable(config, {__index = Config})
