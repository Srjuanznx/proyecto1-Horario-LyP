# Guía para explicar el código de Prolog

Esta guía acompaña el recorrido del código en pantalla. Primero explica **[proyectoHorario.pl](proyectoHorario.pl)** y después **[pruebas.pl](pruebas.pl)**, siguiendo el orden de sus definiciones. Incluye todos los predicados propios, sus argumentos, su lógica y ejemplos.

En Prolog hablamos de **predicados**: una consulta puede tener éxito, fallar o encontrar valores para variables. La notación `nombre/2` indica dos argumentos; no implica una función que devuelve un valor como en otros lenguajes.

**Cómo usar la guía:** lee la explicación detallada para entender cada bloque y utiliza las frases «Para narrar» mientras muestras el código. Al final hay un recorrido breve para un video de hasta cinco minutos. Leer toda la guía en voz alta excedería ese tiempo.

## Contexto mínimo de datos.pl

Los hechos describen cursos, horarios, prerrequisitos, estudiantes y aprobaciones. `prerequisito(Curso, Pre)` significa que Pre debe aprobarse antes de Curso. Ana no tiene aprobaciones; Juan ya aprobó Cálculo 1, Álgebra y Programación 1. No hace falta recorrer todo el catálogo para explicar los algoritmos.

## Cómo leer las líneas

- Las variables empiezan con mayúscula; códigos como `calculo1` son átomos.
- `:-` separa la cabeza de la regla de sus condiciones; las comas entre objetivos significan «y».
- `.` termina una cláusula. Varias cláusulas pueden definir el mismo predicado.
- `[X|Resto]` separa cabeza y cola; `[]` es la lista vacía; `_` ignora un argumento.
- `=` unifica términos; `is` evalúa una expresión aritmética.
- `dif(X,Y)` exige que los términos sean distintos.
- `\+ Objetivo` es negación por fallo: tiene éxito si el objetivo no se puede demostrar.
- `(Condicion -> Entonces ; SiNo)` elige una rama según el éxito de la condición. El punto final pertenece a toda la regla.
- `findall(X, Objetivo, Lista)` recoge las soluciones en una lista; no realiza por sí mismo los filtros recursivos del proyecto.

Las listas de cursos se consultan con códigos concretos y una longitud finita. Los datos presuponen un horario semanal válido por curso.

## Archivo 1: proyectoHorario.pl

### Inicio: cargar la base de hechos

```prolog
:- ensure_loaded('datos.pl').
```

Es una directiva que carga la base al leer el archivo. Permite usar `curso/3`, `horario/4`, `prerequisito/2`, `estudiante/1` y `aprobado/2` sin copiar sus hechos dentro de las reglas.

**Para narrar:** «El archivo comienza cargando los datos que van a consultar las reglas.»

### 1. `pertenece`

**Uso:** `pertenece(X, Lista)`.

Comprueba si X aparece en Lista.

```prolog
pertenece(X, [X|_]).
pertenece(X, [Y|Resto]) :-
    dif(X, Y),
    pertenece(X, Resto).
```

**Cómo funciona:** La primera cláusula unifica X con la cabeza y termina con éxito. La segunda exige con dif(X,Y) que no sea esa cabeza y busca en Resto. No hay cláusula para la lista vacía: si no encuentra X, falla.

**Ejemplo o conexión:** pertenece(algebra, [calculo1, algebra]) avanza una posición y tiene éxito.

**Para narrar:** «Busca el elemento recorriendo la lista; cuando coincide con la cabeza, termina.»

### 2. `concatenar`

**Uso:** `concatenar(Primera, Segunda, Resultado)`.

Une dos listas conservando su orden.

```prolog
concatenar([], Lista, Lista).
concatenar([X|Resto], Lista, [X|Resultado]) :-
    concatenar(Resto, Lista, Resultado).
```

**Cómo funciona:** Si Primera es [], Resultado es Segunda. En el paso recursivo conserva X en la cabeza del resultado y concatena Resto con Segunda. La lista final se construye por unificación.

**Ejemplo o conexión:** concatenar([a,b], [c], R) produce R = [a,b,c].

**Para narrar:** «Reconstruye la primera lista y coloca la segunda al final.»

### 3. `sin_repetidos`

**Uso:** `sin_repetidos(Lista, Unicos) y sin_repetidos(Lista, Vistos, Unicos)`.

Elimina duplicados conservando la primera aparición.

```prolog
sin_repetidos(Lista, Unicos) :-
    sin_repetidos(Lista, [], Unicos).

sin_repetidos([], _, []).
sin_repetidos([X|Resto], Vistos, Unicos) :-
    ( pertenece(X, Vistos)
    -> sin_repetidos(Resto, Vistos, Unicos)
    ;  Unicos = [X|Cola],
       sin_repetidos(Resto, [X|Vistos], Cola)
    ).
```

**Cómo funciona:** La versión de dos argumentos inicia Vistos en []. La de tres termina con salida [] cuando no quedan elementos. Si X ya pertenece a Vistos, lo omite. Si no, construye Unicos = [X|Cola], agrega X a Vistos y procesa Resto para completar Cola.

**Ejemplo o conexión:** sin_repetidos([a,b,a], U) produce U = [a,b]. Vistos es un acumulador interno, no la salida.

**Para narrar:** «Guarda qué elementos ya vio y solo incorpora la primera aparición.»

### 4. `prerrequisitos_directos`

