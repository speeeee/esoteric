#lang racket
(require racket/list
         racket/string)

(define o (current-output-port))
(define new-wav "target.wav")

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

(define afuns '("+" "-" "*" "/" "dup" "swap" "drop" "import" ":word"))
(define pfuns '(#| w x y -- w' |# "sample" #| w1 w2 -- w1212.. |# "concur"
                #| w sh -- w*sh |# "shift" #| f -- w |# "wav"))
(define wrds* '())

(define (in-block s)
  (map (λ (x) (fprintf o x s)) '("FILE *~a;~n" "fopen(\"~a.wav\", \"rb\");~n" "fseek(~a,0,SEEK_END);~n" "long ~asz = " "ftell(~a);~n"
                                 "rewind(~a);~n" "fseek(~a,44,SEEK_SET);~n" "short *~abuf;~n" "~abuf = malloc(sizeof(short)*" 
                                 "(~asz-44)/2);~n" "size_t ~ar = fread" "(~abuf,2," "~asz," "~a);~n"
                                 "fclose(~a);~n")))

(define (call-a s n) (case s 
  [("+" "-" "/" "*") 
   (push (take n (- (length n) 2)) (number->string
         ((case s [("+") +] [("-") -] [("*") *] [("/") /]) (string->number (pop (ret-pop n))) (string->number (pop n)))))]
  [("dup") (push n (pop n))] [("swap") (append (ret-pop (ret-pop n)) (list (pop n) (pop (ret-pop n))))]
  [("drop") (ret-pop n)]))
(define (call-p s n) (case s
  [("wav") (begin (in-block (pop n)) #;(fprintf o "FILE *~a;~n fopen(\"~a.wav\", \"rb\");~n"
                           (pop n) (pop n))
                  (push (ret-pop n) (list 'wav (pop n))))]
  [("sample") (push (take n (- (length n) 3)) (list 'sample (pop (ret-pop (ret-pop n))) (pop (ret-pop n)) (pop n)))]
  [("concur") (push (ret-pop (ret-pop n)) (list 'concur (pop (ret-pop n)) (pop n)))]
  [else "oops"]))

(define (parse-expr lst init) (foldl (λ (s n) 
  (cond [(member s afuns) (call-a s n)]
        [(member s pfuns) (call-p s n)]
        [else (push n s)])) init lst))

(define (parse l) (parse-expr (check-parens (string-split-spec l)) '()))
