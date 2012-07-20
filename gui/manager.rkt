#lang racket

(require racket/gui/base)

(provide (all-defined-out))

(define (create-search-screen manager parent)
  
  (define search-wrapper 
    (new vertical-panel% 
         (style (list 'border))
         (border 10)
         (alignment
          (list 'center 'top))
         (parent parent)))
  
  (define font (make-object font% 50 "Courier" 'default))
  (define search-query (new text-field% 
                            (label "Search for Movies")
                            (init-value "Search...")
                            (style (list 'single 'vertical-label))
                            (font font)
                            (parent search-wrapper)))
  search-wrapper)

(define (create-movie-screen manager parent)
  
  (define movie-wrapper 
    (new vertical-panel% 
         (style (list 'border))
         (border 10)
         (alignment
          (list 'center 'top))
         (parent parent)))
  
  (define font (make-object font% 30 "Courier" 'default))
  (define search-query (new text-field% 
                            (label "Cool for Movies")
                            (init-value "Search...")
                            (style (list 'single 'vertical-label))
                            (font font)
                            (parent movie-wrapper)))
  (define home (new button% (label "Home") (parent movie-wrapper)
                    (callback (λ (e a) (manager 'magic)))))
  movie-wrapper)


(define (make-screen-manager root wrapper)
  (define self null)
  (define screens null)
  (define app null)
  (define search null)
  (define home null)
  (define current null)
  
  (define (init)
    (set! self screen-manager-dispatcher)
    (send root maximize #t)
    self)
  
  (define (set-app! app-) (set! app app-))
  (define (set-home! home-) (set! home home-))
  (define (set-current! current-)
    (for-each (λ (screen) (send screen show #f)) screens)
    (set! current current-)
    (send current show #t))
  (define (set-search! search-) (set! search search-))
  
  (define (start)
    (when (null? app)
      (error "Please set the application first via set-app!"))
    (set-current! home)
    (send app show #t))
  
  (define (create-new-screen callback)
    (define new-screen (callback self wrapper))
    (set! screens (cons new-screen screens))
    new-screen)
  
  (define (magic)
    void)
  
  (define (screen-manager-dispatcher msg)
    (case msg
      ((home) home)
      ((set-app!) set-app!)
      ((set-home!) set-home!)
      ((set-search!) set-search!)
      ((create-new-screen) create-new-screen)
      ((go-home!) (set-current! home))
      ((magic) (magic))
      ((start) (start))
      (else
       (error "screen-manager does not understand your request: " msg))))
  (init))