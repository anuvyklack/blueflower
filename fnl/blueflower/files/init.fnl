(local async (require :blueflower.async))
(local {: class : full-path : notify-error-once} (require :blueflower.util))
(local Buffer (require :blueflower.api-wrappers.buffer))
(local {: eprint} (require :blueflower.debug))
(local File (require :blueflower.files.file))
(local {: read-file-async} (require :blueflower.files.util))
; (local autocmd vim.api.nvim_create_autocmd)
(local autocmd vim.api.nvim_create_autocmd)
(local {: augroup} (require :blueflower.config))
(local P vim.pretty_print)

(local files {})

;; Add new blueflower buffer on open in to FILES list.
(autocmd "FileType"
         {:pattern "blueflower"
          :group augroup
          :desc "Handle blueflower file loading"
          :callback
          (fn [{:file filename :buf bufnr}]
            (local buffer (Buffer:new bufnr))
            (local path (buffer:get-name))
            (when path
              (tset files path (File:new {: path : buffer}))
              (autocmd "BufUnload"
                       {:buffer bufnr
                        :group augroup
                        :once true
                        :desc "Handle blueflower file unloading"
                        :callback
                        (async.void
                          (fn []
                            (let [(content stat) (read-file-async path)]
                              (async.scheduler)
                              (tset files path (File:new {: path : content : stat})))
                            ; Return true to delete autocmd after execution.
                            true))}))
            ; Return false to not delete autocmd after execution.
            false)})


(local load-file-async
  (-> (fn [path ?callback]
        (match (. files path)
          file (file:refresh)
          nil  (let [(content stat) (read-file-async path)]
                 (when (= (vim.filetype.match {:filename path :contents content})
                          "blueflower")
                   (tset files path (File:new {: path : content : stat})))))
        (when ?callback
          (?callback files)))
      (async.create 2 true)
      (async.wrap 2)))


(fn get-current-file []
  (. files (vim.api.nvim_buf_get_name 0)))


{: files
 : get-current-file}

