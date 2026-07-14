# MyLISP v1.0 — Referencia Técnica

Intérprete LISP para Sinclair QL desarrollado en Pro Pascal (Prospero) bajo QDOS.
Diseñado como motor de álgebra computacional (CAS): prioriza la exactitud
matemática sobre la comodidad, el ámbito léxico estricto, y la seguridad
aritmética sobre tipos concretos.

---

## 1. Arquitectura general

MyLISP implementa un intérprete LISP clásico con las siguientes capas:

- **Lexer**: tokeniza la entrada carácter a carácter, detectando literales
  numéricos (enteros, racionales, flotantes), símbolos, strings y delimitadores.
- **Parser**: construye el árbol de sintaxis abstracta (AST) como una estructura
  de pares enlazados en el heap.
- **Evaluador**: `Eval`/`Apply` mutuamente recursivos con ámbito léxico. El
  entorno (`env`) se pasa siempre por valor para preservar la semántica
  funcional en cada nivel de recursión.
- **Heap**: array estático de 24.000 celdas gestionado con un recolector
  mark-sweep de cuatro fases (heap principal, tabla de reales, tabla de strings).
- **REPL**: bucle de lectura-evaluación-impresión con soporte de entrada
  multilinea y protección ante el límite de consola de QDOS.

---

## 2. Límites del sistema

MyLISP opera dentro de los siguientes límites fijos. El programador debe
tenerlos presentes al diseñar sus programas:

- **24.576 celdas** de heap disponibles para almacenar todas las listas,
  números, símbolos y funciones de la sesión. El recolector de basura recupera
  automáticamente las celdas que ya no se usan, pero las funciones con
  recursión muy profunda o que generan estructuras muy grandes pueden agotar
  este espacio.

- **256 símbolos distintos** como máximo en una sesión. Cada nombre de
  variable o función que se define ocupa una entrada. Los símbolos builtin del
  intérprete ya consumen algunas de estas entradas al arrancar.

- **8 caracteres** es la longitud máxima significativa de un nombre de
  símbolo. Los caracteres a partir del noveno se descartan silenciosamente.
  `MIFUNCION-LARGA` y `MIFUNCION-CORTA` serían el mismo símbolo
  (`MIFUNCIO`) — conviene que los primeros ocho caracteres sean únicos para
  cada función o variable.

- **128 números flotantes** y **64 strings** pueden existir simultáneamente
  en el heap. En uso normal estas tablas no se agotan, pero programas que
  manejen muchos números reales o carguen muchos ficheros seguidos pueden
  acercarse al límite.

- **80 caracteres** por expresión en el REPL interactivo. Expresiones más
  largas deben escribirse en fichero y cargarse con `LOAD`.

- **36 caracteres** de longitud máxima para un string (pensado para cubrir
  los nombres de fichero QDOS más largos).

---

## 3. Tipos de dato

MyLISP tiene siete tipos de celda internos:

| Tipo interno | Descripción | Ejemplo literal |
|---|---|---|
| `TINT` | Entero con signo de 32 bits | `42`, `-7` |
| `TRAT` | Racional exacto, siempre reducido a mínimos | `1/3`, `-5/2` |
| `TFLOAT` | Número en coma flotante | `3.0`, `-2.5` |
| `TSYM` | Símbolo (identificador LISP) | `X`, `MI-FUN?` |
| `TSTRING` | Cadena de texto entre comillas dobles | `"mdv1_fichero"` |
| `TPAIR` | Par `(car . cdr)`, estructura base de las listas | `(1 2 3)` |
| `TCLOSURE` | Función con su entorno léxico capturado | — |

Las constantes predefinidas `T` (verdad) y `NIL` (falso / lista vacía) son
símbolos especiales internos que siempre están vivos en el heap.

---

## 4. El sistema numérico: aritmética exacta

**Principio fundamental:** MyLISP nunca promueve silenciosamente un entero a
flotante. Esta decisión es deliberada e irrevocable: un CAS que convierte `13`
en `13.000001` por overflow silencioso produce resultados algebraicos
incorrectos que se propagan de forma indetectable.

### Tipos numéricos y sus reglas

**Entero (`TINT`):** rango de −2.147.483.647 a +2.147.483.647 (32 bits con
signo en el Sinclair QL). Si una operación amenaza con superar ese rango, se
interrumpe con `ERROR: valor fuera de rango` antes de producir el resultado
incorrecto.

