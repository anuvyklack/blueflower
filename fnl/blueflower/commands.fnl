(local command vim.api.nvim_create_user_command)
(local a (require :blueflower.async))
(local scandir (require :blueflower.scandir))

(local scandir-wrapper
  (fn []
    (a.run
      (fn []
        (local output (scandir "." {:pattern "scandir"
                                    :depth nil
                                    :add-dirs? false
                                    :first-found? false}))
        (vim.pretty_print output)))))



(command :Scandir scandir-wrapper {})


