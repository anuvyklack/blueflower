(local ts (require :blueflower.treesitter))
(local {: open-hyperlink-at-cursor} (require :blueflower.hyperlink))
(local {: show-outline} (require :blueflower.outline))
(local {: augroup} (require :blueflower.config))
(local autocmd vim.api.nvim_create_autocmd)
(local keymap vim.keymap)
(local P vim.pretty_print)

(fn set-keymaps [{:buf bufnr}]
  (keymap.set :n :<CR> open-hyperlink-at-cursor {:buffer bufnr})
  (keymap.set :n :<Tab> show-outline {:buffer bufnr}))

(autocmd :FileType {:pattern "blueflower"
                    :desc "Set blueflower keymaps"
                    :callback set-keymaps})


