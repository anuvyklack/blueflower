(fn do-until-true [form ...]
  "Accept a sequence of forms.  Execute first one. If it returns false, execute
  second one. If it returns false, execute third one, and so on.  If any form
  returns true, stop execution."
  (if (not= form nil)
    `(let [ret# ,form]
       (if ret#
           ret#
           (do-until-true ,...)))))


{: do-until-true}

