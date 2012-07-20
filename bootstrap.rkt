#lang racket

(require
 db
 "common/utils/debug.rkt"
 "dao/connection-pool.rkt"
 "common/utils/base.rkt"
 "common/syntax.rkt"
 "model/syntax.rkt"
 "rtm/reader/base.rkt"
 "rtm/request.rkt"
 (prefix-in model: "model/base.rkt"))

(provide
 (all-defined-out))

(define (list->string+ lst #:sep (sep ","))
  (map+ (λ (i x) (if (eq? i 1) (format "~a" x) (format "~a ~a" sep x))) lst))

(define (create-table name cols)
  (format "CREATE TABLE IF NOT EXISTS ~a ~a" name (list->string+ cols)))
   
(define (drop-table name) 
  (format "DROP TABLE IF EXISTS ~a" name))

(define (generate-drop-statements)
  (define statements null)
  (define (add statement)
    (push statements statement))
  (add (drop-table "movie"))
  (add (drop-table "movie_roles"))
  statements)

(define (generate-create-statements)
  (define statements null)
  (define (add statement)
    (push statements statement))
  
  (add
   (create-table "movies" 
                 (list
                  "id INTEGER PRIMARY KEY"
                  "title VARCHAR(255)"
                  "year INTEGER"
		  "runtime INTEGER"
		  )))
  
  (add
   (create-table "movie_roles" 
                 (list
                  "id INTEGER PRIMARY KEY"
                  "movieid REFERENCES movies")))
  
  statements)

(define (generate-insert-statements)
  (list ""))

(define (get-connection) (connection-pool-lease (get-connection-pool)))

(define (bootstrap)  
  (define dbc (get-connection))
  (define (exec stmt) (query-exec dbc stmt))
  (for-each exec (generate-drop-statements))
  (for-each exec (generate-create-statements))
  (disconnect dbc))

(define observer<%>
  (interface () update))

(define dao%
  (class* object% (observer<%>)
    (super-new)
    (define/public (update model)
      (dbg 'dao-update model))))

(define movie-dao%
  (class dao%
    (super-new)
    
    (define/overment (update movie)
      (dbg 'movie-dao-update movie)
      (when (null? (send movie get-id))
        (send this save movie)))
    
    (define/public (save movie)

      (define insert-statement
        (format 
         (string-append
          "INSERT INTO movies "
          "(title, year, runtime) VALUES "
          "('~a' , ~a,   ~a)")
         (send movie get-title)
         (send movie get-year)
         (send movie get-runtime)
         ))
      
      (define dbc (get-connection))
      (call-with-transaction
       dbc
       (λ ()
         (query-exec dbc insert-statement)
	 (let ((rowid (query-value dbc "SELECT last_insert_rowid()")))
	   (send movie set-id rowid))))

      (disconnect dbc))))

(bootstrap)

(define-values
  (make-movie make-person)
  (values
   (model+ model:movie% (new movie-dao%))
   (model+ model:person% (new dao%))))

(define-struct info-provision-request
  (supplier object-of-interest object))

(define (movie-mediator requests)
  (define rtm (car requests))
  (define m (info-provision-request-object rtm))
  (make-movie
   #:title (rtm-movie-title m)
   #:year (rtm-movie-year m)
   #:runtime (rtm-movie-runtime m)
  ))

(define m
  (movie-mediator
 (list
  (make-info-provision-request
   'rtm
   'movie
   (car 
    (rtm-search-result-movies (read-rtm (search-movies "Separation"))))))))
