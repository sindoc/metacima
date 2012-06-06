#lang racket

(require db)

(provide get-connection-pool
         connection-pool-lease
         disconnect)

(define metacima-home
  (build-path
   (find-system-path 'home-dir)
   ".metacima"))

(unless (directory-exists? metacima-home)
  (make-directory metacima-home))

(define db-path
  (path->string
   (build-path
    metacima-home
    "db.sqlite")))

(define pool
  (connection-pool
   (λ () 
     (displayln "Connecting...")
     (sqlite3-connect
      #:database db-path
      #:mode 'create))
   #:max-idle-connections 1
   #:max-connections 10))

(define (get-connection-pool) pool)