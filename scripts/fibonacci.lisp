; Generate Fibonacci sequence
(define fib-list '(1 1))
(define a 1)
(define b 1)
(define count 0)
(define next 0)

(print "Fibonacci sequence:")
(print fib-list)

(while (<= count 8)  ; First 10 numbers
  (set! next (+ a b))
  (set! fib-list (cons next fib-list))
  (set! a b)
  (set! b next)
  (set! count (+ count 1)))

; Display list in reverse order (normally would need reverse function)
(print "Generated (in reverse):")
(print fib-list)