; Safe recursive list construction without cond
; Recursive list construction

; Create a list of numbers
(define nums (cons 1 (cons 2 (cons 3 '()))))
(print "Numbers list:")
(print nums)

; Extract list elements
(print "First element:")
(print (car nums))

(print "Second element:")
(print (car (cdr nums)))

(print "Third element:")
(print (car (cdr (cdr nums))))

; Complex list structure
(print "")
(print "Complex structure:")
(define data 
  (cons 'person 
    (cons (cons 'name 'alice)
      (cons (cons 'age 25) 
        '()))))
(print data)

; Simple conditional test
(print "")
(print "Simple conditional:")
(define x 15)
(if (= x 15)
    (print "x is 15")
    (print "x is not 15"))