#lang racket/base
(require racket/list
         racket/string)

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

(define test0 (apply-eq "Sum" '((1 "First") (2 "Second")) '(("Sum" ("$Sum" "First" "Second")))))

(define (make-assoc! a b) (set! assocs (push assocs (list a b)))) ; : (For when the data is static)
(define (equate! a b) (set! eqs (push eqs (list a b)))) ; = (For when the data is not necessarily static)
(define (make-assoc a b lst) (push lst (list a b)))
(define (equate a b lst) (push lst (list b a)))

(define (apply-eq a lst eqs) ; a = the variable to be reviewed, lst = a list of variables possibly used in the equation.
                             ; e.g. a = Sum, lst = ((1 First) (2 Second))
  (let ([c (find-eq a car eqs)]) ; c = (Sum ($Sum First Second))
    (map (λ (x) (if (member x (map second lst)) (first (find-eq x second lst)) x)) (second c))))

(define (populate stk lst eqs) (foldl (λ (s n) ; when `!' is used
  (cond [(equal? s "(unify)") (

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\])) (append n (list (list s)) (list '()))]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (member elt '(")" "]")))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) 
              ((λ (x) (if (equal? elt "]") (cons "quot:" x) x)) (reverse (takef (reverse n) expr))))))) '() lst))

(define (parse l) (check-parens (string-split-spec l)))