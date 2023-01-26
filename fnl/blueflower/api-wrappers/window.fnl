(local api vim.api)
(local Buffer (require "blueflower/api-wrappers/buffer"))
(local Window (let [class (. (require "blueflower.util") :class)]
                (class)))

(fn Window.initialize [self ?winid]
  (set self.id (if (or (not ?winid) (= ?winid 0))
                   (api.nvim_get_current_win)
                   ?winid))
  (set self.wo
       (setmetatable {}
         {:__index    (fn [_ opt]
                        (api.nvim_win_get_option self.id opt))
          :__newindex (fn [_ opt value]
                        (api.nvim_win_set_option self.id opt value))})))

(fn Window.__eq [l r]
  (= l.id r.id))

(fn Window.close [{: id} ?force]
  (api.nvim_win_close id (or ?force false)))

(fn Window.get-buffer [{: id}]
  (Buffer:new (api.nvim_win_get_buf id)))

(fn Window.valide? [{: id}]
  (api.nvim_win_is_valid id))

(fn Window.get-type [{: id}]
  "Return:
     - WIN-TYPE : 'autocmd' | 'command' | 'loclist' | 'popup' |
                  'preview' | 'quickfix' | 'unknown'"
  (vim.fn.win_gettype id))

(fn Window.floating? [self]
  (= (self:get-type) "popup"))

(fn Window.set-buffer [self buffer]
  "Parameters:
    - BUFFER : number | Buffer
  "
  (api.nvim_win_set_buf self.id (match (type buffer)
                                  :table buffer.id
                                  _      buffer)))

(fn Window.get-option [{: id} name]
  (api.nvim_win_get_option id name))

(fn Window.set-option [{: id} name value]
  (api.nvim_win_set_option id name value))

(fn Window.get-text-offset [{: id}]
  "The width of offset of the window, occupied by line number column,
  fold column and sign column."
  (. (vim.fn.getwininfo id) 1 :textoff))

(fn Window.get-width [{: id}]
  (api.nvim_win_get_width id))

(fn Window.get-height [{: id}]
  (api.nvim_win_get_height id))

(fn Window.set-width [{: id} width]
  (api.nvim_win_set_width id width))

(fn Window.set-height [{: id} height]
  (api.nvim_win_set_height id height))

(fn Window.get-cursor [{: id}]
  (api.nvim_win_get_cursor id))

(fn Window.set-cursor [{: id} pos]
  (api.nvim_win_set_cursor id pos))

(fn Window.set-highglight-namespace [self ns-id]
  "Set highlight namespace for a window."
  (api.nvim_win_set_hl_ns self.id ns-id))

Window

; vim: fml=1
