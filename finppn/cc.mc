~ cc: functions for mcrolog -> C.
  3 January 2016
--------------------------------~
$
(import rlist)
(define c-init (la () (REF ($ (PRINTLN "#include <stdlib.h>") 
                              (PRINTLN "#include <stdio.h>")) 0)))
(CREATE-STORAGE cfuns)

~ #include ~
(define include (la (x) (PRINTLN ($str "#include "\" x ""\"))))
(define inc (la (x) (PRINTLN ($str "#include <" x ">"))))

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

~ allow reference to an externally defined function. ~
(define extern (la (name args) (extern0 name (UNLIST args) args)))
(define extern0 (la (name args1 args)
  (define name (la args1 ($str name "(" (!# $str (ins args ",")) ")")))))

~ define C functions from a list. ~
(define list-c (la (lst) (map (la (x) (c-fun (#car x) (REF x 2) (REF x 3) (REF x 4))))))

~ directly call a C function. ~
~(define @ (la (name args) ~

(define MAIN (la (exprs) ($ (PRINTLN "int main(int argc, char **argv) { ")
                            (mapr (la (x) (PRINTLN ($str x ";"))) exprs)
                            (PRINTLN " return 0; }"))))