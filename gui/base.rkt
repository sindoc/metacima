#lang racket

(require framework)
(require racket/gui/base)

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


(define (fill root wrapper)
  (define search-wrapper 
    (new vertical-panel% 
         (style (list 'border))
         (border 10)
         (alignment
          (list 'center 'top))
         (parent wrapper)))
  (define font (make-object font% 50 "Courier" 'default))
  (define search-query (new text-field% 
                            (label "Search for Movies")
                            (init-value "Search...")
                            (style (list 'single 'vertical-label))
                            (font font)
                            (parent search-wrapper)))
  
  (send root enable #f)
  ;(define search-button (new button% (label "Search for Movies") (parent search-wrapper)))
  (send root maximize #t)
  root)

(define app (new app% (proc fill) (label (application:current-app-name))))
(send app show #t)