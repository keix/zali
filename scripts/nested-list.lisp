; Nested list manipulation demo
(define matrix '((1 2 3) (4 5 6) (7 8 9)))

(print "Matrix:")
(print matrix)

(print "First row:")
(print (car matrix))

(print "Element at [1][1] (which is 5):")
(print (car (cdr (car (cdr matrix)))))

; Building lists
(print "Building a tree structure:")
(define tree (cons 'root 
              (cons (cons 'left '(1 2 3))
                    (cons (cons 'right '(4 5 6))
                          '()))))
(print tree)