#lang racket
(require racket/list
         racket/string)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define words (list (list "+" "Fun")))
(define ruls '((("str-numeric?") ("Num" "2" "n$"))))
(define prims '("#STK" "n$" "!" "str-numeric?" "str-symbolic?"
                "add" "sub" "div" "mul"))

(define test0 "1 2 3 2 n$")
(define test1 "1 2 2 (n$) !")
(define test2 "1 2 add 3 4 add add")

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (quoti (pop (second n)))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\: #\')) (append n (list (list s)) (list '()))]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (lex s)
  (cond ; [(member s (list "(" ")" "{" "}" "[" "]")) s]
        ; [(member s (map car words)) (find-eq s car words)] 
        ; [(char-numeric? (strcar s)) (list s "Int")] [(equal? (strcar s) #\") (list s "String")] 
        [else s]))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) (reverse (takef (reverse n) expr)))))) '() lst))

(define (call stk c) (parse-expr c stk))

; n$ ! str-numeric? str-symbolic? :rule
(define (call-prim stk s) (case s 
  [("#STK") (push stk (number->string (length stk)))]
  [("n$") (push (take stk (- (length stk) (string->number (pop stk)) 1))
                (ret-pop (drop stk (- (length stk) (string->number (pop stk)) 1))))] 
  [("!") (parse-expr (pop stk) (ret-pop stk))] [("str-numeric?") (push (ret-pop stk) (char-numeric? (strcar (pop stk))))]
  [("add" "sub" "div" "mul") 
   (push (take stk (- (length stk) 2)) (number->string
         ((case s [("add") +] [("sub") -] [("mul") *] [("div") /]) (string->number (pop (ret-pop stk))) (string->number (pop stk)))))]))
          

(define (parse-expr stk init) (displayln init) (foldl (λ (s n)
  (cond [(member s prims) (call-prim n s)]
        #;[(ormap (λ (x) (pop (call (push n s) x))) (map car ruls))
         (call (push n s) (second (findf (λ (x) (pop (call (push n s) (car x)))) ruls)))]
        [else (push n s)])) init stk))

(define (parse l) (parse-expr (check-parens (map lex (string-split-spec l))) '()))