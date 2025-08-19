(print (cons 1 (quote (2 3))))     ; => (1 2 3)
(print (car (quote (1 2 3))))      ; => 1
(print (cdr (quote (1 2 3))))      ; => (2 3)
(print (cons 1 (cons 2 (cons 3 (quote ())))))  ; => (1 2 3)
(print (car (cdr (quote (a b c))))) ; => b