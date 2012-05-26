#lang racket

(require
 "private/struct.rkt"
 db
 metacima/common/utils/base
 metacima/common/utils/debug
 (prefix-in : "private/base.rkt"))

(provide 
 (all-defined-out))

(define (exec statement connection)
  (dbg 'executing statement)
  (query-exec connection (prepare connection statement)))

(define (primary-key? col)
  (eq? (list-ref col 2) 'primary-key))

(define (create-table 
         name  
         cols
         #:ignore-if-exists? (ignore-if-exists #t))
  (define stmt
    (:create-table
     (make-create-table-statement
      name
      (map
       (λ (col)
         (cond 
           ((null? col)
            (error "Column definition required"))
           ((null? (cdr col))
            (error "Column type required"))
           (else
            (let ((options 
                   (flatten
                    (sort
                     (zip (cddr col) 2)
                     (λ (a b)
                       (keyword<? a b))))))
              (define option-kws (filter keyword? options))
              (define option-vals (filter (λ (x) (not (keyword? x))) options))
              (dbg 'cool-1 options option-kws option-vals)
              (keyword-apply
               make-column-def
               option-kws
               option-vals
               (take col 2))))))
       cols)
      #:ignore-if-exists? ignore-if-exists)))
  (λ (conn)
    (exec stmt conn)))

(define (drop-table 
         name
         #:only-if-exists? (if-exists #t))
  (define stmt
    (:drop-table
     (make-drop-table-statement
      name
      #:only-if-exists? if-exists)))
  (λ (conn)
    (exec stmt conn)))

(define (insert
         table-name
         #:populate-with-defaults? (default? #t))
  (define stmt
    (:insert
     (make-insert-statement
      table-name
      #:populate-with-defaults? default? #t)))
  (λ (conn)
    (exec stmt conn)))