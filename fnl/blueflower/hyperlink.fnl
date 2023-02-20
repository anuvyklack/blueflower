(local async (require :blueflower.async))
(local ts (require :blueflower.treesitter))
(local get-node-text vim.treesitter.query.get_node_text)
(local scandir-async (require :blueflower.scandir))
(local {: os-sep &as config} (require :blueflower.config))
(local {: getcwd : fnamemodify} vim.fn)
(local {: open-file : open-in-vim : find-file-async} (require :blueflower.files.util))
(local {: notify-error} (require :blueflower.util))
(import-macros {: look-through} "fnl.blueflower.macros")
; (import-macros {: looking-through} "blueflower.macros")
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


(local get-file-path-async
  (-> (fn get-file-path-async [name callback]
        (if (name:find "^///")
            (callback (name:sub 3))
            ;elseif
            (or (name:find "^/")
                (name:find "^./")
                (name:fine "^~/"))
            (callback (fnamemodify name ":p"))
            ;else
            (let [[file] (scandir-async (getcwd) {:pattern name :first-found? true})]
              (callback file))
            (callback (find-file-async (getcwd) name))
            ))
      (async.create 2 true)
      (async.wrap 2)))


(fn process-link-shortcuts [link]
  (var new-link nil)
  (each [shortcut expand-to (pairs config.link_shortcuts) &until new-link]
    (let [pattern (string.format "^%s:" shortcut)
          (start stop) (link:find pattern)]
      (when start
        (set new-link (.. expand-to (link:sub (+ stop 1)))))))
  (or new-link link))


(local open-hyperlink-at-cursor-async
  (-> (fn open-hyperlink-at-cursor-async []
        "Open hyperlink at cursor."
        ; (local node (get-hyperlink-parent-node))
        (local node (ts.find-parent-node-of-type (ts.get-node-at-cursor)
                                                 [:link :short_link :link_definition]))
        (when node
          (let [lines (icollect [_ line (ipairs (-> (node:field "target") (. 1)
                                                    (ts.get-node-text)))]
                        (vim.trim line))
                link (table.concat lines " ")
                link (process-link-shortcuts link)]
            (look-through
              (let [(fname target) (link:match "^file:(.-)::(.*)$")]
                (when fname
                  (open-in-vim (get-file-path-async fname))
                  true))

              (let [(path fname) (link:match "^file:(.-):find:(.*)$")]
                (when (and path fname)
                  (let [file (find-file-async path fname)]
                    (async.scheduler)
                    (if file
                        (open-file file)
                        (notify-error
                          (string.format "No file found! Path: \"%s\" File: \"%s\""
                                         path fname)))))
                (or path fname))

              (let [fname (link:match "^file:(.*)$")]
                (when fname
                  (let [path (get-file-path-async fname)]
                    (async.scheduler)
                    (open-file (vim.uri_from_fname path)))
                  true))

              (when (link:find "^https?://")
                ; (if vim.g.loaded_netrwPlugin
                ;     (vim.fn.netrw#BrowseX link (vim.fn.netrw#CheckIfRemote))
                ;     ;else
                ;     (xdg-open link))
                (xdg-open link)
                true)

              (let [title (link:match "^%**")]
                (when title
                  true)
                ))
            )))
      (async.void)))


{: open-hyperlink-at-cursor-async}
