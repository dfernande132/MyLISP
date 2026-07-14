; Ordenacion de listas - Selection Sort
; Cargar con: (LOAD "mdv1_sort")

(DEFUN MENOR (L)
  (COND ((ATOM (CDR L)) (CAR L))
        ((< (CAR L) (MENOR (CDR L))) (CAR L))
        (T (MENOR (CDR L)))))

(DEFUN QUITAR (X L)
  (COND ((ATOM L) NIL)
        ((EQ (CAR L) X) (CDR L))
        (T (CONS (CAR L) (QUITAR X (CDR L))))))

(DEFUN SORT (L)
  (COND ((ATOM L) NIL)
        (T (CONS (MENOR L) (SORT (QUITAR (MENOR L) L))))))

(SORT '(5 3 8 1 9 2))
(SORT '(1 2 3))
(SORT '(3 2 1))
(SORT '(7))
