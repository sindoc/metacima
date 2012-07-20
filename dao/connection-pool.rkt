#lang racket

(require db
         "../common/utils/debug.rkt")

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
    "database.sqlite")))

(define pool
  (connection-pool
   (λ () 
     (dbg 'connection-pool db-path)
     (displayln (format "Connecting to: ~a " db-path))
     (sqlite3-connect
      #:database db-path
      #:mode 'create))
   #:max-idle-connections 1
   #:max-connections 100))

(define (get-connection-pool) pool)