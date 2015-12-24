#lang racket/base
(require racket/list
         racket/string
         racket/promise)

(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
(define (length? x y) (= (length x) y))
(define (maxl l) (foldl max 0 l)) (define (strcar x) (car (string->list x)))
(define (push stk elt) (append stk (list elt)))
(define (push& stk elt) (if (list? stk) (push (cons "||" stk) elt) (list "||" stk elt)))
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))

(define test0 "1((_x _y)λ(|| _x,_y))2")
(define test1 "világ => (_x _y)λ(|| _x,_y,_x)")

(define o (current-output-port))
(define dyads* '()) (define monads* '()) (define imports* '())

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define (if-do a b) (if (force a) (force a) (if (force b) (force b) #f)))

(define (s-expr? x) (and (list? x) (> (length x) 1)))

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (if (equal? (pop (pop (pop n))) #\$)
                                     (list 'str (push (ret-pop (cadr n)) (push (ret-pop (pop (cadr n))) #\")))
                                     (push (push (ret-pop (second n)) (push (cons #\" (pop (second n))) #\")) '())) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\' #\, #\; #\: #\λ #\\)) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (distrib v q) (map (λ (x) (if (list? x) (distrib v x) (let ([c (find-eq x car v)]) (if c (cadr c) x)))) q))

(define (lambda? x) (and (list? x) (not (empty? x)) (equal? (car x) 'lambda)))
(define (lit? x)
  (or (and (list? x) (not (lambda? x))) 
      (and (string? x) (or (char-numeric? (strcar x)) (char=? (strcar x) #\") (char=? (strcar x) #\_)))))

(define (primd l d r) (case d
  [(",") (string-join (list "(" l "&&" r ")") "")]
  [("\\" "λ") (list 'lambda l r)]
  [("=>") (begin (set! dyads* (push dyads* (list l r))) "True")]
  [("->") (begin (set! monads* (push monads* (list l r))) "True")]
  [else #f]))
(define (primm d r) (case d
  [("show") (begin (fprintf o "~a" r) "True")]
  [("LIST") r]
  [else #f]))
(define (monad d r) (let ([c (find-eq d car monads*)])
  (if c (parse-expr (list (cadr c) r))
      (if (lambda? d) (distrib (list (list (caadr d) (parse-expr r))) (caddr d))
          (if-do (delay (primm d r)) (delay (fprintf o "unrecognized token: ~a" d)))))))
(define (dyad l d r) (let ([c (find-eq d car dyads*)])
  (if c (parse-expr (list l (cadr c) r)) 
      (if (lambda? d) (parse-expr (distrib (list (list (caadr d) l) (list (cadadr d) (parse-expr r))) (caddr d)))
          (if-do (delay (primd l d r)) (delay (fprintf o "unrecognized token: ~a" d)))))))
(define (parse-expr x)
  (cond [(or (not (list? x)) (empty? x)) x]
        [(length? x 1) (parse-expr (car x))]
        [(equal? (car x) "||") (cdr x)] [(equal? (car x) 'lambda) x]
        [else (let ([a (parse-expr (car x))] [b (parse-expr (cadr x))])
                (cond [(and (lit? a) (lit? b)) (parse-expr (cons (push& a b) (cddr x)))]
                      [(not (lit? b)) (dyad a b (parse-expr (cddr x)))]
                      [(not (lit? a)) (monad a (parse-expr (cdr x)))] [else "Error"]))]))

;(define (split-expr x) (foldr (λ (x n) (if (list? x) ((non-lit x)

(define (parse x) (parse-expr (check-parens (string-split-spec x))))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating ? debugger...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) 
                                                                           (if (empty? (string->list d)) '() (fprintf o "~a" (parse d))))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".li") ""))])
    (parse (readn f "")))))

(main)