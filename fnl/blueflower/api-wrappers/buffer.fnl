(local api vim.api)
(local {: class} (require :blueflower.util))
(local Buffer (class))

(fn Buffer.initialize [self input]
  "If INPUT is a number, then it is treated as bufnumber.
  If INPUT is string, then it's treated as filename.
  If no INPUT is passed, then current buffer bufnr is used."
  (match (type input)
    :number (set self.id input)
    :string (set self.id (vim.fn.bufnr input))
    :nil    (set self.id (api.nvim_get_current_buf)))
  ; (set self._changedtick (self.get-var "changedtick"))
  (set self.bo (setmetatable {}
                 {:__index    (fn [_ opt]
                                (api.nvim_buf_get_option self.id opt))
                  :__newindex (fn [_ opt value]
                                (api.nvim_buf_set_option self.id opt value))})))

(fn Buffer.__eq [_ l r]
  (= l.id r.id))

(fn Buffer.get-name [self]
  "Gets the full file name of the buffer."
  (api.nvim_buf_get_name self.id))

(fn Buffer.delete [self {: force : unload}]
  (api.nvim_buf_delete self.id {:force  (or force false)
                                :unload (or unload false)}))

(fn Buffer.loaded? [self]
   (api.nvim_buf_is_loaded self.id))

(fn Buffer.get-var [self name]
  (vim.api.nvim_buf_get_var self.id name))

(fn Buffer.set-var [self name value]
  (vim.api.nvim_buf_set_var self.id name value))

(fn Buffer.get-option [self name]
  (api.nvim_buf_get_option self.id name))

(fn Buffer.set-option [self name value]
   (api.nvim_buf_set_option self.id name value))

(fn Buffer.line-count [self]
   (api.nvim_buf_line_count self.id))

(fn Buffer.get-text [self  start-row  start-col  end-row  end-col]
  (api.nvim_buf_get_text self.id
                         start-row start-col
                         end-row   end-col
                         {}))

(fn Buffer.get-lines [self start end ?strict-indexing]
  (api.nvim_buf_get_lines self.id start end (or ?strict-indexing false)))

(fn Buffer.set-lines [{: id} start end lines ?strict-indexing]
  "Parameters:
      - START : integer
            First line index
      - END : integer
            Last line index, exclusive.
      - LINES : string[]
            Array of lines to set.
      - STRICT-INDEXING : boolean?
            Whether out-of-bounds should be an error.
  "
  (api.nvim_buf_set_lines id
                          start
                          end
                          (or ?strict-indexing false)
                          lines))

(fn Buffer.add-higlight [self ns-id hl-group line col-start col-end]
  "Parameters:
      - NS_ID : integer
            Namespace to use or -1 for ungrouped highlight.
      - HL_GROUP : string
            Name of the highlight group to use.
      - LINE : integer
            Line to highlight (zero-indexed).
      - COL_START : integer
            Start of (byte-indexed) column range to highlight.
      - COL_END : integer
            End of (byte-indexed) column range to highlight, or -1 to highlight
            to end of line.
  "
  (api.nvim_buf_add_highlight self.id
                              ns-id
                              hl-group
                              line
                              col-start
                              col-end))

Buffer

; vim: fml=1
