(local uv vim.loop)
(local {: class} (require :blueflower.util))
(local {: read-file} (require :blueflower.files.util))
(local LanguageTree (require :vim.treesitter.languagetree))
(local {: parse_query :get_node_text get-node-text} vim.treesitter.query)
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


(fn File.get-node-text [self node concat?]
  (get-node-text node
                 (or self.bufnr self.content)
                 {:concat (or concat? false)}))


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
      (let [id-text (self:get-node-text content-node "concat")]
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
      (let [label (self:get-node-text label-node "concat")
            link  (self:get-node-text target-node "concat")
            line-num (+ (link-def-node:start) 1)]
        (tset output label {: link
                            : line-num})))
    output))


(fn File.get-headings [self sort?]
  (self:refresh)
  (let [output {}
        source (or self.bufnr  self.content)
        root   (self.tstree:root)
        query  "(heading) @heading"
        ts-query (self:parse-query query)]
    (each [_ h-node _ (ts-query:iter_captures root source)]
      (let [[level-node] (h-node:field "level")
            (_ start _ stop) (level-node:range)
            level (- stop start)
            entry {:level level
                   :title (let [[title-node] (h-node:field "title")]
                            (-> (self:get-node-text title-node "concat")
                                (string.gsub "\r?\n"  " ")
                                (string.gsub "%s+"  " ")
                                (vim.trim)))
                   :node  h-node}]
        (if sort?
            (do (when (not (. output level))
                  (tset output level {}))
                (table.insert (. output level) entry))
            ;else
            (table.insert output entry))))
    output))


(fn File.get-icons-positions [self  first-row  last-row]
  "Get positions of the icons to place above text for concealing."
  (self:refresh)
  (let [icons-positions {}
        source (or self.bufnr self.content)
        root (self.tstree:root)
        query "(list_item
                 level: (token) @list_token)
               (list_item
                 checkbox: (checkbox) @checkbox
                 (#not-eq? @checkbox \"[ ]\"))"
        ts-query (self:parse-query query)]
    (each [id node _ (ts-query:iter_captures root source first-row last-row)]
      (local name (. ts-query.captures id))
      (when (not (vim.startswith name "_"))
        (local (start-row  start-col  end-row  end-col) (node:range))
        (table.insert icons-positions {:type name
                                       ; :type (node:type)
                                       :text (self:get-node-text node true)
                                       :line-num start-row
                                       : start-col
                                       : end-col})))
    icons-positions))


File
