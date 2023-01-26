(local uv vim.loop)
(local a (require :blueflower.async))
(local {: eprint} (require :blueflower.debug))
(local os-sep "/")
(local await {:fs_access  (a.wrap uv.fs_access 3 true)
              :fs_scandir (a.wrap uv.fs_scandir 2 true)})

(fn scandir [path ?opts callback]
  "Scan directory recursively and asynchronously.

  Parameters:
    - PATH : string
    - OPTS : table?
      - PATTERN : string | string[] | fun(entry) -> boolean
            search pattern
      - DEPTH : integer?
      - ADD-DIRS? : boolean?
            Add directories into output?
      - FIRST-FOUND? : boolean?
            Stop search after first found entry.
      - HIDDEN? : boolean?
            Add hidden files into search
    - CALLBACK : function
      - OUTPUT : string[]
  "
  (var found? false)
  (let [{: pattern : depth : add-dirs? : first-found? : hidden?} (or ?opts {})
        output []
        check-pattern (match (type pattern)
                        :string (fn [entry] (entry:match pattern))
                        :table  (fn [entry] ; list of patterns
                                  (var found? false)
                                  (each [_ pat (ipairs pattern) &until found?]
                                    (when (entry:match pat)
                                      (set found? true)))
                                  found?)
                        :function pattern
                        :nil #true)
        match-pattern? (fn [entry]
                         (if (check-pattern entry)
                           (when first-found?
                             (set found? true))
                           true))]
    (var parse-dir-async nil)
    (fn parse-dir [current-dir level callback]
      (match-try (await.fs_access current-dir "X")
        (nil true) (await.fs_scandir current-dir)
        (nil fd) (let [traverse-dir (fn [] (uv.fs_scandir_next fd))]
                   (each [name type_ traverse-dir &until found?]
                     (when (or hidden?
                               (not= (name:sub 1 1) "."))
                       (let [entry (.. current-dir  os-sep  name)]
                         (match type_
                           :directory
                           (do (when (and (not= name ".git")
                                          add-dirs?
                                          (match-pattern? entry))
                                 (table.insert output (.. entry os-sep)))
                               (when (and (not found?)
                                          (or (not depth)
                                              (< level depth)))
                                 (parse-dir-async entry (+ level 1))))

                           _ ; all others
                           (when (match-pattern? entry)
                             (table.insert output entry)))))))
        (catch
          err (eprint err)
          (nil false) (print
                        (string.format
                          "%s directory is not accessible by the current user!"
                          path))))
      (callback))

    (set parse-dir-async (a.create parse-dir 3))
    (set parse-dir-async (a.wrap parse-dir-async 3 true))
    (parse-dir-async path 1)
    (callback output)))

(local scandir (a.create scandir 3 true))
(local scandir (a.wrap scandir 3 true))

scandir


