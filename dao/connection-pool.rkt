#lang racket

(require db)

(provide get-connection-pool
         connection-pool-lease
         disconnect)

(define pool
  (connection-pool
   (λ () 
     (displayln "Connecting...")
     (sqlite3-connect
      #:database "metacima.sqlite"
      #:mode 'create))
   #:max-idle-connections 1
   #:max-connections 10))

(define (get-connection-pool) pool)