# MyLISP v1.0 — Technical Reference

LISP interpreter for the Sinclair QL, written in Pro Pascal (Prospero) under QDOS.
Designed as a computer algebra system (CAS) engine: it prioritises mathematical
exactness over convenience, strict lexical scoping, and arithmetic safety over
concrete types.

---

## 1. General architecture

MyLISP implements a classic LISP interpreter with the following layers:

- **Lexer**: tokenises input character by character, recognising numeric literals
  (integers, rationals, floats), symbols, strings and delimiters.
- **Parser**: builds the abstract syntax tree (AST) as a structure of linked
  pairs on the heap.
- **Evaluator**: mutually recursive `Eval`/`Apply` with lexical scoping. The
  environment (`env`) is always passed by value to preserve functional semantics
  at each level of recursion.
- **Heap**: a static array of 24,576 cells managed by a four-phase mark-sweep
  collector (main heap, reals table, strings table).
- **REPL**: read-eval-print loop with multiline input support and protection
  against the QDOS console limit.

---

## 2. System limits

MyLISP operates within the following fixed limits. Programmers should be aware
of them when designing programs:

- **24,576 cells** of heap available for all lists, numbers, symbols and
  functions in the session. The garbage collector automatically reclaims cells
  that are no longer referenced, but deeply recursive functions or programs
  that generate very large structures may exhaust this space.

- **256 distinct symbols** maximum per session. Each variable or function name
  defined by the user occupies one entry. The interpreter's built-in symbols
  already consume some of these entries at startup.

- **8 characters** is the maximum significant length of a symbol name.
  Characters beyond the eighth are silently discarded. `MYFUNCTION-A` and
  `MYFUNCTION-B` would be the same symbol (`MYFUNCTI`) — names should differ
  within the first eight characters to avoid silent collisions.

- **128 floating-point numbers** and **64 strings** can exist simultaneously
  on the heap. In normal use these tables do not fill up, but programs that
  handle many real numbers or load many files in sequence may approach the limit.

- **80 characters** per expression in the interactive REPL. Longer expressions
  must be written to a file and loaded with `LOAD`.

- **36 characters** maximum length for a string (designed to cover the longest
  QDOS file names).

---

## 3. Data types

MyLISP has seven internal cell types:

| Internal type | Description | Literal example |
|---|---|---|
| `TINT` | Signed 32-bit integer | `42`, `-7` |
| `TRAT` | Exact rational, always reduced to lowest terms | `1/3`, `-5/2` |
| `TFLOAT` | Floating-point number | `3.0`, `-2.5` |
| `TSYM` | Symbol (LISP identifier) | `X`, `MY-FUN?` |
| `TSTRING` | Text string between double quotes | `"mdv1_file"` |
| `TPAIR` | Pair `(car . cdr)`, the base structure for lists | `(1 2 3)` |
| `TCLOSURE` | Function with its captured lexical environment | — |

The predefined constants `T` (true) and `NIL` (false / empty list) are special
internal symbols that are always alive on the heap.

---

## 4. The numeric system: exact arithmetic

**Fundamental principle:** MyLISP never silently promotes an integer to a float.
This is a deliberate design decision: a CAS that silently converts `13` to
`13.000001` due to overflow produces algebraically incorrect results that
propagate without any warning.

### Numeric types and their rules

**Integer (`TINT`):** range −2,147,483,647 to +2,147,483,647 (32-bit signed on
the Sinclair QL). If an operation would exceed that range, it is interrupted
with `ERROR: value out of range` before producing an incorrect result.

**Rational (`TRAT`):** generated automatically when `/` divides two integers
without an exact remainder. Always stored and operated in reduced form using
the GCD. `(/ 4 6)` returns `2/3`, not `0.666`.

**Float (`TFLOAT`):** generated only when the literal contains an explicit
decimal point (`3.0`, not `3`). Once one operand is a float, the whole
operation produces a float. Float is an explicit input type, not an automatic
system output.

### Division: `/` vs `DIV`/`MOD`

