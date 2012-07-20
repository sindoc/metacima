#lang racket

(require 
 metacima/common/utils/base
 metacima/common/utils/meta
 (prefix-in 
  neil: 
  (planet neil/json-parsing:1:=2)))

(provide json->list reify-json make-record-handler)

(define json-parser
  (neil:json-fold-lambda
   
   #:error-name
   'metacima-json-to-sjson
   
   #:visit-object-start 
   (λ (seed)
     '())
   
   #:visit-object-end
   (λ (seed parent-seed)
     `(,seed ,@parent-seed))

   #:visit-member-start 
   (λ (name seed)
     '())
   
   #:visit-member-end
   (λ (name seed parent-seed)
     (define key (string->symbol name))
     (define val (car seed))
     (set! parent-seed (append parent-seed (list (list key val))))
     parent-seed)
   
   #:visit-array-start  
   (λ (seed)
     '())
   
   #:visit-array-end
   (λ (seed parent-seed)
     `(,seed ,@parent-seed))
   
   #:visit-string
   (λ (str seed)
     `(,str ,@seed))
   
   #:visit-number
   (λ (num seed)
     `(,num ,@seed))
   
   #:visit-constant
   (λ (name seed)
     `(,(case name
          ((true)  #t)
          ((false) #f)
          ((null)  #\nul)
          (else 
           (error 'metacima-json-to-sjson
                  "invalid constant ~S"
                  name)))
       ,@seed))))

(define (json->list in)
  (cons 'result (car (json-parser in null #f))))

(define-struct record-handler 
  (hook constructor collection-component object?))

;(define collector cons)
(define collector keyword-apply-)

(define (reify-json obj #:handlers handlers)
  
  (define handlers- (make-hash handlers))
  
  (define (fetch-handler hook)
    (hash-ref 
     handlers-
     hook
     (λ ()
       (symbol->keyword hook))))
  
  (define (read obj)
    (cond
      ((null? obj) obj)
      ((not (pair? obj))
       (cond
         ((symbol? obj)
          (fetch-handler obj))
         (else obj)))
      (else 
       (let ((head (read (car obj))))
         (cond
           ((record-handler? head)
            (let ((comp (record-handler-collection-component head))
                  (obj? (record-handler-object? head)))
              (cond 
                (comp 
                 (cons 
                  (symbol->keyword 
                   (record-handler-hook head))
                  (list
                   (map
                    (λ (movie-records)
                      (collector comp movie-records))
                    (read (cadr obj))))))
                (obj?
                 (cons 
                  (symbol->keyword
                   (record-handler-hook head))
                  (list
                   (collector 
                    (record-handler-constructor head)
                    (read (cadr obj))))))
                (else
                 (collector
                  (record-handler-constructor head)
                  (read (cdr obj)))))))
           (else 
            (cons head (read (cdr obj)))))))))
  
  (read obj))