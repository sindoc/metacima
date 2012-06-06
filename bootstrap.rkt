#lang racket

(require
 "common/syntax.rkt")

(provide
 (all-defined-out))

(define (bootstrap qs)
  
  (define (add statement)
    (push qs statement))
  
  (add
   (format
    (string-append
     "CREATE TABLE ~a IF NOT EXISTS"
     "")
    "name"))
  
  qs)