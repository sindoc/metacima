#lang racket

(require
 "syntax.rkt")

(provide (all-defined-out))


(define observable%
  (class object%
    (super-new)    
    (define observers- null)
    (define/public (add-observer observer)
      (set! observers- (cons observer observers-)))
    (define/public (get-observers) observers-)
    (define/public (notify)
      (for-each
       (lambda (observer)
         (send observer update this))
       observers-))))

(define model%
  (class observable% 
    (super-new)))

(define person%
  (class model%
    (init-model)
    (field* firstname)
    (field* lastname)
    (field* middlename optional)))

(define movie%
  (class model%
    (init-model)
    (field* title)
    (field* year)
    (field* runtime)
  ))