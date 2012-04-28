#lang racket

(provide
 string->date)

(require
 (prefix-in srfi: srfi/19))

(define (string->date src)
  (define date (srfi:string->date src "~Y-~m-~d"))
  (define day (srfi:date-day date))
  (define month (srfi:date-month date))
  (define year (srfi:date-year date))
  (make-date 0 0 0 day month year 0 0 #f 0))