| Expression | Result | Type |
|---|---|---|
| `(/ 10 3)` | `10/3` | `TRAT` — exact fraction |
| `(/ 10 2)` | `5` | `TINT` — exact result |
| `(/ 1.0 3)` | `0.3333` | `TFLOAT` — one operand is float |
| `(DIV 10 3)` | `3` | `TINT` — integer quotient, truncated toward zero |
| `(MOD 10 3)` | `1` | `TINT` — remainder, same sign as dividend |

`DIV` and `MOD` accept only `TINT`. Passing a rational or float gives an error.

### Equality: `=` vs `EQUAL`

| Expression | Result | Criterion |
|---|---|---|
| `(= 3 3.0)` | `T` | Same numeric value, ignores type |
| `(= 1/2 0.5)` | `T` | Same numeric value |
| `(EQUAL 3 3.0)` | `NIL` | Different types (`TINT` ≠ `TFLOAT`) |
| `(EQUAL 1/2 1/2)` | `T` | Same type and same value |
| `(EQ 'X 'X)` | `T` | Same internal symbol |
| `(EQ '(1 2) '(1 2))` | `NIL` | Different heap cells |

---

## 5. Syntax

### Identifiers

Symbols may contain letters, digits, and the characters `-`, `?`, `!` and `<`
in any position except the first. Only the first 8 characters are significant.

```lisp
MY-FUNCTION   ; valid
EVEN?         ; valid (convention: predicates end in ?)
STR<          ; valid (convention: comparators end in <)
COUNTER!      ; valid
3X            ; invalid: cannot start with a digit
```

### Strings

Strings are written between double quotes and may contain any character,
including the underscore that symbols cannot have. Their primary use is passing
QDOS file names to `LOAD`. Maximum 36 characters.

```lisp
"mdv1_my_library"   ; valid QDOS file name
"hello world"       ; string with space
```

### Comments

The `;` character starts a comment that extends to the end of the line.
Valid both in the REPL and in files loaded with `LOAD`.

```lisp
; this is a full-line comment
(+ 1 2)   ; inline comment
```

### Rational literals

```lisp
1/3    ; stored directly as TRAT
4/8    ; automatically reduced to 1/2
```

---

## 6. Immutability

MyLISP does not implement `SETQ` or any form of binding mutation. This is a
**deliberate design decision**, not a technical limitation. Once a symbol is
bound to a value (by `DEFINE`, `DEFUN`, or a function parameter), that binding
is permanent within its environment.

`DEFINE` always adds a new binding to the global environment. If the same
symbol is defined twice, the second definition shadows the first during lookups,
but the original cell is not modified.

For algorithms that require mutable state, the idiomatic solution in MyLISP
is to use accumulator parameters in recursive functions:

```lisp
(DEFUN SUM-LIST (L ACC)
  (IF (NULL L) ACC
      (SUM-LIST (CDR L) (+ ACC (CAR L)))))

(SUM-LIST '(1 2 3 4 5) 0)   ; -> 15
```

---

## 7. Lexical scope and closures

`LAMBDA` captures the lexical environment at the moment of its creation:

```lisp
(DEFINE make-adder
  (LAMBDA (n)
    (LAMBDA (x) (+ x n))))

(DEFINE add5 (make-adder 5))
(add5 10)   ; -> 15
```

**`DEFUN` as syntactic sugar:**
`(DEFUN F (X) body)` is exactly equivalent to `(DEFINE F (LAMBDA (X) body))`.

**`LET` and the environment:**
Binding values in `LET` are all evaluated in the enclosing environment,
not relative to each other (this distinguishes `LET` from `LET*`):

```lisp
(LET ((X 1)
      (Y X))    ; X here is from the outer environment, not the 1 just defined
  (+ X Y))
```

**Single namespace (Lisp-1):**
MyLISP uses a single environment for both variables and functions. Defining
a variable with the same name as a builtin will shadow it.

---

## 8. Special forms

