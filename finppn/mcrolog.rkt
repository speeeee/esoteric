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

; requires logic and cc.
(define test0 "c-fun name ($ int int) int (la (x y) (, x y))")

(define o (current-output-port)) (define l (current-output-port))
(define funs* '()) (define storage* '()) (define imports* '())

(define (if-do a b) (if (force a) (force a) (if (force b) (force b) #f)))
(define (distrib v q) (map (λ (x) (if (list? x) (distrib v x) (let ([c (find-eq x car v)]) (if c (cadr c) x)))) q))

(define (quoti lst) (append (list #\") (push lst #\")))
(define (quotish s) (list->string (quoti (string->list s))))
(define (dequoti lst) (list->string (cdr (ret-pop (string->list lst)))))
(define (q? lst) (and (equal? (car (string->list lst)) #\") (equal? (last (string->list lst)) #\")))
(define (dequoti@ lst) (if (q? lst) (dequoti lst) lst))
(define (string-split-spec s) (cadr (foldr (λ (c nn) (let ([m (car nn)] [n (cadr nn)]) (case m
   [(neutral) (cond [(equal? c #\") (list 'string (cons '() n))]
                    [(equal? c #\~) (list 'comment n)] [(member c '(#\( #\) #\, #\; #\: #\@)) (list m (append (list '() (list c)) n))]
                    [(char-whitespace? c) (list m (cons '() n))]
                    [else (list m (cons (cons c (car n)) (cdr n)))])]
   [(comment) (if (equal? c #\~) (list 'neutral n) nn)]
   [(string) (cond [(equal? (cadr nn) 'escape) (let ([cn (caddr nn)]) (list 'string (cons (cons c (car cn)) (cdr cn))))]
                   [(equal? c #\") (list 'neutral (cons '() (cons (quoti (car n)) (cdr n))))] [(equal? c #\\) (list 'string 'escape n)]
                   [else (list 'string (cons (cons c (car n)) (cdr n)))])]
   [else 'error]))) '(neutral (())) s)))
(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (sss->str lst) (map list->string (filter (compose not empty?) lst)))
(define (mk-tokens s) (check-parens (sss->str (string-split-spec (string->list s)))))

; varargs
(define (prim d r) (case d
  [("la") (cons d r)] [("#.") (cons "$" (cons (parse-expr (car r)) (cdr (parse-expr (cadr r)))))] 
  [("#cdr") (cons "$" (cddr (parse-expr (car r))))] [("NIL?") (if (equal? (car r) '("$")) "True" "False")]
  [("CREATE-STORAGE") (begin (set! storage* (cons (list (car r) '()) storage*)) "True")]
  [("STORE") (let ([c (find-eq (parse-expr (car r)) car storage*)])
                 (if c (begin (set! storage* (cons (list (car c) (cons (parse-expr (cadr r)) (cadr c))) 
                                                   (filter (λ (x) (not (equal? x c))) storage*))) 
                              "True") "False"))]
  [("FOUND?") (if (member (car r) (find-eq (cadr r) car storage*)) "True" "False")]
  [("PRINT") (begin (fprintf o "~a" (dequoti (parse-expr (car r)))) "True")] 
  [("PRINTLN") (begin (fprintf o "~a~n" (dequoti (parse-expr (car r)))) "True")]
  [("REF") (list-ref (parse-expr (car r)) (string->number (parse-expr (cadr r))))]
  [(">LIST") (cons "$" (parse-expr (car r)))] [("LIST?") (if (list? (car r)) "True" "False")]
  [("$") (cons "$" (map parse-expr r))] [("$str") (quotish (string-join (map (compose dequoti@ parse-expr) r) ""))]
  [("!#") (parse-expr (cons (parse-expr (car r)) (cdr (parse-expr (cadr r)))))]
  [("#") (parse-expr (list (parse-expr (car r)) (cons "$" (map parse-expr (cdr r)))))] 
  [("#IF") (if (equal? (parse-expr (car r)) "False") (parse-expr (caddr r)) (parse-expr (cadr r)))]
  [("import") (if (member (car r) imports*) '()
                  (begin (parse (readn (open-input-file (string-join (list (car r) ".mc") "")) ""))
                         (set! imports* (push imports* (car r))) "True"))]
  [("define") (begin (set! funs* (push funs* (list (car r) (cadr r)))) "True")]
  [else #f]))

(define (parse-expr xe) (if (and (list? xe) (not (empty? xe)))
  (let* ([q (parse-expr (car xe))]
         [c (find-eq q car funs*)]) 
    (if-do (prim q (cdr xe))
      (delay (cond [c (parse-expr (cons (cadr c) (map parse-expr (cdr xe))))] [(empty? q) q]
               [(and (list? q) (equal? (car q) "la"))
                  (parse-expr (distrib (map (λ (x y) (list x y)) (cadr q) (cdr xe)) (caddr q)))]
               [else (fprintf o "error: no such function: ~a~n" q)])))) xe))

(define (parse xe) (parse-expr (mk-tokens xe)))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating Mcrolog REPL...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) 
                                                                           (if (empty? (string->list d)) '() (fprintf o "~a" (parse d))))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".mc") ""))])
    (parse (readn f "")))))

(main)