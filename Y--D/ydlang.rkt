#lang racket/base
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
(define (length? x y) (= (length x) y))

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define o (current-output-port))

(define test0 "Hello. I am 'world'!")
(define test1 ":> 2 | succ(succ(Z)).")
(define test2 ":> 2 3 | succ(succ(Z)), succ(Z); Z.")
(define test3 "elo 'X', bbb 'X', ccc.")

(define test4 "plo 'X' e.")

(define ruls* '())

; :>
; <:

(define (quot-str s) (foldl (λ (c n)
  (if (equal? c #\') (if (equal? 'var (car (pop n))) (push (push (ret-pop n) (list (car (pop n)) (list->string (cdr (pop n))))) '()) (push n '(var)))
      (if (and (char? c) (char-whitespace? c)) n (push (ret-pop n) (push (pop n) c))))) '(())  s))
(define (check-parens s) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt #\)))) (push n elt)
      (let ([expr (λ (x) (not (equal? x #\()))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() (string->list s)))
(define (flat l) (foldl (λ (x n)
  (if (equal? (car x) 'var) (push n x) (append n x))) '() l))
(define (cg-fact l) (map (λ (x)
  (if (and (> (length x) 3) (equal? (car x) 'fact))
      (case (list->string (list (cadr x) (caddr x)))
        [(":>") (cons 'yield (cdddr x))] [("<:") (cons 'derives (cdddr x))]
        [else x]) x)) l))
(define (bar l) (map (λ (x) (if (not (member (car x) '(yield derives))) x
  (cons (car x) (foldl (λ (x n) (if (equal? x #\|) (push n '()) 
                                    (push (ret-pop n) (push (pop n) x)))) '(()) (cdr x))))) l))

(define (andor l) (map (λ (x)
  (cons (car x) (foldl (λ (c n) (if (member c '(#\, #\; #\?))
                                    (append (ret-pop n) (list (cons (case c [(#\,) 'and] [(#\;) 'or] [(#\?) 'derives]) (pop n)) '()))
                                    (push (ret-pop n) (push (pop n) c)))) '(()) (cdr x)))) l))

(define (rm-vs x) (foldl (λ (c n) (if (and (list? c) (equal? (car c) 'var)) (push n '())
                                      (push (ret-pop n) (push (pop n) c)))) '(()) x))

(define (leq? e x) (and (= (length e) (length x)) (andmap (λ (y z) (or (equal? y z) (and (list? z) (equal? (car z) 'var)))) (car e) (car x))))
(define (find-match e) (findf (λ (x) (leq? e x)) ruls*))

(define (derive-vars e x) (if x
  (foldl (λ (y z v) (if (and (list? z) (equal? (car z) 'var) (not (member (cadr z) (map car v))))
                        (push v (list (second z) y)) v)) '() (car e) (car x)) "False"))

(define (expr e v) (let* ([x (find-match e)]
                          [nv (derive-vars e x)])
  (if (not (equal? nv "False")) (list e nv) "False")))
(define (parse-expr a v) 
  (cond [(= (length a) 1) (expr a v)]))

(define (parse l) (map (λ (x) (case (car x) ; r as in rules
  [(fact) (begin (set! ruls* (push ruls* (cdr x))))] 
  [(act) (parse-expr (cdr x) '())]
  [else (begin (displayln (car x)))])) l))

(define (fq s) (parse (andor (stmt-str (flat (quot-str (check-parens s)))))))
(define (stmt-str s) (ret-pop (foldl (λ (c n)
  (if (member c '(#\. #\!)) (push (push (ret-pop n) (cons (if (char=? c #\.) 'fact 'act) (pop n))) '()) 
      (push (ret-pop n) (push (pop n) c)))) '(()) s)))
