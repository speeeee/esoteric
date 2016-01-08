~ rlist: functions for lists that are processed at runtime.
  7 January 2016
----------------------------------------------------------~
$
(define #car (la (lst) (REF lst 1)))

(define map (la (l lst) (map$ l lst ($))))
(define map$ (la (l lst n) (#IF (NIL? lst) n (map$ l (#cdr lst) (#. (l (#car lst)) n)))))