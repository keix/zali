; Calculate factorial
(define n 5)
(define result 1)
(define i 1)

(while (<= i n)
  (set! result (* result i))
  (set! i (+ i 1)))

(print "5! = ")
(print result)