**Racional (`TRAT`):** se genera automáticamente cuando `/` divide dos enteros
sin resto exacto. Se almacena y opera siempre en forma reducida por el MCD.
`(/ 4 6)` devuelve `2/3`, no `0.666`.

**Flotante (`TFLOAT`):** se genera solo cuando el literal lleva punto decimal
explícito (`3.0`, no `3`). Una vez que un operando es flotante, la operación
completa produce un flotante. El flotante es un tipo de entrada explícita, no
una salida automática del sistema.

### División: `/` vs `DIV`/`MOD`

| Expresión | Resultado | Tipo |
|---|---|---|
| `(/ 10 3)` | `10/3` | `TRAT` — fracción exacta |
| `(/ 10 2)` | `5` | `TINT` — resultado exacto |
| `(/ 1.0 3)` | `0.3333` | `TFLOAT` — un operando es float |
| `(DIV 10 3)` | `3` | `TINT` — cociente entero truncado hacia cero |
| `(MOD 10 3)` | `1` | `TINT` — resto, mismo signo que el dividendo |

`DIV` y `MOD` solo aceptan `TINT`. Pasar un racional o flotante produce error.

### Igualdad: `=` vs `EQUAL`

| Expresión | Resultado | Criterio |
|---|---|---|
| `(= 3 3.0)` | `T` | Mismo valor numérico, ignora el tipo |
| `(= 1/2 0.5)` | `T` | Mismo valor numérico |
| `(EQUAL 3 3.0)` | `NIL` | Tipos distintos (`TINT` ≠ `TFLOAT`) |
| `(EQUAL 1/2 1/2)` | `T` | Mismo tipo y mismo valor |
| `(EQ 'X 'X)` | `T` | Mismo símbolo interno |
| `(EQ '(1 2) '(1 2))` | `NIL` | Celdas distintas en el heap |

---

## 5. Sintaxis

### Identificadores

Los símbolos pueden contener letras, dígitos, y los caracteres `-`, `?`, `!` y `<`
en cualquier posición salvo la primera. Solo los primeros 8 caracteres son
significativos.

```lisp
MI-FUNCION   ; valido
PAR?         ; valido (convencion: predicados terminan en ?)
STR<         ; valido (convencion: comparadores terminan en <)
CONTADOR!    ; valido (raro en LISP puro, mas comun en Scheme)
3X           ; invalido: no puede comenzar por digito
```

### Strings

Los strings se escriben entre comillas dobles y admiten cualquier carácter,
incluido el guión bajo que los símbolos no pueden tener. Su uso principal es
pasar nombres de fichero QDOS a `LOAD`. Máximo 36 caracteres.

```lisp
"mdv1_mi_biblioteca"   ; nombre de fichero QDOS valido
"hola mundo"           ; string con espacio
```

### Comentarios

El carácter `;` inicia un comentario que se extiende hasta el final de la línea.
Válido tanto en el REPL como en ficheros cargados con `LOAD`.

```lisp
; esto es un comentario completo
(+ 1 2)   ; esto tambien es un comentario
```

### Racionales literales

```lisp
1/3    ; almacenado directamente como TRAT
4/8    ; reducido automaticamente a 1/2
```

---

## 6. Inmutabilidad

MyLISP no implementa `SETQ` ni ninguna forma de modificación de bindings
existentes. Esta es una **decisión de diseño deliberada**, no una limitación
técnica. Una vez que un símbolo queda ligado a un valor (por `DEFINE`, `DEFUN`,
o un parámetro de función), ese binding es permanente en ese entorno.

`DEFINE` siempre añade un nuevo binding en el entorno global. Si se define el
mismo símbolo dos veces, la segunda definición añade una nueva entrada que
sombrea a la anterior durante las búsquedas, pero no modifica la celda original.

Para algoritmos que requieren estado mutable, la solución idiomática en MyLISP
es usar parámetros acumuladores en funciones recursivas:

```lisp
; En vez de mutar una variable, pasar el estado como parametro
(DEFUN SUMA-LISTA (L ACC)
  (IF (NULL L) ACC
      (SUMA-LISTA (CDR L) (+ ACC (CAR L)))))

(SUMA-LISTA '(1 2 3 4 5) 0)   ; -> 15
```

---

## 7. Ámbito léxico y clausuras

