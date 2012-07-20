#lang racket

(require framework racket/gui/base "manager.rkt")


(application:current-app-name "MetaCima")

(define app-frame%
  (frame:status-line-mixin
   (frame:info-mixin
    (frame:standard-menus-mixin
     (frame:register-group-mixin
      (frame:focus-table-mixin
       (frame:basic-mixin frame%)))))))

(define app%
  (class app-frame%
    (init-field proc label)
    (super-new (label label))
    (define wrapper null)
    (define/override (make-root-area-container cls parent)
      (set! wrapper
            (super make-root-area-container vertical-panel% parent))
      (proc parent wrapper))))

(define (init)
  (define manager null)
  (define (draw root wrapper)
    (set! manager (make-screen-manager root wrapper)))
  (define app (new app% (proc draw) (label (application:current-app-name))))
  ((manager 'set-app!) app)
  (define search-screen ((manager 'create-new-screen) create-search-screen))
  (define movie-screen ((manager 'create-new-screen) create-movie-screen))
  ((manager 'set-home!) movie-screen)
  ((manager 'set-search!) search-screen)
  (manager 'start))

(init)