**Uso:** `prerrequisitos_directos(Curso, Requisitos)`.

Reúne los prerrequisitos inmediatos de una materia.

```prolog
prerrequisitos_directos(Curso, Requisitos) :-
    findall(Pre, prerequisito(Curso, Pre), Requisitos).
```

**Cómo funciona:** findall(Pre, prerequisito(Curso,Pre), Requisitos) recoge cada Pre que satisface el hecho. Si no hay hechos, devuelve []. No recorre todavía prerrequisitos de prerrequisitos.

**Ejemplo o conexión:** Para calculo2 devuelve [calculo1,algebra].

**Para narrar:** «Recoge los hechos directos; las comprobaciones se hacen después con recursividad.»

### 5. `puede_tomar`

**Uso:** `puede_tomar(Estudiante, Curso)`.

Comprueba que el estudiante cumpla todos los prerrequisitos directos.

```prolog
puede_tomar(Estudiante, Curso) :-
    estudiante(Estudiante),
    curso(Curso, _, _),
    prerrequisitos_directos(Curso, Requisitos),
    requisitos_aprobados(Estudiante, Requisitos).
```

**Cómo funciona:** estudiante/1 valida o enumera estudiantes registrados; curso/3 valida o enumera cursos. Los guiones bajos ignoran nombre y créditos. Luego recoge Requisitos y llama a requisitos_aprobados/2. Las comas exigen que se cumplan todas las condiciones.

**Ejemplo o conexión:** puede_tomar(juan,calculo2) es verdadero; para Ana es falso. También acepta una materia ya aprobada si cumple sus prerrequisitos.

**Para narrar:** «Valida estudiante y curso y exige todas las aprobaciones previas; aquí aún no excluye materias aprobadas.»

### 6. `requisitos_aprobados`

**Uso:** `requisitos_aprobados(Estudiante, Requisitos)`.

Verifica uno por uno los prerrequisitos contra los hechos aprobado/2.

```prolog
requisitos_aprobados(_, []).
requisitos_aprobados(Estudiante, [Pre|Resto]) :-
    aprobado(Estudiante, Pre),
    requisitos_aprobados(Estudiante, Resto).
```

**Cómo funciona:** El caso [] tiene éxito sin más verificaciones. En [Pre|Resto] comprueba aprobado(Estudiante,Pre) y sigue con Resto. Si una aprobación falta, falla la regla completa.

**Ejemplo o conexión:** Para Juan: [calculo1,algebra] → [algebra] → []. Ambos hechos aprobado existen.

**Para narrar:** «La lista vacía es el caso base; cada llamada verifica una aprobación y reduce la lista.»

### 7. `cruce_horario`

**Uso:** `cruce_horario(Curso1, Curso2)`.

Determina si dos cursos distintos coinciden en horario.

```prolog
cruce_horario(Curso1, Curso2) :-
    curso(Curso1, _, _),
    curso(Curso2, _, _),
    dif(Curso1, Curso2),
    horario(Curso1, Dia, Inicio1, Fin1),
    horario(Curso2, Dia, Inicio2, Fin2),
    Inicio1 < Fin2,
    Inicio2 < Fin1.
```

**Cómo funciona:** Primero obtiene códigos concretos del catálogo; dif/2 evita comparar un curso consigo mismo. La variable Dia compartida exige el mismo día. Inicio1 < Fin2 e Inicio2 < Fin1 detectan superposición. Las desigualdades estrictas permiten horarios contiguos.

**Ejemplo o conexión:** calculo2 (miércoles 7–9) y fisica1 (miércoles 8–10) se cruzan. calculo1 (lunes 7–9) y programacion1 (lunes 9–11) no.

**Para narrar:** «Dos cursos se cruzan si son del mismo día y cada uno empieza antes de que el otro termine.»

### 8. `horario_valido`

**Uso:** `horario_valido(ListaCursos)`.

Valida una lista concreta de cursos sin repeticiones ni cruces.

```prolog
horario_valido([]).
horario_valido([Curso|Resto]) :-
    curso(Curso, _, _),
    horario(Curso, _, Inicio, Fin),
    Inicio < Fin,
    \+ pertenece(Curso, Resto),
    sin_cruces(Curso, Resto),
    horario_valido(Resto).
```

**Cómo funciona:** [] es válido. Para la cabeza verifica existencia, horario e Inicio < Fin. La negación de pertenece impide duplicados en Resto. sin_cruces compara esa cabeza con toda la cola; horario_valido vuelve a aplicar el proceso sobre la cola.

**Ejemplo o conexión:** [calculo1,algebra,programacion1] es válido. [calculo1,algebra,introingenieria] falla aunque las materias que chocan no sean adyacentes.

**Para narrar:** «Cada curso se compara con todos los siguientes, por eso se revisan todos los pares.»

### 9. `sin_cruces`

**Uso:** `sin_cruces(Curso, Lista)`.

Comprueba que Curso no se cruce con ningún elemento de Lista.

```prolog
sin_cruces(_, []).
sin_cruces(Curso, [Otro|Resto]) :-
    \+ cruce_horario(Curso, Otro),
    sin_cruces(Curso, Resto).
```

**Cómo funciona:** Con [] termina. Con [Otro|Resto], la negación de cruce_horario exige que la pareja sea compatible y luego recorre Resto. No valida por sí solo que todos los códigos tengan horarios correctos; esa validación la hacen sus llamadores.

**Ejemplo o conexión:** Se usa tanto al validar una matrícula como al elegir materias de un semestre.

