#lang racket

(provide (all-defined-out))

(define-struct orm-table
  (name columns)
  #:mutable
  #:prefab)

(define-struct orm-join
  (type)
  #:mutable
  #:prefab)

(define-struct orm-column
  (name value type id? join)
  #:mutable
  #:prefab)

(define persistable<%> (interface () orm:table))

(define model%
  (class* object% (persistable<%>)
    (super-new)
    (define/public (orm:table) void)))