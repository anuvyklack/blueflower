(local ts (require :blueflower.treesitter))
(local {: open-hyperlink-at-cursor-async} (require :blueflower.hyperlink))
(local {: augroup} (require :blueflower.config))
(local autocmd vim.api.nvim_create_autocmd)
(local keymap vim.keymap)
(local P vim.pretty_print)

(fn set-keymaps [{: buf}]
  (keymap.set :n :<CR> open-hyperlink-at-cursor-async {:buffer buf}))

(autocmd :FileType {:pattern "blueflower"
                    :desc "Set blueflower keymaps"
                    :callback set-keymaps})


