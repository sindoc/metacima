#lang racket

(require
 metacima/common/utils/base)

(provide dbg)

(define dbg? #f)
;(define dbg? #t)

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
