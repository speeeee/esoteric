#lang racket/base
(require racket/list
         racket/string)
(provide populate apply-eq)

; model of the stack (bottom represents the top of the stack):
; () ~ List of typed literals (using :)
; () ~ List of equated literals (using =)
; the rest is just the stack itself.

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (popp x) (pop (ret-pop x)))
(define (poppp x) (pop (ret-pop (ret-pop x))))

(define assocs '())
(define eqs '())

(define fout '())

;(define test0 '((1 "First") (2 "Second")))
;(define test0-1 '(("Sum" ("$Sum" "First" "Second")))) ; (apply-eq "Sum"...)
;(define test1 '(() () ("$Sum" "First" "Second") "Sum" "(unify)")) ; populate ... '()
;(define test0 '(1 2 3)) ; distribute ... test0
;(define test1 '((a b 1) (a c b 2) (b 3))) ; factor '(a b) test1
(define test0 "1 2 1 <@")
(define test1 "1 2 [1 <@] 0 call@")
(define test2 "True a b ?")
(define test3 "swap [1 <@ [dr] 2 call@] :word 1 2 swap")
(define test4 "prelude :import 1 2 swap")
(define test5 "abc >codes")
(define test6 "prelude :import 1 2 over-unsafe")
(define test7 "(1 2)") (define test8 "((1 2) 3)") ;both need prelude

(define wrds* '())
(define imports* '())
(define o (current-output-port))

(define (readf f lst) (let ([c (read-line f)])
  (if (eof-object? c) (set! wrds* (append wrds* lst)) 
      (readf f (push lst (let ([d (check-parens (string-split-spec c))]) (list (car d) (cdr (second d)))))))))
(define (readn f str) (let ([c (read-line f)])
  (if (eof-object? c) str (readn f (string-join (list str c) " ")))))

(define (rem-at-index lst n)
  (map second (filter-not (λ (x) (= (car x) n)) (map (λ (y z) (list y z)) (range (length lst)) lst))))

(define (make-assoc! a b) (set! assocs (push assocs (list a b)))) ; : (For when the data is static)
(define (equate! a b) (set! eqs (push eqs (list a b)))) ; = (For when the data is not necessarily static)
(define (make-assoc a b lst) (push lst (list a b)))
(define (equate a b lst) (push lst (list b a)))

(define (apply-eq a lst eqs) ; a = the variable to be reviewed, lst = a list of variables possibly used in the equation.
                             ; e.g. a = Sum, lst = ((1 First) (2 Second))
  (let ([c (find-eq a car eqs)]) ; c = (Sum ($Sum First Second))
    (map (λ (x) (if (member x (map second lst)) (first (find-eq x second lst)) x)) (second c))))

(define (contains a lst) (not (empty? (filter (λ (x) (member x a)) lst))))

(define (distribute a lst) (map (λ (x) ((if (list? a) append cons) a (if (list? x) x (list x)))) lst))
(define (factor a lst) (map (λ (x) (if (contains a x) (filter (λ (y) (not (member y a))) x) "False")) lst))

(define (populate stk init) (foldl (λ (s n) ; when `!' is used
  (cond [(equal? s "(unify)") (append (list (car n) (push (cadr n) (list (pop n) (popp n)))) (cddr n))]
        [(equal? s "(assoc)") (append (list (push (car n) (list (pop n) (popp n))) (cadr n)) (cddr n))]
        [else (push n s)])) init stk))

(define (parse-expr stk init) (foldl (λ (s n)
  (case s [("@") (push (ret-pop (ret-pop n)) (list-ref (popp n) (string->number (pop n))))]
          [("<@") (let* ([b (- (length (ret-pop (ret-pop n))) (string->number (pop n)))]
                                [c (list-ref (ret-pop n) b)])
                           (push #;(rem-at-index (ret-pop n) b) (ret-pop n) c))]
          [("}") (push (ret-pop (ret-pop n)) (list (popp n) (pop n)))]
          [(":") (push (ret-pop (ret-pop n)) (append (list (popp n)) (pop n)))] [(equal? s "!") (append (ret-pop n) (pop n))]
          [("list?") (push (ret-pop n) (if (list? (pop n)) "True" "False"))]
          [("?") (push (ret-pop (ret-pop (ret-pop n))) (if (not (equal? (poppp n) "False")) (popp n) (pop n)))]
          [("dr") (ret-pop n)]
          [("=") (push (ret-pop (ret-pop n)) (if (equal? (pop n) (popp n)) "True" "False"))]
          [("call@") (let* ([m (- (length (ret-pop (ret-pop n))) (string->number (pop n)))]
                                   [a (take n m)] [b (drop (ret-pop (ret-pop n)) m)])
                              (append (parse-expr (cdr (popp n)) a) b))]
          [(":word") (begin (set! wrds* (push wrds* (list (popp n) (cdr (pop n)))))
                            #;(fprintf fout "~a [~a]~n" (popp n) (string-join (cdr (pop n)) " ")) '())]
          [(":import") (if (member (pop n) imports*) '()
                           (begin (parse (readn (open-input-file (string-join (list (pop n) ".ul") "")) ""))
                                  (set! imports* (push imports* (pop n))) '()))]
          [("out") (begin (fprintf o (pop n)) (ret-pop n))]
          [(">codes") (push (ret-pop n) (append (list "List") (map (λ (x) (number->string (char->integer x))) (string->list (pop n)))))]
          [(">chars") (push (ret-pop n) (list->string (map (λ (x) (integer->char (string->number x))) (cdr (pop n)))))]
          [("add" "sub" "div" "mul") (push (take n (- (length n) 2)) (number->string
           ((case s [("add") +] [("sub") -] [("mul") *] [("div") /]) (string->number (pop (ret-pop n))) (string->number (pop n)))))]
          [("#LEN") (push n (number->string (length n)))] [("out-rt") (begin (fprintf (current-output-port) (pop n)) (ret-pop n))]
          ;[(map car wrds*) (parse-expr (second (find-eq s car wrds*)) n)]
          [else (if (member s (map car wrds*)) (parse-expr (second (find-eq s car wrds*)) n) (push n s))])) init stk))
        

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'com) (if (equal? s #\~) (second n) n)]
        [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\])) (append n (list (list s)) (list '()))]
        [(equal? s #\~) (list 'com n)]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (member elt '( "]")))) (push n elt)
      (let* ([c (case elt [("]") "["] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) 
              ((λ (x) (if (equal? elt "]") (cons "quot:" x) x)) (reverse (takef (reverse n) expr))))))) '() lst))

(define (parse l) (parse-expr (check-parens (string-split-spec l)) '()))

(define (main) (if (= (length (vector->list (current-command-line-arguments))) 0)
  (begin (fprintf o "Initiating ulang REPL...~nPress ENTER/RETURN once a command is entered.  Enter the command, `:q', to quit.~n")
         #;(set! fout (open-output-file "repl-temp.ufns" #:exists 'replace))
         (let main () (begin (fprintf o "~n> ") (let ([d (read-line)]) (if (or (equal? d ":q") (eof-object? d)) 
                                                                           (begin (displayln "quitting") (exit)) (parse d))) (main))))
  (let* ([c (vector->list (current-command-line-arguments))] [f (open-input-file (string-join (list (car c) ".ul") ""))])
    #;(set! fout (open-output-file (string-join (list (car c) ".ufns") "") #:exists 'replace)) (parse (readn f "")))))

(main)