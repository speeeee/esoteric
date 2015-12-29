#lang racket/base
(require racket/promise
         racket/list
         racket/string
         racket/function)

(define (push stk elt) (append stk (list elt)))
(define (cons& a b) (if (list? b) (cons a b) (list a b)))
(define (strcar x) (car (string->list x)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
(define (length? x y) (= (length x) y))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))

(define o (current-output-port))
(define dyads* '((F))) (define monads* '()) (define imports* '())

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

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

(define (lex x) (let ([c (strcar x)]) (if (or (member c '(#\" #\_ #\-)) (member x '("$x" "$y"))
                                              (char-numeric? c)) 'lit 'sym)))
(define (lex2 xe) (if (length? xe 1) (list (lex (car xe)))
  (cons (lex (car xe)) 
        (if (equal? (lex (cadr xe)) 'sym) (list (lex (cadr xe)) 'expr) (list 'expr)))))

(define (app-dyad d l r) (let ([f (find-eq d car dyads*)])
  (if f (string-join (list d "(" l "," r ")") "") (begin (printf "error: no such dyadic function: ~a~n" d) "False"))))
(define (app-mon d r) (let ([f (find-eq d car monads*)])
  (if f (string-join (list d "(" r ")") "") (begin (printf "error: no such monadic function: ~a~n" d) "False"))))

(define (combinator d l r) 
  (if (equal? d "->") (let ([x (string->number (takef (λ (x) (not (equal? x #\,)) 
                                                        (drop 2 (string->list r)))))])
    (set! monads* (cons (list d x) monads*))) ""))
(define (parse-expr xe) (let ([x (lex2 xe)]) (displayln x)(case x
  [((lit)) (car xe)] #;[(group) (parse-expr (car xe))]
  [((lit expr)) (string-join (list (car xe) (parse-expr (cdr xe))) ",")]
  [((lit sym expr)) (app-dyad (cadr xe) (car xe) (parse-expr (cddr xe)))]
  [((sym expr)) (app-mon (car xe) (parse-expr (cdr xe)))]
  ;[(sym) (emptyFun (car xe))] 
  [((sym sym expr)) (combinator (cadr xe) (car xe) (parse-expr (cddr xe)))]
  [else "error"])))

(define (parse xe) (parse-expr (mk-tokens xe)))