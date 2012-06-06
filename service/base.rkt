#lang racket

(require
 (prefix-in dao: "../dao/base.rkt"))

(provide (all-defined-out))

(dao:bootstrap-db)

(define (make-movie title)
  (dao:make-movie title))

