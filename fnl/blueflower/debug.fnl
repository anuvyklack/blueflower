(var debug-mode true)
(local messages [])

(fn eprint [msg]
  (print "eprint:enter")
  (let [level 1
        info (debug.getinfo (+ level 2) "Sl")]
    (when info
      (let [msg (string.format "(ERROR) %s:%d\n%s"
                               info.short_src  info.currentline  msg)]
        (table.insert messages msg)
        (when debug-mode
          (print "eprint: call error msg")
          (error msg))))))

{: debug-mode
 : messages
 : eprint}
