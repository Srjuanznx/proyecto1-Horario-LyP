# Parte II: programación lógica en Prolog

Sistema experto de matrícula y rutas académicas del proyecto **Programming Languages and Paradigms — Practice No. 1: Functional and Logical Programming (2026-2)**.

Esta carpeta implementa la **Parte II del enunciado, secciones 2.1 y 2.2**. Permite consultar qué materias puede cursar un estudiante, validar horarios, sumar créditos, recorrer prerrequisitos y construir un plan por semestres.

## Contenido

1. [Alcance y requisitos](#1-alcance-y-requisitos)
2. [Archivos y ejecución](#2-archivos-y-ejecución)
3. [Base de conocimiento](#3-base-de-conocimiento)
4. [Sistema de elegibilidad de matrícula](#4-sistema-de-elegibilidad-de-matrícula)
5. [Sistema de rutas académicas](#5-sistema-de-rutas-académicas)
6. [Recursividad y auxiliares](#6-recursividad-y-auxiliares)
7. [Decisiones y límites](#7-decisiones-y-límites)
8. [Pruebas automatizadas](#8-pruebas-automatizadas)
9. [Lectura del flujo de ejecución](#9-lectura-del-flujo-de-ejecución)

## 1. Alcance y requisitos

El enunciado exige implementar los algoritmos manualmente y utilizar recursividad explícita en las reglas de Prolog. La correspondencia con el código es:

| Sección del enunciado | Predicado requerido | Responsabilidad |
| --- | --- | --- |
| 2.1.1 | `puede_tomar/2` | Comprobar todos los prerrequisitos directos mediante una verificación recursiva. |
| 2.1.1 | `cruce_horario/2` | Detectar superposición de horarios. |
| 2.1.1 | `horario_valido/1` | Verificar recursivamente que ningún par de cursos se cruce. |
| 2.1.1 | `creditos_totales/2` | Sumar recursivamente los créditos. |
| 2.1.1 | `cursos_disponibles/2` | Filtrar recursivamente el catálogo según prerrequisitos e historial. |
| 2.2.1 | `cadena_prerequisitos/2` | Obtener prerrequisitos directos e indirectos sin duplicados. |
| 2.2.1 | `semestre_minimo/2` | Calcular el semestre más temprano según las dependencias. |
| 2.2.1 | `ruta_academica/3` | Distribuir cursos pendientes por semestres, respetando dependencias y horarios. |

La notación `nombre/N` indica el nombre del predicado y su número de argumentos. Por ejemplo, `ruta_academica/3` recibe estudiante, objetivos y ruta.

La generación de combinaciones, el rango de créditos, los puntajes de preferencias y el ranking de mejores horarios corresponden a la **Parte I, Haskell**. El enunciado no exige esas funciones para la ruta de Prolog.

## 2. Archivos y ejecución

| Archivo | Función |
| --- | --- |
| [datos.pl](datos.pl) | Hechos: cursos, créditos, horarios, prerrequisitos, estudiantes e historial. |
| [proyectoHorario.pl](proyectoHorario.pl) | Ocho predicados públicos y auxiliares recursivos. Carga automáticamente `datos.pl`. |
| [pruebas.pl](pruebas.pl) | 51 pruebas automatizadas con `plunit`, incluyendo 3.072 planes académicos. |
| [README.md](README.md) | Documentación de los datos, reglas, flujo de ejecución y pruebas de Prolog. |

### Requisito

Tener **SWI-Prolog** instalado y el comando `swipl` disponible en la terminal. La implementación se validó previamente con SWI-Prolog 10.0.2.

### Cargar desde la raíz del repositorio

```sh
swipl -s Prolog/proyectoHorario.pl
```

Si ya abriste la consola de SWI-Prolog desde la raíz:

```prolog
?- ['Prolog/proyectoHorario.pl'].
```

Si la terminal está dentro de la carpeta `Prolog`:

```sh
swipl -s proyectoHorario.pl
```

Una vez cargado, escribe las consultas terminadas en punto:

```prolog
?- puede_tomar(juan, calculo2).
true.
```

El prefijo `?-` representa el indicador de la consola: **no debes volver a escribirlo ni incluirlo en el archivo fuente**. Usa `;` para solicitar otra solución, Enter para aceptar la actual y `halt.` para salir. Después de editar un archivo cargado, puedes ejecutar `make.`.

## 3. Base de conocimiento

### Significado de los hechos

```prolog
curso(calculo1, 'Calculo 1', 4).
horario(calculo1, lunes, 7, 9).
prerequisito(calculo2, calculo1).
estudiante(juan).
aprobado(juan, calculo1).
```

| Hecho | Interpretación |
| --- | --- |
| `curso(Codigo, Nombre, Creditos)` | Identifica una materia y sus créditos. |
| `horario(Curso, Dia, Inicio, Fin)` | Indica su único bloque semanal. |
| `prerequisito(Curso, Requisito)` | Requisito debe aprobarse antes de Curso. El orden de los argumentos importa. |
| `estudiante(Estudiante)` | Registra a una persona, incluso si aún no tiene materias aprobadas. |
| `aprobado(Estudiante, Curso)` | Registra una materia ya aprobada. |

### Catálogo del proyecto

Los datos son ficticios y permiten demostrar casos de dependencias y cruces.

| Código | Materia | Créditos | Horario | Prerrequisitos directos |
| --- | --- | --- | --- | --- |
| `calculo1` | Cálculo 1 | 4 | lunes, 7–9 | Ninguno |
| `algebra` | Álgebra lineal | 3 | martes, 7–9 | Ninguno |
| `programacion1` | Programación 1 | 4 | lunes, 9–11 | Ninguno |
| `introingenieria` | Introducción a la ingeniería | 2 | lunes, 8–10 | Ninguno |
| `calculo2` | Cálculo 2 | 4 | miércoles, 7–9 | `calculo1`, `algebra` |
| `fisica1` | Física 1 | 4 | miércoles, 8–10 | `calculo1` |
| `programacion2` | Programación 2 | 4 | jueves, 7–9 | `programacion1` |
| `calculo3` | Cálculo 3 | 4 | viernes, 7–9 | `calculo2` |
| `estructuras` | Estructuras de datos | 3 | jueves, 8–10 | `programacion2`, `algebra` |
| `proyecto` | Proyecto integrador | 3 | viernes, 8–10 | `calculo3`, `estructuras` |

Las horas son decimales: `8.5` significa 08:30; `8.30` no representa las 08:30.

### Historiales

- **Ana:** ninguna materia aprobada.
- **Juan:** `calculo1`, `algebra` y `programacion1`.
- **Luisa:** las tres anteriores, `calculo2`, `fisica1` y `programacion2`.

Los ejemplos del PDF ilustran el comportamiento con una base parcial. Los resultados de este README corresponden a los hechos reales de [datos.pl](datos.pl); por eso la lista de disponibles de Juan difiere del ejemplo del enunciado.

## 4. Sistema de elegibilidad de matrícula

### 4.1 `puede_tomar(Estudiante, Curso)`

Comprueba que ambos estén registrados, recoge los prerrequisitos directos y verifica recursivamente que todos estén aprobados.

- **Caso base:** una lista vacía de prerrequisitos se satisface.
- **Paso recursivo:** comprobar `aprobado(Estudiante, Pre)` para la cabeza y continuar con la cola.
- **Auxiliar:** `requisitos_aprobados/2`.

```prolog
?- puede_tomar(juan, calculo2).
true.

?- puede_tomar(ana, calculo2).
false.

?- puede_tomar(ana, calculo1).
true.

?- puede_tomar(desconocido, calculo1).
false.
```

Juan cumple porque aprobó Cálculo 1 y Álgebra. Ana puede tomar un curso inicial aunque su historial esté vacío.

**Cumplir prerrequisitos y tener una materia pendiente son condiciones diferentes.** Por contrato, `puede_tomar(juan, calculo1)` también es verdadero. La exclusión de aprobados se realiza en `cursos_disponibles/2`.

Admite consultas con variables para enumerar estudiantes o cursos:

```prolog
?- puede_tomar(Estudiante, calculo2).
Estudiante = juan ;
Estudiante = luisa.
```

### 4.2 `cruce_horario(Curso1, Curso2)`

Busca dos cursos distintos, exige el mismo día y compara sus intervalos:

```text
Inicio1 < Fin2
y
Inicio2 < Fin1
```

Los intervalos se interpretan como `[Inicio, Fin)`: compartir únicamente un extremo es compatible.

```prolog
?- cruce_horario(calculo2, fisica1).
true.

?- cruce_horario(calculo1, programacion1).
false.

?- cruce_horario(calculo1, algebra).
false.
```

Cálculo 2 y Física 1 coinciden el miércoles entre las 8 y las 9. Cálculo 1 termina a las 9 y Programación 1 empieza a las 9, así que no se cruzan. También permite enumerar pares con variables.

### 4.3 `horario_valido(ListaCursos)`

Recibe una lista concreta y finita de códigos. Comprueba que cada curso exista, tenga inicio menor que fin, no esté repetido y no se cruce con ninguno de los siguientes.

- **Caso base:** `horario_valido([])`.
- **Paso recursivo:** comparar la cabeza con toda la cola usando `sin_cruces/2` y validar después la cola.

```prolog
?- horario_valido([calculo1, algebra, programacion1]).
true.

?- horario_valido([calculo1, algebra, introingenieria]).
false.

?- horario_valido([calculo1, calculo1]).
false.

?- horario_valido([inexistente]).
false.
```

La segunda consulta demuestra que se comparan también cursos que no son adyacentes en la lista. Este predicado valida horarios; no recibe un estudiante ni comprueba su elegibilidad.

### 4.4 `creditos_totales(ListaCursos, Total)`

Suma créditos mediante recursividad:

```prolog
creditos_totales([], 0).
creditos_totales([Curso|Resto], Total) :-
    curso(Curso, _, Creditos),
    creditos_totales(Resto, Subtotal),
    Total is Creditos + Subtotal.
```

```prolog
?- creditos_totales([calculo1, algebra, programacion1], Total).
Total = 11.

?- creditos_totales([], Total).
Total = 0.
```

El caso base aporta 0. Al regresar de la recursión se suman 4 de Programación 1, 3 de Álgebra y 4 de Cálculo 1.

Cuenta cada aparición: `[calculo1, calculo1]` suma 8. Para validar una matrícula se debe comprobar además `horario_valido/1`. Un código desconocido hace fallar la suma.

### 4.5 `cursos_disponibles(Estudiante, Disponibles)`

Obtiene el catálogo y lo filtra recursivamente con `filtrar_disponibles/3`. Conserva una materia cuando el estudiante cumple sus prerrequisitos **y no la ha aprobado**.

```prolog
?- cursos_disponibles(ana, Disponibles).
Disponibles = [calculo1, algebra, programacion1, introingenieria].

?- cursos_disponibles(juan, Disponibles).
Disponibles = [introingenieria, calculo2, fisica1, programacion2].
```

El resultado conserva el orden del catálogo. Son materias disponibles individualmente: la lista completa puede contener cruces, como Cálculo 2 y Física 1.

## 5. Sistema de rutas académicas

### 5.1 `cadena_prerequisitos(Curso, Cadena)`

Recorre las dependencias en profundidad y elimina repeticiones conservando la primera aparición.

```prolog
?- cadena_prerequisitos(calculo1, Cadena).
Cadena = [].

?- cadena_prerequisitos(calculo3, Cadena).
Cadena = [calculo2, calculo1, algebra].

?- cadena_prerequisitos(proyecto, Cadena).
Cadena = [calculo3, calculo2, calculo1, algebra,
          estructuras, programacion2, programacion1].
```

`cadena_desde/3` guarda los cursos visitados en la rama actual. Volver a encontrar uno significa que existe un ciclo y la consulta falla. Compartir un ancestro entre dos ramas, como Álgebra, sí es válido.

La lista expresa el orden de recorrido; no es por sí misma un orden de matrícula. Por ejemplo, Cálculo 2 aparece antes que Cálculo 1 en la cadena anterior.

### 5.2 `semestre_minimo(Curso, Semestre)`

Calcula la profundidad de las dependencias:

```text
Sin prerrequisitos: semestre = 1.
Con prerrequisitos: semestre = 1 + máximo de sus semestres mínimos.
```

`maximo_semestre/3` calcula el máximo manualmente. Su caso base devuelve 0, de modo que un curso inicial queda en 1.

```prolog
?- semestre_minimo(calculo1, S).
S = 1.

?- semestre_minimo(calculo3, S).
S = 3.

?- semestre_minimo(proyecto, S).
S = 4.
```

Este cálculo considera las dependencias académicas. Los retrasos por cruces de horario se resuelven al construir la ruta.

### 5.3 `ruta_academica(Estudiante, Cursos, Ruta)`

Recibe un estudiante registrado y una lista concreta y finita de cursos objetivo. Devuelve términos `semestre(Numero, ListaCursos)`.

El proceso es:

1. Validar los objetivos y expandir los que no están aprobados con sus prerrequisitos.
2. Eliminar duplicados y materias aprobadas.
3. Validar el horario individual de cada curso pendiente.
4. Recoger el historial en la lista de cursos completados.
5. Recorrer los pendientes para seleccionar los de cada semestre.
6. Incorporar los elegidos a completados únicamente para el siguiente semestre.
7. Repetir hasta que no queden pendientes; omitir los semestres vacíos.

Para elegir una materia se exige que llegue su semestre mínimo, estén completados todos sus prerrequisitos y no se cruce con las materias ya elegidas.

#### Ejemplo completo: Ana quiere llegar a Proyecto integrador

```prolog
?- ruta_academica(ana, [proyecto], Ruta).
Ruta = [semestre(1, [calculo1, algebra, programacion1]),
        semestre(2, [calculo2, programacion2]),
        semestre(3, [calculo3, estructuras]),
        semestre(4, [proyecto])].
```

| Semestre | Materias | Razón |
| --- | --- | --- |
| 1 | Cálculo 1, Álgebra, Programación 1 | No tienen prerrequisitos y sus horarios son compatibles. |
| 2 | Cálculo 2, Programación 2 | Sus prerrequisitos terminaron en el semestre anterior. |
| 3 | Cálculo 3, Estructuras | Ya se completaron Cálculo 2, Programación 2 y Álgebra. |
| 4 | Proyecto integrador | Se completaron Cálculo 3 y Estructuras. |

Introducción a la ingeniería y Física 1 no aparecen porque no son objetivos ni prerrequisitos de Proyecto.

#### Ejemplo con cruce

```prolog
?- ruta_academica(juan, [calculo2, fisica1], Ruta).
Ruta = [semestre(2, [calculo2]), semestre(3, [fisica1])].
```

Ambas están habilitadas para Juan, pero se cruzan. Se prioriza Cálculo 2 por aparecer primero. Si se invierte el orden de los objetivos, Física 1 queda primero.

#### Ejemplo con materias ya aprobadas

```prolog
?- ruta_academica(luisa, [calculo3], Ruta).
Ruta = [semestre(3, [calculo3])].

?- ruta_academica(juan, [calculo1, algebra], Ruta).
Ruta = [].

?- ruta_academica(ana, [], Ruta).
Ruta = [].
```

Los números respetan `semestre_minimo/2`; **no representan cuántos semestres le faltan al estudiante desde hoy**. Por eso Cálculo 3 conserva el número 3 en la ruta de Luisa.

## 6. Recursividad y auxiliares

El procesamiento de listas y los cálculos del código de producción están implementados manualmente.

| Auxiliares | Trabajo que realizan |
| --- | --- |
| `pertenece/2` | Buscar en una lista, avanzando por su cola; usa `dif/2` para distinguir elementos. |
| `concatenar/3` | Unir listas reconstruyendo la primera recursivamente. |
| `sin_repetidos/2`, `sin_repetidos/3` | Mantener una lista de vistos y conservar la primera aparición. |
| `prerrequisitos_directos/2` | Recoger los hechos de prerrequisitos mediante `findall/3`. |
| `requisitos_aprobados/2` | Comprobar cada prerrequisito contra el historial. |
| `sin_cruces/2` | Comparar un curso con cada elemento de otra lista. |
| `filtrar_disponibles/3` | Incluir o descartar cada curso del catálogo. |
| `cadena_desde/3`, `expandir_requisitos/3` | Recorrer dependencias y detectar ciclos en la rama actual. |
| `semestre_desde/3`, `maximo_semestre/3` | Recorrer dependencias y calcular el máximo recursivamente. |
| `objetivos_pendientes/3`, `quitar_aprobados/3` | Expandir objetivos y retirar materias completadas. |
| `validar_horarios/1` | Validar individualmente los horarios pendientes. |
| `planificar/4` | Avanzar de un semestre al siguiente hasta vaciar los pendientes. |
| `seleccionar_semestre/6` | Separar cursos elegidos y pendientes mientras acumula horarios ocupados. |
| `habilitado_en/3`, `todos_completados/2` | Comprobar semestre mínimo y prerrequisitos completados. |

`findall/3` se usa únicamente para recoger hechos del catálogo, los prerrequisitos y el historial. Los filtros, verificaciones y cálculos se realizan en reglas recursivas propias. No se usa `forall/2` en el código de producción ni agregaciones predefinidas para calcular créditos o máximos.

El archivo de pruebas sí usa utilidades como `forall/2`, `sort/2` y `length/2` para contrastar resultados. Esas utilidades pertenecen al verificador, no a los algoritmos de la solución.

### Sintaxis que aparece en el código

| Elemento | Significado |
| --- | --- |
| `:-` | La cabeza de la regla se cumple si se satisface su cuerpo. |
| `,` | Conjunción: deben satisfacerse ambos objetivos. |
| `.` | Final de un hecho, regla o consulta. |
| `[Cabeza\|Cola]` | Separación de una lista en primer elemento y resto. |
| `[]` | Lista vacía, utilizada en casos base. |
| `_` | Variable anónima cuyo valor no necesitamos conservar. |
| `=` | Unificación; no realiza evaluación aritmética. |
| `is` | Evalúa la expresión aritmética de la derecha. |
| `dif(A, B)` | Exige que los términos sean distintos. |
| `\+` | Negación por fallo: se cumple si no se puede demostrar el objetivo. |
| `(Condicion -> Entonces ; SiNo)` | Condicional utilizado para filtrar, comparar y seleccionar. |
| `findall(X, Objetivo, Lista)` | Reúne las soluciones de un objetivo en una lista. |

En estas reglas, los elementos se concretan antes de las negaciones y comparaciones que lo necesitan. Las consultas con listas se deben hacer en los modos descritos; los predicados no constituyen un generador general de listas parcialmente instanciadas.

## 7. Decisiones y límites

- **Datos:** se supone un código único y un único bloque semanal por curso, con valores numéricos e inicio menor que fin. No se modelan varios grupos ni varias sesiones semanales.
- **Historial:** los ejemplos son coherentes con los prerrequisitos. Una aprobación se trata como un curso completado antes del plan.
- **Cursos iniciales:** necesitan un estudiante registrado, pero no aprobaciones previas.
- **Cursos repetidos:** se rechazan en `horario_valido/1`; en una ruta se eliminan; la suma de créditos cuenta cada aparición.
- **Objetivos y dependencias:** la ruta incorpora automáticamente los prerrequisitos pendientes. Esta es una decisión de implementación que permite pedir directamente una materia avanzada.
- **Ciclos y referencias inexistentes:** hacen fallar los recorridos de dependencias cuando se encuentran en la cadena consultada. Un objetivo ya aprobado se omite sin recorrer su cadena.
- **Horarios defectuosos:** la ruta rechaza cursos pendientes sin horario o con inicio mayor o igual que fin. Se presupone que el resto de los hechos está bien formado.
- **Semestres:** los cursos elegidos solo pasan a completados en el siguiente semestre. No se permite tomar una materia junto con su prerrequisito.
- **Selección:** se usa el orden de los pendientes para resolver conflictos. Se obtiene un plan válido, sin garantizar el menor número de semestres ni enumerar todos los planes posibles.
- **Créditos:** no se limita la carga por semestre en la ruta de Prolog.
- **Resultados negativos:** `false` comunica que la consulta no se satisface; el programa no devuelve un diagnóstico textual de la causa.
- **Escala:** el catálogo de demostración es pequeño. Los recorridos vuelven a calcular dependencias compartidas; no se implementa memoización.

## 8. Pruebas automatizadas

Desde la raíz del repositorio:

```sh
swipl -q -s Prolog/pruebas.pl -g run_tests -t halt
```

Desde la carpeta `Prolog`:

```sh
swipl -q -s pruebas.pl -g run_tests -t halt
```

**Resultado verificado en la revisión del 1 de octubre de 2026: 51 pruebas aprobadas.**

Se cubren los ocho predicados, consultas con variables, cursos desconocidos, estudiantes desconocidos, listas vacías, duplicados, cruces no adyacentes, extremos contiguos, ciclos, prerrequisitos inexistentes y horarios faltantes o invertidos.

La última prueba recorre los **1.024 subconjuntos** del catálogo de diez materias para cada uno de los **tres estudiantes**: **3.072 rutas**. Comprueba que:

- haya exactamente una solución por combinación;
- aparezcan las materias pendientes necesarias, sin duplicados;
- los prerrequisitos estén aprobados o en un semestre anterior;
- se respete el semestre mínimo;
- los semestres estén ordenados y no estén vacíos;
- no existan cruces dentro de un semestre.

El verificador contrasta el plan con las relaciones básicas; para el límite de semestre reutiliza `semestre_minimo/2`, que también tiene pruebas específicas. La cobertura exhaustiva corresponde a los subconjuntos del catálogo de ejemplo, no a todas las bases de datos posibles.

Las pruebas agregan y retiran hechos temporales para simular datos defectuosos. No cambian los archivos de datos.

## 9. Lectura del flujo de ejecución

Esta sección conecta las reglas con el estado de sus argumentos. Los fragmentos son extractos de `proyectoHorario.pl`.

### 9.1 Verificar una lista de prerrequisitos

```prolog
requisitos_aprobados(_, []).
requisitos_aprobados(Estudiante, [Pre|Resto]) :-
    aprobado(Estudiante, Pre),
    requisitos_aprobados(Estudiante, Resto).
```

Para `puede_tomar(juan, calculo2)`, primero se recoge `[calculo1, algebra]`. La regla comprueba `aprobado(juan, calculo1)` y continúa con `[algebra]`; después comprueba Álgebra y llega a `[]`. El caso base permite terminar con éxito. Si falta una aprobación, la conjunción falla.

`_` en el caso base indica que, una vez vacía la lista, no hace falta consultar nuevamente al estudiante. El registro del estudiante ya fue comprobado por `puede_tomar/2`.

### 9.2 Incluir o descartar un curso

```prolog
filtrar_disponibles([], _, []).
filtrar_disponibles([Curso|Resto], Estudiante, Disponibles) :-
    ( puede_tomar(Estudiante, Curso), \+ aprobado(Estudiante, Curso)
    -> Disponibles = [Curso|Cola]
    ;  Disponibles = Cola
    ),
    filtrar_disponibles(Resto, Estudiante, Cola).
```

La condición combina dos objetivos: cumplir los prerrequisitos y no tener la materia aprobada. Si ambos se cumplen, se construye una lista cuya cabeza es `Curso`; en caso contrario, el resultado es directamente `Cola`. En ambas ramas, la llamada final procesa los cursos restantes y completa esa cola.

No se modifica el catálogo ni se registra una matrícula: se construye el argumento de salida mediante unificación.

### 9.3 Diferenciar la cadena y el semestre mínimo

Para Cálculo 3 se recorren estas dependencias:

```text
calculo3
└── calculo2
    ├── calculo1
    └── algebra
```

En `cadena_prerequisitos/2`, el objetivo es reunir códigos: primero Cálculo 2 y luego sus ancestros, dando `[calculo2, calculo1, algebra]`.

En `semestre_minimo/2`, el objetivo es calcular números: Cálculo 1 y Álgebra dan 1; Cálculo 2 da `1 + max(1, 1) = 2`; Cálculo 3 da `1 + 2 = 3`. Aquí `max` es notación explicativa: el código realiza la comparación recursivamente con `maximo_semestre/3`.

### 9.4 Preparar los pendientes de una ruta

```prolog
ruta_academica(Estudiante, Cursos, Ruta) :-
    estudiante(Estudiante),
    objetivos_pendientes(Cursos, Estudiante, Necesarios),
    sin_repetidos(Necesarios, Unicos),
    quitar_aprobados(Unicos, Estudiante, Pendientes),
    validar_horarios(Pendientes),
    findall(Curso, aprobado(Estudiante, Curso), Aprobados),
    planificar(Pendientes, Aprobados, 1, Ruta).
```

Con Ana y el objetivo `[proyecto]`, los pendientes quedan en este orden:

```prolog
[proyecto, calculo3, calculo2, calculo1, algebra,
 estructuras, programacion2, programacion1]
```

Ana tiene `Aprobados = []`. La lista de pendientes no está ordenada por semestre: el selector la recorre y decide cuáles puede elegir según las condiciones del semestre actual.

### 9.5 Entender los seis argumentos del selector

```prolog
seleccionar_semestre(PendientesEntrada, Completados, Semestre,
                     Ocupados, Elegidos, PendientesSalida)
```

Los nombres anteriores describen los papeles de los argumentos; la implementación usa patrones de cabeza y cola para procesarlos.

| Argumento | Papel |
| --- | --- |
| Pendientes de entrada | Cursos que aún se deben ubicar. |
| Completados | Historial más cursos de semestres anteriores; permanece fijo durante esta selección. |
| Semestre | Número del semestre que se está construyendo. |
| Ocupados | Cursos ya elegidos en este recorrido; se usa para detectar cruces. |
| Elegidos | Lista de salida con los cursos seleccionados para este semestre. |
| Pendientes de salida | Lista de salida con los cursos aplazados. |

La condición de selección es:

```prolog
habilitado_en(Curso, Completados, Semestre),
sin_cruces(Curso, Ocupados)
```

Si se cumple, el curso se añade a elegidos y ocupados. Si falla, se conserva en pendientes. Cada rama continúa con el resto de la lista.

### 9.6 Avanzar al siguiente semestre

En la primera selección de Ana, Proyecto, Cálculo 3 y Cálculo 2 se aplazan; se eligen Cálculo 1 y Álgebra. Estructuras y Programación 2 también se aplazan, y se elige Programación 1.

Aunque Cálculo 1 y Álgebra ya hayan sido elegidos, no cuentan como completados durante ese mismo semestre. Esta separación impide aprobar un prerrequisito y cursar su dependiente simultáneamente.

Después, `planificar/4` ejecuta:

```prolog
Siguiente is Semestre + 1,
concatenar(Elegidos, Completados, NuevosCompletados)
```

La llamada recursiva usa los pendientes que quedaron, los nuevos completados y el siguiente número. En el caso de Ana:

| Estado al terminar la selección | Elegidos | Pendientes para continuar |
| --- | --- | --- |
| Semestre 1 | `[calculo1, algebra, programacion1]` | `[proyecto, calculo3, calculo2, estructuras, programacion2]` |
| Semestre 2 | `[calculo2, programacion2]` | `[proyecto, calculo3, estructuras]` |
| Semestre 3 | `[calculo3, estructuras]` | `[proyecto]` |
| Semestre 4 | `[proyecto]` | `[]` |

Al alcanzar `planificar([], _, _, [])`, no quedan cursos y termina la construcción. Si un semestre no tiene elegidos, se avanza el número sin agregar un término vacío a la ruta.

`NuevosCompletados` es una lista local de la consulta. El plan propuesto **no agrega hechos `aprobado/2` a la base**: representa lo que se consideraría completado al avanzar dentro del plan.
