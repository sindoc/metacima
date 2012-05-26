#lang racket

(require
 metacima/common/syntax)

(provide
 (all-defined-out))

(define (true? x)
  (eq? x #t))

(define (symbol->keyword sym)
  (string->keyword (symbol->string sym)))

(define (map* n lst proc)
  (define lst-length (length lst))
  (cond 
    ((null? lst) lst)
    (else
     (unless (zero? (remainder lst-length n))
       (error 
        (string-append
         "map*: length of list should be a"
         " multiple of chunk size n:") 
        n lst-length lst))
     (let iter
       ((partial-lst lst))
       (cond
         ((null? partial-lst) partial-lst)
         (else
          (cons 
           (apply proc (take partial-lst n))
           (iter (drop partial-lst n)))))))))

(define (show . args)
  (for-each
   (λ (arg)
     (display arg)
     (display " "))
   args)
  (newline))

(define (zip lst (n 2))
  (map* n lst (λ args args)))

(define (map+ proc lst)
  (let ((i 0))
    (map
     (λ (e)
       (inc i 1)
       (proc i e))
     lst)))

(define (force-thunks thunks . args)
  (for-each (λ (thunk) (apply thunk args)) thunks))