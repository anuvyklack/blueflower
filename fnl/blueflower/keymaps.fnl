(local augroup "blueflower")
(local autocmd vim.api.nvim_create_autocmd)
(local keymap vim.keymap)
(local ts (require "blueflower/treesitter"))
(local {: open-hyperlink-at-cursor} (require "blueflower/hyperlink"))
(local P vim.pretty_print)

(fn set-keymaps []
  (keymap.set :n :<CR> open-hyperlink-at-cursor)
  )

; (fn set-keymaps []
;   (keymap.set :n :<CR>
;               (fn []
;                 ; (P (ts.get-node-text (ts.current-node)))
;                 ; (P (get-hyperlink-parent-node))
;                 (open-hyperlink)
;                 )))

(autocmd :FileType {:pattern "blueflower"
                    :desc "Set blueflower keymaps"
                    :callback set-keymaps})


