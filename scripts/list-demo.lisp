; List manipulation demonstration

; Basic list operations
(print "=== Basic List Operations ===")
(define fruits '(apple banana cherry))
(print "Original list:")
(print fruits)

(print "First fruit:")
(print (car fruits))

(print "Rest of fruits:")
(print (cdr fruits))

(print "Add orange to front:")
(print (cons 'orange fruits))

; Nested lists
(print "")
(print "=== Nested Lists ===")
(define menu '((breakfast eggs toast) (lunch sandwich soup) (dinner pasta salad)))
(print "Full menu:")
(print menu)

(print "Breakfast items:")
(print (car menu))

(print "First lunch item:")
(print (car (car (cdr menu))))

; Building lists
(print "")
(print "=== Building Lists ===")
(print "Empty list:")
(print '())

(print "List of numbers:")
(print (cons 1 (cons 2 (cons 3 (cons 4 '())))))

; Calculations in lists
(print "")
(print "=== Calculations in Lists ===")
(define calc-list (cons (+ 1 2) (cons (* 3 4) (cons (- 10 5) '()))))
(print "List of calculated values:")
(print calc-list)