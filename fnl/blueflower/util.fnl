(fn class [parent]
  (let [mt    {:__index parent}
        class (setmetatable {} mt)]
    (set class.__index class)
    (fn class.new [_ ...]
      (let [obj (setmetatable {} class)]
        (when (= (type class.initialize) "function")
          (obj:initialize ...))
        obj))
    (set mt.__call class.new)
    class))

(fn notify-error-once [message]
  (vim.notify_once message vim.log.levels.ERROR {:title "Blueflower:"}))

(fn notify-error [message]
  (vim.notify message vim.log.levels.ERROR {:title "Blueflower:"}))

(fn full-path [path]
  (vim.fn.fnamemodify path ":p"))

{: class
 : notify-error
 : notify-error-once
 : full-path}

; vim: fml=1
