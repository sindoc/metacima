#lang racket

(require
 "base.rkt")

(provide dbg)

(define dbg? #t)
;(define dbg? #f)

(define-syntax (dbg stx)
  (syntax-case stx ()
    ((_ context arg ...)
     #'(when dbg?
         (show 
          context
          "\n"
          'arg ... 
          "\n"
          arg ...
          "\n")))))
