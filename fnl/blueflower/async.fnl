;;; This is basically rewritten in fennel https://github.com/lewis6991/async.nvim plugin.

(local lua-unpack unpack)
(macro unpack [lst ?i ?j]
  (let [i (or ?i 1)
        j (or ?j `(table.maxn ,lst))]
    `(lua-unpack ,lst ,i ,j)))

;; Store all the async threads in a weak table so we don't prevent them from
;; being garbage collected
(local handles (setmetatable {} {:__mode "k"}))
; (local handles-stack (setmetatable [] {:__mode "k"}))

(fn running? []
  "Returns whether the current execution context is async."
  ;; Note: coroutine.running() was changed between Lua 5.1 and 5.2:
  ;; - 5.1: Returns the running coroutine, or nil when called by the main thread.
  ;; - 5.2: Returns the running coroutine plus a boolean, true when the running
  ;;   coroutine is the main one.
  ;;
  ;; For LuaJIT, 5.2 behaviour is enabled with LUAJIT_ENABLE_LUA52COMPAT
  ;;
  ;; We need to handle both.
  (let [thread (coroutine.running)]
    (if (and thread (. handles thread))
        true
        false)))

(local Async_T {})


(fn Async_T.new [thread]
  (let [handle (setmetatable {} {:__index Async_T})]
    (tset handles thread handle)
    handle))


(fn Async_T.cancel [{: _current} thread]
  "Analogous to uv.close. Cancel anything running on the event loop."
  (when (and _current (not (_current:is_cancelled)))
    (_current:cancel thread)))


(fn Async_T.is_cancelled [{: _current}]
  "Analogous to uv.is_closing."
  (if _current (_current:is_cancelled)))


(fn Async_T? [handle]
  (if (and handle
           (= (type handle) :table)
           (vim.is_callable handle.cancel)
           (vim.is_callable handle.is_cancelled))
    true))


(fn run [func callback ...]
  "Run a FUNC in an async context.

  Parameters:
    - FUNC : function
    - CALLBACK : function
    - ... : any
          Arguments for FUNC
  "
  (vim.validate {:func [func :function]
                 :callback [callback :function true]})
  (local thread (coroutine.create func))
  (local handle (Async_T.new thread))

  (fn step [...]
    (let [[ok nargs fun &as ret] [(coroutine.resume thread ...)]
          args [(select 4 (unpack ret))]]
      (when (not ok)
        (print (string.format "The coroutine failed with this message:\n%s\n%s"
                              (. ret 2) ; error message
                              (debug.traceback thread)))
        (error (string.format "The coroutine failed with this message:\n%s\n%s"
                              (. ret 2) ; error message
                              (debug.traceback thread))
               0)
        )
      (match (coroutine.status thread)
        :dead (when callback
                (callback (unpack ret 4)))
        _ (do
            (assert (= (type fun) :function) "type error :: expected func")
            (tset args nargs step)
            (let [r (fun (unpack args))]
              (when (Async_T? r)
                (set handle._current r)))))))

  (step ...)
  handle)


(fn _wait [argc func ...]
  (vim.validate {:argc [argc :number]
                 :func [func :function]})

  ;; Always run the wrapped functions in xpcall and re-raise
  ;; the error in the coroutine. This makes pcall work as normal.
  (fn pfunc [...]
    (let [args [...]
          callback (. args argc)]
      (tset args argc (fn [...]
                        (callback true ...)))
      (xpcall func
              (fn [err]
                (callback false err (debug.traceback)))
              (unpack args 1 argc))))

  (let [ [ok &as ret] [(coroutine.yield argc pfunc ...)] ]
    (when (not ok)
      (let [[_ err traceback] ret]
        (print (string.format "wait: Wrapped function failed: %s\n%s" err traceback))
        (error (string.format "Wrapped function failed: %s\n%s" err traceback))
        ))
    (unpack ret 2)
    ))


(fn wait [...]
  "Wait on a callback style function.

  Parameters:
    - ARGC : integer?
          The number of arguments of FUNC.
    - FUNC : function
          Callback style function to execute.
    - ... : any
          Arguments for FUNC.
  "
  (match (type ...) ; the type of the first argument
    :number (_wait ...)
    ;; Else, assume argc is equal to the number of passed arguments
    ;; (- 1 for function itself that is first argument,
    ;;  + 1 for callback that hasn't been passed).
    _  (_wait (select "#" ...) ...)))


(fn create [func ?argc ?strict]
  "Use this to create a function which executes in an async context but
  called from a non-async context. Inherently this cannot return anything
  since it is non-blocking.

  Parameters:
    - FUNC : function
    - ARGC : integer?
          The number of arguments of func. Defaults to 0.
    - STRICT : boolean?
          Error when called in non-async context.

  Return:
      function(...):async_t
  "
  (vim.validate {:func [func :function] :argc [?argc :number true]})
  (local argc (or ?argc 0))
  (fn [...]
    (if (running?)
        (do (when ?strict (error "This function must run in a non-async context"))
            (func ...))
        (let [callback (select (+ argc 1) ...)]
          (run func callback (unpack [...] 1 argc))))))


(fn void [func ?strict]
  "Create a function which executes in an async context but
  called from a non-async context.

  Parameters:
    - FUNC : function
    - STRICT : boolean
          Error when called in non-async context.
  "
  (vim.validate {:func [func :function]})
  (fn [...]
    (if (running?)
        (do (when ?strict (error "This function must run in a non-async context"))
            (func ...))
        ;; else
        (run func nil ...))))


(fn wrap [func argc ?strict]
  "Creates an async function from a callback style function.

  Parameters:
    - FUNC : function
          A callback style function to be converted.
          The last argument must be the callback.
    - ARGC : integer
          The number of arguments of func. Must be included.
    - STRICT : boolean
          Error when called in non-async context.
  "
  (vim.validate {:argc [argc :number]})
  (fn [...]
    (if (running?)
        (wait argc func ...)
        ; else
        (do (when ?strict (error "This function must run in an async context"))
            (func ...)))))


(fn join [thunks n ?interrupt-check]
  "Run a collection of async functions (THUNKS) concurrently and return when
  all have finished.

  Parameters:
    - THUNKS : function[]
    - N : integer
          Max number of thunks to run concurrently
    - INTERRUPT-CHECK : function?
          Function to abort thunks between calls
  "
  (fn run [finish]
    (if (= 0 (length thunks))
        (finish)
        (let [remaining [(select (+ n 1) (unpack thunks))]
              to-go (length thunks)
              ret []
              callback (fn [...]
                         (table.insert ret [...])
                         (let [to-go (- to-go 1)]
                           (if (= to-go 0)
                             (finish ret)
                             ;; elseif
                             (and (or (not ?interrupt-check)
                                      (?interrupt-check))
                                  (< 0 (length remaining)))
                             (let [next-task (table.remove remaining)]
                               (next-task callback)))))]
          (for [i 1 (math.min n (length thunks))]
            (let [thunk (. thunks i)]
              (thunk callback))))))
  (if (not (running?)) run
      ; else
      (wait 1 false run)))


(fn curry [fun ...]
  "Partially applying arguments to an async FUNCTION.

  Parameters:
    - FUN : function
    - ... : any
          Arguments to apply to FUN.
  "
  (local args [...])
  (local nargs (select "#" ...))
  (fn [...]
    (local other [...])
    (for [i 1 (select "#" ...)]
      (tset args (+ nargs i) (. other i)))
    (fun (unpack args))))


{:running? running?
 : run
 : wait
 : create
 : void
 : wrap
 : join
 : curry
 :scheduler (wrap vim.schedule 1 false)}
