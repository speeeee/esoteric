#lang racket/base
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
(define (length? x y) (= (length x) y))

(define o (current-output-port))

(define (popp x) (pop (ret-pop x)))
(define (poppp x) (pop (ret-pop (ret-pop x))))

(define test0 "std-add (car (cdr (1 2 3))) 2")
(define test1 ">chars (>codes hello)")

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\])) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (member elt '(")" "]")))) (push n elt)
      (let* ([c (case elt [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) 
              ((λ (x) (if (equal? elt "]") (cons "quot:" x) x)) (reverse (takef (reverse n) expr))))))) '() lst))

(define (parse-expr s) (if (not (list? s)) s (case (car s)
  [("std-add" "std-sub" "std-div" "std-mul") (if (length? s 3) (number->string
   ((case (car s) [("std-add") +] [("std-sub") -] [("std-mul") *] [("std-div") /]) 
    (string->number (parse-expr (pop (ret-pop s)))) (string->number (parse-expr (pop s)))))
   (fprintf o "ERROR: `~a' required length: 3, given: ~a.~n" (car s) (length s)))]
  [("car" "cdr") (if (length? s 2) ((case (car s) [("car") car] [("cdr") cdr]) (parse-expr (pop s))) 
                     (fprintf o "ERROR: `car' required length: 2, given ~a; also possible that given argument is not a list.~n" (length s)))]
  [("std-eq") (if (equal? (cadr s) (caddr s)) "True" "False")]
  [(">codes") (map (λ (x) (number->string (char->integer x))) (string->list (parse-expr (cadr s))))]
  [(">chars") (list->string (map (λ (x) (integer->char (string->number x))) (parse-expr (cadr s))))]
  [("if") (if (length? s 3) (if (equal? (parse-expr (cadr s)) "False") (parse-expr (pop s)) (parse-expr (caddr s)))
              (fprintf o "ERROR: `if' required length: 2, given ~a.~n" (length s)))]
  [else s])))                                                                 

(define (parse l) (parse-expr (check-parens (string-split-spec l))))