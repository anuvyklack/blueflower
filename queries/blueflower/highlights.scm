;; General {{{

(comment) @bf.comment

;; Comment block
(tag
  (tag_name) @_name
  (#eq? @_name "comment")) @bf.comment

(ERROR) @bf.error

(hard_break) @bf.hard_break

;;}}}

;; Headings {{{
;; Headings here will be matched cyclically, easily extended to match however
;; your heart desires.
(section
  (heading
    level: (token) @bf.token.H1
    (#match? @bf.token.H1 "^(\\*{6})*\\*$")
    (title)) @bf.H1
  ; (directive
  ;   (token) @bf.directive.H1
  ;   (name)  @bf.directive.H1)*
  ;   (token) @bf.directive.H1
  ; (content
  ;   . (hashtag
  ;       (token) @bf.tag.hashtag.H1
  ;       (tag_name) @bf.tag.hashtag.H1)*)
  (dinkus)? @bf.dinkus.H1)

(section
  (heading
    level: (token) @bf.token.H2
    (#match? @bf.token.H2 "^(\\*{6})*\\*\\*$")
    (title)) @bf.H2
  (dinkus)? @bf.dinkus.H2)

(section
  (heading
    level: (token) @bf.token.H3
    (#match? @bf.token.H3 "^(\\*{6})*\\*\\*\\*$")
    (title)) @bf.H3
  (dinkus)? @bf.dinkus.H3)

(section
  (heading
    level: (token) @bf.token.H4
    (#match? @bf.token.H4 "^(\\*{6})*\\*\\*\\*\\*$")
    (title)) @bf.H4
  (dinkus)? @bf.dinkus.H4)

(section
  (heading
    level: (token) @bf.token.H5
    (#match? @bf.token.H5 "^(\\*{6})*\\*\\*\\*\\*\\*$")
    (title)) @bf.H5
  (dinkus)? @bf.dinkus.H5)

(section
  (heading
    level: (token) @bf.token.H6
    (#match? @bf.token.H6 "^(\\*{6})*\\*\\*\\*\\*\\*\\*$")
    (title)) @bf.H6
  (dinkus)? @bf.dinkus.H6)

(section
  (directive
    (token) @bf.directive.name.section
    (name)  @bf.directive.name.section
    (token) @bf.directive.name.section
    (content) @bf.directive.content.section)* @bf.directive.section)

;; }}}

;; Tags {{{

(inline_tag
  (token) @bf.inline_tag
  (tag_name) @bf.inline_tag
  (token)? @bf.token.inline_tag.label
  label: (label)? @bf.inline_tag.label
  (token)? @bf.token.inline_tag.label
  open_content: (token)? @bf.token.inline_tag.content
  (content)? @bf.inline_tag.content
  close_content: (token)? @bf.token.inline_tag.content
  open_parameters: (token)? @bf.token.inline_tag.parameters
  (parameters)? @bf.inline_tag.parameters
  close_parameters: (token)? @bf.token.inline_tag.parameters)

(hashtag
  (token) @bf.hashtag
  (tag_name) @bf.hashtag)

(tag
  (directive
    (token) @bf.directive.name.tag
    (name)  @bf.directive.name.tag
    (token) @bf.directive.name.tag
    (content) @bf.directive.content.tag)* @bf.directive.tag
  (token) @bf.tag
  (tag_name) @bf.tag
  parameter: (tag_parameter)* @bf.tag.parameter
  (end_tag)@bf.tag )

;; @code
(tag
  (directive
    (token) @bf.directive.name.code
    (name)  @bf.directive.name.code
    (token) @bf.directive.name.code
    (content) @bf.directive.content.code)* @bf.directive.code
  (token) @bf.tag.code
  (tag_name) @bf.tag.code
  (#eq? @bf.tag.code "code")
  . (tag_parameter)? @bf.tag.code.language
  ; (tag_parameter)* @bf.tag.parameter
  (content) @bf.code_block
  (end_tag) @bf.tag.end.code)

(code_block
  (directive
    (token) @bf.directive.name.code
    (name)  @bf.directive.name.code
    (token) @bf.directive.name.code
    (content) @bf.directive.content.code)* @bf.directive.code
  (token) @bf.token.code_block
  . (tag_parameter) @bf.tag.code.language
  (tag_parameter)* @bf.tag.parameter
  code: (content) @bf.code_block
  (token) @bf.token.code_block)

;; }}}

;; Markup {{{
(bold (token) @bf.token.bold)
(bold (content) @bf.bold)

(italic (token) @bf.token.italic)
(italic (content) @bf.italic)

(underline (token) @bf.token.underline)
(underline (content) @bf.underline)

(strikethrough (token) @bf.token.strikethrough)
(strikethrough (content) @bf.strikethrough)

(verbatim (token) @bf.token.verbatim)
(verbatim (content) @bf.verbatim)

(inline_math (token) @bf.token.inline_math)
(inline_math (content) @bf.inline_math)
;; }}}

;; Lists {{{

(list_block
  (list
    (directive
      (token) @bf.directive.name.list
      (name)  @bf.directive.name.list
      (token) @bf.directive.name.list
      (content) @bf.directive.content.list)* @bf.directive.list)
  (list_break) @bf.token.list_break)

(list_item
  level: (token) @bf.token.list)

((checkbox) @_checkbox (#eq? @_checkbox "[ ]")) @bf.checkbox.undone
((checkbox) @_checkbox (#eq? @_checkbox "[x]")) @bf.checkbox.done
((checkbox) @_checkbox (#eq? @_checkbox "[!]")) @bf.checkbox.urgent
((checkbox) @_checkbox (#eq? @_checkbox "[+]")) @bf.checkbox.in_progress
((checkbox) @_checkbox (#eq? @_checkbox "[-]")) @bf.checkbox.pending
((checkbox) @_checkbox (#eq? @_checkbox "[?]")) @bf.checkbox.uncertain
(list_item
  ((checkbox) @_checkbox (#eq? @_checkbox "[_]")) @bf.checkbox.discarded
  (paragraph) @bf.paragraph.list.discarded)

;; }}}

;; Links {{{

(link
  open_label: (token) @bf.token.link.label
  (label) @bf.link.label
  close_label: (token) @bf.token.link.label
  open_target: (token) @bf.token.link.target
  (target) @bf.link.target
  close_target: (token) @bf.token.link.target)

(short_link
  (token) @bf.token.link.short_reference
  (target) @bf.link.short_reference
  (token) @bf.token.link.short_reference)

(link_definition
  (token) @bf.token.link.reference_definition
  (label) @bf.link.reference_definition
  (token) @bf.token.link.reference_definition
  (target) @bf.link)

;; }}}

;; Definitions {{{
(definition
  (directive
    (token) @bf.directive.name.definition
    (name)  @bf.directive.name.definition
    (token) @bf.directive.name.definition
    (content) @bf.directive.content.definition)* @bf.directive.definition
  (term) @bf.definition.term
  description_begin: (token) @bf.token.definition.begin
  (description) @bf.definition.description
  description_end: (token) @bf.token.definition.end
  )
;; }}}

; ;; Tasks status {{{
;
; (section
;   (heading
;     (title
;       . (word) @bf.TODO
;       (#eq? @bf.TODO "TODO"))))
;
; (section
;   (heading
;     (title
;       . (word) @bf.DONE
;       (#eq? @bf.DONE "DONE"))))
;
; ;;}}}

(escaped_char
  (token) @bf.token.escaped)

;; vim: ts=2 sts=2 sw=2 nospell fdm=marker
