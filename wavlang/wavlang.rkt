#lang racket
(require racket/list
         racket/string
         racket/function)

(define o (current-output-port))
(define new-wav "target.wav")

; works on Mac OSX where the wav files loaded have the data at the 36th byte
; and beyond as well as use only one channel.

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (popp x) (pop (ret-pop x)))
(define (poppp x) (pop (ret-pop (ret-pop x))))
(define (&& a b) (and a b)) (define (|| a b) (or a b))

(define test0 "hi (+) :word 1 2 hi")
(define test1 "aa wav 3 2 / shift bb wav 1 120 sample cc wav concur concur")

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

(define afuns '("+" "-" "*" "/" "=" ">" "<" "and" "or" "?" "dup" "swap" "drop" "import"))
(define pfuns '(#| w x y -- w' |# "sample" #| w1 w2 -- w1212.. |# "concur"
                #| w sh -- w*sh |# "shift" #| f -- w |# "wav"))
(define wrds* '()) (define wavs* '())

(define (in-block s)
  (map (λ (x) (fprintf o x s)) '("FILE *~a;~n" "fopen(\"~a.wav\", \"rb\");~n" "fseek(~a,0,SEEK_END);~n" "long ~asz = " "(ftell(~a)-44)/2;~n"
                                 "rewind(~a);~n" "fseek(~a,44,SEEK_SET);~n" "short *~adat;~n" "~adat = malloc(sizeof(short)*" 
                                 "~asz);~n" "size_t ~ar = fread" "(~abuf,2," "~asz*2+44," "~a);~n"
                                 "fclose(~a);~n")))

(define (make-header)
  (fprintf o "FILE *f = f = fopen(\"~a.wav\",\"w\");~n" new-wav)
  (map (λ (x) (fprintf o x)) '("fwrite(\"RIFF\", 1, 4, f);~n" "write_little_endian(36 + 2*tsz, 4, f);~n"
    "fwrite(\"WAVE\", 1, 4, f);~n" "fwrite(\"fmt \", 1, 4, f);~n" "write_little_endian(16, 4, f);~n"
    "write_little_endian(1, 2, f);~n" "write_little_endian(1, 2, f);~n" "write_little_endian(44100, 4, f);~n"
    "write_little_endian(88200, 4, f);~n" "write_little_endian(2, 2, f);~n" "write_little_endian(16, 2, f);~n"))) 
(define (get-tsz) (fprintf o "long tsz = ")
  (map (λ (x) (fprintf o "~asz*" x)) wavs*) (fprintf o "1;~n"))


(define (call-a s n) (case s 
  [("+" "-" "/" "*") 
   (push (take n (- (length n) 2)) (number->string
         ((case s [("+") +] [("-") -] [("*") *] [("/") /]) (string->number (pop (ret-pop n))) (string->number (pop n)))))]
  [(">" "<")
   (push (take n (- (length n) 2))
         ((case s [(">") >] [("<") <]) (string->number (pop (ret-pop n)) (string->number (pop n)))))]
  [("=" "and" "or")
   (push (take n (- (length n) 2))
         ((case s [("=") equal?] [("and") &&] [("or") ||]) (pop (ret-pop n)) (pop n)))]
  [("?") (let ([cnd (poppp n)] [t (popp n)] [f (pop n)])
     (parse-expr (if cnd t f) (take n (- (length n) 3))))]
  [("dup") (push n (pop n))] [("swap") (append (ret-pop (ret-pop n)) (list (pop n) (pop (ret-pop n))))]
  [("drop") (ret-pop n)]))
