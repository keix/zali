; Collatz conjecture demonstration - first few steps only
(define n 27)
(print "Collatz sequence starting from 27:")
(print n)

; Step 1: 27 is odd, so 3*27+1 = 82
(set! n 82)
(print n)

; Step 2: 82 is even, so 82/2 = 41
(set! n 41)
(print n)

; Step 3: 41 is odd, so 3*41+1 = 124
(set! n 124)
(print n)

; Step 4: 124 is even, so 124/2 = 62
(set! n 62)
(print n)

; Step 5: 62 is even, so 62/2 = 31
(set! n 31)
(print n)

(print "... (continues until reaching 1)")