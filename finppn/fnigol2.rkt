#lang racket/base
(require racket/promise
         racket/list
         racket/string
         racket/function)

(define (push stk elt) (append stk (list elt)))
(define (cons& a b) (if (list? b) (cons a b) (list a b)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
(define (strcar x) (car (string->list x)))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define o (current-output-port)) (define l (current-output-port))
(define funs* '(("+" 2 1))) (define v* 0)

(define (if-do a b) (if (force a) (force a) (if (force b) (force b) #f)))

(define (string-split-spec s) (cadr (foldr (λ (c nn) (let ([m (car nn)] [n (cadr nn)]) (case m
   [(neutral) (cond [(equal? c #\") (list 'string (cons '() n))]
                    [(equal? c #\~) (list 'comment n)] [(member c '(#\( #\) #\, #\; #\:)) (list m (append (list '() (list c)) n))]
                    [(char-whitespace? c) (list m (cons '() n))]
                    [else (list m (cons (cons c (car n)) (cdr n)))])]
   [(comment) (if (equal? c #\~) (list 'neutral n) nn)]
   [(string) (cond [(equal? (cadr nn) 'escape) (let ([cn (caddr nn)]) (list 'string (cons (cons c (car cn)) (cdr cn))))]
                   [(equal? c #\") (list 'neutral (cons '() n))] [(equal? c #\\) (list 'string 'escape n)]
                   [else (list 'string (cons (cons c (car n)) (cdr n)))])]
   [else 'error]))) '(neutral (())) s)))
(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (sss->str lst) (map list->string (filter (compose not empty?) lst)))
(define (mk-tokens s) (check-parens (sss->str (string-split-spec (string->list s)))))

(define (lex x) (if (list? x) 'group
  (let ([c (strcar x)]) (if (or (member c '(#\" #\_ #\-)) (char-numeric? c)) 
     'lit 'sym))))

(define (gen-var) (set! v* (+ v* 1)) v*)

(define (derive-ctype x) (let ([s (string->list x)])
  (if (char-numeric? (car s)) (if (member #\. s) "DOUBLE" "INT") "STRING")))

(define (app-sym d n) (let ([f (find-eq d car funs*)])
  (if f (let* ([c (string-join (list (car f) "(" (string-join (drop n (- (length n) (cadr f))) ",") ")") "")]
               [q (- (length n) (cadr f))])
          (case (caddr f) [(0) (begin (fprintf o "~a;~n" c) (take n q))]
            [(1) (push (take n q) c)] 
            [else (let ([q (gen-var)]) (fprintf o "void **a~a = ~a;~n" q c)
              (append (take n q) (map (λ (x) (string-join (list c "[" (number->string x) "]") "")) (range q))))]))
        (begin (printf "error: no such function: ~a~n" d) '("False")))))

(define (ia xe) (let* ([q (foldr (λ (x i)
  (case (lex x) [(lit group) (- i 1)] 
    [(sym) (let ([c (find-eq x car funs*)]) (- (+ i (cadr c)) (caddr c)))])) 0 (cdr (reverse xe)))] 
  [p (+ q (case (lex (last xe)) [(lit group) -1] [(sym) (cadr (find-eq (last xe) car funs*))]))])
  (if (negative? p) 0 p)))
(define (oa xe) (let ([q (foldl (λ (x i)
  (case (lex x) [(lit group) (+ i 1)]
    [(sym) (let ([c (find-eq x car funs*)]) (+ (- i (cadr c)) (caddr c)))])) 0 xe)])
  (if (not (positive? q)) (case (lex (last xe)) [(lit group) 1] [(sym) (caddr (find-eq (last xe) car funs*))])
      q)))
(define (mk-la x n) (let ([i (list (ia x) (oa x))] [d (gen-var)]) (displayln i)
  (fprintf l "if(!strcmp(la,\"LAMBDA_~a\")) { return ~a;~n}~n" d 
           (parse-expr x (map (λ (x) (format "_vl[~a]" x)) (range (car i)))))
  (push n (format "LAMBDA_~a" d))))
                    
(define (parse-expr xe init) (foldl (λ (x n) (case (lex x)
  [(lit) (push n x)] [(group) (if (and (not (empty? n)) (equal? (last n) ":"))
                                  (push x n) #;(begin (word x (car (reverse n)) (cadr (reverse n))) '())
                                  (mk-la x n))] 
  [(sym) (app-sym x n)])) init xe))

(define (parse xe) (parse-expr (mk-tokens xe) '()))