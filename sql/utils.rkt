#lang racket

(provide
 (all-defined-out))

(define (->sql literal)
  (case literal
    ((integer) "INTEGER")
    ((text) "TEXT")
    ((string) "VARCHAR(255)")
    ((primary-key) "PRIMARY KEY")
    (else
     (error "Wrong literal to convert: " literal))))