`LAMBDA` captura el entorno léxico en el momento de su creación. Esto permite
fábricas de funciones y funciones de orden superior:

```lisp
(DEFINE crear-sumador
  (LAMBDA (n)
    (LAMBDA (x) (+ x n))))

(DEFINE suma5 (crear-sumador 5))
(suma5 10)   ; -> 15  (n queda capturado como 5)
```

**`DEFUN` como azúcar sintáctico:**
`(DEFUN F (X) cuerpo)` es exactamente equivalente a
`(DEFINE F (LAMBDA (X) cuerpo))`.

**`LET` y el entorno:**
Los valores de los bindings de `LET` se evalúan todos en el entorno anterior,
no entre sí. Esto distingue `LET` de `LET*`:

```lisp
(LET ((X 1)
      (Y X))    ; X aqui es el X del entorno exterior, no el 1 recien definido
  (+ X Y))
```

**Espacio de nombres único (Lisp-1):**
MyLISP usa un único entorno para variables y funciones. Si defines una variable
con el mismo nombre que una función builtin, la sobrescribirás:

```lisp
(DEFINE LIST 5)   ; LIST ya no funciona como funcion
(LIST 1 2 3)      ; ERROR: 5 no es una funcion
```

---

## 8. Formas especiales

Las formas especiales no evalúan todos sus argumentos de la forma estándar.

| Forma | Evaluación |
|---|---|
| `(QUOTE expr)` o `'expr` | No evalúa `expr` |
| `(IF test then)` | Evalúa solo `test`; si verdadero, evalúa `then`; si falso, devuelve `NIL` |
| `(IF test then else)` | Evalúa `test`; evalúa solo la rama elegida |
| `(COND (t1 e1) ...)` | Evalúa los tests en orden; para en el primero verdadero |
| `(AND e1 e2 ...)` | Cortocircuito: para en el primer `NIL`; devuelve el último valor |
| `(OR e1 e2 ...)`  | Cortocircuito: para en el primer no-`NIL`; devuelve ese valor |
| `(PROGN e1 e2 ...)` | Evalúa todas en orden; devuelve el valor de la última |
| `(LET ((v1 e1) ...) cuerpo)` | Evalúa los `ei` en el entorno actual; evalúa `cuerpo` en el nuevo entorno |
| `(LAMBDA (params) cuerpo)` | Crea una clausura sin evaluar el cuerpo |
| `(DEFINE sym val)` | Evalúa `val`; añade binding en el entorno global |
| `(DEFUN f (params) cuerpo)` | Azúcar para `(DEFINE f (LAMBDA ...))` |
| `(LOAD "fichero")` | No evalúa el nombre; lee y evalúa el fichero |
| `(EVAL expr)` | Evalúa `expr` y luego vuelve a evaluar el resultado en `GlobalEnv` |
| `(STATUS)` | Muestra el estado de todas las tablas internas: heap, símbolos, strings y reales. Devuelve `VOID` |
| `(CLEAN)` | Fuerza una recolección de basura inmediata mostrando el antes y después. Devuelve `VOID` |
| `(NEW)` | Reinicia el intérprete pidiendo confirmación. Borra todas las definiciones del usuario. Devuelve `VOID` |
| `(SYMBOLS)` | Lista todos los símbolos definidos por el usuario en el entorno global. Devuelve `VOID` |

---

## 9. Gestión de memoria y recolector de basura

### El heap

El heap es un array estático de 24.000 celdas preasignado en memoria en tiempo
de compilación. No hay asignación dinámica de memoria del sistema operativo.
Cada celda contiene un tag de tipo, un campo `car` y un campo `cdr`.

Adicionalmente existen tres tablas auxiliares:
- `realtab`: valores flotantes (máx. 128 entradas)
- `strtab`: contenidos de strings (máx. 64 entradas, 36 caracteres cada una)
- `symtab`: nombres de símbolos (máx. 256 entradas, 8 caracteres cada una)

### El recolector mark-sweep

El GC se dispara automáticamente entre iteraciones del REPL cuando el heap
supera el 80% de ocupación, y durante la carga de ficheros cuando supera el
50%. El programador **nunca lo invoca manualmente** y **nunca recibe ningún
mensaje** cuando se ejecuta — es completamente transparente.

