; $Id$

;; some helpers for printing TAP, Test anything protocol

(define skip-all
  (lambda (reason)
    ( printf "1..0 # Skip ~s\n" reason)
    (exit)))

(define plan
  (lambda (num-tests)
    ( printf "~s..~s\n" 1 num-tests)))

(define pass
  (lambda (test-num test-description)
    ( printf "ok ~s - ~s\n" test-num test-description)))

(define fail
  (lambda (test-num test-description)
    ( printf "not ok ~s - ~s\n" test-num test-description)))

