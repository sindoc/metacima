#lang racket

(require
 (for-syntax
  racket
  "../common/utils/debug.rkt"
  "public.rkt"
  "../common/syntax.rkt")
 "../common/syntax.rkt"
 "public.rkt")

(provide 
 (all-defined-out)
 (all-from-out
  "public.rkt"))

(define-syntax (init-model stx)
  (syntax-case stx (table)
    ((_ (table table-name))
     (with-syntax
         ((orm-table (gensym "orm-table")))
       #'(begin
           (super-new)
           (define orm-table 
             (make-orm-table (symbol->string table-name) null))
           (define/override (orm:table) orm-table)
           (define/public (notify callback field)
             (unless (null? callback)
               (apply 
                callback 
                (list 
                 (send this orm:table) 
                 field))))
           (field* id 'id))))))

(define-for-syntax (fetch-joins props)
  (define datum (syntax->datum props))
  (define lst (if (null? datum) datum (car datum)))
  (define found (assoc 'join lst))
  (if (false? found)
      #f
      (make-orm-join (cadr found))))
  
(define-syntax (field* stx)
  (syntax-case stx (join)
    ((_ name type . props)
     (with-syntax
         ((name- (make-id stx "~a-" #'name))
          (get-name (make-id stx "get-~a" #'name))
          (set-name (make-id stx "set-~a" #'name))
          (joins (fetch-joins #'props)))
       #`(begin
           (init (name null))
           (define name- name)
           (define/public (get-name) name-)
           (define/public (set-name new-name (callback null))
             (set! name- new-name)
             (send this notify callback name-))
           (let ((table (send this orm:table)))
             (set-orm-table-columns! 
              table
              (cons (apply make-orm-column 
                           (list 'name name type (eq? type 'id) joins))
                    (orm-table-columns table)))))))))