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
  (connection-pool-lease 
   (get-connection-pool)))

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

(define (insert table-name column-names column-values)
  (define (normalize value)
    (dbg 'insert-normalize value)
    (cond
      ((is-a? value model%)
      (model->table
       value
       (λ (table _ col-names col-values)
         (set! deps 
               (cons
                (insert (orm-table-name table) col-names col-values)
                deps)))))
      ((list? value) 
       (for-each 
        (λ (val)
          (normalize val))
        value))
      (else value)))
  (set!
   deps
   (cons
    (sql:insert table-name column-names 
                (map normalize column-values))
    deps))
  (dbg 'insert deps)
  deps)

(define (create-table model)
  void)

(define (model->table object proc)
  
  (define (create-mapping-filter orm-col mapping-type)
    (dbg 'create-mapping-filter (orm-mapping orm-col))
    (let ((mapping (orm-column-mapping orm-col)))
      (if (false? (orm-column-mapping orm-col))
          #f
          (eq? (orm-mapping-type mapping) mapping-type))))
  
  (define (one-to-many? col)
    (create-mapping-filter col 'one-to-many))
  
  (define (orm-col->sql-col source)
    (define name (orm-column-name source))
    (define type (orm-column-type source))
    (define id? (orm-column-id? source))
    (define mapping (orm-column-mapping source))
    (dbg 'convert-orm-to-sql name type mapping)
    (append
     (list name)
     (if (true? id?) null (list type))
     (if (true? id?)
         '(integer #:primary-key? #t) null)))
     
  (define (id? orm-col)
    (true? (orm-column-id? orm-col)))
  
  (define (col-filter-create orm-col)
    (cond
      ((id? orm-col) #t)
      (else
       (col-filter orm-col))))
  
  (define (col-filter orm-col)
    (cond
      ((id? orm-col) #f)
      ((false? (orm-column-mapping orm-col)) #t)
      ((one-to-many? orm-col) #f)))
  
  (define table (send object orm:table))
  (define table-name (orm-table-name table))
  (define cols (orm-table-columns table))
  (define filtered-cols (filter col-filter cols))
  (define col-defs (map orm-col->sql-col (filter col-filter-create cols)))
  (define col-names (map orm-column-name filtered-cols))
  (define col-values (map orm-column-value filtered-cols))
  (proc table col-defs col-names col-values))

(define (bootstrap-db . objects)
  (for-each
   (λ (unique-object)
     (model->table 
      unique-object
      (λ (table col-defs col-names _)
        (let ((table-name (orm-table-name table)))
          (run
           (sql:drop-table table-name)
           (sql:create-table table-name col-defs))))))
   (remove-duplicates 
    objects
    #:key
    (λ (x) (object-name x))))
  (for-each
   (λ (object)
     (model->table
      object
      (λ (table _ col-names col-values)
        (let ((dbc (get-connection))
              (table-name (orm-table-name table)))
          (run
           #:connection dbc
           (insert table-name col-names col-values)
           (λ args
             (let ((rowid (sql:query-value dbc "SELECT last_insert_rowid()")))
               (λ (generated-row-id)
                 (send object set-id generated-row-id)))))))))
   objects))

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
