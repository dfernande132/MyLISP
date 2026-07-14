PROCEDURE InitMessages;
{ Messages in English -- replace with MSGS_ES for
  the Spanish version }
BEGIN
  { --- Critical memory errors (red text) --- }
  MsgHeapAgotado         := '*** HEAP EXHAUSTED ***';
  MsgTablaSimbolos       := '*** SYMBOL TABLE FULL ***';
  MsgTablaStrings        := '*** STRING TABLE FULL ***';
  MsgTablaReales         := '*** REAL TABLE FULL ***';
  MsgHeapReinicio        := '*** All definitions have been lost ***';

  { --- Evaluation errors (white text) --- }
  MsgErrorLexico         := 'LEXICAL ERROR: ';
  MsgDesbordamiento      := 'ERROR: value out of range';
  MsgEsperabaNumero      := 'ERROR: number expected';
  MsgSoloEnteros         := 'ERROR: integer expected';
  MsgEsperabaSimbolo     := 'ERROR: symbol expected';
  MsgFloatNoSoportado    := 'ERROR: STRCAT does not support floats';
  MsgStatusHeap          := 'Heap:     ';
  MsgStatusSimbolos      := 'Symbols:  ';
  MsgStatusStrings       := 'Strings:  ';
  MsgStatusReales        := 'Reals:    ';
  MsgCleanAntes             := 'Cleaning... before heap=';
  MsgCleanDespues           := 'Done.       after  heap=';
  MsgNewConfirmar        := 'Reset (all definitions will be lost)? (Y/N): ';
  MsgNewReiniciando      := 'Resetting...';
  MsgDivisionCero        := 'ERROR: division by zero';
  MsgSimboloNoDefinido   := 'ERROR: undefined symbol: ';
  MsgLoadEsperaString    := 'ERROR: LOAD requires a name in quotes';
  MsgTipoNoEvaluable     := 'ERROR: type cannot be evaluated';
  MsgRequiereArgumentos  := 'ERROR: requires at least one argument';
  MsgRequiereLista       := 'ERROR: requires a non-empty list';
  MsgNoAplicable         := 'ERROR: function or symbol expected';
  MsgTextoSobrante       := 'ERROR: unexpected text after expression';
  MsgExpresionLarga      := 'ERROR: expression too long';
  MsgUsaLoadFichero      := 'Use LOAD for expressions over 80 characters';
  MsgFicheroNoEncontrado := 'ERROR: file not found: ';

  { --- Informational messages --- }
  MsgCargando            := 'Loading: ';
  MsgCargaCompletada     := 'Load complete.';
  MsgHastaPronto         := 'Goodbye.';
  MsgPromptRepl          := '> ';
  MsgPromptContinua      := '.. ';

  { --- Banner --- }
  MsgTituloInterprete    := '  LISP Interpreter for Sinclair QL';
  MsgVersion             := '  Version 1.0  -  MyLISP';
  MsgCopyright           := '  (c) 2026 dfsantos';
  MsgEscribeBye          := '  Type BYE to exit';
  MsgUsaLoad             := '  Use (LOAD "mdv1_file") to load expressions';
  MsgAvisoLimite1        := '  REPL limit: 80 characters per input line';
END;
