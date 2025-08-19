; Collatz conjecture (3n+1 problem)
(define n 27)
(define steps 0)
(define sequence '())

(print "Collatz sequence starting from ")
(print n)

(while (> n 1)
  (set! sequence (cons n sequence))
  (if (= (mod n 2) 0)
    (set! n (/ n 2))
    (set! n (+ (* 3 n) 1)))
  (set! steps (+ steps 1)))

(set! sequence (cons 1 sequence))

(print "Steps taken: ")
(print steps)
(print "Sequence (reversed): ")
(print sequence)