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
       (frame:basic-mixin
        frame%)))))))

(define app%
  (class app-frame%
    (super-new)
    (define status-panel null)
    (define/override (make-root-area-container cls parent)
      (set! status-panel
            (super make-root-area-container vertical-panel% parent))
      (let ((root (make-object cls status-panel)))
        (define test (new button% (label "test button") (parent root)))
        (define msg (new message% (label "test message") (parent root)))
        root))))

(define app (new app% (label (application:current-app-name))))

;(define field%
;  (html-text-mixin text%))

(send app show #t)