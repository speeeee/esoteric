#lang racket/base
(require racket/list
         racket/string
         racket/contract/base)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (quoti lst) (append (list #\") (push lst #\")))

(define funs (list (list "add" 2) (list "mul" 2) (list "div" 2)))
(define afuns (list "call"))

(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (quoti (pop (second n)))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\:)) (append n (list (list s)) (list '()))]
        [(equal? s #\,) (append n (list '()))]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) (reverse (takef (reverse n) expr)))))) '() lst))

(define (lex s)
  (cond [(member s (list "(" ")" "{" "}" "[" "]")) s]
        [(member s (map second funs)) (find-eq s second funs)] 
        [(char-numeric? (strcar s)) (string->number s)] ;[(equal? (strcar s) #\") (list s "String")] 
        [else s]))

(define (take-contiguous-x x lst) 
  (takef (dropf (reverse lst) (λ (y) (not (equal? (caar y) x))))
         (λ (y) (not (equal? (caadr y) "break")))))

(define (into-list lst) (foldl (λ (x n) 
  (if ((listof number?) x) (push n (list x)) (push (ret-pop n) (push (pop n) x))))
  '() (filter (λ (x) (not (equal? x "#"))) lst)))

#;(define (parse lst) (map (λ (x)
  ())))

(define (parse l) (into-list (check-parens (map lex (string-split-spec l)))))