| Form | Evaluation |
|---|---|
| `(QUOTE expr)` or `'expr` | Does not evaluate `expr` |
| `(IF test then)` | Evaluates `test`; if true evaluates `then`; if false returns `NIL` |
| `(IF test then else)` | Evaluates `test`; evaluates only the chosen branch |
| `(COND (t1 e1) ...)` | Evaluates tests in order; stops at first true |
| `(AND e1 e2 ...)` | Short-circuit: stops at first `NIL`; returns last value |
| `(OR e1 e2 ...)`  | Short-circuit: stops at first non-`NIL`; returns that value |
| `(PROGN e1 e2 ...)` | Evaluates all in order; returns value of last |
| `(LET ((v1 e1) ...) body)` | Evaluates `ei` in current env; evaluates `body` in new env |
| `(LAMBDA (params) body)` | Creates a closure without evaluating the body |
| `(DEFINE sym val)` | Evaluates `val`; adds binding to global environment |
| `(DEFUN f (params) body)` | Sugar for `(DEFINE f (LAMBDA ...))` |
| `(LOAD "file")` | Does not evaluate the name; reads and evaluates the file |
| `(EVAL expr)` | Evaluates `expr` then re-evaluates the result in `GlobalEnv` |
| `(STATUS)` | Shows state of all internal tables. Returns `VOID` |
| `(CLEAN)` | Forces immediate garbage collection showing before/after. Returns `VOID` |
| `(NEW)` | Resets interpreter after confirmation. Erases all user definitions. Returns `VOID` |
| `(SYMBOLS)` | Lists all user-defined symbols in the global environment. Returns `VOID` |

---

## 9. Memory management and garbage collector

### The heap

The heap is a static array of 24,576 cells pre-allocated at compile time.
There is no dynamic memory allocation from the OS. Each cell contains a type
tag, a `car` field and a `cdr` field.

Three auxiliary tables:
- `realtab`: float values (max. 128 entries)
- `strtab`: string contents (max. 64 entries, 36 characters each)
- `symtab`: symbol names (max. 256 entries, 8 characters each)

### The mark-sweep collector

The GC fires automatically between REPL iterations when the heap exceeds 80%
or `strtab` exceeds 80% (51 entries), and during file loading when either
exceeds 50%. It is completely silent — no message is shown unless `(CLEAN)`
is used explicitly.

Four phases:
1. **Mark**: traverses live cells from the root (`GlobalEnv`, `NIL`, `T`).
2. **Sweep**: frees unmarked cells to the `freelist`.
3. **Compact `realtab`**: removes orphaned floats and updates `TFLOAT` indices.
4. **Compact `strtab`**: removes orphaned strings and updates `TSTRING` indices.

`symtab` is never compacted: symbols are interned once and are permanent
for the session.

### Heap exhaustion

If the heap is exhausted during evaluation, `HeapError` and `ErrorFlag` are
activated to cut the recursion in an orderly way. On returning to the REPL,
a complete heap reset occurs: **all user definitions are lost**. The interpreter
continues running normally. The programmer must reload their libraries with `LOAD`.

---

## 10. The REPL and its limits

### Multiline input

If an expression has unclosed parentheses at the end of a line, the REPL
shows `..` and waits for continuation. Lines are accumulated internally
until the parentheses are balanced.

### The 80-character limit

The QDOS console driver manages a keyboard editing buffer of approximately
80 characters per line. This limit belongs to the **operating system**, not
the interpreter. MyLISP measures the accumulated buffer length before requesting
each new line. If adding the next line would push the total beyond 80 characters,
the interpreter does not attempt to read it and shows an error message.

This limit **does not affect `LOAD`**: files are read byte by byte from the
microdrive without going through the keyboard driver, using a 500-character
buffer.

---

## 11. The LOAD function

```lisp
(LOAD "mdv1_my_library")   ; main form, supports _ and special characters
(LOAD 'MYLIB)              ; alternative if the name has no _ or spaces
```

Reads the file line by line, evaluates each complete expression, and shows
results as in the REPL. Errors in one expression do not stop the load.
The GC may fire during loading if the heap exceeds 50% occupancy.

---

## 12. Quick reference

### List constructors and selectors

| Function | Description |
|---|---|
| `(CAR list)` | First element. Error if `list` is `NIL` or an atom |
| `(CDR list)` | Rest after the first element |
| `(CONS x list)` | New pair with `x` as `car` and `list` as `cdr` |
| `(LIST e1 e2 ...)` | New list with all arguments |
| `(APPEND l1 l2)` | Concatenates two lists. `l1` is rebuilt; `l2` is shared |

### Predicates