El proceso tiene cuatro fases:
1. **Marcar**: recorre el grafo de celdas vivas desde la raíz (`GlobalEnv`,
   `NIL` y `T`) marcando cada celda alcanzable.
2. **Barrer**: libera las celdas no marcadas al `freelist` (lista de celdas
   reutilizables).
3. **Compactar `realtab`**: elimina los flotantes huérfanos y actualiza los
   índices en las celdas `TFLOAT`.
4. **Compactar `strtab`**: elimina los strings huérfanos y actualiza los
   índices en las celdas `TSTRING`.

`symtab` no se compacta: los símbolos se internan una sola vez y son
permanentes en la sesión.

### Agotamiento del heap

Si el heap se agota en medio de una evaluación (situación que el GC no puede
resolver porque podría barrer celdas vivas en la pila de llamadas de Pascal),
el intérprete activa los flags `HeapError` y `ErrorFlag` para cortar la
recursión de forma ordenada. Al volver al REPL, se produce un reinicio
completo del heap: **todas las definiciones del usuario se pierden**.

Tras el reinicio el intérprete sigue funcionando y muestra el prompt `>` con
normalidad. El programador debe recargar sus bibliotecas con `LOAD`.

---

## 10. El REPL y sus límites

### Entrada multilinea

Si una expresión tiene paréntesis sin cerrar al final de la línea, el REPL
muestra `..` y espera la continuación. Las líneas se acumulan internamente
hasta que los paréntesis quedan balanceados.

### Límite de 80 caracteres

El driver de consola de QDOS gestiona un buffer de edición de teclado de
aproximadamente 80 caracteres por línea. Este límite es **del sistema
operativo**, no del intérprete: ocurre antes de que `READLN` entregue la
entrada al programa.

MyLISP mide la longitud acumulada del buffer antes de pedir cada nueva línea
en modo multilinea. Si añadir la siguiente línea haría que el total superara
los 80 caracteres, el intérprete **no intenta leerla** y muestra:

```
ERROR: expresion demasiado larga
Usa LOAD para expresiones de mas de 80 caracteres
```

Este límite **no afecta a `LOAD`**: los ficheros se leen byte a byte desde la
microdrive sin pasar por el driver de teclado, usando un buffer de 500
caracteres. Cualquier función que no quepa en 80 caracteres debe escribirse en
un fichero y cargarse con `LOAD`.

### Recomendación de estilo para el REPL

- Expresiones simples y pruebas rápidas: directamente en el REPL.
- Definiciones de funciones, bibliotecas, programas: siempre en fichero con `LOAD`.
- En los ficheros, partir las definiciones largas en varias líneas cortas
  (cada una menor de 80 caracteres por compatibilidad con los editores del QL).

---

## 11. La función LOAD

```lisp
(LOAD "mdv1_mibiblioteca")   ; forma principal, admite _ y caracteres especiales
(LOAD 'MIBIBL)               ; alternativa si el nombre no tiene _ ni espacios
```

`LOAD` lee el fichero línea a línea, acumulando hasta que los paréntesis
quedan balanceados, y evalúa cada expresión completa. Los resultados se
muestran igual que en el REPL. Los errores en una expresión **no detienen la
carga**: el intérprete muestra el error y continúa con la siguiente expresión.

El GC puede dispararse durante la carga si el heap supera el 50% de ocupación.

---

## 12. Referencia rápida de primitivas

### Constructores y selectores de lista

| Función | Descripción |
|---|---|
| `(CAR lista)` | Primer elemento. Error si `lista` es `NIL` o un átomo |
| `(CDR lista)` | Resto. Error si `lista` es `NIL` o un átomo |
| `(CONS x lista)` | Nuevo par con `x` como `car` y `lista` como `cdr` |
| `(LIST e1 e2 ...)` | Nueva lista con todos los argumentos |
| `(APPEND l1 l2)` | Concatena dos listas. `l1` se reconstruye; `l2` se comparte |

### Predicados

| Función | Descripción |
|---|---|
| `(ATOM x)` | `T` si `x` no es un par (número, símbolo, string, `NIL`) |
| `(NULL x)` | `T` si `x` es `NIL` |
| `(NOT x)` | `T` si `x` es `NIL`; `NIL` en cualquier otro caso |
| `(NUMBERP x)` | `T` si `x` es `TINT`, `TRAT` o `TFLOAT` |
| `(SYMBOLP x)` | `T` si `x` es `TSYM` |
| `(LISTP x)` | `T` si `x` es `TPAIR` o `NIL` |
| `(EQ x y)` | `T` si son el mismo símbolo o la misma celda en memoria |
| `(EQUAL x y)` | `T` si tienen la misma estructura y el mismo tipo exacto |

