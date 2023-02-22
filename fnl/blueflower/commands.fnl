; (local command vim.api.nvim_create_user_command)
(local async (require :blueflower.async))
(local config (require :blueflower.config))
(local scandir-async (require :blueflower.files.scandir))
(local {: get-current-file} (require :blueflower.files))
(local P vim.pretty_print)

(macro command [name cmd ?opts]
  (local opts (or ?opts {}))
  `(vim.api.nvim_create_user_command ,name ,cmd ,opts))

(local scandir-wrapper
  (async.void
    (fn []
      (local output (scandir-async "." {:pattern "init"
                                        :depth nil
                                        :add-dirs? false
                                        :first-found? false}))
      (vim.pretty_print output))))

; (command :Scandir scandir-wrapper {})
(command :Scandir scandir-wrapper)

(command :BlueflowerFiles
         (fn []
           ; (P files)
           (let [file (get-current-file)]
             (file:get-headings))))

; (command :BlueflowerFiles
;          (fn []
;            ; (P files)
;            (let [{: buffer : tstree &as file} (. files (vim.api.nvim_buf_get_name 0))
;                  root (tstree:root)
;                  query "(directive
;                           (name) @name
;                           (#eq? @name \"label\")
;                           (content) @content) @label"
;                  ts-query (file:ts-query query)]
;              (P ts-query.captures)
;              (each [id node metadata (ts-query:iter_matches root buffer.id)]
;                (P id node metadata))
;              )
;            ))
