#lang racket

(require
 (for-syntax racket/list))

(provide
 (all-defined-out)
 (for-syntax (all-defined-out)))
 
(define-for-syntax (make-id stx template . ids)
  (datum->syntax 
   stx 
   (string->symbol 
    (apply 
     format template 
     (map syntax->datum ids)))))

(define-syntax (define-struct* stx)
  (syntax-case stx ()
    ((_ name (field ...))
     (with-syntax
         ((shadowed-constructor-name 
           (make-id stx "make-~a-" #'name))
          (constructor-name
           (make-id stx "make-~a" #'name))
          (field-lst 
           (sort 
            (syntax->list #'(field ...))
            string<? #:key 
            (λ (stx-obj)
              (symbol->string
               (syntax->datum stx-obj))))))
       (with-syntax
           ((kw-lst
             (map 
              (λ (field-name)
                (string->keyword
                 (symbol->string 
                  (syntax->datum field-name))))
              (syntax->list #'field-lst)))
            (field-lst-
             (map
              (λ (field-name)
                #`(#,field-name null))
              (syntax->list #'field-lst))))
         #`(begin
             (define constructor-name
               (λ #,(flatten
                     (map
                      list
                      (syntax->list #'kw-lst)
                      (syntax->list #'field-lst-)))
                 (shadowed-constructor-name #,@#'field-lst)))
             (define-struct
               name
               field-lst
               #:extra-constructor-name 
               shadowed-constructor-name
               #:auto-value null)))))))

(define-syntax (inc stx)
  (syntax-case stx ()
    ((_ var val)
     #'(set! var (+ var val)))))

(define-syntax (push stx)
  (syntax-case stx ()
    ((_ lst e)
     #'(set! lst (cons e lst)))))