### Aritmética

| Función | Descripción |
|---|---|
| `(+ e1 e2 ...)` | Suma variádica. `(+)` → `0` |
| `(- e1 e2 ...)` | Resta variádica. `(- x)` → negación |
| `(* e1 e2 ...)` | Multiplicación variádica. `(*)` → `1` |
| `(/ e1 e2 ...)` | División exacta. Produce `TRAT` si no hay resto exacto |
| `(DIV a b)` | Cociente entero. Solo `TINT`. Trunca hacia cero |
| `(MOD a b)` | Resto entero. Solo `TINT`. Mismo signo que `a` |

### Comparadores

| Función | Descripción |
|---|---|
| `(= a b)` | Igualdad de valor numérico (ignora el tipo) |
| `(< a b)`, `(> a b)` | Menor / mayor estrictos |
| `(<= a b)`, `(>= a b)` | Menor o igual / mayor o igual |

### Utilidades

| Función | Descripción |
|---|---|
| `(EVAL expr)` | Evalúa `expr` como código en el entorno global |
| `(PRINT x)` | Imprime `x` con comillas alrededor de los strings y con salto de línea. Devuelve `x`. Uso: depuración |
| `(DISPLAY x)` | Imprime `x` sin comillas y **sin salto de línea**. Para `TSTRING` muestra el contenido puro. Devuelve un valor especial que el REPL no imprime. Uso: salida para el usuario |
| `(NEWLINE)` | Emite un salto de línea. Sin argumentos. Complemento natural de `DISPLAY` |
| `(SYMNAME sym)` | Convierte un símbolo a string. Devuelve un `TSTRING` con el nombre internado del símbolo. El resultado está truncado a 8 caracteres (límite de `SYMLEN`) |
| `(STR< a b)` | Comparación alfabética. Devuelve `T` si `a` precede lexicográficamente a `b`. Acepta `TSTRING` o `TSYM` |
| `(STRCAT a b)` | Concatena dos valores convirtiéndolos a string. Acepta `TSTRING`, `TSYM`, `TINT`, `TRAT`. No soporta `TFLOAT`. El resultado se trunca a 36 caracteres |

---

## 13. Consejos de programación

### Strings vs símbolos: cuándo usar cada uno

MyLISP tiene dos tipos para representar texto: **símbolos** (`TSYM`) y **strings**
(`TSTRING`). Aunque a primera vista parecen intercambiables para algunos usos,
tienen características muy distintas que afectan al rendimiento y a los límites
del sistema.

| Característica | Símbolo | String |
|---|---|---|
| Longitud máxima | 8 caracteres | 36 caracteres |
| Tabla que usa | `symtab` (256 entradas) | `strtab` (64 entradas) |
| Gestión por el GC | Permanente — nunca se libera | Se libera cuando no hay referencias |
| Autoevalúa a | Su valor en el entorno (o error) | El propio string |
| Uso típico | Nombres de funciones y variables | Nombres de fichero para `LOAD` |

**Regla práctica:** usa símbolos para etiquetas, nombres de test, identificadores
internos y cualquier texto corto que se repita. Usa strings solo cuando necesites
caracteres que los símbolos no permiten (como `_` en nombres de fichero QDOS) o
cuando el texto supere los 8 caracteres significativos.

**Ejemplo concreto — banco de pruebas:**

Un error típico al escribir funciones de test es usar strings como etiquetas:

```lisp
; MAL: cada llamada crea una celda TSTRING en strtab (limite: 50)
(CHECK "test suma" (+ 1 2) 3)
(CHECK "test resta" (- 5 3) 2)
; ... con 64+ tests, la tabla de strings se agota
```

La solución es usar símbolos como etiquetas:

```lisp
; BIEN: los simbolos usan symtab (limite: 200) y son permanentes
(CHECK 'test-suma (+ 1 2) 3)
(CHECK 'test-resta (- 5 3) 2)
```

El resultado visible al fallar un test es igual de claro, y el programa puede
tener hasta 256 tests sin problemas de memoria.

