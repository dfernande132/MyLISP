(DEFUN MAP (F L)
  (COND ((ATOM L) NIL)
        (T (CONS (F (CAR L))
                 (MAP F (CDR L))))))

(DEFUN FILTER (F L)
  (COND ((ATOM L) NIL)
        ((F (CAR L)) (CONS (CAR L) (FILTER F (CDR L))))
        (T (FILTER F (CDR L)))))

(DEFUN REDUCE (F ACC L)
  (COND ((ATOM L) ACC)
        (T (REDUCE F (F ACC (CAR L)) (CDR L)))))

(DEFUN POSITIVO (X) (> X 0))
(DEFUN GRANDE (X) (> X 3))
(DEFUN DOBLE (X) (+ X X))
(DEFUN SUMA (A B) (+ A B))
(DEFUN PRODUCTO (A B) (* A B))

(MAP 'DOBLE '(1 2 3 4 5))

(FILTER 'POSITIVO '(-2 -1 0 1 2 3))

(FILTER 'GRANDE '(1 2 3 4 5 6))

(REDUCE 'SUMA 0 '(1 2 3 4 5))

(REDUCE 'PRODUCTO 1 '(1 2 3 4 5))
