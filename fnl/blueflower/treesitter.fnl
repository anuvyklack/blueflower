(local ts-utils (require "nvim-treesitter.ts_utils"))
(local parsers  (require "nvim-treesitter.parsers"))
(local Buffer   (require "blueflower/api-wrappers/buffer"))


(fn impl-find-parent-node-any-of-types [node types]
  "Supplementary function for `find-parent-node-of-type`"
  (if (. types (node:type))
      node
      (let [parent (node:parent)]
        (when parent
          (impl-find-parent-node-any-of-types parent types)))))


(fn impl-find-parent-node-of-type [node node-type]
  "Supplementary function for `find-parent-node-of-type'"
  (if (= (node:type) node-type)
      node
      (let [parent (node:parent)]
        (when parent
          (impl-find-parent-node-of-type parent node-type)))))


(fn find-parent-node-of-type [node node-type]
  "Find the closest parent of passed NODE of the specific NODE-TYPE
  or list of types."
  (match (type node-type)
    :table (impl-find-parent-node-any-of-types node (collect [_ ntype (ipairs node-type)]
                                                  ntype true))
    :string (impl-find-parent-node-of-type node node-type)))


(fn get-node-text [node ?buffer]
  "(vim.treesitter.query.get_node_text node bufnr {:concat true})"
  (let [buffer (or ?buffer (Buffer))]
    (buffer:get-text (node:range))))


{:get-node-at-cursor ts-utils.get_node_at_cursor
 :go-to-node ts-utils.goto_node
 : find-parent-node-of-type
 : get-node-text}

