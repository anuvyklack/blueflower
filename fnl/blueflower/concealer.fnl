(local {: nvim_get_current_buf : nvim_win_get_cursor &as api} vim.api)
(local Buffer   (require "blueflower/api-wrappers/buffer"))
(local {: files : get-current-file} (require :blueflower.files))
(local config (require :blueflower.config))
(local namespace (api.nvim_create_namespace "blueflower-icons"))
(local ticks {})
(local P vim.pretty_print)


(local virt-text
  {:list [ [config.icons.list "Macro"] ]
   :checkbox (collect [_ status (ipairs [:done :cancelled :urgent :uncertain :half])]
               (let [icon (. config.icons.checkbox status)]
                 (if icon
                   (let [text (.. "[" icon "]")]
                     (values status [ [text] ] )))))})


(fn set-icon [buffer virt-text line-num column]
  (buffer:set-extmark namespace line-num column
                      {:virt_text virt-text
                       :virt_text_pos "overlay"
                       :virt_text_hide true
                       :hl_mode "combine"
                       :ephemeral true}))


(fn set-icons [buffer icons-positions]
  (let [[cursor-line] (nvim_win_get_cursor 0)
        cursor-line (- cursor-line 1)]
    (each [_ {: type : text : line-num : start-col : end-col} (ipairs icons-positions)]
      (when (or config.concealcursor (not= cursor-line line-num))
        (match type
          "list_token" (set-icon buffer virt-text.list line-num (- end-col 1))
          "checkbox"   (let [vt (match text
                                  "[x]" virt-text.checkbox.done
                                  "[-]" virt-text.checkbox.pending
                                  "[+]" virt-text.checkbox.half
                                  "[!]" virt-text.checkbox.urgent
                                  "[?]" virt-text.checkbox.uncertain
                                  "[_]" virt-text.checkbox.cancelled)]
                         (when vt
                           (set-icon buffer vt line-num start-col))))))))


(fn set-heading-background-highlight [buffer heading-node]
  (P (heading-node:type))
  (let [[level-node] (heading-node:field "level")
        (_ start _ stop) (level-node:range)
        level (let [lvl (% (- stop start) 6)]
                (if (= lvl 0) 1 lvl))
        hl-group (string.format "@bf.H%s.background" level)
        (start-line _ end-line _) (heading-node:range)]
    (buffer:set-extmark namespace start-line 0
                        {:hl_group hl-group
                         :end_row end-line
                         :end_col 0
                         :hl_eol true
                         :hl_mode "combine"
                         :ephemeral true})))


(local set-headings-highlight
  (if config.highlight_headings_background
      (fn [file]
        (let [buffer file.buffer
              headings (file:get-headings)]
          (each [_ {: node} (ipairs headings)]
            (set-heading-background-highlight buffer node))))
      ;else
      (fn []) ))


(local set-heading-highlight-for-row
  (if config.highlight_headings_background
      (fn [file line-num]
        (let [node (file:get-named-descendant-for-range line-num 0 (+ line-num 1) 0)]
          (match (node:type)
            "heading" (set-heading-background-highlight file.buffer node))))
      ;else
      (fn []) ))


(api.nvim_set_decoration_provider
  namespace
  {:on_start (fn [_ tick]
               (local bufnr (nvim_get_current_buf))
               (if (= (. ticks bufnr) tick)
                 false
                 ;else
                 (do (tset ticks bufnr tick)
                   true)))
   :on_win   (fn [_ _ bufnr topline botline]
               (local buffer (Buffer bufnr))
               (match-try (= (buffer:get-option "filetype") "blueflower")
                          true (. files (buffer:get-name))
                          file (do
                                 (-?>> (file:get-icons-positions topline botline)
                                       (set-icons buffer))
                                 (set-headings-highlight file)
                                 true)
                          (catch
                            _ false)))
   :on_line  (fn [_ _ bufnr row]
               (let [buffer (Buffer bufnr)
                     file   (. files (buffer:get-name))
                     icons-positions (file:get-icons-positions row (+ row 1))]
                 (set-icons buffer icons-positions)
                 (set-heading-highlight-for-row file row)
                 true))})
