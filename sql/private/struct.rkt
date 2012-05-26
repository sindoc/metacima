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
  (column-name type-name column-constraint primary-key?)
  #:constructor-name make-column-def-)

(define (make-column-def 
         column-name 
         type-name
         #:primary-key? (primary-key #f)
         #:constraint (column-constraint #f))
  (make-column-def- 
   column-name type-name column-constraint primary-key))

(define-struct column-constraint (name))


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
   populate-with-defaults?)
  #:constructor-name make-insert-statement-)

(define (make-insert-statement
         table-name
         (database-name #f)
         #:populate-with-defaults? default?
         #:fail-action (fail-action #f)
         #:column-names (column-names null)
         #:column-values (column-values null))
  (make-insert-statement-
   table-name
   database-name
   column-names
   column-values
   fail-action
   default?))