(local ts (require :blueflower.treesitter))
(local get-node-text vim.treesitter.query.get_node_text)
(import-macros {: do-until-true } "fnl.blueflower.macros")
; (import-macros {: do-until-true } "blueflower.macros")
(local P vim.pretty_print)
(local {: getcwd : fnamemodify} vim.fn)
(local os-sep "/")

; (fn get-hyperlink-parent-node [?node]
;   (let [node (or ?node (ts.current-node))
;         type (node:type)]
;     (match type
;       :section          nil
;       :tag              nil
;       :list             nil
;       :link             node
;       :short_link       node
;       :link_definition  node
;       _ (let [parent (node:parent)]
;           (when parent
;             (get-hyperlink-parent-node parent))))))

; (fn open-link [link]
;   (P link)
;   )

; file:shell::* Title


; function Hyperlinks.get_file_real_path(url_path)
;    local path = url_path
;    path = path:gsub('^file:', '')
;    if path:match('^/') then
;       return path
;    end
;    path = path:gsub('^./', '')
;    return vim.fn.fnamemodify(utils.current_file_path(), ':p:h') .. '/' .. path
; end

(fn get-file-full-path [file]
  (.. (fnamemodify (getcwd) ":p:h") os-sep file))


(fn open-file [path ?line-num]
  "Open file under PATH at LINE-NUM line."
  (if ?line-num
      (do
        (vim.cmd (string.format "edit +%d %s" ?line-num path))
        (vim.cmd "normal! zv"))
      ; else
      (vim.cmd (string.format "edit %s" path))))


(fn open-hyperlink-at-cursor []
  "Open hyperlink at cursor."
  ; (local node (get-hyperlink-parent-node))
  (local node (ts.find-parent-node-of-type (ts.get-node-at-cursor)
                                           [:link :short_link :link_definition]))
  (when node
    (let [link (table.concat
                 (icollect [_ line (ipairs (-> (node:field "target")
                                               (. 1)
                                               (ts.get-node-text)))]
                   (vim.trim line))
                 " ")]
      (P link)
      (do-until-true
        (let [(file target) (link:match "^file:(.-)::(.*)$")]
          (when file
            (P "^file:")
            true))

        (let [file (link:match "^file:(.*)$")]
          (when file
            (P "^file:")
            true))

        (let [title (link:match "^%**")]
          (when title
            (P "title")
            true)
          ))
      )))


; (if (let [(file target) (link:match "^file:(.*)::(.*)$")]
;       )
;   )


; (macro do-until-true [form ...]
;   "Accept a sequence of forms.  Execute first one. If it returns false, execute
; second one. If it returns false, execute third one, and so on.  If any form
; returns true, stop execution."
;   `(,if ,form
;      (if (not (,form))
;          (,do-until-true ,...))))

(macro do-until-true [form ...]
  )


{: open-hyperlink-at-cursor}
