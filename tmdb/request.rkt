#lang racket

(require net/url
         net/url-structs)

(provide (all-defined-out))

(define *api-key* "d47864e19084e06a5056def6d0b81565")
(define *search-page-number* 1)
(define *search-page-limit* 1)
(define *host* "api.themoviedb.org")
(define *api-path* "/2.1/")

(define (prepare-request- path query)
  (make-url 
   "http"
   #f ;; user
   *host* ;; host
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