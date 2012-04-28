#lang racket

(require net/url
         net/url-structs)

(provide (all-defined-out))

(define *rtm-api-key* "9nw4jk48dn9prvxw46why38f")
(define *search-limit-in-page* 10)
(define *search-page-limit* 10)

(define (prepare-request path query)
  (make-url 
   "http" ;; scheme
   #f ;; user
   "api.rottentomatoes.com/api/public/v1.0/" ;; host
   #f ;; port
   #t ;; path-absulute?
   path
   query
   #f ;; fragment
   ))

(define (search-movies query)
  (prepare-request 
   (list 
    (make-path/param 
     "movies.json" 
     (list "a=1")))
   query))

(search-movies (list (cons 'hello #f)))

