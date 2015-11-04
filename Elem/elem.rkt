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

(define test0 ":: recur (lambda x (if (std-eq (car x) 10) \"DONE\" (! recur (std-add (car x) 1))))")
(define test1 ":: and (lambda x (if (car x) (car (cdr x)) False))")
(define test2 "std-out (p: (lambda x ((: (car (cadr x)) (car x)) (cdr (cadr x))) (() (1 2 3))))")

(define (popp x) (pop (ret-pop x)))
(define (poppp x) (pop (ret-pop (ret-pop x))))

(define funs* '())
(define imports* '())

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

(define (distrib var val lst) (map (λ (x)
  (cond [(list? x) (distrib var val x)] [(equal? x var) val] [else x])) lst))

(define (parse-expr s) (if (or (not (list? s)) (empty? s)) s (case (car s)
  [("std-add" "std-sub" "std-div" "std-mul") (if (length? s 3) (number->string
   ((case (car s) [("std-add") +] [("std-sub") -] [("std-mul") *] [("std-div") /]) 
    (string->number (parse-expr (pop (ret-pop s)))) (string->number (parse-expr (pop s)))))
   (fprintf o "ERROR: `~a' required length: 3, given: ~a.~n" (car s) (length s)))]
  [("car" "cdr") (if (length? s 2) ((case (car s) [("car") car] [("cdr") cdr]) (parse-expr (pop s))) 
                     (fprintf o "ERROR: `car' required length: 2, given ~a; also possible that given argument is not a list.~n" (length s)))]
  [("empty?") (if (length? s 2) (if (empty? (parse-expr (cadr s))) "True" "False") (fprintf o "ERROR: `empty?' required length: 2, given ~a." (length s)))]
  [("std-eq") (if (equal? (parse-expr (cadr s)) (parse-expr (caddr s))) "True" "False")]
  [(">codes") (map (λ (x) (number->string (char->integer x))) (string->list (parse-expr (cadr s))))]
  [(">chars") (list->string (map (λ (x) (integer->char (string->number x))) (parse-expr (cadr s))))]
  [("if") (if (length? s 4) (if (equal? (parse-expr (cadr s)) "False") (parse-expr (pop s)) (parse-expr (caddr s)))
              (fprintf o "ERROR: `if' required length: 4, given ~a.~n" (length s)))]
  [(">in") (read-line)] [(":") (if (length? s 3) (cons (parse-expr (cadr s)) (parse-expr (caddr s)))
                                   (fprintf o "ERROR: `:' required length: 3, given ~a.~n" (length s)))]
  [("p") (filter (λ (y) (not (equal? y "#DONE"))) (map (λ (x) (parse-expr x)) (cdr s)))]
  [("lambda") #;(lambda var expr val) (if (length? s 4)
   (parse-expr (distrib (second s) (fourth s) (third s))) s)]
  [("::") (begin (set! funs* (push funs* (cdr s))) "#DONE")] [("list?") (if (list? (cadr s)) "True" "False")]
  [("std-out") (begin (fprintf o "~a" (parse-expr (cadr s))) "#DONE")] [("gamma" "y." "γ") (cdr s)]
  [("!") (parse-expr (filter (λ (y) (not (equal? y "#DONE"))) (map (λ (x) (parse-expr x)) (cdr s))))]
  [("p:") (filter (λ (y) (not (equal? y "#DONE"))) (map (λ (x) (parse-expr x)) (parse-expr (cadr s))))]
  [("import") (if (member (pop s) imports*) '()
                  (begin (parse (readn (open-input-file (string-join (list (pop s) ".lm") "")) ""))
                         (set! imports* (push imports* (pop s))) "#DONE"))]
  [else (if (member (car s) (map car funs*)) (let ([f (find-eq (car s) car funs*)])
                                               (parse-expr (push (cadr f) (cdr s)))) s)])))

(define (parse l) (parse-expr (check-parens (string-split-spec l))))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating Elem REPL...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) 
                                                                           (if (empty? (string->list d)) '() (parse d)))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".lm") ""))])
    (parse (readn f "")))))

(main)