#lang racket
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
;(define (find-ret a lst) (let ([c (findf a lst)]) (if c (a c) #f)))
(define (length? x y) (= (length x) y))
(define (maxl l) (foldl max 0 l))

(define test0 "1, (2; 3), 4")
(define test1 "1(λ:(x y) (x, y))2")
(define test2 "(λ:(x) (show:x)):1")
(define test3 "and => λ:(x y) (x, y)")
(define test4 "and1 -> λ:(x) (1, x)")

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define (if-do a b) (if (force a) (force a) (if (force b) (force b) #f)))

(define o (current-output-port))
(define preds* '()) (define dyads* '(("," ()) (";" ()) ("=>" ()) ("->" ()))) (define monads* '())
#;(define punc* '("," ";" "=>" "->")) (define imports* '())

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\' #\, #\; #\:)) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (distrib v q) (map (λ (x) (let ([c (find-eq x car v)]) (if c (cadr c) x))) q))

; Cannot do arbitrarily placed dyads as finding 
;  dyads would take a while since each item would
;  need to be tested to see if it is a dyad.  It
;  will be possible for select dyads however.
(define (prim-dyad l d r) (case d
  [(",") (string-join (list "(" (parse-expr l) "&&" (parse-expr r) ")") "")]
  [(";") (string-join (list "(" (parse-expr l) "||" (parse-expr r) ")") "")]
  [("=>") (begin (set! dyads* (push dyads* (list l r))) "True")]
  [("->") (begin (set! monads* (push monads* (list l r))) "True")]
  [(":") (monad (parse-expr l) r)]
  [else #f]))
(define (prim-monad d r) (case d
  [("show") (begin (fprintf o "~a" (parse-expr r)) "True")]
  [("#") (map parse-expr r)]
  [("la" "λ") (list 'lambda (car r) (cadr r))]
  [else #f]))
(define (app-dyad l d r) 
  (if (and (list? d) (equal? (car d) 'lambda) (length? (cadr d) 2))
      (parse-expr (distrib (list (list (caadr d) l) (list (cadadr d) (parse-expr r))) (caddr d)))
      (let ([c (find-eq d car dyads*)]) (if c (parse-expr (list l (cadr c) r)) #f))))
(define (app-monad d r)
  (if (and (list? d) (equal? (car d) 'lambda) (length? (cadr d) 1))
      (parse-expr (distrib (list (list (caadr d) (parse-expr r))) (caddr d))) 
      (let ([c (find-eq d car monads*)]) (if c (parse-expr (list (cadr c) ":" r)) #f))))
(define (dyad l d r) (if-do (delay (prim-dyad l d r)) (delay (app-dyad l d r))))
(define (monad d r) (if-do (delay (prim-monad d r)) (delay (app-monad d r))))
(define (parse-expr x) (if (and (list? x) (> (length x) 2)) 
  (dyad (car x) (parse-expr (cadr x)) (cddr x)) 
  (if (and (list? x) (= (length x) 1)) (parse-expr (car x)) x)))

; all return string
#;(define (prim-tdyad l d r) (case d
  [(",") (string-join (list "(" (parse-expr l) "&&" (parse-expr r) ")") "")]
  [(";") (string-join (list "(" (parse-expr l) "||" (parse-expr r) ")") "")]
  [("=>") (set! dyads* (push dyads* (list l r)))]
  [("->") (set! monads* (push monads* (list l r)))]
  [else #f]))
#;(define (prim-dyad l d r) (case d
  [(":") "hello"]
  [else #f]))
#;(define (tdyad x) (let* ([c (filter (λ (z) z) (map (λ (q) (member q x)) punc*))]
                         [d (findf (λ (q) (= (length q) (maxl (map length c)))) c)])
  (if (and c d) (prim-tdyad (take x (- (length x) (length d))) (car d) (cdr d)) #f)))
#|(define (dyad x) (prim-dyad (car x) (parse-expr (cadr x)) (cddr x))) 
(define (fun x) (if (< (length x) 2) (parse-expr (car x)) (if-do (delay (tdyad x)) (delay (dyad x)))))
(define (parse-expr x) ; (if-do (delay (fun x)) (delay (predicate x))))
  (if (list? x) (fun x) x)) |#

(define (parse x) (parse-expr (check-parens (string-split-spec x))))