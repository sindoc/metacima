#lang racket

(require 
 "connection-pool.rkt"
 metacima/common/utils/base
 metacima/sql/base)

(define (bootstrap-movie-table)
  (define name "movie")
  (list
   (drop-table name)
   (create-table 
    name
    '((movieid integer #:primary-key? #t)
      (title string)))
   (insert name)
   (insert name)
   (insert name)
   (insert name)
   (insert name)))

(define statements 
  (bootstrap-movie-table))

(define pool (get-connection-pool))

(define dbc (connection-pool-lease pool))

(force-thunks statements dbc)

(disconnect dbc)