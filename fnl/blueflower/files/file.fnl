(local uv vim.loop)
(local {: class} (require :blueflower.util))
(local {: read-file} (require :blueflower.files.util))
(local LanguageTree (require :vim.treesitter.languagetree))
(local P vim.pretty_print)

(local File (class))

(fn File.initialize [self {: path : buffer : content : stat}]
  "Construct a new File object either from BUFFER object or from file CONTENT string.

  Parameters:
    - SPEC : table
      - PATH : string
      - BUFFER : Buffer?
            See 'blueflower/api-wrappers/buffer'
      - CONTENT : string?
            Content of the file.
      - STAT : table?
            See: uv.fs_stat()
  "
  (set self.path path)
  (if buffer
      (do
        (set self.buffer buffer)
        ; (set self._changetick (buffer.bo.changedtick))
        (set self.tsparser (vim.treesitter.get_parser buffer.id "blueflower"))
        (set self.tstree   (-> (self.tsparser:parse) (. 1))))

      content
      (do
        (set self.tstree (-> (LanguageTree.new content "blueflower")
                             (: :parse) ; tsparser:parse() -> tstree 
                             (. 1)))    ; tstree[1]
        (set self.content (let [lines (vim.split content "\n")]
                            (table.remove lines) ; remove last line
                            lines))
        (set self.mtime stat.mtime))))


(fn File.refresh [self]
  (if self.buffer
      (do
        (assert (self.buffer:loaded?) "Buffer is not loaded!")
        (set self.tstree (-> (self.tsparser:parse) (. 1))))
      ;elseif
      (match (uv.fs_stat self.path)
        (nil err) (error err)
        {: mtime} (not= mtime self.mtime))
      ;then
      (let [(content stat) (read-file self.path)]
        (set self.tstree (-> (LanguageTree.new content "blueflower" {})
                             (: :parse) ; tsparser:parse() -> tstree
                             (. 1)))    ; tstree[1]
        (set self.content (let [lines (vim.split content "\n")]
                            (table.remove lines) ; remove last line
                            lines))
        (set self.mtime stat.mtime))))


File


