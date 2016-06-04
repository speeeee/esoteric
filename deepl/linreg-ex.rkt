#lang racket

(define ø0 0)
(define ø1 0)

; this file should be ignored.

; hø(x) = ø0 + ø1x1
; J(ø) = 1/2(hø(x)-y)^2

; needs rescaling.

(define ß 0.00001)
(define tset '((180 1100) (120 900) (140 1000) (12 17.5) (138 707)
                          (127 900) (189 1000) (187 1200) (49 210)))
(define bset '((100 0) (200 0) (300 0) (400 0) (500 0) (600 1) (700 1) (800 1)
                        (900 1) (1000 1))) ;(395 1) (390 0) (240 0)))
; m = 13

;(define (hø x) (+ ø0 (* ø1 x)))
(define (z x) (+ ø0 (* ø1 x)))
(define (hø x) (/ 1 (+ 1 (exp (- (z x))))))

(for ([i (range 200000)]) ;(displayln ø0)
  (set! ø0 (+ ø0 (* ß (foldr (λ (q p) (+ p (- (cadr q) (hø (car q))))) 0 bset))))
  (set! ø1 (+ ø1 (* ß (foldr
    (λ (q p) (+ p (* (- (cadr q) (hø (car q))) (car q)))) 0 bset)))))