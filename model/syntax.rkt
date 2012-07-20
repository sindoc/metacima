#lang racket

(require  
 "../common/utils/debug.rkt"
 (for-syntax
  "../common/utils/debug.rkt"
  racket
  "../common/syntax.rkt")
 "../common/syntax.rkt")

(provide 
 (all-defined-out))
 
(define-syntax (init-model stx)
  (syntax-case stx ()
    ((_)
     (with-syntax
         ((field-list (gensym 'field-list))
          (optional-field-list (gensym 'optional-field-list)))
       #'(begin
           (super-new)
           (define field-list null)
           (define optional-field-list null)
           (define/public (get-field-list) field-list)
           (define/public (set-field-list modified-field-list)
             (set! field-list modified-field-list))
           (define/public (get-optional-field-list) optional-field-list)
           (define/public (set-optional-field-list modified-field-list)
             (set! optional-field-list modified-field-list))
           (field* id optional))))))

(define-for-syntax (update-field-list props name)
  (define datum (syntax->datum props))
  (define found (member 'optional datum))
  (if (false? found)
      #`(send this set-field-list (cons '#,name (send this get-field-list)))
      #`(send this set-optional-field-list 
              (cons '#,name (send this get-optional-field-list)))))

(define-syntax (field* stx)
  (syntax-case stx (optional)
    ((_ name . props)
     (with-syntax
         ((name- (make-id stx "~a-" #'name))
          (get-name (make-id stx "get-~a" #'name))
          (set-name (make-id stx "set-~a" #'name))
          (update-field-list (update-field-list #'props #'name)))
       #'(begin
           (init (name null))
           (define name- name)
           update-field-list
           (define/public (get-name) name-)
           (define/public (set-name new-name (callback null))
             (set! name- new-name)
             (send this notify)))))))

(define-syntax (model+ stx)
  (syntax-case stx ()
    ((_ class-name persister)
     #'(let ((model (new class-name)))
         (let ((field-list (send model get-field-list)))
           (let ((param-list 
                  (flatten
                   (map 
                    (λ (field) 
                      (list (string->keyword (symbol->string field)) 
                            field)) field-list)))
                 (arguments
                  (map (λ (field) (list field field)) field-list)))
             (dbg 'model+ param-list arguments)
             (eval-syntax
              #`(λ #,param-list 
                  (let ((constructed-model
                         (new class-name #,@arguments)))
                    (send constructed-model add-observer persister)
                    (send constructed-model notify)
                    constructed-model)))))))))