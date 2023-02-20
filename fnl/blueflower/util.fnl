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
  (vim.notify (.. "[Blueflower] " message) vim.log.levels.ERROR))

(fn notify-warning [message]
  (vim.notify (.. "[Blueflower] " message) vim.log.levels.WARN))

(fn merge-table-deep! [t-into t-from]
  "Merge table T-FROM into table T-INTO.
  This function modify the T-INTO table!"
  (each [key value (pairs t-from)]
    (match (type value)
      :table (tset t-into key (merge-table-deep! (. t-into key) value))
      _      (tset t-into key (. t-from key))))
  t-into)

(fn make-set-from-list [list]
  (let [set_ {}]
    (for [i 1 (length list)]
      (tset set_ (. list i) true))
    set_))

(fn full-path [path]
  (vim.fn.fnamemodify path ":p"))

(fn executable? [name]
  "Is NAME is executable on this system?"
  (< 0 (vim.fn.executable name)))

(fn has? [feature]
  (= 1 (vim.fn.has feature)))

{: class
 : merge-table-deep!
 : make-set-from-list
 : notify-warning
 : notify-error
 : notify-error-once
 : full-path
 : executable?
 : has?}

; vim: fml=1