**Para narrar:** «Mantiene fijo un curso y lo compara uno a uno con los demás.»

### 10. `creditos_totales`

**Uso:** `creditos_totales(ListaCursos, Total)`.

Suma los créditos mediante recursividad.

```prolog
creditos_totales([], 0).
creditos_totales([Curso|Resto], Total) :-
    curso(Curso, _, Creditos),
    creditos_totales(Resto, Subtotal),
    Total is Creditos + Subtotal.
```

**Cómo funciona:** [] suma 0. Para cada Curso obtiene Creditos, calcula primero el Subtotal de Resto y después evalúa Total is Creditos + Subtotal. is realiza la suma; = no evaluaría la expresión.

**Ejemplo o conexión:** [calculo1,algebra,programacion1] baja hasta [] y regresa con 0 → 4 → 7 → 11. Cuenta duplicados si se le pasan.

**Para narrar:** «Al regresar de la recursión acumula los créditos de cada materia.»

### 11. `cursos_disponibles`

**Uso:** `cursos_disponibles(Estudiante, Disponibles)`.

Devuelve materias habilitadas que todavía no están aprobadas.

```prolog
cursos_disponibles(Estudiante, Disponibles) :-
    estudiante(Estudiante),
    findall(Curso, curso(Curso, _, _), Catalogo),
    filtrar_disponibles(Catalogo, Estudiante, Disponibles).
```

**Cómo funciona:** Verifica estudiante/1, reúne todos los códigos con findall/3 y delega el filtrado en filtrar_disponibles/3. Conserva el orden del catálogo.

**Ejemplo o conexión:** Para Juan: [introingenieria,calculo2,fisica1,programacion2]. La lista puede contener cruces.

**Para narrar:** «Reúne el catálogo y obtiene las opciones disponibles individualmente para el estudiante.»

### 12. `filtrar_disponibles`

**Uso:** `filtrar_disponibles(Catalogo, Estudiante, Disponibles)`.

Construye recursivamente la lista de disponibles.

```prolog
filtrar_disponibles([], _, []).
filtrar_disponibles([Curso|Resto], Estudiante, Disponibles) :-
    ( puede_tomar(Estudiante, Curso), \+ aprobado(Estudiante, Curso)
    -> Disponibles = [Curso|Cola]
    ;  Disponibles = Cola
    ),
    filtrar_disponibles(Resto, Estudiante, Cola).
```

**Cómo funciona:** [] produce []. El condicional exige puede_tomar y ausencia de aprobado. Si se cumple, Disponibles = [Curso|Cola]; si falla, Disponibles = Cola. La llamada final procesa Resto y completa esa misma Cola en ambas ramas.

**Ejemplo o conexión:** Cálculo 1 se descarta para Juan por estar aprobado; Cálculo 2 se conserva.

**Para narrar:** «Decide si conserva la cabeza y siempre continúa filtrando la cola.»

### 13. `cadena_prerequisitos`

**Uso:** `cadena_prerequisitos(Curso, Cadena)`.

Obtiene todos los prerrequisitos directos e indirectos sin duplicados.

```prolog
cadena_prerequisitos(Curso, Cadena) :-
    cadena_desde(Curso, [], Repetidos),
    sin_repetidos(Repetidos, Cadena).
```

**Cómo funciona:** Inicia cadena_desde con Visitados = [] y obtiene una lista que puede repetir ancestros. Luego sin_repetidos conserva solo su primera aparición. La cadena sigue el orden de recorrido, no el orden de matrícula.

**Ejemplo o conexión:** Para calculo3: [calculo2,calculo1,algebra].

**Para narrar:** «Primero recorre todas las dependencias y después elimina las repeticiones.»

### 14. `cadena_desde`

**Uso:** `cadena_desde(Curso, Visitados, Cadena)`.

Controla el recorrido de una materia y detecta ciclos.

```prolog
cadena_desde(Curso, Visitados, Cadena) :-
    curso(Curso, _, _),
    \+ pertenece(Curso, Visitados),
    prerrequisitos_directos(Curso, Directos),
    expandir_requisitos(Directos, [Curso|Visitados], Cadena).
```

**Cómo funciona:** Comprueba que Curso exista y que no esté en Visitados. Recoge sus Directos y los expande pasando [Curso|Visitados]. Visitados contiene la rama actual, no todos los nodos de todo el recorrido.

**Ejemplo o conexión:** Si A requiere B y B requiere A, al regresar a A ya está visitado y la consulta falla.

**Para narrar:** «Guarda el camino actual para evitar volver a entrar en un curso de la misma rama.»

### 15. `expandir_requisitos`

**Uso:** `expandir_requisitos(Directos, Visitados, Cadena)`.

Expande recursivamente una lista de prerrequisitos.

```prolog
expandir_requisitos([], _, []).
expandir_requisitos([Pre|Resto], Visitados, [Pre|Cadena]) :-
    cadena_desde(Pre, Visitados, Ancestros),
    expandir_requisitos(Resto, Visitados, Otros),
    concatenar(Ancestros, Otros, Cadena).
```

**Cómo funciona:** El caso [] produce []. Para Pre, la cabeza de salida [Pre|Cadena] lo incorpora. cadena_desde obtiene sus Ancestros; la siguiente llamada obtiene Otros a partir de Resto. concatenar une Ancestros y Otros para completar Cadena. Ambas ramas reciben el mismo Visitados del padre.

