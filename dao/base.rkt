#lang racket

(require 
 (prefix-in sql: "../sql/base.rkt")
 (prefix-in model: "../model/base.rkt")
 "../common/utils/debug.rkt"
 "../common/utils/base.rkt"
 "connection-pool.rkt"
 "../orm/public.rkt")

(provide (all-defined-out))

(define (get-connection)
  (connection-pool-lease (get-connection-pool)))

(define (run 
         #:exec (exec sql:query-exec) 
         #:atomic (atomic? #t) 
         #:connection (connection (get-connection)) 
         . queries)
  (define (run-promise) (force-thunks (flatten queries) connection exec))
  (dbg 'sql-run queries)
  (if (true? atomic?)
      (sql:call-with-transaction connection run-promise)
      (run-promise)))

(define statements null)

(define-syntax (push stx)
  (syntax-case stx ()
    ((_ lst e)
     #'(set! lst (cons e lst)))))
      
(define (make-movie #:title title #:year year #:cast cast)
  (make-object model:movie% 'no-id-assigned-yet title year cast))

(define (make-person #:firstname fn #:surname sn)
  (make-object model:person% 'no-id-assigned-yet fn sn))

(define dao% (class object% (super-new)))

(define (create-tables model)
  (define table (send model orm:table))
  (define cols (orm-table-columns table))
  void)

(define (bootstrap-db . objects)
  (for-each
   (λ (unique-object)
     (unless (is-a? unique-object model%)
       (error "Only instances of model% can be bootstrapped, given " unique-object))
     (create-tables unique-object))
   (remove-duplicates objects #:key (λ (x) (object-name x)))))

(define-values
  (p1)
  (values
   (make-person #:firstname "Sina" #:surname "Khakbaz Heshmati")))

(define-values
  (m1 m2)
  (values
   (make-movie #:title "A Separation" #:year 2010 #:cast (list p1))
   (make-movie #:title "Baaraan" #:year 2000 #:cast (list p1))))

(bootstrap-db p1 m1 m2)