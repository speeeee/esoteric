~ rlist: functions for lists that are processed at runtime.
  7 January 2016
----------------------------------------------------------~
$
~ access the head of a list. ~
(define #car (la (lst) (REF lst 1)))

~ reverses a list. ~
(define reverse (la (lst) (reverse$ lst ($))))
(define reverse$ (la (lst n) (#IF (NIL? lst) n (reverse$ (#cdr lst) (#. (#car lst) n)))))

~ simple function for interpolation. ~
(define interpolate (la (x y) (reverse (interpolate$ x y ($)))))
(define interpolate$ (la (x y n) (#IF (NIL? x) n 
  (interpolate$ (#cdr x) (#cdr y) (#. ($ (#car x) (#car y)) n)))))

~ maps a lambda expression to every element of a list. ~
(define map (la (l lst) (reverse (mapr l lst))))
(define mapr (la (l lst) (map$ l lst ($))))
(define map$ (la (l lst n) (#IF (NIL? lst) n (map$ l (#cdr lst) (#. (l (#car lst)) n)))))

~ access the last element of a list. ~
(define last (la (lst) (#car (reverse lst))))

~ access all but the head of a list; the reverse of the rest of the reverse of a list. ~
(define init (la (lst) (reverse (#cdr (reverse lst)))))

~ NOTE: add foldr/l for this function. ~
~ insert a new element between each element. ~
(define ins (la (lst i) (reverse (ins$ (#cdr lst) i (#. (#car lst) ($))))))
(define ins$ (la (lst i n) (reverse (#IF (NIL? lst) n 
  (ins$ (#cdr lst) i (#. (#car lst) (#. i n)))))))