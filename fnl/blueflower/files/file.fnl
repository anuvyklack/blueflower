(local uv vim.loop)
(local {: class} (require :blueflower.util))
(local {: read-file} (require :blueflower.files.util))
; (local {: parse_query : get_node_text} (require :vim.treesitter.query))
(local LanguageTree (require :vim.treesitter.languagetree))
(local {: parse_query : get_node_text} vim.treesitter.query)
(local query-cache {})
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
        (set self.bufnr  buffer.id)
        (set self.buffer buffer)
        ; (set self._changetick (buffer.bo.changedtick))
        (set self.tsparser (vim.treesitter.get_parser buffer.id "blueflower"))
        (set [self.tstree] (self.tsparser:parse)))

      content
      (do
        (set self.tstree (let [tsparser (LanguageTree.new content "blueflower")
                               [tstree] (tsparser:parse)]
                           tstree))
        (set self.content (let [lines (vim.split content "\n")]
                            (table.remove lines) ; remove last line
                            lines))
        (set self.mtime stat.mtime))))


(fn File.refresh [self]
  (if self.buffer
      (do
        (assert (self.buffer:loaded?) "Buffer is not loaded!")
        (set [self.tstree] (self.tsparser:parse)))
      ;elseif
      (match (uv.fs_stat self.path)
        (nil err) (error err)
        {: mtime} (not= mtime self.mtime))
      ;then
      (let [(content stat) (read-file self.path)]
        (set self.tstree (let [tsparser (LanguageTree.new content "blueflower")
                               [tstree] (tsparser:parse)]
                           tstree))
        (set self.content (let [lines (vim.split content "\n")]
                            (table.remove lines) ; remove last line
                            lines))
        (set self.mtime stat.mtime))))


(fn File.parse-query [self query]
  (let [query (query:gsub "\n?%s"  " ")
        ts-query (or (. query-cache query)
                     (let [ts-query (parse_query "blueflower" query)]
                       (tset query-cache query ts-query)
                       ts-query))]
    ts-query))


(fn File.get-ids [self]
  "Get all ID directives from file."
  (self:refresh)
  (let [output {}
        source (or self.bufnr self.content)
        root   (self.tstree:root)
        query "(directive
                 (name) @name
                 (#eq? @name \"id\")
                 (content) @content) @id"
        ts-query (self:parse-query query)]
    ; (P ts-query.captures)
    (each [_ [_ content-node id-node] _ (ts-query:iter_matches root source)]
      (let [id-text (get_node_text content-node source {:concat true})]
        (tset output id-text id-node)))
    output))


(fn File.get-link-definitions [self]
  (self:refresh)
  (let [output {}
        query "(link_definition
                 (label) @label
                 (target) @target) @link-definition"
        ts-query (self:parse-query query)
        source (or self.bufnr self.content)
        root   (self.tstree:root)]
    (each [_ [label-node target-node link-def-node] _ (ts-query:iter_matches root source)]
      (let [label    (get_node_text label-node source {:concat true})
            link   (get_node_text target-node source {:concat true})
            line-num (+ (link-def-node:start) 1)]
        (tset output label {: link
                            : line-num})))
    output))


(fn File.get-headings [self]
  (self:refresh)
  (let [output {}
        source (or self.bufnr  self.content)
        root   (self.tstree:root)
        query  "(heading) @heading"
        ts-query (self:parse-query query)]
    (each [_ [h-node] _ (ts-query:iter_matches root source)]
      (let [[level-node] (h-node:field "level")
            (_ start _ stop) (level-node:range)
            level (- stop start)]
        (when (not (. output level))
          (tset output level {}))
        (table.insert (. output level)
                      {:level level
                       :title (let [[title-node] (h-node:field "title")]
                                (-> (get_node_text title-node source {:concat true})
                                    (string.gsub "\r?\n"  " ")
                                    (string.gsub "%s+"  " ")
                                    (vim.trim)))
                       :node  h-node})))
    output))


File
