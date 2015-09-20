#lang racket
(require racket/list
         racket/string
         racket/function)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define wrds '(("num" (("str-numeric?") ("Num" "2" "n$") () "?"))))
(define prims '("#STK" "n$" "!" "str-numeric?" "str-symbolic?"
                "add" "sub" "div" "mul" "?" "=" "cmp" "not"
                "@" "push" "drop" "dup" "swap" ":word"))

(define test0 "1 2 3 2 n$")
(define test1 "1 2 2 [n$] !")
(define test2 "1 2 add 3 4 add add")
(define test3 "1 num 2 num 2 n$")
(define test4 "1 cmp") (define test5 "e [2.718] :word")
(define test6 "[1 cmp 1 =] [2] [3] ?")
(define test7 "(1 2 3) num")

(define o (current-output-port))

(define (quoti lst) (append (list #\") (push lst #\")))
(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (quoti (pop (second n)))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\')) (append n (list (list s)) (list '()))]
        [(char-whitespace? s) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (lex s)
  (cond ; [(member s (list "(" ")" "{" "}" "[" "]")) s]
        ; [(member s (map car words)) (find-eq s car words)] 
        ; [(char-numeric? (strcar s)) (list s "Int")] [(equal? (strcar s) #\") (list s "String")] 
        [else s]))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (member elt '(")" "]")))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) 
              ((λ (x) (if (equal? elt "]") (cons "quot:" x) x)) (reverse (takef (reverse n) expr))))))) '() lst))

(define (call stk c) (parse-expr (cdr c) stk))

; n$ ! str-numeric? str-symbolic? :rule
(define (call-prim stk s) (case s 
  [("#STK") (push stk (number->string (length stk)))]
  [("n$") (push (take stk (- (length stk) (string->number (pop stk)) 1))
                (ret-pop (drop stk (- (length stk) (string->number (pop stk)) 1))))] 
  [("!") (parse-expr (cdr (pop stk)) (ret-pop stk))] [("str-numeric?") (push (ret-pop stk) (char-numeric? (strcar (pop stk))))]
  [("add" "sub" "div" "mul") 
   (push (take stk (- (length stk) 2)) (number->string
         ((case s [("add") +] [("sub") -] [("mul") *] [("div") /]) (string->number (pop (ret-pop stk))) (string->number (pop stk)))))]
  [("?") (let ([lst (take stk (- (length stk) 3))])
           (if (call lst (caddr (reverse stk))) (call lst (cadr (reverse stk))) (call lst (pop stk))))]
  [("=") (push (take stk (- (length stk) 2)) (equal? (cadr (reverse stk)) (pop stk)))] [("cmp") (push (ret-pop stk) (cond [(> (string->number (pop stk)) 0) "1"]
                                                                                                     [(< (string->number (pop stk)) 0) "-1"]
                                                                                                     [else "0"]))]
  [(":word") (begin (set! wrds (push wrds (list (cadr (reverse stk)) (cdr (pop stk))))) (take stk (- (length stk) 2)))]
  [("@") (push (take stk (- (length stk) 2)) (list-ref (cadr (reverse stk)) (string->number (pop stk))))]
  [("push") (push (take stk (- (length stk) 2)) (push (cadr (reverse stk)) (pop stk)))]
  [("drop") (ret-pop stk)] [("dup") (append (ret-pop stk) (list (pop stk) (pop stk)))]
  [("swap") (append (take stk (- (length stk) 2)) (list (pop stk) (cadr (reverse stk))))]))

; same as `call-prim', but outputs C++ instead.
(define (call-prim-cpp stk s) (case s
  [("#STK") (fprintf o "push_int(stk.size());~n")]
  [("n$") (begin (map out stk) (fprintf o "RSTK_GET_ELEM();~n"))]))

(define (list->str lst) (foldl (λ (l s) (string-append s l)) "" lst))
(define (lit x) (format "(Lit) { ~a"
  (if (list? x) (format "\"\", new list<Lit> });~n~a" 
        (list->str (map (λ (y) (format "stk.top->lst.push_back(~a);~n" (lit y))) x)))
      (format "\"~a\", NULL }" x))))
(define (out x) (fprintf o "stk.push(~a"
                  (if (list? x) (lit x)
                      (format "(Lit) { \"~a\", NULL });~n" x))))

(define (parse-expr stk init) (foldl (λ (s n)
  (cond [(member s prims) (call-prim-cpp n s)]
        [(member s (map car wrds)) (begin (map out #;(λ (x) (fprintf o "stk.push(~a"
                                                               (if (list? x) (lit x)
                                                                   (format "(Lit) { \"~a\", NULL });~n" x)))) n)
                                          (fprintf o "~a();~n" s) '())]
                                   #;(call n (second (find-eq s car wrds)))
        #;[(ormap (λ (x) (pop (call (push n s) x))) (map car ruls))
         (call (push n s) (second (findf (λ (x) (pop (call (push n s) (car x)))) ruls)))]
        [else (push n s)])) init stk))

(define (parse l) (parse-expr (check-parens (map lex (string-split-spec l))) '()))