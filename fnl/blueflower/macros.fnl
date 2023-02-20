(fn look-through [form ...]
  "Accept a sequence of forms.  Try first one. If it returns false, try
  second one. If it returns false, try third one, and so on.  When any form
  evaluates to true, stop execution."
  (if (not= form nil)
    `(let [ret# ,form]
       (if ret#
           ret#
           (look-through ,...)))))


{: look-through}

