#lang racket

(define-syntax (bind-fields stx)
  (syntax-case stx ()
    ((_ mappings  
        field ...)
     
        