(local {: nvim_create_buf} vim.api)
(local Window (require :blueflower.api-wrappers.window))
(local Buffer (require :blueflower.api-wrappers.buffer))
(local {: get-current-file} (require :blueflower.files))
(local {: go-to-node} (require :blueflower.treesitter))
(local P vim.pretty_print)


(macro ++ [n]
  `(do
     (set ,n (+ ,n 1))
     ,n))


(fn show-outline []
  (var n 0)
  (let [lines []
        links []
        window (Window)
        curbuf (Buffer)
        buffer (Buffer (nvim_create_buf false true))
        file (get-current-file)
        headings (file:get-headings)]
    (each [_ {: node} (ipairs headings)]
      (let [text (file:get-node-text node false)]
        (each [_ line (ipairs text)]
          (let [i (++ n)]
            (tset lines i line)
            (tset links i node)))))
    (buffer:set-lines 0 1 lines)
    (buffer:set-name "[Outline]")
    (set buffer.bo.bufhidden "wipe")
    (set buffer.bo.filetype "blueflower")
    (set buffer.bo.modifiable false)
    (vim.keymap.set "n" "<CR>" (fn []
                                 (let [[lnum] (window:get-cursor)
                                       node (. links lnum)]
                                   (window:set-buffer curbuf)
                                   (go-to-node node)
                                   (vim.cmd "normal! zv")))
                    {:buffer buffer.id})
    (vim.keymap.set "n" "<Esc>" #(window:set-buffer curbuf) {:buffer buffer.id})
    (vim.keymap.set "n" "<Tab>" #(window:set-buffer curbuf) {:buffer buffer.id})
    (window:set-buffer buffer)))


{: show-outline}

