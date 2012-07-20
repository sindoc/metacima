#lang racket

(require
 "base.rkt"
 "connection-pool.rkt"
 "../common/utils/base.rkt"
 "../sql/base.rkt"
 "../common/utils/debug.rkt")

(provide bootstrap)

(define (bootstrap objects)
  (define statements
    (map
     (λ (object)
       (unless (is-a? object persistable<%>)
         (error 
          (format 
           "Only persistable objects can be bootstrapped; were given: ~a" object)))
       (let ((name (send object sql-name))
             (table-spec (send object sql-table-spec)))
         (list
          (drop-table name)
          (create-table name table-spec)
          (insert name)
          (insert name)
          (insert name))))
     objects))
  (define pool (get-connection-pool))
  (define dbc (connection-pool-lease pool))
  (dbg 'bootstrap statements)
  (for-each
   (λ (sub-statements)
     (call-with-transaction
      dbc
      (λ ()
        (force-thunks sub-statements dbc))))
   statements)
  (disconnect dbc))