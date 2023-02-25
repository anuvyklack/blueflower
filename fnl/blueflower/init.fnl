;; Set keybindings -- lua/orgmode/config/init.lua :: 282
;; Hyperlinks      -- lua/neorg/modules/core/norg/esupports/hop/module.lua

(local M {})

(fn M.setup [user-opts]
  (let [config (require :blueflower.config)]
    (config:setup user-opts))
  (vim.filetype.add {:extension {:note "blueflower"
                                 :bf   "blueflower"}})
  (require :blueflower.highlight)
  (require :blueflower.autocmd)
  (require :blueflower.keymaps)
  (require :blueflower.commands)
  (require :blueflower.concealer)
)


; (fn M.setup_ts_parser []
;   (let [{: get_parser_configs : filetype_to_parsername} (require :nvim-treesitter.parsers)
;         parser-config (get_parser_configs)
;         ts-parsers    (require :nvim-treesitter.parsers)
;         parser-config (ts-parsers.get_parser_configs)
;         ft-to-parser  ts-parsers.filetype_to_parsername]
;     (set parser-config.blueflower
;          {:install_info {:url    "https://github.com/anuvyklack/tree-sitter-blueflower"
;                          :files  ["src/parser.c" "src/scanner.cc"]
;                          :branch :main}
;           :filetype "blueflower"})
;     (set ft-to-parser.blueflower "blueflower")))


(fn M.setup_ts_parser []
  (let [{: get_parser_configs
         : filetype_to_parsername} (require :nvim-treesitter.parsers)
        parser-config (get_parser_configs)]
    (set parser-config.blueflower
         {:install_info {:url    "https://github.com/anuvyklack/tree-sitter-blueflower"
                         :files  ["src/parser.c" "src/scanner.cc"]
                         :branch :main}
          :filetype "blueflower"})
    (set filetype_to_parsername.blueflower "blueflower")))

M