(define (call-p s n) (case s
  [("wav") (begin (set! wavs* (push wavs* (pop n))) (in-block (pop n)) ; return pointer to sample.
                  (push (ret-pop n) (list 'wav (pop n))))]
  [("sample") ; replace the three items on the stack with a pointer to the new sample.
   (let ([d (pop n)] [c (popp n)] [name (second (poppp n))])
     (fprintf o "long ~assz = ~a-~a;~n" name d c)
     (fprintf o "int *~asdat = malloc(sizeof(int)*~assz)" name name)
     (fprintf o "for(int i=~a; i<~a; i++) {~n~asdat[i-~a] = ~adat[i]; }~n" c d name c name)
     (push (take n (- (length n) 3)) (list 'sample (format "~as" name))))]
  [("shift") (let ([c (pop n)] [name (second (popp n))])
     (fprintf o "long ~ashsz = ~asz*~a;~n" name name (/ 1 (string->number c)))
     (fprintf o "int ~ashdat = malloc(sizeof(int)*~ashsz);~n" name name)
     (fprintf o "for(int i=0; i<~ashsz; i++) { ~ashdat[i] = ~adat[i*~a]; }~n"
              name name name c) (push (ret-pop (ret-pop n)) (list 'shift (format "~ash" name))))]
  [("concur") ; replace the two chosen wavs and return a pointer with the two playing concurrently.
   (let ([n2 (second (pop n))] [n1 (second (popp n))])
     (fprintf o "long ~a_~asz = ~asz+~asz;~n" n1 n2 n1 n2)
     (fprintf o "int ~a_~adat = malloc(sizeof(int)*~a_~asz)~n" n1 n2 n1 n2)
     (fprintf o "for(int i=0; i<~a_~asz; i+=2) { ~a_~adat[i] = ~adat[i]; ~a_~adat[i+1] = ~adat[i]; }~n"
              n1 n2 n1 n2 n1 n1 n2 n2)
     (push (ret-pop (ret-pop n)) (list 'concur (format "~a_~a" n1 n2))))]
  [else "oops"]))

(define (out n)
  (make-header) (fprintf o "fwrite(\"data\", 1, 4, f);~nwrite_little_endian(")
  (map (λ (x) (fprintf o "~asz+" x)) n) (fprintf o "*1, 4, f);~n")
  (map (λ (x) (fprintf o "for(int i=0; i<~asz; i++) { write_little_endian((unsigned int)(~adat[i]),2,f); }~n" x)) n)
  (fprintf o "fclose(f);~n"))

(define (mk-word n) (set! wrds* (push wrds* (list (popp n) (pop n)))))

(define (parse-expr lst init) (foldl (λ (s n) 
  (cond [(member s afuns) (call-a s n)]
        [(member s pfuns) (call-p s n)]
        [(member s (map car wrds*)) (let ([e (findf (λ (x) (equal? (car x) s)) wrds*)]) (parse-expr (second e) n))]
        [(equal? s ":word") (begin (mk-word n) '())]
        [else (push n s)])) init lst))

(define (out-lst lst) (make-header) (get-tsz) (map (λ (x)
  (cond [(not (list? x)) (displayln x)]
        [(equal? (car x) 'wav) (in-block (second x))]
        [(equal? (car x) 'sample) (let ([c (second x)])
           (fprintf o "int *~asdat = malloc(sizeof(int)*(~a-~a))"
                    c (fourth x) (third x))
           (fprintf o "for(int i=~a; i<~a; i++) {~n~adat[i] = ~abuf[i]; }~n"
                    (fourth x) (third x) c c))]
        [(equal? (car x) 'shift) (let ([c (second x)])
           (fprintf o "int ~ashdat = malloc(sizeof(int)*(~asz-44)*~a);~n" c c (/ 1 (number->string (third x))))
           (fprintf o "for(int i=0; i<(~asz-44)*~a; i++) { ~adat[i] = ~abuf[i*~a]; }~n"
                    c (/ 1 (number->string (third x))) c c (third x)))]
        [(equal? (car x) 'concur) (let ([c (second x)] [d (third x)])
           (fprintf o "int ~a_~adat = malloc(sizeof(int)*(~asz+~asz))~n" c d c d)
           (fprintf o "for(int i=0; i<(~asz+~asz); i+=2) { ~a_~adat[i] = ~abuf[i]; ~a_~adat[i+1] = ~abuf[i]; }~n"
                    c d c d c c d d))])) lst))

(define (parse l) (parse-expr (check-parens (string-split-spec l)) '()))

(define (out-top) (fprintf o "#include <stdlib.h>~n#include <stdio.h>~n~n")
  (fprintf o "void write_little_endian(unsigned int word, int num_bytes, FILE *wav_file) {~n
unsigned buf;~nwhile(num_bytes>0)~n
    { buf = word & 0xff;
      fwrite(&buf, 1,1, wav_file);
      num_bytes--;
      word >>= 8;
    } }~n~n")
  (fprintf o "int main(int argc, char **argv) {~n"))

(define (readf f str) (let ([c (read-char f)])
  (if (eof-object? c) str (readf f (push str c)))))
  
(define (main) (displayln wrds*)
  (displayln (parse (read-line))) (main))

(define (main2) (out-top)
  (let ([f (open-input-file (string-join (list (car (vector->list (current-command-line-arguments))) ".wl") ""))])
    (set! o (open-output-file (string-join (list (second (vector->list (current-command-line-arguments))) ".c") ""))) 
    (parse (list->string (readf f '())))) (fprintf o "return 0; }~n"))

(main)