(local highlight (require "blueflower.api-wrappers.highlight"))
(local get-hl highlight.get)

(macro hl [name spec]
  (tset spec :default true)
  `(highlight.set ,name ,spec))

(hl "@bf.token" {:fg (. (get-hl "Comment") :fg)})

(hl "@bf.comment" {:link "@comment"})
(hl "@bf.error" {:link "Error"})

;; Section {{{
;; Headings
(for [i 1 6]
  (hl (.. "@bf.H" i)
      {:fg (-> (.. "markdownH" i) (get-hl) (?. :fg))
       :bold true}))

(for [i 1 6]
  (hl (.. "@bf.dinkus.H" i)
      {:fg (-> (.. "@bf.H" i) (get-hl) (?. :fg))}))

(hl "@bf.TODO" {:fg (. (get-hl :Error) :fg)})
(hl "@bf.DONE" {:fg (. (get-hl :String) :fg)})

;; }}}

(hl "@bf.hard_break" {:fg (. (get-hl "@bf.H1") :fg)
                      :bold true})

;; Markup {{{
(hl "@bf.bold"          {:bold true})
(hl "@bf.italic"        {:italic true})
(hl "@bf.underline"     {:underline true})
(hl "@bf.strikethrough" {:strikethrough true})
(hl "@bf.verbatim"      {:fg (?. (get-hl "markdownCode") :fg)})
;; }}}

;; List {{{

;; List checkboxes
(each [_ [status hl-group] (ipairs [[:undone      :Normal]
                                    [:done        :Type]
                                    [:urgent      :Error]
                                    [:in_progress :WarningMsg]
                                    [:pending     :String]
                                    [:uncertain   :Boolean]
                                    [:discarded   :Comment]])]
  (hl (.. "@bf.checkbox." status)
      {:fg (. (get-hl hl-group) :fg)}))

(hl "@bf.paragraph.list.discarded" {:link "@bf.strikethrough"})

;; }}}

;; Links {{{

; @bf.link
; @bf.link.label
; @bf.link.reference
; @bf.link.short_reference
; @bf.link.reference_definition
; @bf.link.target
; @bf.token.link.reference_definition

(hl "@bf.link"                      {:link  :markdownURL})
(hl "@bf.link.label"                {:link  :markdownLinkText})
(hl "@bf.link.target"               {:fg (. (get-hl :Comment) :fg)})
(hl "@bf.link.reference"            {:link  "@bf.link.target"})
(hl "@bf.link.short_reference"      {:link  "@bf.link.label"})
(hl "@bf.link.reference_definition" {:link  "@bf.link.label"})

(hl "@bf.token.link.label"                {:link  "@bf.link.label"})
(hl "@bf.token.link.short_reference"      {:link  "@bf.token.link.label"})
(hl "@bf.token.link.reference_definition" {:link  "@bf.token.link.label"})

;; }}}

;; Tags {{{

(hl "@bf.tag"         {:link :Comment})
(hl "@bf.hashtag"     {:link :Constant})
(hl "@bf.tag.code.language" {:link  :Constant})
(hl "@bf.tag.code"          {:link  "@bf.token.code_block"})
(hl "@bf.tag.end.code"      {:link  "@bf.tag.code"})

(hl "@bf.inline_tag"  {:link :Constant})
; (hl "@bf.token.inline_tag.label" {})
(hl "@bf.inline_tag.label" {:fg (. (get-hl :Normal) :fg)})
; (hl "@bf.token.inline_tag.content" {})
(hl "@bf.inline_tag.content" {:link  :markdownURL})
; (hl "@bf.token.inline_tag.parameters" {})
(hl "@bf.inline_tag.parameters" {:link :Boolean})

;; }}}

; (hl "@bf.directive.name"    {:link "@bf.token"})
(hl "@bf.directive.name"    {:link "String"})
(hl "@bf.directive.content" {:link "Comment"})

;; vim: fdm=marker
