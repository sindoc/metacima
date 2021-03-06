#lang racket

(require net/url
         net/url-structs
         "reader/base.rkt")

(provide (all-defined-out))

(define *api-key* "9nw4jk48dn9prvxw46why38f")
(define *search-page-number* 1)
(define *search-page-limit* 1)
(define *host* "api.rottentomatoes.com")
(define *api-path* "/api/public/v1.0/")

(define (prepare-request- path query)
  (make-url 
   "http"
   #f ;; user
   "api.rottentomatoes.com" ;; host
   #f ;; port
   #t ;; path-absulute?
   path
   query
   #f ;; fragment
   ))

(define (prepare-request path-elements query #:api-key (api-key *api-key*))
  (prepare-request-
   (append
    (list
     (make-path/param "api" null)
     (make-path/param "public" null)
     (make-path/param "v1.0" null))
    (map (λ (path-element) (make-path/param path-element null)) path-elements))
   (append 
    query
    (list
     (cons 'apikey api-key)))))

(define (search-movies query                          
                       #:page-limit (page-limit *search-page-limit*)
                       #:page-number (page-number *search-page-number*))
  (get-pure-port
   (prepare-request 
    (list "movies.json")
    `((q . ,query)
      (page_limit . ,(number->string page-limit))
      (page . ,(number->string page-number))))))