(local uv vim.loop)
(local async (require :blueflower.async))
(local await {:fs_open  (async.wrap uv.fs_open 4)
              :fs_fstat (async.wrap uv.fs_fstat 2)
              :fs_read  (async.wrap uv.fs_read 4)
              :fs_close (async.wrap uv.fs_close 2)})


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
        (print "read-file-async: enter")
        (match-try   (await.fs_open path "r" 292) ; 292 is 444 in octal
          (nil fd)   (await.fs_fstat fd)
          (nil stat) (await.fs_read fd  stat.size  0)
          (nil data) (await.fs_close fd)
          (nil true) (do
                       (print "read-file-async: exit")
                       (callback data {:mtime stat.mtime.sec}))
          (catch
            err (eprint err))))
      (async.create 2 true)
      (async.wrap 2)))


{: read-file
 : read-file-async}


