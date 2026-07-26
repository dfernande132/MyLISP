; ============================================
; TRES EN RAYA vs LA MAQUINA - para MyLISP
; creado con CLAUDE IA 
; Eres el jugador 1 (X), la maquina es el 2 (O).
; Sin numeros aleatorios: la maquina juega con
; estrategia (ganar > bloquear > centro >
; esquina > borde).
; posiciones:  1 2 3
;              4 5 6
;              7 8 9
; Cargar con: (load "iatresraya")
;
; Como se juega:
; (mover p)   ->  jugas en la posicion p,
;                la maquina responde sola
; (reset)     -> empezar otra vez de nuevo.
; ============================================

; --- elemento en la posicion k (empieza en 1) ---
(defun elem (k lst)
  (if (= k 1)
      (car lst)
      (elem (- k 1) (cdr lst))))

; --- devuelve un tablero nuevo con v en la posicion k ---
(defun pon (k v lst)
  (if (= k 1)
      (cons v (cdr lst))
      (cons (car lst) (pon (- k 1) v (cdr lst)))))

; --- simbolo para mostrar segun el valor ---
(defun simb (v)
  (cond
    ((= v 1) "X")
    ((= v 2) "O")
    (t "-")))

; --- imprime una fila de 3 (posiciones p,p+1,p+2) ---
(defun filatr (lst p)
  (progn
    (display (simb (elem p lst)))
    (display " ")
    (display (simb (elem (+ p 1) lst)))
    (display " ")
    (display (simb (elem (+ p 2) lst)))
    (newline)))

; --- imprime el tablero completo ---
(defun tabla (lst)
  (progn
    (filatr lst 1)
    (filatr lst 4)
    (filatr lst 7)))

; --- linea de 3 en raya iguales y no vacias? ---
(defun linea3 (lst a b c)
  (and (= (elem a lst) (elem b lst))
       (and (= (elem b lst) (elem c lst))
            (not (= (elem a lst) 0)))))

; --- version que recibe una terna (lista de 3) ---
(defun linea3t (lst tri)
  (linea3 lst (car tri) (car (cdr tri)) (car (cdr (cdr tri)))))

; --- las 8 lineas ganadoras posibles ---
(defun lineas ()
  '((1 2 3) (4 5 6) (7 8 9)
    (1 4 7) (2 5 8) (3 6 9)
    (1 5 9) (3 5 7)))

; --- recorre las lineas buscando una ganadora ---
(defun chklin (lst lns)
  (if (atom lns)
      nil
      (if (linea3t lst (car lns))
          t
          (chklin lst (cdr lns)))))

; --- hay algun ganador en el tablero? ---
(defun gano (lst)
  (chklin lst (lineas)))

; --- el tablero esta lleno? (para empate) ---
(defun lleno (lst)
  (if (atom lst)
      t
      (if (= (car lst) 0)
          nil
          (lleno (cdr lst)))))

; --- la casilla p ya esta ocupada? ---
(defun ocupada (lst p)
  (not (= (elem p lst) 0)))

(defun libre (lst p)
  (not (ocupada lst p)))

; --- revisa una linea: si 2 son de j y 1 vacia, devuelve esa ---
(defun chkfila (lst j a b c)
  (cond
    ((and (= (elem a lst) j) (and (= (elem b lst) j) (= (elem c lst) 0))) c)
    ((and (= (elem a lst) j) (and (= (elem c lst) j) (= (elem b lst) 0))) b)
    ((and (= (elem b lst) j) (and (= (elem c lst) j) (= (elem a lst) 0))) a)
    (t 0)))

; --- recorre las lineas buscando una jugada de j ---
(defun buscaf (lst j lns)
  (if (atom lns)
      0
      (buscaf2 lst j lns)))

(defun buscaf2 (lst j lns)
  (let ((tri (car lns)))
    (let ((r (chkfila lst j (car tri) (car (cdr tri)) (car (cdr (cdr tri))))))
      (cond
        ((not (= r 0)) r)
        (t (buscaf lst j (cdr lns)))))))

; --- posicion donde la maquina ganaria ya (0 si ninguna) ---
(defun ganamov (lst)
  (buscaf lst 2 (lineas)))

; --- posicion donde hay que bloquear al humano ---
(defun bloqmov (lst)
  (buscaf lst 1 (lineas)))

