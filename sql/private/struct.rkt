#lang racket

(provide
 (struct-out create-table-statement)
 (struct-out column-def)
 (all-defined-out))

;; Source:
;; http://sqlite.org/lang_createtable.html

(define-struct create-table-statement
  (table-name
   col-defs
   database-name
   ignore-if-exists?
   temporary?)
  #:constructor-name make-create-table-statement-)

(define (make-create-table-statement 
         table-name 
         col-defs
         (db-name #f)
         #:ignore-if-exists? (ignore-if-exists? #t)
         #:is-temporary? (temporary? #f))
  (make-create-table-statement-
   table-name
   col-defs
   db-name
   ignore-if-exists?
   temporary?))

(define-struct column-def
  (column-name type-name column-constraint primary-key? foreign-key-clause)
  #:constructor-name make-column-def-)

(define (make-column-def 
         column-name 
         type-name
         #:primary-key? (primary-key #f)
         #:constraint (column-constraint #f)
         #:fk (fk #f))
  (make-column-def- 
   column-name type-name column-constraint primary-key fk))

(define-struct column-constraint (name))


(define-struct foreign-key-clause
  (foreign-table))


;; Source:
;; http://sqlite.org/lang_droptable.html

(define-struct drop-table-statement
  (table-name
   database-name
   only-if-exists?)
  #:constructor-name make-drop-table-statement-)

(define (make-drop-table-statement 
         table-name 
         (db-name #f)
         #:only-if-exists? (only-if-exists? #t))
  (make-drop-table-statement-
   table-name
   db-name
   only-if-exists?))

;; Source:
;; http://www.sqlite.org/lang_insert.html

(define-struct insert-statement
  (table-name
   database-name
   column-names
   column-values
   fail-action
   auto-populate?)
  #:constructor-name make-insert-statement-)

(define (make-insert-statement
         table-name
         (database-name #f)
         #:auto-populate? auto-populate?
         #:fail-action (fail-action #f)
         #:column-names (column-names null)
         #:column-values (column-values null))
  (make-insert-statement-
   table-name
   database-name
   column-names
   column-values
   fail-action
   auto-populate?))

;; Source:
;; http://sqlite.org/lang_update.html

(define-struct update-statement
  (table-name
   database-name
   row-filter
   column-name
   column-value
   fail-action)
  #:constructor-name make-update-statement-)

(define (make-update-statement
         table-name
         (database-name #f)
         #:fail-action (fail-action #f)
         #:column-name (column-name null)
         #:column-value (column-value null)
         #:row-filter (row-filter #f))
  (make-update-statement-
   table-name
   database-name
   row-filter
   column-name
   column-value
   fail-action))