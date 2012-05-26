#lang racket

(require "base.rkt")

(provide (all-defined-out))

(define (keyword-apply- proc pool)
  
  (define sorted-pool 
    (sort pool (λ (a b)
                 (keyword<? (car a) (car b)))))
  
  (define kws (map car sorted-pool))
  (define non-kws (map cadr sorted-pool))
  (define kws-count (length kws))
  (define kargs (take non-kws kws-count))
  (define pargs (drop non-kws kws-count))
  
  (keyword-apply proc kws kargs pargs))