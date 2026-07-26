## TIC TAC TOE PARA MyLISP

***Creado por Miguel Ángel Rojo***

Este repositorio contiene una implementación clásica del juego del Tres en Raya (Tic-Tac-Toe) escrita en MyLISP, diseñada para ejecutarse en entornos retro como el Sinclair QL o el ZX Spectrum Next .

El juego enfrenta al usuario (Jugador 1, `X`) contra la máquina (Jugador 2, `O`). La IA no utiliza números aleatorios; implementa un árbol de decisión determinista basado en prioridades estratégicas absolutas .

## 🕹️ Cómo jugar

1. **Cargar el juego:** En el REPL de MyLISP, carga el archivo principal:
   ```lisp
   (load "iatresraya")


Al cargarse, el sistema mostrará automáticamente la pantalla de bienvenida y el tablero vacío .  

1. **Realizar un movimiento:** El tablero está numerado del 1 al 9. Para colocar tu ficha (`X`), utiliza la función `mover` pasando la posición deseada:

   Lisp

   ```
   (mover 5)
   ```

   La máquina evaluará el tablero y responderá automáticamente con su movimiento.

2. **Reiniciar la partida:** Si la partida termina (victoria, derrota o empate), o si deseas empezar de cero, ejecuta:

   Lisp

   ```
   (reset)
   ```

*Mapa de posiciones:*

Plaintext

```
  1 2 3
  4 5 6
  7 8 9
```

## 🏗️ Arquitectura y Construcción

El programa está diseñado bajo un paradigma mayoritariamente funcional, mitigando las limitaciones de memoria de los sistemas de 8 y 32 bits clásicos.

### Decisiones de Diseño

1. **Estructura de Datos:** El tablero no es una matriz bidimensional, sino una lista plana de 9 elementos `'(0 0 0 0 0 0 0 0 0)`. El valor `0` indica casilla vacía, `1` es el jugador humano y `2` la máquina .  
2. **Mutación Controlada:** Aunque LISP promueve la inmutabilidad, el estado del juego (`tablero` y `turno`) se mantiene en variables globales mutadas mediante `define` . Esto evita arrastrar el estado a través de infinitas recursiones en el REPL.  
3. **Estrategia Heurística Pura (IA):** En lugar de implementar Minimax (que saturaría la memoria y la pila de llamadas en sistemas retro), la IA utiliza una heurística secuencial de cortocircuito (`iamov` a `iamov4`) :  
   - **Ganar:** Si hay una línea con dos `O` y un hueco, ocupa el hueco.
   - **Bloquear:** Si hay una línea con dos `X` y un hueco, ocupa el hueco.
   - **Centro:** Ocupa la casilla 5 si está libre.
   - **Esquinas:** Ocupa la primera esquina libre (1, 3, 7, 9).
   - **Bordes:** Ocupa el primer borde libre (2, 4, 6, 8).
4. **Gestión de Memoria (GC):** Dado que MyLISP/QL tiene un heap limitado, el juego incluye un recolector de basura explícito `(clean)` que se dispara en turnos pares para evitar el desbordamiento de memoria durante partidas prolongadas .  

## 🛠️ Referencia de Funciones

El código está estructurado en pequeños bloques de una sola responsabilidad para facilitar la legibilidad y la recursión.

### 1. Manipulación y Acceso a Datos

- `(elem k lst)`: Devuelve el elemento en la posición `k` de la lista (índice base 1) .  
- `(pon k v lst)`: Reconstruye y devuelve una nueva lista insertando el valor `v` en la posición `k` .  
- `(simb v)`: Traduce los valores enteros (`0`, `1`, `2`) a sus representaciones en cadena (`"-"`, `"X"`, `"O"`) .  

### 2. Representación Visual (Salida)

- `(filatr lst p)`: Imprime una fila del tablero a partir del índice `p` .  
- `(tabla lst)`: Imprime el tablero completo llamando a `filatr` tres veces .  
- `(msgocup lst)`, `(msggano nuevo j)`, `(msgemp nuevo)`, `(msgturno)`: Funciones de renderizado de mensajes de estado .  
- `(titulo)`, `(ayuda1...4)`, `(bienve)`: Muestran la cabecera y las instrucciones al iniciar .  

### 3. Lógica de Reglas y Estado

- `(lineas)`: Devuelve una lista constante con las 8 ternas ganadoras posibles .  
- `(linea3 lst a b c)` / `(linea3t lst tri)`: Evalúa si tres índices específicos contienen la misma ficha y no están vacíos .  
- `(chklin lst lns)`: Itera recursivamente sobre las combinaciones para encontrar una línea ganadora .  
- `(gano lst)` / `(lleno lst)`: Predicados de fin de partida (victoria o empate) .  
- `(ocupada lst p)` / `(libre lst p)`: Predicados de disponibilidad de casilla .  

### 4. Inteligencia Artificial

- `(chkfila lst j a b c)`: Evalúa una línea buscando si tiene dos fichas del jugador `j` y un hueco. Devuelve el índice del hueco o `0` .  
- `(buscaf lst j lns)` / `(buscaf2 lst j lns)`: Busca recursivamente una jugada clave (ganar o bloquear) en todas las líneas .  
- `(ganamov lst)` / `(bloqmov lst)`: Wrappers de `buscaf` para la máquina (`2`) y el humano (`1`) respectivamente .  
- `(esquinas)` / `(bordes)`: Devuelven listas con los índices correspondientes .  
- `(primlib lst lns)`: Busca y devuelve la primera casilla libre de una lista de candidatos .  
- `(iamov lst)` -> `(iamov2)` -> `(iamov3)` -> `(iamov4)`: Cadena de evaluación prioritaria (Cascada Estratégica). Cada función comprueba una regla y si falla delega en la siguiente .  

### 5. Control de Flujo y Turnos

- `(inicio)`: Devuelve un tablero vacío .  
- `(incturno)`, `(tocalimp)`, `(limpiasi)`: Gestión manual de la recolección de basura cada dos turnos .  
- `(reset)`: Restablece las variables globales `tablero` y `turno` .  
- `(mover p)` / `(mover2 p)`: Entrada principal del usuario. Valida y delega .  
- `(turnohum p)` / `(turnh2)`: Aplica el movimiento del usuario y comprueba condición de victoria antes de pasar el turno [cite: 2].
- `(turnomaq)` / `(turnm2)`: Aplica el movimiento de la IA y verifica estado de victoria [cite: 2].

