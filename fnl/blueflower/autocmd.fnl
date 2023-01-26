(local {: files : load-file-async} (require :blueflower.files))
(local {: full-path} (require :blueflower.util))
(local autocmd vim.api.nvim_create_autocmd)
(local group (vim.api.nvim_create_augroup "blueflower" {:clear true}))
(local P vim.pretty_print)

(autocmd "FileType"
         {:pattern "blueflower"
          : group
          :callback (fn [{: file :buf bufnr}]
                      ; (P (full-path file))
                      ; (P (vim.fn.bufnr (full-path file)))
                      (load-file-async (full-path file)
                                       (fn []
                                         (P files)))
                      ; Return false to not delete autocmd after execution.
                      false)})
