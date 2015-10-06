#lang racket
(require racket/list
         racket/string)

(define o (current-output-port))

; works on Mac OSX where the wav files loaded have the data at the 36th byte
; and beyond as well as use only one channel.

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (pop (second n))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\')) (append n (list (list s)) (list '()))]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (member elt '(")" "]")))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) 
              ((λ (x) (if (equal? elt "]") (cons "quot:" x) x)) (reverse (takef (reverse n) expr))))))) '() lst))

(define afuns '("+" "-" "*" "/" "dup" "swap" "drop" "import"))
(define pfuns '(#| w x y -- w' |# "sample" #| w1 w2 -- w1212.. |# "concur"
                #| w sh -- w*sh |# "shift" #| f -- w |# "wav"))
(define wrds* '())

(define (call-a s n) (case s 
  [("+" "-" "/" "*") 
   (push (take n (- (length n) 2)) (number->string
         ((case s [("+") +] [("-") -] [("*") *] [("/") /]) (string->number (pop (ret-pop n))) (string->number (pop n)))))]
  [("dup") (push n (pop n))] [("swap") (append (ret-pop (ret-pop n)) (list (pop n) (pop (ret-pop n))))]
  [("drop") (ret-pop n)]))

(define (parse-expr lst init) (foldl (λ (s n) 
  (cond [(member s afuns) (call-a s n)]
        ;[(member s pfuns) (call-p s n)]
        [else (push n s)])) init lst))

(define (parse l) (parse-expr (check-parens (string-split-spec l)) '()))
