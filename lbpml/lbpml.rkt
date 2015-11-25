#lang racket/base
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (if (> (length stk) 0) (car (reverse stk)) (begin (displayln "ERROR: stack underflow") (exit))))
(define (ret-pop stk) (if (> (length stk) 0) (reverse (cdr (reverse stk))) (begin (displayln "ERROR: stack underflow") (exit))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))
;(define (find-ret a lst) (let ([c (findf a lst)]) (if c (a c) #f)))
(define (length? x y) (= (length x) y))

(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define (if-do a b) (if a a b))

(define o (current-output-port))
(define ruls* '()) (define imports* '())

(define test0 ":- ($x + $y) (CFun Add $x $y)")
(define test1 ":- ($x + $y) (>> (Show $x) (Show $y))")
(define test2 ":- (AAA $x #y) (>> (Show $x) (Show #y))")

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

(define (is-rest x) (and (string? x) (char=? (car (string->list x)) #\#)))
(define (collect a b) (let ([c (takef b (λ (x) (not (is-rest x))))])
  (if (>= (length a) (length c)) (list (take a (length c)) (drop a (length c)))
      #f)))
(define (get-vars a b) (display a) (displayln b) (foldl (λ (x y r)
  (cond [(and (string? y) (equal? (car (string->list y)) #\$)) (push r (list y (parse-expr x)))]
        [else r])) '() a b))
(define (expr-eq a b) (if (ormap (λ (x) (is-rest x)) b)
  (if (collect a b) (append (expr-eq (car (collect a b)) (ret-pop b)) (list (list (pop b) (cadr (collect a b)))) #;(get-vars (ret-pop b) (cadr (collect a b)))) #f)
  (if (= (length a) (length b)) (get-vars a b) #f)))
(define (app-vars v a) (displayln v)
  (map (λ (x) (if (member x (map car v)) (cadr (find-eq x car v)) 
                  (if (list? x) (app-vars v x) x))) a))

(define (app-expr x) (let ([expr (findf (λ (y) (expr-eq x (car y))) ruls*)])
  (if expr (parse-expr (app-vars (expr-eq x (car expr)) (second expr))) #f)))

(define (primitive l) (case (car l)
  [(">>") (map (λ (x) (parse-expr x)) (cdr l))]
  [(":-") (begin (set! ruls* (push ruls* (cdr l))) "True")]
  [("Show") (begin (fprintf o "~a" (parse-expr (cadr l))) "True")]
  [("Show!") (begin (fprintf o "~a" (cadr l)) "True")]
  [("Import") (if (member (pop l) imports*) '()
                  (begin (parse (readn (open-input-file (string-join (list (pop l) ".li") "")) ""))
                         (set! imports* (push imports* (pop l))) "True"))]
  [else #f]))
(define (parse-expr l) (if (or (not (list? l)) (empty? l)) l (let* ([c (primitive l)])
  (if c c (let ([q (app-expr l)]) (if q q (begin (display "no such rule for expression: ") (displayln l) "False"))))))) 

(define (parse x) (parse-expr (check-parens (string-split-spec x))))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating lbpml REPL...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) 
                                                                           (if (empty? (string->list d)) '() (fprintf o "~a" (parse d))))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".lbpml") ""))])
    (parse (readn f "")))))

(main)