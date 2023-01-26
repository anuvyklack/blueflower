(local uv (vim.loop))
(local {: eprint} (require :blueflower.debug))

(fn close-pipes [...]
  "Accepts a number of uv PIPEs and close them if not yet."
  (for [i (select :# ...)]
    (let [pipe (select i ...)]
      (when (and pipe (not (pipe:is_closing)))
        (pipe:close)))))


(fn write-to-pipe [pipe data]
  "Write DATA into PIPE.

  Parameters:
      - PIPE : uv.pipe
      - DATA : string | string[]
  "
  (match (type data)
    :table  (each [_ str (ipairs data)]
              (do (pipe:write str)
                  (pipe:write "\n")))
    :string (pipe:write data)))


(fn read-from-pipe [pipe output]
  "Read string from PIPE and append it to OUTPUT.

  Parameters:
      - PIPE : uv.pipe
      - OUTPUT : string[]
  "
  (pipe:read_start (fn [err data]
                     (when err (eprint err))
                     (when data
                       (let [data (data:gsub "\r" "")]
                         (table.insert output data))))))


(fn run-job [{: cmd : args : cwd : input &as spec} callback]
  "Start the process.

  Parameters:
    - SPEC : table
      - CMD : string
            command (path to the executable)
      - ARGS : string[]
            command line arguments
      - CWD : string
            current working directory to run subprocess in
    - CALLBACK : function
      - CODE : integer
      - SIGNAL : integer
      - ?STDOUT-DATA : string[]?
      - ?STDERR-DATA : string[]?
  "
  (let [stdout-data []
        stderr-data []
        stdin  (when input (uv.new_pipe))
        stdout (uv.new_pipe)
        stderr (uv.new_pipe)
        (handle pid) (uv.spawn cmd
                               {: args
                                :stdio [stdin stdout stderr]
                                : cwd}
                               (fn [code signal]
                                 (handle:close)
                                 (stdout:read_stop)
                                 (stderr:read_stop)
                                 (close-pipes stdin stdout stderr)
                                 (callback code
                                           signal
                                           (if (< 0 (length stdout-data)) stdout-data)
                                           (if (< 0 (length stderr-data)) stderr-data))))]
    (when (not handle)
      (close-pipes stdin stdout stderr)
      (error (debug.traceback (.. "Failed to spawn process: "
                                  (vim.inspect spec)))))
    (read-from-pipe stdout stderr-data)
    (read-from-pipe stderr stderr-data)
    (write-to-pipe  stdin  input)))


{: run-job}
