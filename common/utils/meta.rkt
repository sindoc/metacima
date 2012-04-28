#lang racket

(require
 metacima/common/utils/base
 metacima/common/utils/debug)

(provide keyword-apply-)

(define (keyword-apply- proc pool)
  
  (define (comparator a b)
    (dbg 'comparator a b)
    (string<? 
     (keyword->string (car a))
     (keyword->string (car b))))
  
  (define sorted-pool 
    (sort pool comparator))
  
  (define kws (map car sorted-pool))
  (define non-kws (map cadr sorted-pool))
  
  (define kws-count (length kws))
  (define kargs (take non-kws kws-count))
  (define pargs (drop non-kws kws-count))

  (dbg 'keyword-apply- proc pool 
       sorted-pool kws non-kws kws-count kargs pargs)
  
  (keyword-apply proc kws kargs pargs))