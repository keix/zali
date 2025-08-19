; Simple mathematical calculation demo

; Basic arithmetic
(print "Basic arithmetic:")
(print (+ 10 20 30))
(print (- 100 25))
(print (* 5 5 4))
(print (/ 100 4))

; Conditional branching
(print "")
(print "Conditional:")
(if (>= 10 5)
    (print "10 is greater than or equal to 5")
    (print "This won't print"))

; List operations
(print "")
(print "List operations:")
(define mylist '(apple banana cherry))
(print mylist)
(print (car mylist))
(print (cdr mylist))
(print (cons 'fruit mylist))

; Nested calculation
(print "")
(print "Nested calculation:")
(print (+ (* 3 4) (- 10 5)))  ; 3*4 + (10-5) = 12 + 5 = 17