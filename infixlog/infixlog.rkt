#lang racket
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
;(define (push stk elt) (
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define (if-do a b) (if a a b))

(define o (current-output-port))
(define mon* '(("show" ()))) (define dya* '())

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\' #\, #\;)) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (mprimitive x r) (case x 
  [("show") (begin (fprintf o "~a" r) "True")]
  [else #f]))
(define (dprimitive l x r) #f)

(define (app-dyad l x r) (let ([f (find-eq x car dya*)]
                               [fp (dprimitive l x r)])
  (if fp fp (parse-expr (list l (cadr f) r)))))
(define (app-monad x r) (let ([f (find-eq x car mon*)]
                              [fp (mprimitive x r)])
  (if fp fp (parse-expr (push (cadr f) r)))))

(define (parse-exprg x) (parse-expr '() (car x) (cdr x)))
(define (parse-expr l x r) (if (empty? r) (push l x) (let ([c (if (list? x) (parse-expr '() (car x) (cdr x)) x)])
  (if (empty? l) (if (member x (map car mon*)) (app-monad x (parse-exprg r)) (parse-expr (push l x) (car r) (cdr r)))
      (if (member x (map car dya*)) (app-dyad l x (parse-exprg r)) (parse-expr (push l x) (car r) (cdr r)))))))

(define (parse x) (parse-exprg (check-parens (string-split-spec x))))