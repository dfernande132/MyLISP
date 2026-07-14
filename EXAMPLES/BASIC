'(PRUEBA2)


; --- Tipos ---
(NUMBERP 5)
(NUMBERP 'X)
(SYMBOLP 'X)
(SYMBOLP 5)
(LISTP '(1 2))
(LISTP 5)
(ATOM 'X)
(ATOM '(1 2))

; --- Listas basicas ---
(CAR '(1 2 3))
(CDR '(1 2 3))
(CONS 1 '(2 3))
(LIST 1 2 3)
(APPEND '(1 2) '(3 4))
(EQ 'X 'X)
(EQ '(1 2) '(1 2))
(EQUAL '(1 2) '(1 2))
(EQUAL 3 3.0)

; --- Control de flujo ---
(COND (NIL 1) (T 2))
(PROGN 1 2 3)
(LET ((X 5) (Y 10)) (+ X Y))
(LET ((X 1)) (LET ((Y 2)) (+ X Y)))

; --- Funciones definidas por el usuario ---
(DEFUN CUADRADO (X) (* X X))
(CUADRADO 7)
(DEFUN FACT (N) (COND ((= N 0) 1) (T (* N (FACT (- N 1))))))
(FACT 10)
(DEFUN FIB (N) (COND ((= N 0) 0) ((= N 1) 1) 
(T (+ (FIB (- N 1)) (FIB (- N 2))))))
(FIB 10)

; --- Funciones de orden superior ---
(DEFUN MAP (F L) (COND ((ATOM L) NIL) (T (CONS (F (CAR L)) (MAP F (CDR L))))))
(DEFUN DOBLE (X) (+ X X))
(MAP 'DOBLE '(1 2 3))

; --- Errores controlados (el REPL debe seguir vivo despues) ---
(FOO)
(CAR NIL)
(/ 5 0)
(+ 1 'X)