**Ejemplo o conexión:** Álgebra puede aparecer por las ramas de Cálculo y Estructuras sin ser un ciclo; los duplicados se eliminan después.

**Para narrar:** «Agrega cada prerrequisito, desciende por sus ancestros y luego continúa con sus hermanos.»

### 16. `semestre_minimo`

**Uso:** `semestre_minimo(Curso, Semestre)`.

Expone el cálculo del primer semestre posible según dependencias.

```prolog
semestre_minimo(Curso, Semestre) :-
    semestre_desde(Curso, [], Semestre).
```

**Cómo funciona:** Llama a semestre_desde/3 con una lista vacía de visitados. Este predicado no usa el historial del estudiante ni resuelve cruces de horario.

**Ejemplo o conexión:** calculo1 da 1, calculo3 da 3 y proyecto da 4.

**Para narrar:** «Calcula la profundidad académica de la materia a partir de sus prerrequisitos.»

### 17. `semestre_desde`

**Uso:** `semestre_desde(Curso, Visitados, Semestre)`.

Calcula el semestre de un curso y evita ciclos.

```prolog
semestre_desde(Curso, Visitados, Semestre) :-
    curso(Curso, _, _),
    \+ pertenece(Curso, Visitados),
    prerrequisitos_directos(Curso, Directos),
    maximo_semestre(Directos, [Curso|Visitados], Maximo),
    Semestre is Maximo + 1.
```

**Cómo funciona:** Valida existencia y ausencia en Visitados. Recoge Directos y obtiene su máximo semestre pasando el camino actualizado. Semestre is Maximo + 1 coloca el curso después de todos ellos.

**Ejemplo o conexión:** Sin prerrequisitos, el máximo auxiliar es 0 y el semestre queda en 1.

**Para narrar:** «La materia queda un semestre después del prerrequisito que más tarde puede completarse.»

### 18. `maximo_semestre`

**Uso:** `maximo_semestre(Directos, Visitados, Maximo)`.

Calcula manualmente el mayor semestre de una lista de prerrequisitos.

```prolog
maximo_semestre([], _, 0).
maximo_semestre([Pre|Resto], Visitados, Maximo) :-
    semestre_desde(Pre, Visitados, SemestrePre),
    maximo_semestre(Resto, Visitados, MaximoResto),
    ( SemestrePre > MaximoResto
    -> Maximo = SemestrePre
    ;  Maximo = MaximoResto
    ).
```

**Cómo funciona:** [] devuelve 0. Calcula SemestrePre para la cabeza y MaximoResto para la cola. El condicional compara ambos números y unifica Maximo con el mayor. La comparación > no suma; la suma de 1 ocurre en semestre_desde.

**Ejemplo o conexión:** Cálculo 1 y Álgebra dan 1; su máximo es 1 y Cálculo 2 queda en 2.

**Para narrar:** «Combina dos recursiones: profundiza en una dependencia y recorre las dependencias restantes.»

### 19. `ruta_academica`

**Uso:** `ruta_academica(Estudiante, Cursos, Ruta)`.

Coordina la construcción del plan por semestres.

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

**Cómo funciona:** En orden: valida estudiante; expande objetivos pendientes en Necesarios; elimina repetidos en Unicos; quita aprobados en Pendientes; valida sus horarios; recoge el historial en Aprobados; inicia planificar con semestre 1. Ruta será una lista de semestre(Numero,Cursos).

**Ejemplo o conexión:** ruta_academica(ana,[proyecto],R) agrega las materias previas necesarias automáticamente.

**Para narrar:** «Esta regla conecta las etapas: preparar las materias pendientes y distribuirlas por semestres.»

### 20. `objetivos_pendientes`

**Uso:** `objetivos_pendientes(Cursos, Estudiante, Necesarios)`.

Expande los objetivos que el estudiante todavía no aprobó.

```prolog
objetivos_pendientes([], _, []).
objetivos_pendientes([Curso|Resto], Estudiante, Necesarios) :-
    curso(Curso, _, _),
    ( aprobado(Estudiante, Curso)
    -> Necesarios = Otros
    ;  cadena_prerequisitos(Curso, Cadena),
       concatenar([Curso|Cadena], Otros, Necesarios)
    ),
    objetivos_pendientes(Resto, Estudiante, Otros).
```

**Cómo funciona:** [] produce []. Valida el Curso de la cabeza. Si está aprobado, Necesarios se unifica directamente con Otros. Si no, obtiene Cadena y concatena [Curso|Cadena] con Otros. La última llamada calcula Otros procesando Resto: esta variable puede quedar pendiente de completar por unificación.

**Ejemplo o conexión:** [calculo3] para Ana se amplía a [calculo3,calculo2,calculo1,algebra]. Un objetivo ya aprobado se omite sin recorrer su cadena.

**Para narrar:** «Cada objetivo pendiente aporta la materia y sus dependencias; los aprobados se saltan.»

### 21. `quitar_aprobados`

**Uso:** `quitar_aprobados(Lista, Estudiante, Pendientes)`.

Retira aprobaciones de toda la lista expandida.

```prolog
quitar_aprobados([], _, []).
quitar_aprobados([Curso|Resto], Estudiante, Pendientes) :-
    ( aprobado(Estudiante, Curso)
    -> Pendientes = Cola
    ;  Pendientes = [Curso|Cola]
    ),
    quitar_aprobados(Resto, Estudiante, Cola).
```

