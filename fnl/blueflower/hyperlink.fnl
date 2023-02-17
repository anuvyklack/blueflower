(local async (require :blueflower.async))
(local ts (require :blueflower.treesitter))
(local get-node-text vim.treesitter.query.get_node_text)
(local scandir-async (require :blueflower.scandir))
(import-macros {: do-until-true } "fnl.blueflower.macros")
; (import-macros {: do-until-true } "blueflower.macros")
(local {: os-sep} (require :blueflower.config))
(local {: getcwd : fnamemodify} vim.fn)
(local P vim.pretty_print)

; file:shell::* Title


; function Hyperlinks.get_file_real_path(url_path)
;    local path = url_path
;    path = path:gsub('^file:', '')
;    if path:match('^/') then
;       return path
;    end
;    path = path:gsub('^./', '')
;    return fnamemodify(utils.current_file_path(), ':p:h') .. '/' .. path
; end

; (fn get-file-full-path [file]
;   (.. (fnamemodify (getcwd) ":p") os-sep file))


(local find-hyperlink-file-async
  (-> (fn [name callback]
        (if (or (name:find "^/")
                (name:find "^./"))
          (callback (fnamemodify name ":p"))
          ;else
          (callback (scandir-async (getcwd) {:pattern name
                                             :first-found? true})
          ; (callback (-> (scandir-async (getcwd) {:pattern name :first-found? true})
          ;               ; (. 1)
          ;               ; (fnamemodify ":p")
          ;               ))
          )))
      (async.create 2 true)
      (async.wrap 2)))


(fn open-file [path ?line-num]
  "Open file under PATH at LINE-NUM line."
  (if ?line-num
      (do
        (vim.cmd (string.format "edit +%d %s" ?line-num path))
        (vim.cmd "normal! zv"))
      ; else
      (vim.cmd (string.format "edit %s" path))))

(local open-hyperlink-at-cursor-async
  (-> (fn []
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
                  (P (find-hyperlink-file-async file))
                  true))

              (let [file (link:match "^file:(.*)$")]
                (when file
                  (P "^file:")
                  (P (find-hyperlink-file-async file))
                  true))

              (let [title (link:match "^%**")]
                (when title
                  (P "title")
                  true)
                ))
            )))
      (async.void)))


{: open-hyperlink-at-cursor-async}
