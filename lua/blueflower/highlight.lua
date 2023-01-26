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
  local _5_
  do
    local t_4_ = get_hl(("@bf.H" .. i))
    if (nil ~= t_4_) then
      t_4_ = (t_4_).fg
    else
    end
    _5_ = t_4_
  end
  highlight.set(("@bf.dinkus.H" .. i), {fg = _5_, default = true})
end
highlight.set("@bf.TODO", {fg = (get_hl("Error")).fg, default = true})
highlight.set("@bf.DONE", {fg = (get_hl("String")).fg, default = true})
highlight.set("@bf.hard_break", {fg = (get_hl("@bf.H1")).fg, bold = true, default = true})
highlight.set("@bf.bold", {bold = true, default = true})
highlight.set("@bf.italic", {italic = true, default = true})
highlight.set("@bf.underline", {underline = true, default = true})
highlight.set("@bf.strikethrough", {strikethrough = true, default = true})
local _8_
do
  local t_7_ = get_hl("markdownCode")
  if (nil ~= t_7_) then
    t_7_ = (t_7_).fg
  else
  end
  _8_ = t_7_
end
highlight.set("@bf.verbatim", {fg = _8_, default = true})
for _, _10_ in ipairs({{"undone", "Normal"}, {"done", "Type"}, {"urgent", "Error"}, {"in_progress", "WarningMsg"}, {"pending", "String"}, {"uncertain", "Boolean"}, {"discarded", "Comment"}}) do
  local _each_11_ = _10_
  local status = _each_11_[1]
  local hl_group = _each_11_[2]
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
highlight.set("@bf.tag", {link = "Comment", default = true})
highlight.set("@bf.hashtag", {link = "Constant", default = true})
highlight.set("@bf.tag.code.language", {link = "Constant", default = true})
highlight.set("@bf.tag.code", {link = "@bf.token.code_block", default = true})
highlight.set("@bf.tag.end.code", {link = "@bf.tag.code", default = true})
highlight.set("@bf.inline_tag", {link = "Constant", default = true})
highlight.set("@bf.inline_tag.label", {fg = (get_hl("Normal")).fg, default = true})
highlight.set("@bf.inline_tag.content", {link = "markdownURL", default = true})
highlight.set("@bf.inline_tag.parameters", {link = "Boolean", default = true})
highlight.set("@bf.directive.name", {link = "String", default = true})
return highlight.set("@bf.directive.content", {link = "Comment", default = true})