**Cómo funciona:** [] produce []. Si Curso está aprobado, Pendientes = Cola; si no, Pendientes = [Curso|Cola]. Continúa con Resto. Es necesario porque las cadenas pueden incluir prerrequisitos ya aprobados aunque el objetivo no lo esté.

**Ejemplo o conexión:** La cadena de Cálculo 3 para Luisa incluye materias previas, pero el filtro deja solo calculo3.

**Para narrar:** «Limpia las aprobaciones que aparecieron al expandir las dependencias.»

### 22. `validar_horarios`

**Uso:** `validar_horarios(Pendientes)`.

Verifica que cada curso tenga un horario individual válido.

```prolog
validar_horarios([]).
validar_horarios([Curso|Resto]) :-
    horario_valido([Curso]),
    validar_horarios(Resto).
```

**Cómo funciona:** El caso [] termina. horario_valido([Curso]) revisa una lista de un solo elemento, luego continúa con Resto. No exige compatibilidad de todos los pendientes a la vez: pueden distribuirse en semestres diferentes.

**Ejemplo o conexión:** Cálculo 2 y Física 1 pueden pasar esta validación aunque se crucen entre sí.

**Para narrar:** «Aquí comprueba cada horario; los cruces entre materias se resuelven al seleccionar cada semestre.»

### 23. `planificar`

**Uso:** `planificar(Pendientes, Completados, Semestre, Ruta)`.

Construye recursivamente la secuencia de semestres.

```prolog
planificar([], _, _, []).
planificar([Curso|Resto], Completados, Semestre, Ruta) :-
    seleccionar_semestre([Curso|Resto], Completados, Semestre, [],
                         Elegidos, Pendientes),
    Siguiente is Semestre + 1,
    concatenar(Elegidos, Completados, NuevosCompletados),
    ( Elegidos = []
    -> Ruta = Cola
    ;  Ruta = [semestre(Semestre, Elegidos)|Cola]
    ),
    planificar(Pendientes, NuevosCompletados, Siguiente, Cola).
```

**Cómo funciona:** Si no hay pendientes, la ruta restante es []. Si hay, seleccionar_semestre parte con Ocupados = [] y devuelve Elegidos y Pendientes nuevos. Incrementa Semestre; concatena Elegidos y Completados. Si Elegidos = [], omite ese semestre en la salida; si no, agrega semestre(Semestre,Elegidos). Repite con los pendientes y completados actualizados.

**Ejemplo o conexión:** Puede avanzar por un semestre vacío para respetar semestre_minimo. Los cursos recién elegidos solo se consideran completados en la siguiente selección.

**Para narrar:** «En cada vuelta arma un semestre, actualiza el estado y continúa hasta ubicar todas las materias.»

### 24. `seleccionar_semestre`

**Uso:** `seleccionar_semestre(Lista, Completados, Semestre, Ocupados, Elegidos, Pendientes)`.

Separa los cursos que caben en el semestre de los que deben esperar.

```prolog
seleccionar_semestre([], _, _, _, [], []).
seleccionar_semestre([Curso|Resto], Completados, Semestre, Ocupados,
                      Elegidos, Pendientes) :-
    ( habilitado_en(Curso, Completados, Semestre),
      sin_cruces(Curso, Ocupados)
    -> Elegidos = [Curso|MasElegidos],
       seleccionar_semestre(Resto, Completados, Semestre, [Curso|Ocupados],
                            MasElegidos, Pendientes)
    ;  Pendientes = [Curso|MasPendientes],
       seleccionar_semestre(Resto, Completados, Semestre, Ocupados,
                            Elegidos, MasPendientes)
    ).
```

**Cómo funciona:** Los primeros cuatro argumentos representan el estado de entrada; los últimos dos son listas de salida. El caso [] termina con ambas salidas vacías. Para Curso exige habilitado_en y sin_cruces con Ocupados. Si cumple, lo añade a Elegidos y a Ocupados. Si falla, lo añade a Pendientes. Ambas ramas recorren Resto manteniendo Completados fijo.

**Ejemplo o conexión:** Ocupados cambia dentro del semestre; Completados solo cambia entre semestres. Ante un cruce gana el primer curso habilitado encontrado.

**Para narrar:** «Elige una materia solo si cumple sus dependencias y cabe en el horario del semestre actual.»

### 25. `habilitado_en`

**Uso:** `habilitado_en(Curso, Completados, Semestre)`.

Comprueba si académicamente una materia puede ubicarse ahora.

```prolog
habilitado_en(Curso, Completados, Semestre) :-
    semestre_minimo(Curso, Minimo),
    Semestre >= Minimo,
    prerrequisitos_directos(Curso, Directos),
    todos_completados(Directos, Completados).
```

**Cómo funciona:** Obtiene Minimo y exige Semestre >= Minimo. Recoge los prerrequisitos directos y llama a todos_completados/2. La compatibilidad horaria se comprueba aparte, en seleccionar_semestre.

**Ejemplo o conexión:** Cumplir el semestre mínimo no basta si un prerrequisito se atrasó por un cruce.

**Para narrar:** «Exige tanto el número mínimo de semestre como haber completado realmente las materias previas del plan.»

### 26. `todos_completados`

**Uso:** `todos_completados(Directos, Completados)`.

Verifica prerrequisitos contra el estado local del plan.

```prolog
todos_completados([], _).
todos_completados([Pre|Resto], Completados) :-
    pertenece(Pre, Completados),
    todos_completados(Resto, Completados).
```

