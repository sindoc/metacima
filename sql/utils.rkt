#lang racket

(provide
 (all-defined-out))

(define (->sql thing)
  (cond
    ((symbol? thing)
     (case thing
       ((integer) "INTEGER")
       ((text) "TEXT")
       ((string) "VARCHAR(255)")
       ((primary-key) "PRIMARY KEY")
       (else
        (error "Wrong literal to convert: " thing))))
    ((class? thing)
     " ")
    (else
     (error "Cannot convert object" thing))))