### DISPLAY vs PRINT: cuándo usar cada uno

| | `PRINT` | `DISPLAY` |
|---|---|---|
| Strings | Con comillas: `"hola"` | Sin comillas: `hola` |
| Salto de línea | Siempre, automático | Nunca — usa `(NEWLINE)` |
| Valor de retorno | El propio valor (visible en REPL) | `VOID` (el REPL no lo imprime) |
| Uso típico | Depuración, ver el tipo exacto | Salida para el usuario final |

Para construir una línea de salida pieza a pieza:

```lisp
(DISPLAY "resultado: ")
(DISPLAY (+ 2 3))
(NEWLINE)
; imprime: resultado: 5
```

Nota: `(DISPLAY 42)` en el REPL interactivo muestra `42` y el cursor queda en la misma línea justo antes del prompt `>`. Es el comportamiento estándar de Scheme — el programador controla los saltos de línea con `(NEWLINE)`.

### Comparación y ordenación de símbolos

Para comparar símbolos alfabéticamente, MyLISP ofrece dos primitivas inspiradas
en el estilo Scheme (Lisp-1):

- **`SYMNAME`**: convierte un símbolo a string para poder compararlo
- **`STR<`**: compara dos strings o símbolos lexicográficamente

```lisp
(STR< "ALFA" "BETA")              ; -> T
(STR< (SYMNAME 'BETA) (SYMNAME 'ALFA))  ; -> NIL
```

Con estas dos primitivas se puede definir un comparador de símbolos en una
línea, que sirve como argumento a funciones de ordenación:

```lisp
(DEFUN SYM< (A B) (STR< (SYMNAME A) (SYMNAME B)))
(SYM< 'ALFA 'BETA)   ; -> T
(SYM< 'ZETA 'ALFA)   ; -> NIL
```

`STR<` también acepta símbolos directamente sin pasar por `SYMNAME`, lo que
evita crear una celda `TSTRING` intermedia:

```lisp
(STR< 'ALFA 'BETA)   ; -> T  (mas eficiente que usar SYMNAME)
```



### Herramientas de diagnóstico y control de sesión

MyLISP incluye cuatro formas especiales pensadas para la gestión interactiva
de la sesión y el diagnóstico de problemas de memoria:

**`(STATUS)`** muestra el estado de todas las tablas internas:

```
Heap:       245/24576  (1%)
Simbolos:    47/200
Strings:     12/50
Reales:       3/100
```

Útil para saber cuántos recursos consume el programa antes de ejecutar
operaciones intensivas.

**`(CLEAN)`** fuerza una recolección de basura inmediata aunque no se hayan
alcanzado los umbrales automáticos. Muestra el antes y después. Útil antes
de operaciones que van a generar muchas estructuras temporales, o para
liberar espacio cuando `STATUS` muestra que `strtab` está casi llena.

**`(NEW)`** reinicia el intérprete completamente pidiendo confirmación antes
de borrar todas las definiciones. Equivalente a cerrar y volver a arrancar.

**`(SYMBOLS)`** lista todos los símbolos definidos por el usuario en el
entorno global. Útil para ver qué hay disponible en la sesión actual.

### Strings temporales y strtab

A diferencia de los símbolos, los strings son objetos temporales gestionados
por el GC. Cada vez que el intérprete evalúa `"mi texto"`, crea una nueva
celda `TSTRING` en `strtab`. El GC puede liberar esas celdas cuando ya no
hay referencias a ellas, pero durante la ejecución de un programa largo con
muchos strings activos simultáneamente, la tabla puede llenarse.

Si un programa necesita más de 64 strings simultáneos, la alternativa es
dividir el programa en partes más pequeñas que se carguen y ejecuten por
separado con `LOAD`.

### Nombres de símbolo y el límite de 8 caracteres

Solo los primeros 8 caracteres de un nombre de símbolo son significativos.
Los caracteres adicionales se descartan silenciosamente. Esto puede causar
colisiones inesperadas:

```lisp
(DEFUN CALCULAR-SUMA (X Y) (+ X Y))
(DEFUN CALCULAR-PROD (X Y) (* X Y))
; Ambas se almacenan como CALCULAN -- son el mismo simbolo
; La segunda definicion sobrescribe a la primera
```

Conviene diseñar los nombres de función y variable de forma que los primeros
8 caracteres sean únicos y descriptivos.
