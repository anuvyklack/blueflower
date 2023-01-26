(local uv vim.loop)
(local LanguageTree (require :vim.treesitter.languagetree))
(local {: class : notify-error-once} (require :blueflower.util))
(local Buffer (require :blueflower.api-wrappers.buffer))
(local {: eprint} (require :blueflower.debug))
(local a (require :blueflower.async))
(local await {:fs_open   (a.wrap uv.fs_open 4)
              :fs_fstat  (a.wrap uv.fs_fstat 2)
              :fs_read   (a.wrap uv.fs_read 4)
              :fs_close  (a.wrap uv.fs_close 2)})

(local files {})
(local File (class))


(fn read-file [path]
  "Read the content of the file.

  Return:
    - CONTENT : string
          Content of the file.
    - STAT : table
          See: uv.fs_stat()
  "
  (match-try (uv.fs_open path)
    fd    (uv.fs_fstat fd)
    stat  (uv.fs_read fd stat.size)
    data  (fs_close fd)
    true  (values data stat)
    (catch
      (nil err) (error err))))


(fn read-file-async [path callback]
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
    (nil true) (callback data stat)
    (catch
      err (eprint err))))
(local read-file-async (a.create read-file 2 true))
(set await.read-file (a.wrap read-file-async 2 true))


(fn load-file-async [path ?callback]
  (match (. files path)
    file (file:refresh)
    nil  (match (vim.fn.bufnr path)
           -1 (let [(file-content file-stat) (await.read-file path)]
                (when (= (vim.filetype.match {:filename path :contents content})
                         "blueflower")
                  (tset files path (File:new {: path : file-content : file-stat}))))
           bufnr (let [buffer (Buffer:new bufnr)]
                   (when (= (buffer:get-option :filetype) "blueflower")
                     (tset files path (File:new {: path : buffer}))))))
  (when ?callback (?callback)))
(local load-file-async (a.create load-file-async 2 true))


(fn File.initialize [self {: path : buffer : file-content : file-stat}]
  "Parameters:
    - SPEC : table
      - PATH : string
      - BUFFER : Buffer?
            See 'blueflower/api-wrappers/buffer'
      - FILE-CONTENT : string?
            Content of the file.
      - FILE-STAT : table
            See: uv.fs_stat()
  "
  (set self.path path)
  (if buffer
      (do
        (set self.buffer buffer)
        ; (set self._changetick (buffer.bo.changedtick))
        (set self.tsparser (vim.treesitter.get_parser buffer.id "blueflower"))
        (set self.tstree   (-> (self.tsparser:parse) (. 1))))
      ;else
      (do
        (set self.tstree (-> (LanguageTree:new file-content "blueflower" {})
                             (tsparser:parse)
                             (. 1)))
        (set self.content (-> (vim.split file-content "\n")
                              (table.remove))) ; remove last line
        (set self.mtime file-stat.mtime.sec)
        )))


(fn File.refresh [self]
  (if (and self.buffer (self.buffer:loaded?))
      (set self.tstree   (-> (self.tsparser:parse) (. 1)))
      ;elseif
      (or (when self.buffer
            (set self.buffer nil)
            (set self.tsparser nil)
            true)
          (match (uv.fs_stat self.path)
            (nil err) (error err)
            (where {: mtime} (not= mtime.sec self.mtime)) true))
      ;then
      (let [(content stat) (read-file self.path)]
        (set self.tstree (-> (LanguageTree:new content "blueflower" {})
                             (tsparser:parse)
                             (. 1)))
        (set self.content (-> (vim.split content "\n")
                              (table.remove))) ; remove last line
        (set self.mtime stat.mtime.sec))))


{: files
 : load-file-async}