**Cómo funciona:** [] tiene éxito. Para [Pre|Resto], pertenece comprueba Pre en Completados y luego se procesa Resto. Se diferencia de requisitos_aprobados: aquel consulta hechos aprobado/2; este consulta una lista que incluye también lo planificado en semestres anteriores.

**Ejemplo o conexión:** No agrega hechos aprobado/2: simula el avance académico dentro de la consulta.

**Para narrar:** «Comprueba que cada prerrequisito esté en el historial o en un semestre anterior del plan.»

## Ejemplo completo para mostrar el resultado

Desde la raíz del repositorio, abre la consola:

```sh
swipl -s Prolog/proyectoHorario.pl
```

El indicador `?-` lo muestra la consola; escribe solo la consulta que le sigue.

```prolog
?- ruta_academica(ana, [proyecto], Ruta).
Ruta = [semestre(1, [calculo1, algebra, programacion1]),
        semestre(2, [calculo2, programacion2]),
        semestre(3, [calculo3, estructuras]),
        semestre(4, [proyecto])].
```

Tras expandir objetivos y eliminar repetidos, los pendientes de Ana son:

```prolog
[proyecto, calculo3, calculo2, calculo1, algebra,
 estructuras, programacion2, programacion1]
```

| Selección | Elegidos | Pendientes para la siguiente llamada |
| --- | --- | --- |
| Semestre 1 | Cálculo 1, Álgebra, Programación 1 | Proyecto, Cálculo 3, Cálculo 2, Estructuras, Programación 2 |
| Semestre 2 | Cálculo 2, Programación 2 | Proyecto, Cálculo 3, Estructuras |
| Semestre 3 | Cálculo 3, Estructuras | Proyecto |
| Semestre 4 | Proyecto | Ninguno: se alcanza el caso base |

Al explicar la tabla, señala `seleccionar_semestre` para la elección y `planificar` para el avance. Las listas representan un plan hipotético; no se insertan aprobaciones en la base.

Otros dos ejemplos permiten explicar los límites sin extenderse:

```prolog
?- ruta_academica(juan, [calculo2, fisica1], R).
R = [semestre(2, [calculo2]), semestre(3, [fisica1])].

?- ruta_academica(luisa, [calculo3], R).
R = [semestre(3, [calculo3])].
```

El primero separa dos cursos por un cruce. El segundo conserva el semestre mínimo académico: no significa que a Luisa le falten tres semestres. La ruta respeta el orden de selección y no garantiza minimizar la duración ni limita créditos por semestre.

## Archivo 2: pruebas.pl

Este archivo verifica el comportamiento del programa. Los auxiliares de pruebas no forman parte del algoritmo que genera la ruta.

### 1. Carga, biblioteca y predicados dinámicos

```prolog
:- ensure_loaded('proyectoHorario.pl').
:- use_module(library(plunit)).
:- dynamic curso/3, horario/4, prerequisito/2, aprobado/2.
:- begin_tests(horarios_prolog).
```

- `ensure_loaded` carga el programa y, a través de él, los datos.
- `use_module` carga el sistema de pruebas de SWI-Prolog.
- `dynamic` permite agregar y retirar hechos temporalmente durante las pruebas de datos defectuosos.
- `begin_tests` abre el grupo; `end_tests`, al final del archivo, lo cierra.

**Para narrar:** «Este segundo archivo carga el programa y prepara pruebas que comparan su comportamiento con resultados esperados.»

### 2. Cómo leer test y sus opciones

```prolog
test(sin_prerrequisitos) :- puede_tomar(ana, calculo1).
test(faltan_prerrequisitos, [fail]) :- puede_tomar(ana, calculo2).
test(creditos_varios, true(T == 11)) :-
    creditos_totales([calculo1,algebra,programacion1], T).
```

| Construcción | Qué verifica o hace |
| --- | --- |
| `test(Nombre) :- Consulta` | Espera que la consulta tenga éxito. |
| `[fail]` | Espera que falle; ese fallo significa que la prueba pasó. |
| `true(T == 11)` | Comprueba el valor obtenido; `==` compara términos sin unificarlos. |
| `[nondet]` | Permite que el éxito deje puntos de elección; no obliga a producir varias respuestas. |
| `set(C == [...])` | Recoge las soluciones y las compara como conjunto. |
| `setup(...)` | Prepara datos antes del caso. |
| `cleanup(...)` | Retira los datos temporales después del caso. |
| `assertz(...)` | Inserta un hecho al final del predicado en memoria. |
| `retractall(...)` | Elimina todos los hechos que coinciden con el patrón indicado. |
| `user:` | Dirige el cambio a los predicados del programa cargados en el módulo user. |
| `assertion(Condicion)` | Comprueba una propiedad dentro de una prueba. |

Por ejemplo, `falta_solo_un_prerrequisito` agrega temporalmente que Ana aprobó Cálculo 1. La consulta para Cálculo 2 debe seguir fallando porque aún falta Álgebra. Después elimina la aprobación temporal.

### 3. Recorrido de los casos, en orden

