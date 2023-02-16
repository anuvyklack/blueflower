; (local command vim.api.nvim_create_user_command)
(local a (require :blueflower.async))
(local scandir-async (require :blueflower.scandir))
(local {: files} (require :blueflower.files))
(local P vim.pretty_print)

(macro command [name cmd ?opts]
  (local opts (or ?opts {}))
  `(vim.api.nvim_create_user_command ,name ,cmd ,opts))

(local scandir-wrapper
  (a.void
    (fn []
      (local output (scandir-async "." {:pattern "scandir"
                                        :depth nil
                                        :add-dirs? false
                                        :first-found? false}))
      (vim.pretty_print output))))

; (command :Scandir scandir-wrapper {})
(command :Scandir scandir-wrapper)

(command :BlueflowerFiles (fn [] (P files)))


