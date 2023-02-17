(local async (require :blueflower.async))
(local {: class : full-path : notify-error-once} (require :blueflower.util))
(local Buffer (require :blueflower.api-wrappers.buffer))
(local {: eprint} (require :blueflower.debug))
(local File (require :blueflower.files.file))
(local {: read-file-async} (require :blueflower.files.util))
(local autocmd vim.api.nvim_create_autocmd)
(local group (vim.api.nvim_create_augroup "blueflower" {:clear true}))
(local P vim.pretty_print)

(local files {})

;; Add new blueflower buffer on open in to FILES list.
(autocmd "FileType"
         {:pattern "blueflower"
          : group
          :desc "Handle blueflower file loading"
          :callback
          (fn [{:buf bufnr}]
            (let [buffer (Buffer:new bufnr)
                  path (buffer:get-name)
                  file (File:new {: path : buffer})]
              (tset files path file)
              (autocmd "BufUnload"
                       {:buffer bufnr
                        : group
                        :once true
                        :desc "Handle blueflower file unloading"
                        :callback
                        (fn []
                          (read-file-async path
                            (vim.schedule_wrap ; callback
                              (fn [content stat]
                                (tset files path (File:new {: path : content : stat})))))
                          ; Return true to delete autocmd after execution.
                          true)}))
            ; Return false to not delete autocmd after execution.
            false)})


(local load-file-async
  (-> (fn [path ?callback]
        (match (. files path)
          file (file:refresh)
          nil  (let [(content stat) (read-file-async path)]
                 (when (= "blueflower"
                          (vim.filetype.match {:filename path :contents content}))
                   (tset files path (File:new {: path : content : stat})))))
        (when ?callback
          (?callback)))
      (async.create 2 true)
      (async.wrap 2)))


{: files
 : load-file-async}

