#lang racket

(require
 metacima/common/utils/base
 "../utils.rkt"
 "struct.rkt")

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

(define (insert spec)
  (format
   "INSERT ~a INTO ~a ~a"
   (if (not (false? (insert-statement-fail-action spec)))
       (insert-statement-fail-action spec) "")
   (insert-statement-table-name spec)
   (cond
     ((insert-statement-populate-with-defaults? spec)
      "DEFAULT VALUES")
     (else
      ""))))