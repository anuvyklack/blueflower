(local {: merge-table-deep! : make-set-from-list} (require :blueflower.util))
(var initialized false)
(local Config {})

(local config
  {:os-sep "/"
   :augroup (vim.api.nvim_create_augroup "blueflower" {:clear true})
   :open_in_external_app ["pdf" "png" "jpeg" "jpg" "doc" "docx"]
   :link_abbreviations {}
   :link_definition_behavior "stick" ; "pass"
   :concealcursor true
   :icons {:list "•"
           :checkbox {
                      :done "󰸞"
                      :cancelled ""
                      :urgent ""
                      ; :uncertain ""
                      :half "•"
                      ; :half "󱎫" ; U+f13ab: Material Design Icons
                      ; :half "" ; U+e425: Material Icons
                      ; :half ""
                      ; :half ""
                      }}
   :highlight_headings_background true
   })

(fn Config.setup [self ?input]
  (when (not initialized)
    (merge-table-deep! self (or ?input {}))
    (set self.open-in-external-app
         (make-set-from-list self.open_in_external_app))
    (set initialized true)))

(setmetatable config {:__index Config})
