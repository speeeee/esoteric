~ cc: functions for mcrolog -> C.
  3 January 2016
--------------------------------~
$
(import rlist)
(define c-init (la () (REF ($ (PRINTLN "#include <stdlib.h>") 
                              (PRINTLN "#include <stdio.h>")) 0)))

~ simple temporary function for interpolation. ~
(define interpolate (la (x y) (interpolate$ x y ($))))
(define interpolate$ (la (x y n) (#IF (NIL? x) n 
  (interpolate$ (#cdr x) (#cdr y) (#. ($ (#car x) (#car y)) n)))))

~ write a standard C function. ~
(define c-fun (la (name args out body) ($
  (PRINT ($str out " " name "(")) 
  (map (la (x) (PRINT ($str (#car x) " " (#car (#cdr x)) ","))) 
    (interpolate args (>LIST (REF body 1)))))))