| Bloque de pruebas | Propiedad que comprueba |
| --- | --- |
| Elegibilidad y disponibles | Cursos iniciales, todos o algunos prerrequisitos, códigos desconocidos, estudiantes desconocidos, aprobados y consultas con variables. |
| Cruces | Superposición parcial, simetría, extremos contiguos, días distintos, exclusión del mismo curso y enumeración de pares. |
| Horarios y créditos | Lista vacía, compatibilidad, conflicto no adyacente, repeticiones, cursos inexistentes y suma esperada. |
| Cadenas y semestres | Ausencia de prerrequisitos, dependencias transitivas, ancestro compartido, varias ramas y semestre mínimo. |
| Rutas | Objetivos vacíos o aprobados, expansión automática, cruces, prerrequisitos en semestres anteriores, duplicados y entradas desconocidas. |
| Datos defectuosos | Ciclos, prerrequisitos inexistentes, horarios ausentes y horarios invertidos. |

Cada `test` es un caso declarativo, no un nuevo algoritmo del sistema experto. Para el video basta mostrar cómo se leen un caso positivo, uno negativo y uno con resultado; el resto aplica el mismo patrón.

### 4. crear_ciclo/0 y borrar_ciclo/0

`crear_ciclo` agrega los cursos ficticios `ciclo_a` y `ciclo_b` y dos prerrequisitos opuestos: A requiere B y B requiere A. No recibe argumentos.

`borrar_ciclo` retira ambos cursos y sus relaciones. Las opciones `setup(crear_ciclo)` y `cleanup(borrar_ciclo)` aíslan cada caso. Las pruebas esperan que cadena, semestre mínimo y ruta fallen al encontrar el ciclo.

**Para narrar:** «Se crea un ciclo temporal para comprobar que los recorridos lo detectan y luego se limpia la base.»

### 5. subconjunto/2

```prolog
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :- subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :- subconjunto(Xs, Ys).
```

**Argumentos:** catálogo de entrada y subconjunto generado.

La primera cláusula termina. La segunda incluye la cabeza; la tercera la omite. Mediante backtracking se exploran ambas decisiones para cada curso. Con diez cursos aparecen 2 elevado a 10, es decir, 1.024 subconjuntos, incluido el vacío.

**Para narrar:** «Este generador permite probar todas las combinaciones de objetivos del catálogo.»

### 6. ancestro/2

```prolog
ancestro(Curso, Pre) :- prerequisito(Curso, Pre).
ancestro(Curso, Pre) :- prerequisito(Curso, Directo), ancestro(Directo, Pre).
```

**Argumentos:** curso consultado y prerrequisito directo o indirecto encontrado.

La primera cláusula encuentra una dependencia directa. La segunda baja por un prerrequisito y continúa buscando. Sirve para calcular qué materias deberían estar en el plan sin utilizar los auxiliares del planificador.

Este auxiliar de pruebas presupone el catálogo sin ciclos; no lleva Visitados. Los ciclos temporales se retiran antes de la comprobación masiva.

**Para narrar:** «Se vuelven a obtener las dependencias desde los hechos para contrastar lo que generó la ruta.»

### 7. verificar_ruta/3

**Argumentos:** estudiante, objetivos originales y ruta que se quiere comprobar.

El bloque se lee por etapas:

1. `findall` y dos llamadas a `member` recorren los semestres y sus listas para reunir todos los cursos en `Planeados`.
2. `sort(Planeados, Unicos)` ordena y elimina duplicados. Exigir que ambas listas tengan la misma longitud comprueba que no había cursos repetidos.
3. Otro `findall` obtiene los objetivos no aprobados y sus ancestros pendientes. `sort` normaliza esa lista en `Esperados`.
4. `assertion(Unicos == Esperados)` verifica que no sobren ni falten materias.
5. Recoge los números de semestre y los compara con su versión ordenada y sin repetidos: deben aparecer en orden estricto.
6. Un `forall` recorre cada semestre y exige que su lista no esté vacía.
7. Otro recorre cada curso: no debe estar aprobado y su número debe ser al menos el de `semestre_minimo`.
8. Para cada prerrequisito exige una de dos posibilidades: ya está aprobado, o aparece en un semestre anterior de la ruta.
9. Finalmente recorre pares del mismo día y comprueba `FA =< IB ; FB =< IA`: uno debe terminar antes o justo cuando empieza el otro.

Aquí `;` expresa alternativas lógicas; `=<` significa menor o igual; `\=` exige que dos términos no puedan unificarse en ese momento.

El verificador usa utilidades predefinidas en las pruebas; el procesamiento del código de producción sigue siendo manual y recursivo. Reutiliza `semestre_minimo/2` para el límite académico, por lo que esa comprobación no es independiente de dicho predicado; este cuenta además con casos específicos.

**Para narrar:** «El verificador comprueba materias exactas, ausencia de duplicados, orden de semestres, dependencias anteriores y compatibilidad horaria.»

### 8. rutas_de_todos_los_subconjuntos

Recoge el catálogo con `findall`. El `forall` exterior combina cada uno de los estudiantes `[ana,juan,luisa]` con cada subconjunto generado.

Para cada combinación:

- `findall(R, ruta_academica(E,Objetivos,R), Soluciones)` reúne todas las rutas obtenidas.
- `assertion(Soluciones = [_])` exige una lista con exactamente una solución.
- `Soluciones = [Ruta]` obtiene esa única ruta.
- `verificar_ruta` comprueba sus propiedades.

Se verifican **3 × 1.024 = 3.072 rutas**. La cobertura es exhaustiva para los subconjuntos de este catálogo y estos tres historiales, no para cualquier base de datos posible ni para todas las permutaciones de objetivos.

**Para narrar:** «La última prueba genera 3.072 casos y exige una única ruta válida para cada uno.»

