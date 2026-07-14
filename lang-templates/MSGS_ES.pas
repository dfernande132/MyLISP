PROCEDURE InitMessages;
{ Mensajes en espanol -- sustituir por MSGS_EN para
  compilar la version en ingles }
BEGIN
  { --- Errores criticos de memoria (texto rojo) --- }
  MsgHeapAgotado         := '*** HEAP AGOTADO ***';
  MsgTablaSimbolos       := '*** TABLA DE SIMBOLOS AGOTADA ***';
  MsgTablaStrings        := '*** TABLA DE STRINGS AGOTADA ***';
  MsgTablaReales         := '*** TABLA DE REALES AGOTADA ***';
  MsgHeapReinicio        := '*** Las definiciones se han perdido ***';

  { --- Errores de evaluacion (texto blanco) --- }
  MsgErrorLexico         := 'ERROR lexico: ';
  MsgDesbordamiento      := 'ERROR: valor fuera de rango';
  MsgEsperabaNumero      := 'ERROR: se esperaba un numero';
  MsgSoloEnteros         := 'ERROR: se esperaba un entero';
  MsgEsperabaSimbolo     := 'ERROR: se esperaba un simbolo';
  MsgFloatNoSoportado    := 'ERROR: STRCAT no soporta flotantes';
  MsgStatusHeap          := 'Heap:     ';
  MsgStatusSimbolos      := 'Simbolos: ';
  MsgStatusStrings       := 'Strings:  ';
  MsgStatusReales        := 'Reales:   ';
  MsgCleanAntes             := 'Limpiando... antes  heap=';
  MsgCleanDespues           := 'Completado.  despues heap=';
  MsgNewConfirmar        := 'Reiniciar (perderan las definiciones)? (S/N): ';
  MsgNewReiniciando      := 'Reiniciando...';
  MsgDivisionCero        := 'ERROR: division por cero';
  MsgSimboloNoDefinido   := 'ERROR: simbolo no definido: ';
  MsgLoadEsperaString    := 'ERROR: LOAD requiere un nombre entre comillas';
  MsgTipoNoEvaluable     := 'ERROR: tipo no evaluable';
  MsgRequiereArgumentos  := 'ERROR: requiere al menos un argumento';
  MsgRequiereLista       := 'ERROR: requiere una lista no vacia';
  MsgNoAplicable         := 'ERROR: se esperaba una funcion o simbolo';
  MsgTextoSobrante       := 'ERROR: texto no esperado tras la expresion';
  MsgExpresionLarga      := 'ERROR: expresion demasiado larga';
  MsgUsaLoadFichero      := 'Usa LOAD para expresiones de mas de 80 caracteres';
  MsgFicheroNoEncontrado := 'ERROR: fichero no encontrado: ';

  { --- Mensajes informativos --- }
  MsgCargando            := 'Cargando: ';
  MsgCargaCompletada     := 'Carga completada.';
  MsgHastaPronto         := 'Hasta pronto.';
  MsgPromptRepl          := '> ';
  MsgPromptContinua      := '.. ';

  { --- Banner --- }
  MsgTituloInterprete    := '  Interprete LISP para Sinclair QL';
  MsgVersion             := '  Version 1.0  -  MyLISP';
  MsgCopyright           := '  (c) 2026 dfsantos';
  MsgEscribeBye          := '  Escribe BYE para salir';
  MsgUsaLoad             := '  Usa (LOAD "mdv1_fichero") para cargar expresiones';
  MsgAvisoLimite1        := '  Limite del REPL: 80 caracteres por entrada';
END;
