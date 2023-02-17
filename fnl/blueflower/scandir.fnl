(local uv vim.loop)
(local a (require :blueflower.async))
(local {: eprint} (require :blueflower.debug))
(local {: os-sep} (require :blueflower.config))
(local empty? vim.tbl_isempty)
(local await {:fs_access  (a.wrap uv.fs_access 3 true)
              :fs_scandir (a.wrap uv.fs_scandir 2 true)})
(local P vim.pretty_print)

(var impl-depth-first-async nil)
(var impl-breadth-first-async nil)

(local scandir-async
  (-> (fn [path ?opts callback]
        "Scan directory recursively and asynchronously.

        Parameters:
          - PATH : string
          - OPTS : table?
            - PATTERN : string | string[] | fun(entry) -> boolean
                  search pattern
            - TYPE : 'breadth' | 'depth'
                  Breadth-first or depth-first algorithm. If not specified -
                  breadth-first algorithm is used.
            - FIRST-FOUND? : boolean?
                  Stop search after first found entry?
            - DEPTH : integer?
            - ADD-DIRS? : boolean?
                  Add directories into output?
            - HIDDEN? : boolean?
                  Add hidden files into search?
          - CALLBACK : function
            - OUTPUT : string[]
        "
        (local spec (or ?opts {}))
        (when spec.pattern
          (let [{: pattern : first-found?} spec
                pattern-fn (match (type pattern)
                             :function pattern
                             :string (fn [entry] (entry:match pattern))
                             :table  (fn [entry] ; list of patterns
                                       (var found? false)
                                       (each [_ pat (ipairs pattern) &until found?]
                                         (when (entry:match pat)
                                           (set found? true)))
                                       found?))]
            (set spec.match-pattern? (fn [entry]
                                       (when (pattern-fn entry)
                                         (when first-found?
                                           (set spec.found? true))
                                         true)))))
        (set spec.base-path path)
        (set spec.output [])
        (if (= spec.type "depth")
          (impl-depth-first-async nil 1 spec)
          (do
            (set spec.queue [])
            (impl-breadth-first-async nil 1 spec)
            (while (not (empty? spec.queue))
              (let [next-dir (table.remove spec.queue 1)]
                (impl-breadth-first-async next-dir 2 spec)))))
        (callback spec.output))
      (a.create 3)
      (a.wrap 3 true)))


(set impl-depth-first-async
     (-> (fn [current-dir
              level
              {: base-path : output : match-pattern? : depth : add-dirs? : hidden? &as spec}
              callback]
           (local full-path (if current-dir
                                (.. base-path  os-sep  current-dir)
                                base-path))
           (match-try (await.fs_access full-path "X")
             (nil true) (await.fs_scandir full-path)
             (nil fd) (let [traverse-dir (fn [] (uv.fs_scandir_next fd))]
                        (each [name type_ traverse-dir &until spec.found?]
                          (when (or hidden?
                                    (not= (name:sub 1 1) "."))
                            (let [entry (.. (or current-dir "")  os-sep  name)]
                              (match type_
                                :directory
                                (do (when (and (not= name ".git")
                                               add-dirs?
                                               (match-pattern? entry))
                                      (table.insert output (.. base-path entry os-sep)))
                                    (when (and (not spec.found?)
                                               (or (not depth)
                                                   (< level depth)))
                                      (impl-depth-first-async entry (+ level 1) spec)))

                                _ ; all others
                                (when (match-pattern? entry)
                                  (table.insert output (.. base-path  entry))))))))
             (catch
               ; err (eprint err)
               err (print err)
               (nil false) (print (string.format
                                    "%s directory is not accessible by the current user!"
                                    current-dir))))
           (callback))
         (a.create 4)
         (a.wrap 4 true)))


(set impl-breadth-first-async
     (-> (fn [current-dir
              level
              {: base-path : queue : output : match-pattern?
               : depth : add-dirs? : hidden? &as spec}
              callback]
           (local full-path (if current-dir
                                (.. base-path  os-sep  current-dir)
                                base-path))
           (match-try (await.fs_access full-path "X")
             (nil true) (await.fs_scandir full-path)
             (nil fd) (let [traverse-dir (fn [] (uv.fs_scandir_next fd))]
                        (each [name type_ traverse-dir &until spec.found?]
                          (when (or hidden?
                                    (not= (name:sub 1 1) "."))
                            (let [entry (.. (or current-dir "")  os-sep  name)]
                              (match type_
                                :directory
                                (do (when (and (not= name ".git")
                                               add-dirs?
                                               (match-pattern? entry))
                                      (table.insert output (.. base-path entry os-sep)))
                                    (when (or (not depth)
                                              (< level depth))
                                      (table.insert queue entry)))

                                _ ; all others
                                (when (match-pattern? entry)
                                  (table.insert output (.. base-path  entry))))))))
             (catch
               ; err (eprint err)
               err (print err)
               (nil false) (print (string.format
                                    "%s directory is not accessible by the current user!"
                                    current-dir))))
           (callback))
         (a.create 4)
         (a.wrap 4 true)))


scandir-async

