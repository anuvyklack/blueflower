local highlight = require("blueflower.api-wrappers.highlight")
local get_hl = highlight.get
highlight.set("@bf.token", {fg = (get_hl("Comment")).fg, default = true})
highlight.set("@bf.comment", {link = "@comment", default = true})
highlight.set("@bf.error", {link = "Error", default = true})
for i = 1, 6 do
  local _2_
  do
    local t_1_ = get_hl(("markdownH" .. i))
    if (nil ~= t_1_) then
      t_1_ = (t_1_).fg
    else
    end
    _2_ = t_1_
  end
  highlight.set(("@bf.H" .. i), {fg = _2_, bold = true, default = true})
end
for i = 1, 6 do
  local hl_name = ("@bf.H" .. i)
  local background_hl_name = string.format("@bf.H%s.background", i)
  local _let_4_ = get_hl(hl_name)
  local bg = _let_4_["bg"]
  local hl_group = _let_4_
  hl_group.bg = nil
  highlight.set(hl_name, hl_group)
  if bg then
    highlight.set(background_hl_name, {bg = bg, default = true})
  else
    highlight.set(background_hl_name, {link = "CursorLine", default = true})
  end
end
for i = 1, 6 do
  local _7_
  do
    local t_6_ = get_hl(("@bf.H" .. i))
    if (nil ~= t_6_) then
      t_6_ = (t_6_).fg
    else
    end
    _7_ = t_6_
  end
  highlight.set(("@bf.dinkus.H" .. i), {fg = _7_, default = true})
end
highlight.set("@bf.TODO", {fg = (get_hl("Error")).fg, default = true})
highlight.set("@bf.DONE", {fg = (get_hl("String")).fg, default = true})
highlight.set("@bf.hard_break", {fg = (get_hl("@bf.H1")).fg, bold = true, default = true})
highlight.set("@bf.bold", {bold = true, default = true})
highlight.set("@bf.italic", {italic = true, default = true})
highlight.set("@bf.underline", {underline = true, default = true})
highlight.set("@bf.strikethrough", {strikethrough = true, default = true})
local _10_
do
  local t_9_ = get_hl("String")
  if (nil ~= t_9_) then
    t_9_ = (t_9_).fg
  else
  end
  _10_ = t_9_
end
highlight.set("@bf.verbatim", {fg = _10_, default = true})
highlight.set("@bf.tag", {link = "Comment", default = true})
highlight.set("@bf.hashtag", {link = "Constant", default = true})
highlight.set("@bf.tag.code.language", {link = "Comment", default = true})
highlight.set("@bf.tag.code", {link = "@bf.token.code_block", default = true})
highlight.set("@bf.tag.end.code", {link = "@bf.tag.code", default = true})
highlight.set("@bf.inline_tag", {link = "Constant", default = true})
highlight.set("@bf.inline_tag.label", {fg = (get_hl("Normal")).fg, default = true})
highlight.set("@bf.inline_tag.content", {link = "markdownURL", default = true})
highlight.set("@bf.inline_tag.parameters", {link = "Boolean", default = true})
for _, _12_ in ipairs({{"undone", "Normal"}, {"done", "Type"}, {"urgent", "Error"}, {"in_progress", "WarningMsg"}, {"pending", "String"}, {"uncertain", "Boolean"}, {"discarded", "Comment"}}) do
  local _each_13_ = _12_
  local status = _each_13_[1]
  local hl_group = _each_13_[2]
  highlight.set(("@bf.checkbox." .. status), {fg = get_hl(hl_group).fg, default = true})
end
highlight.set("@bf.paragraph.list.discarded", {link = "@bf.strikethrough", default = true})
highlight.set("@bf.link", {link = "markdownURL", default = true})
highlight.set("@bf.link.label", {link = "markdownLinkText", default = true})
highlight.set("@bf.link.target", {fg = (get_hl("Comment")).fg, default = true})
highlight.set("@bf.link.reference", {link = "@bf.link.target", default = true})
highlight.set("@bf.link.short_reference", {link = "@bf.link.label", default = true})
highlight.set("@bf.link.reference_definition", {link = "@bf.link.label", default = true})
highlight.set("@bf.token.link.label", {link = "@bf.link.label", default = true})
highlight.set("@bf.token.link.short_reference", {link = "@bf.token.link.label", default = true})
highlight.set("@bf.token.link.reference_definition", {link = "@bf.token.link.label", default = true})
highlight.set("@bf.token.definition", {fg = (get_hl("Type")).fg, default = true})
highlight.set("@bf.directive.name", {link = "String", default = true})
return highlight.set("@bf.directive.content", {link = "Comment", default = true})
