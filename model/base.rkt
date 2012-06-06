#lang racket

(require
 "../orm/base.rkt")

(provide (all-defined-out))

(define person%
  (class model%
    (init-model
     (table 'people))
    (field* firstname)
    (field* surname)))

(define role%
  (class model%
    (init-model
     (table 'roles))
    (field* movie movie%)
    (field* actor person% 
            ((join many-to-many)))
    (field* character person%)))

(define movie%
  (class model%
    (init-model 
     (table 'movies))
    (field* title 'string)
    (field* year 'integer)
    (field* 
     cast person% 
     ((join one-to-many)))))