### 9. Ejecutar las pruebas

Desde la raíz del repositorio:

```sh
swipl -q -s Prolog/pruebas.pl -g run_tests -t halt
```

`-q` reduce mensajes iniciales; `-s` carga el archivo; `-g run_tests` ejecuta las pruebas y `-t halt` termina la sesión al llegar al objetivo final.

En la revisión del 1 de octubre de 2026 pasaron las 51 pruebas. Una de ellas incluye las 3.072 rutas anteriores. Para grabar la demostración, ejecuta el comando y muestra su resultado actual.

## Guion breve para grabar hasta cinco minutos

La explicación anterior es el material de apoyo completo. El siguiente texto agrupa auxiliares para que el video pueda ser breve. Los tiempos son orientativos: ensaya la lectura y los desplazamientos antes de grabar.

### 0:00–0:20 — Inicio y auxiliares de listas

**Mostrar:** carga de datos, pertenece, concatenar y sin_repetidos.

> Este programa resuelve la elegibilidad de matrícula y construye rutas académicas. Primero carga los hechos. Los auxiliares recorren listas: pertenece busca un elemento, concatenar une dos listas y sin_repetidos conserva la primera aparición usando una lista de elementos vistos.

### 0:20–0:55 — Elegibilidad

**Mostrar:** prerrequisitos_directos, puede_tomar y requisitos_aprobados.

> Prerrequisitos directos recoge los hechos con findall. Puede tomar comprueba que existan estudiante y curso y después verifica todos los prerrequisitos recursivamente. La lista vacía es el caso base. En cada paso se exige la aprobación de la cabeza y se continúa con la cola. Por eso Juan puede tomar Cálculo 2 y Ana todavía no. Esta regla comprueba prerrequisitos; la exclusión de materias aprobadas se hace después.

### 0:55–1:30 — Horarios y créditos

**Mostrar:** cruce_horario hasta creditos_totales.

> El cruce exige cursos distintos, el mismo día y dos desigualdades: cada clase debe empezar antes de que termine la otra. Los horarios contiguos son compatibles. Horario válido revisa existencia, duración y duplicados, compara la cabeza con toda la cola mediante sin cruces y repite el proceso. Créditos totales llega al caso base cero y, al regresar, suma los créditos de cada materia.

### 1:30–1:50 — Disponibles

**Mostrar:** cursos_disponibles y filtrar_disponibles.

> Cursos disponibles recoge el catálogo y lo filtra. Si la materia cumple los prerrequisitos y no está aprobada, se agrega a la salida; de lo contrario se omite. Ambas ramas continúan con el resto de la lista. Estas materias están disponibles individualmente, pero pueden cruzarse entre sí.

### 1:50–2:35 — Dependencias y semestre mínimo

**Mostrar:** cadena_prerequisitos hasta maximo_semestre.

> Cadena de prerrequisitos recorre las dependencias en profundidad y elimina duplicados. Cadena desde guarda los visitados de la rama actual para detectar ciclos. Expandir requisitos incorpora cada dependencia, recorre sus ancestros y continúa con las restantes. Semestre mínimo usa un recorrido similar: calcula manualmente el mayor semestre de los prerrequisitos y suma uno. Sin prerrequisitos, el máximo es cero y la materia queda en primero. Así Cálculo 3 tiene semestre mínimo tres.

### 2:35–4:15 — Preparación y planificación

**Mostrar:** ruta_academica y desplazar hasta todos_completados; terminar con la consulta de Ana.

> Ruta académica coordina el proceso. Objetivos pendientes agrega las dependencias de las materias solicitadas; después se eliminan duplicados y aprobadas. Validar horarios comprueba cada horario individualmente, porque los cursos pueden quedar en semestres distintos.
>
> Planificar construye un semestre a la vez. Seleccionar semestre recorre los pendientes y separa elegidos de aplazados. Para elegir una materia, habilitado en exige alcanzar su semestre mínimo y tener todos sus prerrequisitos en completados. También debe ser compatible con los cursos ocupados del semestre.
>
> Ocupados cambia al elegir cada materia, pero completados permanece fijo durante esa selección. Solo al pasar al semestre siguiente se agregan los elegidos a completados. Esto evita cursar una materia junto con su prerrequisito. Cuando ya no quedan pendientes, se alcanza el caso base.
>
> Para Ana y el objetivo Proyecto, primero se ubican Cálculo 1, Álgebra y Programación 1; después Cálculo 2 y Programación 2; luego Cálculo 3 y Estructuras; finalmente Proyecto. El plan no modifica los hechos de aprobaciones y no busca necesariamente el menor número de semestres.

### 4:15–5:00 — Pruebas y cierre

**Mostrar:** apertura de pruebas.pl, ejemplos test, auxiliares y comando de ejecución.

> El segundo archivo contiene las pruebas. Un caso puede exigir éxito, fallo o un resultado concreto. Setup y cleanup permiten agregar datos defectuosos y retirarlos después. Crear ciclo y borrar ciclo comprueban la detección de dependencias circulares.
>
> Subconjunto genera las combinaciones de objetivos y ancestro obtiene las dependencias para contrastarlas. Verificar ruta revisa que estén las materias exactas, sin repetidos, con prerrequisitos anteriores y sin cruces. La última prueba evalúa los 1.024 subconjuntos para tres estudiantes: 3.072 rutas. Al ejecutar las pruebas comprobamos el comportamiento de ambos sistemas expertos.
