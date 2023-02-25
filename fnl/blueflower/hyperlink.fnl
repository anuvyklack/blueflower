(local {: nvim_buf_get_name : nvim_win_set_cursor} vim.api)
(local async (require :blueflower.async))
(local {: go-to-node &as ts} (require :blueflower.treesitter))
(local scandir-async (require :blueflower.files.scandir))
(local {: os-sep &as config} (require :blueflower.config))
(local {: getcwd : fnamemodify} vim.fn)
(local {: open-file : xdg-open
        : find-and-open-file-async} (require :blueflower.files.util))
(local {: notify-error} (require :blueflower.util))
(local {: get-current-file} (require :blueflower.files))
(import-macros {: look-through} "fnl.blueflower.macros")
; (import-macros {: looking-through} "blueflower.macros")
(var open-link-async nil)
(local P vim.pretty_print)

;; TODO: When open file on direct path, check if file exists, and rise an error if not.

(fn process-link-shortcuts [link]
  (var new-link nil)
  (each [shortcut expand-to (pairs config.link_abbreviations) &until new-link]
    (let [pattern (string.format "^%s:" shortcut)
          (start stop) (link:find pattern)]
      (when start
        (set new-link (.. expand-to (link:sub (+ stop 1)))))))
  (or new-link link))


(local hyperlink-open-file-async
  (-> (fn hyperlink-open-file-async [file callback]
        (local file (file:gsub "^///" "/"))
        (if (or (file:find "^/")
                (file:find "^%./")
                (file:find "^~/"))
            (let [file (fnamemodify file ":p")]
              (open-file file)
              (callback true))
            ;else
            (callback (find-and-open-file-async (getcwd) file))))
      (async.create 2 true)
      (async.wrap 2 true)))


(fn jump-to-heading [heading]
  (let [(_ level) (heading:find "^%*+")
        title (-> (heading:sub (+ level 1))
                  (string.gsub "\r?\n"  " ")
                  (string.gsub "%s+"  " ")
                  (vim.trim))
        file (get-current-file)
        headings (file:get-headings true)]
    (var found-title nil)
    (each [_ h (ipairs (. headings level)) &until found-title]
      (when (= title h.title)
        (set found-title h)))
    (when (not found-title)
      (let [headings (do (table.remove headings level)
                         (vim.tbl_flatten headings))]
        (each [h (ipairs headings) &until found-title]
          (when (= title h.title)
            (set found-title h)))))
    (if (not found-title)
        (notify-error (.. "No section with title: " title))
        ; (let [(row col) (found-title.node:start)]
        ;   (nvim_win_set_cursor 0 [(+ row 1) col]))
        (go-to-node found-title.node)
        )))


(fn jump-to-link-definition [target]
  (let [file (get-current-file)
        link-defs (file:get-link-definitions)
        link-definition (. link-defs target)]
    (if link-definition
        (let [{: link : line-num} link-definition]
          (match config.link_definition_behavior
            "pass"  (open-link-async link)
            "stick" (nvim_win_set_cursor 0 [line-num 0]))
          true)
        false)))


(fn jump-to-id [target]
  (let [file (get-current-file)
        ids (file:get-ids)
        id-node (. ids target)]
    (if (not id-node)
        (notify-error (.. "No such id: " target))
        (let [parent (id-node:parent)
              target-node (match (parent:type)
                            "section"    parent
                            "list"       (. (parent:field "list_item") 1)
                            "definition" (. (parent:field "term") 1)
                            "tag"        (. (parent:field "content") 1))
              (row col) (target-node:start)]
          ; (nvim_win_set_cursor 0 [(+ row 1) col])
          (go-to-node target-node)
          ))))


(fn jump-to-target [target]
  (look-through
    (when (target:find "^%*+")
      (jump-to-heading target)
      true)

    (jump-to-link-definition target)

    (jump-to-id target)))


(set open-link-async
  (-> (fn [link]
        (local link (process-link-shortcuts link))
        (look-through
          (when (link:find "^https?://")
            ; (if vim.g.loaded_netrwPlugin
            ;     (vim.fn.netrw#BrowseX link (vim.fn.netrw#CheckIfRemote))
            ;     ;else
            ;     (xdg-open link))
            (xdg-open link)
            true)

          (let [(path fname target) (link:match "^file:(.-):find:(.-)::(.*)$")]
            (when (and path fname target)
              (match-try (find-and-open-file-async path fname)
                    true (jump-to-target target))
              true))

          (let [(path fname) (link:match "^file:(.-):find:(.*)$")]
            (when (and path fname)
              (find-and-open-file-async path fname)
              true))

          (let [(fname target) (link:match "^file:(.-)::(.*)$")]
            (when (and fname target)
              (match-try (hyperlink-open-file-async fname)
                    true (jump-to-target target))
              true))

          (let [fname (link:match "^file:(.*)$")]
            (when fname
              (hyperlink-open-file-async fname)
              true))

          (jump-to-target link)))
      (async.void true)))

(fn open-hyperlink-at-cursor []
  (local node (ts.find-parent-node-of-type (ts.get-node-at-cursor)
                                           [:link :short_link :link_definition]))
  (when node
    (let [lines (icollect [_ line (ipairs (-> (node:field "target") (. 1)
                                              (ts.get-node-text)))]
                  (vim.trim line))
          link (table.concat lines " ")]
      (open-link-async link))))


{: open-hyperlink-at-cursor}
