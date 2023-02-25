(local {: nvim_get_current_buf : nvim_win_get_cursor &as api} vim.api)
(local Buffer   (require "blueflower/api-wrappers/buffer"))
(local {: files : get-current-file} (require :blueflower.files))
(local config (require :blueflower.config))
(local namespace (api.nvim_create_namespace "blueflower-icons"))
(local ticks {})


(fn set-icon [buffer virt-text line-num start-col end-col]
  (buffer:set-extmark namespace line-num start-col
                      {:virt_text virt-text
                       ; :end_col end-col
                       :virt_text_pos "overlay"
                       :hl_mode "combine"
                       :ephemeral true}))


(local virt-text
  {:list [ [config.icons.list "Macro"] ]
   :checkbox (collect [_ status (ipairs [:done :cancelled :urgent :uncertain :half])]
               (let [icon (. config.icons.checkbox status)]
                 (if icon
                   (let [text (.. "[" icon "]")]
                     (values status [ [text] ] )))))})


(fn set-icons [buffer icons-positions]
  (let [[cursor-line] (nvim_win_get_cursor 0)
        cursor-line (- cursor-line 1)]
    (each [_ {: type : text : line-num : start-col : end-col} (ipairs icons-positions)]
      (when (or config.concealcursor (not= cursor-line line-num))
        (match type
          "list_token" (set-icon  buffer  virt-text.list  line-num  (- end-col 1)  end-col)
          "checkbox"   (let [vt (match text
                                  "[x]" virt-text.checkbox.done
                                  "[-]" virt-text.checkbox.pending
                                  "[+]" virt-text.checkbox.half
                                  "[!]" virt-text.checkbox.urgent
                                  "[?]" virt-text.checkbox.uncertain
                                  "[_]" virt-text.checkbox.cancelled)]
                         (when vt
                           (set-icon  buffer  vt  line-num  start-col  end-col))))))))


(api.nvim_set_decoration_provider
  namespace
  {:on_start (fn [_ tick]
               (local bufnr (nvim_get_current_buf))
               (if (= (. ticks bufnr) tick)
                   false
                   ;else
                   (do
                     (tset ticks bufnr tick)
                     true)))
   :on_win   (fn [_ _ bufnr topline botline]
               (local buffer (Buffer bufnr))
               (match-try (= (buffer:get-option "filetype") "blueflower")
                 true  (. files (buffer:get-name))
                 file  (file:get-icons-positions topline botline)
                 icons-positions (do
                                   (set-icons buffer icons-positions)
                                   true)
                 (catch
                   _ false)))
   :on_line  (fn [_ _ bufnr row]
               (let [buffer (Buffer bufnr)
                     file   (. files (buffer:get-name))
                     icons-positions (file:get-icons-positions row (+ row 1))]
                 (set-icons buffer icons-positions)
                 true))})
