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

(define (if-do a b) (if a a b))

(define o (current-output-port))
(define ruls* '()) (define imports* '())

(define test0 "pos 'X <- (real&num:'X) (>:0 'X)!")
(define test1 "std-add 1 2")
(define test2 ":- add1 (lambda X (std-add (car X) 1))")

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\))) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let ([expr (λ (x) (not (equal? x "(")))])
        (push (ret-pop (reverse (dropf (reverse n) expr)))
              (reverse (takef (reverse n) expr)))))) '() lst))

(define (categorize l) (map (λ (x) (if (member x (map car ruls*)) (list x 'rule) x)) l))
(define (excl l) (ret-pop (foldl (λ (x n)
  (if (member x '("!" "?")) (append (ret-pop n) (list (if (equal? x "!") (cons 'fact (pop n)) (pop n)) '()))
      (push (ret-pop n) (push (pop n) x)))) '(()) l)))

(define (distrib var val lst) (map (λ (x)
  (cond [(list? x) (distrib var val x)] [(equal? x var) val] [else x])) lst))

#;(define (parse-prog l) (map (λ (x) (if (equal? (car x) 'fact)
  (set! ruls* (push ruls* (let ([c (member "<-" (cdr x))])
    (if c (list (cadr x) (cdr c)) (list (cdr x) '())))))
  (parse-expr x))) l))

(define (primitive s) (case (car s)
  [("std-add" "std-sub" "std-div" "std-mul") (if (length? s 3) (number->string
   ((case (car s) [("std-add") +] [("std-sub") -] [("std-mul") *] [("std-div") /]) 
    (string->number (parse-expr (pop (ret-pop s)))) (string->number (parse-expr (pop s)))))
   "False")]
  [("car" "cdr") (if (and (length? s 2) (list? (cadr s))) 
                     ((case (car s) [("car") car] [("cdr") cdr]) (parse-expr (pop s))) "False")]
  [("empty?") (if (length? s 2) (if (empty? (parse-expr (cadr s))) "True" "False") (fprintf o "ERROR: `empty?' required length: 2, given ~a." (length s)))]
  [("std-eq") (if (equal? (parse-expr (cadr s)) (parse-expr (caddr s))) "True" "False")]
  [(">codes") (map (λ (x) (number->string (char->integer x))) (string->list (parse-expr (cadr s))))]
  [(">chars") (list->string (map (λ (x) (integer->char (string->number x))) (parse-expr (cadr s))))]
  [("if") (if (length? s 4) (if (equal? (parse-expr (cadr s)) "False") (parse-expr (pop s)) (parse-expr (caddr s)))
              "False")]
  [("lambda") #;(lambda var expr val) (if (length? s 4)
   (parse-expr (distrib (second s) (fourth s) (third s))) s)]
  [(">in") (read-line)] [(">out") (begin (fprintf o "~a" (parse-expr (cadr s))) (parse-expr (cadr s)))]
  [("$") (map (λ (x) (parse-expr x)) (cdr s))] [("eval") (parse-expr (cadr s))]
  [("cons") (cons (parse-expr (cadr s)) (parse-expr (caddr s)))]
  [("import") (if (member (pop s) imports*) '()
                  (begin (parse (readn (open-input-file (string-join (list (pop s) ".li") "")) ""))
                         (set! imports* (push imports* (pop s))) "#DONE"))]
  [(":-") (begin (set! ruls* (push ruls* (cdr s))) "True")] [else #f]))

(define (app-expr s) (let ([c (find-eq (car s) car ruls*)])
  (if c (if (length? c 1) "True" (parse-expr (push (cadr c) (map parse-expr (cdr s))))) #f)))

(define (parse-expr x) (if (not (list? x)) x (let* ([q (cons (parse-expr (car x)) (cdr x))]
                                                    [qq (primitive q)])
  (if qq qq (let ([e (app-expr q)])
              (if e e q))))))

(define (parse x) (parse-expr (check-parens (string-split-spec x))))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating L__I_ REPL...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) 
                                                                           (if (empty? (string->list d)) '() (fprintf o "~a" (parse d))))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".li") ""))])
    (parse (readn f "")))))