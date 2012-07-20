#lang racket

(require 
 metacima/common/syntax
 metacima/common/reader/json)

(provide
 read-rtm
 (struct-out rtm-search-result)
 (struct-out rtm-movie )
 (struct-out rtm-movie-rating-list)
 (struct-out rtm-movie-alternate-ids)
 (struct-out rtm-movie-release-dates)
 (struct-out rtm-movie-cast))

(define-struct* rtm-search-result 
  (total movies links link_template))

(define-struct* rtm-movie
  (id year runtime abridged_cast alternate_ids release_dates ratings posters
      title  mpaa_rating critics_consensus synopsis links audience_score))

(define-struct* rtm-movie-rating-list
  (audience_rating audience_score critics_score critics_rating))

(define-struct* rtm-movie-alternate-ids (imdb))
(define-struct* rtm-movie-release-dates (dvd theater))
(define-struct* rtm-movie-cast (name characters id))

(define (read-rtm payload)
  (reify-json
   (json->list payload)
   #:handlers
   (map
    (λ (handler)
      (cons 
       (car handler)
       (apply make-record-handler handler)))
    (list
     (list 'result make-rtm-search-result #f #f)
     (list 'movies #f make-rtm-movie #f)
     (list 'alternate_ids make-rtm-movie-alternate-ids #f #t)
     (list 'release_dates make-rtm-movie-release-dates #f #t)
     (list 'ratings make-rtm-movie-rating-list #f #t)
     (list 'abridged_cast #f make-rtm-movie-cast #f)))))