; --- primera posicion libre de una lista de candidatas ---
(defun primlib (lst lns)
  (if (atom lns)
      0
      (if (libre lst (car lns))
          (car lns)
          (primlib lst (cdr lns)))))

(defun esquinas ()
  '(1 3 7 9))

(defun bordes ()
  '(2 4 6 8))

; --- estrategia de la maquina, en pasos chicos ---
(defun iamov4 (lst)
  (let ((esq (primlib lst (esquinas))))
    (cond
      ((not (= esq 0)) esq)
      (t (primlib lst (bordes))))))

(defun iamov3 (lst)
  (cond
    ((libre lst 5) 5)
    (t (iamov4 lst))))

(defun iamov2 (lst)
  (let ((bloq (bloqmov lst)))
    (cond
      ((not (= bloq 0)) bloq)
      (t (iamov3 lst)))))

(defun iamov (lst)
  (let ((gana (ganamov lst)))
    (cond
      ((not (= gana 0)) gana)
      (t (iamov2 lst)))))

; --- mensajes, cada uno en su propia funcion chica ---
(defun msgocup (lst)
  (progn
    (display "Casilla ocupada, elegi otra")
    (newline)))

(defun msggano (nuevo j)
  (progn
    (tabla nuevo)
    (display "Jugador ")
    (display j)
    (display " GANO!")
    (newline)))

(defun msgemp (nuevo)
  (progn
    (tabla nuevo)
    (display "EMPATE!")
    (newline)))

(defun msgturno ()
  (progn
    (tabla tablero)
    (display "Tu turno (X)")
    (newline)))

; --- tablero vacio ---
(defun inicio ()
  '(0 0 0 0 0 0 0 0 0))

; --- variable global con el tablero actual ---
(define tablero (inicio))

; --- contador de turnos, para limpiar memoria solo ---
(define turno 0)

(defun incturno ()
  (define turno (+ turno 1)))

(defun tocalimp ()
  (= (mod turno 2) 0))

(defun limpiasi ()
  (cond
    ((tocalimp) (clean))
    (t nil)))

; --- reiniciar la partida ---
(defun reset ()
  (progn
    (define tablero (inicio))
    (define turno 0)))

; --- turno de la maquina, despues del tuyo ---
(defun turnomaq ()
  (progn
    (define tablero (pon (iamov tablero) 2 tablero))
    (turnm2)))

(defun turnm2 ()
  (cond
    ((gano tablero) (msggano tablero 2))
    ((lleno tablero) (msgemp tablero))
    (t (msgturno))))

; --- tu turno, revisa si seguis vos o pasa a la maquina ---
(defun turnh2 ()
  (cond
    ((gano tablero) (msggano tablero 1))
    ((lleno tablero) (msgemp tablero))
    (t (turnomaq))))

(defun turnohum (p)
  (progn
    (define tablero (pon p 1 tablero))
    (turnh2)))

; --- funcion principal: mover posicion ---
(defun mover (p)
  (cond
    ((ocupada tablero p) (msgocup tablero))
    (t (mover2 p))))

(defun mover2 (p)
  (progn
    (incturno)
    (turnohum p)
    (limpiasi)))

; --- pantalla de bienvenida---
(defun titulo ()
  (progn
    (display "*********************")
    (newline)
    (display "*   TRES EN RAYA    *")
    (newline)
    (display "*   vs la maquina   *")
    (newline)
    (display "*********************")
    (newline)))

(defun ayuda1 ()
  (progn
    (display "Posiciones del tablero:")
    (newline)
    (display "  1 2 3")
    (newline)))

(defun ayuda2 ()
  (progn
    (display "  4 5 6")
    (newline)
    (display "  7 8 9")
    (newline)))

(defun ayuda3 ()
  (progn
    (display "Jugar: (mover posicion)")
    (newline)
    (display "Ejemplo: (mover 5)")
    (newline)))

(defun ayuda4 ()
  (progn
    (display "Reiniciar: (reset)")
    (newline)))

(defun bienve ()
  (progn
    (titulo)
    (ayuda1)
    (ayuda2)
    (ayuda3)
    (ayuda4)
    (tabla tablero)))

; --- se muestra sola al cargar el archivo ---
(bienve)
