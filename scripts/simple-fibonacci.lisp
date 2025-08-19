; Simple Fibonacci demonstration without loops
(print "First 10 Fibonacci numbers:")

; Define the first 10 Fibonacci numbers manually
(define fib1 1)
(define fib2 1)
(define fib3 (+ fib1 fib2))
(define fib4 (+ fib2 fib3))
(define fib5 (+ fib3 fib4))
(define fib6 (+ fib4 fib5))
(define fib7 (+ fib5 fib6))
(define fib8 (+ fib6 fib7))
(define fib9 (+ fib7 fib8))
(define fib10 (+ fib8 fib9))

; Display them
(print fib1)
(print fib2)
(print fib3)
(print fib4)
(print fib5)
(print fib6)
(print fib7)
(print fib8)
(print fib9)
(print fib10)