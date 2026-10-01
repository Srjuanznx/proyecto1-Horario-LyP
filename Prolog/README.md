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
9. [Guía para la sustentación](#9-guía-para-la-sustentación)
10. [Aporte de Prolog a la entrega](#10-aporte-de-prolog-a-la-entrega)
11. [Transparencia sobre IA](#11-transparencia-sobre-ia)

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
| [README.md](README.md) | Documentación de uso, diseño, verificación y entrega de Prolog. |

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

## 9. Guía para la sustentación

Orden sugerido para explicar la parte de Prolog:

1. **Modelo:** mostrar los cinco tipos de hechos y explicar el sentido de `prerequisito(Curso, Requisito)`.
2. **Elegibilidad:** ejecutar `puede_tomar(juan, calculo2)` y contrastarlo con Ana; seguir el caso base y recursivo de `requisitos_aprobados/2`.
3. **Horarios:** explicar las dos desigualdades de cruce y demostrar que terminar a las 9 y empezar a las 9 es compatible.
4. **Listas:** mostrar cómo se compara cada curso con la cola, cómo se suman créditos y cómo se filtra el catálogo.
5. **Dependencias:** seguir la cadena de Cálculo 3 y explicar por qué su semestre mínimo es 3.
6. **Planificación:** ejecutar la ruta de Ana hacia Proyecto; explicar pendientes, completados y ocupados.
7. **Casos límite y pruebas:** mostrar un conflicto, una materia desconocida y la ejecución de las pruebas.

Preguntas que debes poder responder:

- ¿Por qué `puede_tomar` puede aceptar una materia aprobada?
- ¿Por qué las materias de `cursos_disponibles` pueden cruzarse entre sí?
- ¿Qué diferencia hay entre prerrequisitos directos y transitivos?
- ¿Por qué visitados guarda la rama actual y no todos los cursos recorridos?
- ¿Cómo se evita cursar una materia y su prerrequisito en el mismo semestre?
- ¿Por qué cambiar el orden de los objetivos puede cambiar la ruta?
- ¿Por qué la ruta de Luisa mantiene el semestre 3 para Cálculo 3?
- ¿Dónde están los casos base y qué lista o conjunto de pendientes reduce cada recursión?

## 10. Aporte de Prolog a la entrega

Según el PDF suministrado, la entrega es el **2 de octubre de 2026 a las 23:59 por EAFIT Interactiva**. El proyecto se realiza en parejas y vale el 20 % del curso.

### Evaluación del proyecto completo

| Criterio | Peso |
| --- | --- |
| Corrección funcional | 30 % |
| Enlace a video que explique código y funcionalidad | 50 % |
| Informe técnico | 20 % |

El docente puede llamar a cualquier estudiante a una sustentación presencial.

### Material que debe aportar el responsable de Prolog

- [ ] Código de Prolog: `datos.pl` y `proyectoHorario.pl`; acompañarlo con `pruebas.pl` y esta guía para facilitar la reproducción.
- [ ] Documentación de hechos, reglas, argumentos y auxiliares recursivos para el informe.
- [ ] Ejemplos funcionales de los ocho requisitos y sus resultados.
- [ ] Explicación del diseño de la ruta, detección de cruces y manejo de prerrequisitos.
- [ ] Demostración y explicación de Prolog en el video conjunto.
- [ ] Problemas abordados, soluciones y declaración concreta del uso de IA.

### Requisitos del informe PDF conjunto

El enunciado pide:

1. Nombres completos, identificaciones y correos de los estudiantes.
2. Enlace al video de sustentación.
3. Documentación de funciones, hechos y reglas.
4. Ejemplos funcionales de ejecución de cada ítem solicitado.
5. Tabla de problemas principales y soluciones, indicando dónde y cómo se utilizó IA.
6. Al menos tres conclusiones y una comparación breve entre paradigmas.

Este README aporta la documentación de Prolog. El informe PDF, los datos personales y el enlace al video deben completarse como entregables conjuntos; la documentación de Haskell corresponde a su sección.

Para la comparación: Haskell expresa el problema mediante funciones que transforman datos, generan combinaciones y calculan rankings; Prolog lo expresa mediante hechos y reglas que permiten demostrar relaciones y obtener soluciones por unificación y búsqueda. En este proyecto ambos deben mostrar recursividad explícita.

## 11. Transparencia sobre IA

La implementación de Prolog, los datos de ejemplo, las pruebas y esta documentación se prepararon con asistencia de **OpenAI Codex**. La actualización de esta guía se realizó contrastando el PDF del enunciado con los archivos del repositorio. Las pruebas automatizadas se ejecutaron en SWI-Prolog.

Los estudiantes deben revisar y comprender la solución y describir en el informe el uso real de la herramienta. No se deben presentar pruebas automatizadas como sustituto de la comprensión del código.

La siguiente tabla resume problemas técnicos abordados en la solución; puede servir de base para la tabla del informe, ajustándola a la experiencia real del equipo:

| Problema abordado | Solución implementada |
| --- | --- |
| Representar estudiantes sin materias aprobadas | Registro explícito con `estudiante/1`. |
| Exigir todos los prerrequisitos | Verificación recursiva con `requisitos_aprobados/2`. |
| Detectar conflictos entre cualquier par | Comparación cabeza-cola mediante `sin_cruces/2`. |
| Evitar duplicados y distinguir ciclos de ancestros compartidos | Lista de vistos para duplicados y lista de visitados de la rama para ciclos. |
| Evitar prerrequisitos simultáneos | Mantener completados fijo durante la selección de un semestre. |
| Resolver conflictos en la ruta | Aplazar el curso que entra en conflicto según el orden de pendientes. |
| Comprobar múltiples objetivos e historiales | Pruebas específicas y revisión de 3.072 rutas del catálogo. |
