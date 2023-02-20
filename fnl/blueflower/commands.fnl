; (local command vim.api.nvim_create_user_command)
(local async (require :blueflower.async))
(local config (require :blueflower.config))
(local scandir-async (require :blueflower.scandir))
(local {: files} (require :blueflower.files))
(local P vim.pretty_print)

(macro command [name cmd ?opts]
  (local opts (or ?opts {}))
  `(vim.api.nvim_create_user_command ,name ,cmd ,opts))

(local scandir-wrapper
  (async.void
    (fn []
      (local output (scandir-async "." {:pattern "init"
                                        :depth nil
                                        :add-dirs? false
                                        :first-found? false}))
      (vim.pretty_print output))))

; (command :Scandir scandir-wrapper {})
(command :Scandir scandir-wrapper)

(command :BlueflowerFiles (fn [] (P files)))

; -- Creating a simple setTimeout wrapper
; local function setTimeout(timeout, callback)
;   local timer = uv.new_timer()
;   timer:start(timeout, 0, function ()
;     timer:stop()
;     timer:close()
;     callback()
;   end)
;   return timer
; end

(local uv vim.loop)

(local set-timeout-async
  (-> (fn set-timeout-async [timeout callback]
        (print "set-timeout-async: enter")
        (let [timer (uv.new_timer)]
          (timer:start timeout 0 (fn [] (timer:stop) (timer:close) (callback)))
          timer))
      (async.wrap 2)))


(local bomb
  (-> (fn bomb []
        (print "bomb: enter")
        (set-timeout-async 400)
        (error "bomb"))
      (async.void)
      (async.wrap 0)))


(local bomb-wrapper
  (-> (fn bomb-wrapper []
        (print "bomb-wrapper: enter")
        (bomb))
      (async.void)))


(command "BlueflowerBomb" bomb-wrapper)

; (command "BlueflowerBomb" bomb)

