~ cc: functions for mcrolog -> C.
  3 January 2016
--------------------------------~
$
(define c-init (la () (REF ($ (PRINTLN "#include <stdlib.h>") 
                              (PRINTLN "#include <stdio.h>")) 0)))

; write a standard C function
(define c-fun (la (name args out body) 