| Function | Description |
|---|---|
| `(ATOM x)` | `T` if `x` is not a pair |
| `(NULL x)` | `T` if `x` is `NIL` |
| `(NOT x)` | `T` if `x` is `NIL`; `NIL` otherwise |
| `(NUMBERP x)` | `T` if `x` is `TINT`, `TRAT` or `TFLOAT` |
| `(SYMBOLP x)` | `T` if `x` is `TSYM` |
| `(LISTP x)` | `T` if `x` is `TPAIR` or `NIL` |
| `(EQ x y)` | `T` if same symbol or same heap cell |
| `(EQUAL x y)` | `T` if same structure and exact same type |

### Arithmetic

| Function | Description |
|---|---|
| `(+ e1 e2 ...)` | Variadic sum. `(+)` → `0` |
| `(- e1 e2 ...)` | Variadic subtraction. `(- x)` → negation |
| `(* e1 e2 ...)` | Variadic multiplication. `(*)` → `1` |
| `(/ e1 e2 ...)` | Exact division. Produces `TRAT` if no exact remainder |
| `(DIV a b)` | Integer quotient. `TINT` only. Truncates toward zero |
| `(MOD a b)` | Integer remainder. `TINT` only. Same sign as `a` |

### Comparators

| Function | Description |
|---|---|
| `(= a b)` | Numeric value equality (ignores type) |
| `(< a b)`, `(> a b)` | Strict less / greater than |
| `(<= a b)`, `(>= a b)` | Less or equal / greater or equal |

### Utilities

| Function | Description |
|---|---|
| `(EVAL expr)` | Evaluates `expr` as code in the global environment |
| `(PRINT x)` | Prints `x` with quotes around strings and newline. Returns `x` |
| `(DISPLAY x)` | Prints `x` without quotes and without newline. Returns `VOID` |
| `(NEWLINE)` | Emits a newline. No arguments |
| `(SYMNAME sym)` | Converts symbol to string. Result truncated to 8 characters |
| `(STR< a b)` | Alphabetical comparison. Accepts `TSTRING` or `TSYM` |
| `(STRCAT a b)` | Concatenates two values as strings. No `TFLOAT` support |

---

## 13. Programming tips

### Strings vs symbols

| Characteristic | Symbol | String |
|---|---|---|
| Maximum length | 8 characters | 36 characters |
| Table used | `symtab` (256 entries) | `strtab` (64 entries) |
| GC management | Permanent — never freed | Freed when no references remain |
| Typical use | Function and variable names | File names for `LOAD` |

Use symbols for labels, test names and short repeated text. Use strings only
when you need characters that symbols do not allow or text longer than 8
significant characters.

**Test suite example:**

```lisp
; BAD: creates TSTRING cells (limit: 64)
(CHECK "test sum" (+ 1 2) 3)

; GOOD: uses symtab (limit: 256)
(CHECK 'test-sum (+ 1 2) 3)
```

### DISPLAY vs PRINT

| | `PRINT` | `DISPLAY` |
|---|---|---|
| Strings | With quotes: `"hello"` | Without quotes: `hello` |
| Newline | Automatic | Never — use `(NEWLINE)` |
| Return value | The value itself | `VOID` |
| Use | Debugging | User output |

```lisp
(DISPLAY "result: ")
(DISPLAY (+ 2 3))
(NEWLINE)
; prints: result: 5
```

### Diagnostic tools

- **`(STATUS)`** — shows heap, symbols, strings and reals occupancy
- **`(CLEAN)`** — forces immediate GC showing before/after stats
- **`(NEW)`** — resets interpreter after confirmation
- **`(SYMBOLS)`** — lists all user-defined symbols

### Symbol comparison and sorting

```lisp
(DEFUN SYM< (A B) (STR< (SYMNAME A) (SYMNAME B)))
(SYM< 'ALFA 'BETA)   ; -> T
```

`STR<` also accepts symbols directly, avoiding an intermediate `TSTRING`:

```lisp
(STR< 'ALFA 'BETA)   ; -> T  (more efficient)
```

### The 8-character symbol limit

Only the first 8 characters are significant. Design names so that the first
8 characters are unique for each function or variable to avoid silent collisions.
