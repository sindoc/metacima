#lang racket

(require
 metacima/common/utils/base
 "../utils.rkt"
 "struct.rkt"
 "../../common/utils/debug.rkt")

(provide
 (all-defined-out))

(define (create-table spec)
  (format 
   "CREATE TABLE ~a ~a ~a"
   (if (true? (create-table-statement-ignore-if-exists? spec))
       "IF NOT EXISTS " "")
   (create-table-statement-table-name spec)
   (map+
    (λ (i col-spec)
      (let ((base "~a ~a ~a"))
        (format 
         (if (eq? i 1)
             base
             (string-append ", " base))
         (column-def-column-name col-spec)
         (->sql (column-def-type-name col-spec))
         (if (true? (column-def-primary-key? col-spec))
             "PRIMARY KEY" ""))))
    (create-table-statement-col-defs spec))))

(define (drop-table spec)
  (format
   "DROP TABLE ~a ~a"
   (if (true? (drop-table-statement-only-if-exists? spec))
       "IF EXISTS " "")
   (drop-table-statement-table-name spec)))

(define (place-separator source #:sep (sep ","))
  (map+
   (λ (i x)
     (if (eq? i 1) (format "~a" x) (format "~a ~a" sep x)))
   source))

(define (process-types vals)
  (map
   (λ (val)
     (cond 
       ((string? val)
        (format "'~a'" val))
      (else (format "~a" val))))
   vals))

(define (insert spec)
  (dbg 'insert 
       (insert-statement-column-names spec)
       (insert-statement-column-values spec)
       (map (λ (x) (string? x)) (insert-statement-column-values spec)))
  
  (format
   "INSERT ~a INTO ~a ~a"
   (if (not (false? (insert-statement-fail-action spec)))
       (insert-statement-fail-action spec) "")
   (insert-statement-table-name spec)
   (cond
     ((true? (insert-statement-auto-populate? spec))
      "DEFAULT VALUES")
     (else
      (format 
       "~a VALUES ~a"
       (place-separator (insert-statement-column-names spec))
       (place-separator (process-types (insert-statement-column-values spec))))))))

(define (update spec)
  (format
   "UPDATE ~a SET ~a = \"~a\" ~a "
   (update-statement-table-name spec)
   (update-statement-column-name spec)
   (update-statement-column-value spec)
   (let ((row-filter (update-statement-row-filter spec)))
     (if (false? row-filter)
         ""  (format "WHERE ~a" row-filter)))))