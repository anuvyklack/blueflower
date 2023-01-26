(code_block
  (token)
  . (tag_parameter) @language
  (content) @content)

(tag
  (tag_name) @_tagname
  (#eq? @_tagname "code")
  . (tag_parameter) @language
  (content) @content)

(tag
  (tag_name) @_tagname
  (#any-of? @_tagname "quote" "footnote")
  (content) @blueflower)

((inline_math) @latex
 (#offset! @latex 0 1 0 -1))

