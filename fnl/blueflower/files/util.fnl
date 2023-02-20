(local uv vim.loop)
(local async (require :blueflower.async))
(local job (require :blueflower.job))
(local scandir-async (require :blueflower.scandir))
(local config (require :blueflower.config))
(local {: executable? : has? : notify-error} (require :blueflower.util))
(local await {:fs_open  (async.wrap uv.fs_open 4)
              :fs_fstat (async.wrap uv.fs_fstat 2)
              :fs_read  (async.wrap uv.fs_read 4)
              :fs_close (async.wrap uv.fs_close 2)
              :job      (async.wrap (require :blueflower.job) 1)})


(fn read-file [path]
  "Read the content of the file.

  Return:
    - CONTENT : string
          Content of the file.
    - STAT : table
          See: uv.fs_stat()
      - MTIME : integer
            Modifiation time in seconds.
  "
  (match-try (uv.fs_open path "r" 292) ; 292 is 444 in octal
    fd    (uv.fs_fstat fd)
    stat  (uv.fs_read fd stat.size)
    data  (uv.fs_close fd)
    true  (values data {:mtime stat.mtime.sec})
    (catch
      (nil err) (error err))))


(local read-file-async
  (-> (fn [path callback]
        "Read the content of the file asynchronously.

        Parameters:
          - PATH : string
                Path to the file.
          - CALLBACK : function
            - CONTENT : string
                  Content of the file.
            - STAT : table
                  See: uv.fs_stat()
        "
        (match-try   (await.fs_open path "r" 292) ; 292 is 444 in octal
          (nil fd)   (await.fs_fstat fd)
          (nil stat) (await.fs_read fd  stat.size  0)
          (nil data) (await.fs_close fd)
          (nil true) (callback data {:mtime stat.mtime.sec})
          (catch
            err (error err))))
      (async.create 2 true)
      (async.wrap 2)))


(local find-file-async
  (-> (fn find-file-async [path name callback]
        "Find file with NAME at PATH."
        (let [path (vim.fn.fnamemodify path ":p")
              [file &as files] (scandir-async path {:pattern name :first-found? true})]
          (callback file)))
      (async.create 3 true)
      (async.wrap 3)))


; (fn xdg-open [target]
;   (print "xdg-open: enter")
;   (let [{: system} vim.fn
;         format  string.format]
;     (if (executable? "xdg-open")
;         (system (format "xdg-open \"%s\"" target))
;
;         (executable? "open")
;         (system (format "open \"%s\"" target))
;
;         (has? "win32")
;         (system (format "start \"%s\"" target)))))


(fn xdg-open [target]
  (if (executable? "xdg-open")
      (job {:cmd "xdg-open" :args [target]})

      (executable? "open")
      (job {:cmd "open" :args [target]})

      (has? "win32")
      (job {:cmd "start" :args [(.. "\"" target "\"")]})))


; (fn xdg-open [target]
;   (var spec nil)
;   (if (executable? "xdg-open")
;       (set spec {:cmd "xdg-open" :args [target]})
;
;       (executable? "open")
;       (set spec {:cmd "open" :args [target]})
;
;       (has? "win32")
;       (set spec {:cmd "rundll32.exe"
;                  :args ["url.dll,FileProtocolHandler" target]}))
;   (job spec))


(fn open-in-vim [path ?line-num]
  "Open file at PATH in Neovim at LINE-NUM line."
  (if ?line-num
      (do
        (vim.cmd (string.format "edit +%d %s" ?line-num path))
        (vim.cmd "normal! zv"))
      ;else
      (vim.cmd (string.format "edit %s" path))))


(fn open-file [path ?line-num]
  "Open file at PATH at LINE-NUM line."
  (let [extension (vim.fn.fnamemodify path ":e")]
    (if (. config.open-in-external-app  extension)
        (xdg-open path)
        ;else open in vim
        (open-in-vim path ?line-num))))


{: read-file
 : read-file-async
 : find-file-async
 : open-file
 : xdg-open
 : open-in-vim}
