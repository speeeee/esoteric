~ cc: functions for mcrolog -> C.
  3 January 2016
--------------------------------~
$
(import rlist)
(define c-init (la () (REF ($ (PRINTLN "#include <stdlib.h>") 
                              (PRINTLN "#include <stdio.h>")) 0)))
(CREATE-STORAGE cfuns)

~ write a standard C function. ~
(define c-fun (la (name args out body) ($
  (PRINT ($str out " " name "(")) 
  (mapr (la (x) (PRINT ($str (#car x) " " (#car (#cdr x)) ","))) 
    (init (interpolate args (>LIST (REF body 1)))))
  (#IF (NIL? args) True (PRINTLN ($str (last args)" "(last (>LIST (REF body 1))) ") {")))
  (PRINTLN (!# body (>LIST (REF body 1)))) (PRINTLN "; }") ~(STORE cfuns name)~
  (new-fun name (>LIST (REF body 1)) (REF body 1)))))
(define new-fun (la (name args0 args) 
  (define name (la args ($str name "(" (!# $str (ins args0 ",")) ")")))))

~ directly call a C function. ~
~(define @ (la (name args) ~
