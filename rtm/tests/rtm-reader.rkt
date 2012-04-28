#lang racket

(require
 metacima/rtm/reader/base
 net/url
 )

(define (on-demand-in)
  (get-pure-port
   (string->url
    (string-append
     "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
     "?q=Catch"
     "&page_limit=20"
     "&page=2"
     "&apikey=9nw4jk48dn9prvxw46why38f"))))

(define (file-in)
  (define prefix "../resources/json/")
  (define postfix ".json")
  (open-input-file 
   (string-append prefix "search-result-01" postfix)))

(define r (read-rtm (on-demand-in)))