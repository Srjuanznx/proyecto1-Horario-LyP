# Parte II: programación lógica

Implementación de los dos sistemas expertos del enunciado: elegibilidad de matrícula y rutas académicas. Se ejecuta con SWI-Prolog; validada con la versión 10.0.2.

## Archivos

- `datos.pl`: catálogo ficticio de diez cursos, horarios, prerrequisitos y tres estudiantes.
- `proyectoHorario.pl`: ocho predicados requeridos y sus auxiliares recursivos. Carga los datos automáticamente.
- `pruebas.pl`: 51 pruebas automatizadas. Una comprueba las 1.024 combinaciones del catálogo para cada estudiante: 3.072 rutas en total.

## Ejecución

Desde la raíz del repositorio:

```sh
swipl -s Prolog/proyectoHorario.pl
```

También se puede abrir SWI-Prolog y cargar:

```prolog
?- ['Prolog/proyectoHorario.pl'].
```

El prefijo `?-` representa la consola; no se escribe dentro del archivo fuente.
Para salir: `halt.`. Para pedir otra solución: `;`.

## Consultas de cada requisito

```prolog
?- puede_tomar(juan, calculo2).
true.

?- cruce_horario(calculo2, fisica1).
true.

?- horario_valido([calculo1, algebra, programacion1]).
true.

?- creditos_totales([calculo1, algebra, programacion1], Total).
Total = 11.

?- cursos_disponibles(juan, Disponibles).
Disponibles = [introingenieria, calculo2, fisica1, programacion2].

?- cadena_prerequisitos(calculo3, Cadena).
Cadena = [calculo2, calculo1, algebra].

?- semestre_minimo(calculo3, Semestre).
Semestre = 3.

?- ruta_academica(ana, [proyecto], Ruta).
Ruta = [semestre(1, [calculo1, algebra, programacion1]),
        semestre(2, [calculo2, programacion2]),
        semestre(3, [calculo3, estructuras]),
        semestre(4, [proyecto])].
```

Ejemplos adicionales para comprobar límites:

```prolog
?- puede_tomar(ana, calculo2).
false.

?- cruce_horario(calculo1, programacion1).
false.

?- horario_valido([calculo1, introingenieria]).
false.

?- ruta_academica(juan, [calculo2, fisica1], Ruta).
Ruta = [semestre(2, [calculo2]), semestre(3, [fisica1])].
```

## Contrato de los predicados

| Predicado | Entradas y resultado | Recursividad |
| --- | --- | --- |
| `puede_tomar/2` | Comprueba todos los prerrequisitos directos. Acepta variables para enumerar cursos o estudiantes registrados. | `requisitos_aprobados/2` consume la lista de prerrequisitos. |
| `cruce_horario/2` | Detecta cruces entre cursos distintos; permite enumerar pares. | Comparación directa de los dos intervalos. |
| `horario_valido/1` | Recibe una lista concreta y finita de cursos conocidos, sin repeticiones. | Cada cabeza se compara con la cola y se valida el resto. |
| `creditos_totales/2` | Recibe una lista concreta y devuelve su suma. Cuenta cada aparición; para una matrícula se debe validar primero la lista. | Suma los créditos de la cabeza al resultado de la cola. |
| `cursos_disponibles/2` | Recibe un estudiante y devuelve cursos habilitados que aún no aprobó, en orden del catálogo. | Filtra el catálogo elemento por elemento. |
| `cadena_prerequisitos/2` | Recibe un curso y devuelve todos sus prerrequisitos sin duplicados; también permite enumerar cursos. | Recorre el grafo en profundidad y elimina repeticiones conservando la primera aparición. |
| `semestre_minimo/2` | Devuelve 1 para cursos iniciales y 1 más que el mayor semestre de sus prerrequisitos. | Calcula recursivamente los semestres y el máximo. |
| `ruta_academica/3` | Recibe estudiante y lista concreta de objetivos; devuelve una lista de `semestre(Numero, Cursos)`. | Expande objetivos, elimina aprobados y asigna cursos semestre por semestre. |

## Decisiones de modelado

1. Cada curso tiene un código único y un único horario semanal con inicio menor que fin. Las horas son decimales: `8.5` son las 08:30, no `8.30`.
2. Las clases que solo comparten un extremo no se cruzan: 7–9 y 9–11 son compatibles. Un horario de matrícula rechaza cursos repetidos.
3. `puede_tomar/2` comprueba los prerrequisitos tal como pide el PDF. La exclusión de materias ya aprobadas corresponde a `cursos_disponibles/2`.
4. `estudiante/1` permite distinguir un estudiante nuevo, sin aprobaciones, de un nombre desconocido. Ana tiene historial vacío; Juan y Luisa tienen avances distintos.
5. La ruta agrega automáticamente prerrequisitos pendientes, elimina materias aprobadas y repeticiones. Una materia aprobada se considera completada antes del plan. Los hechos de ejemplo mantienen un historial coherente con los prerrequisitos.
6. Los números de semestre respetan `semestre_minimo/2`. No representan cuántos semestres le faltan al estudiante. Si Luisa pide Cálculo 3, aparece en el semestre 3 aunque sus prerrequisitos ya estén aprobados. Los semestres sin cursos se omiten.
7. Los cursos de un semestre se consideran completados únicamente para el siguiente. Un retraso por cruce también retrasa las materias que dependen de ese curso.
8. Ante un cruce se favorece el primer curso pendiente según el orden de los objetivos y su expansión. Se produce un plan válido; no se busca minimizar el número total de semestres. El enunciado no solicita un límite de créditos para esta ruta Prolog.
9. Un curso desconocido, un prerrequisito inexistente o un ciclo en una cadena consultada hacen fallar la consulta. La ruta también rechaza cursos pendientes sin horario o con un intervalo inválido. La detección de ciclos usa la rama actual de la búsqueda, por lo que compartir un ancestro entre materias sí es válido.

## Cumplimiento de la recursividad

El código de producción implementa manualmente pertenencia, concatenación, eliminación de repetidos, filtrado, suma, máximo, recorridos de prerrequisitos y planificación. `findall/3` solo recoge hechos de la base; no sustituye los filtros ni las verificaciones recursivas. No se usa `forall/2` para comprobar prerrequisitos ni agregaciones predefinidas para calcular créditos o semestres.

El archivo de pruebas usa utilidades de SWI-Prolog para contrastar resultados de forma independiente. Esas utilidades no forman parte de los algoritmos entregados.

## Pruebas

Desde la raíz del repositorio:

```sh
swipl -q -s Prolog/pruebas.pl -g run_tests -t halt
```

Se comprueban los ocho requisitos, consultas con variables, extremos de horarios, listas vacías, duplicados, cursos y estudiantes desconocidos, ciclos y datos incompletos. Para las 3.072 rutas se verifica que:

- aparezcan exactamente las materias pendientes necesarias, una vez cada una;
- los prerrequisitos estén aprobados o en un semestre anterior;
- los cursos respeten su semestre mínimo;
- los semestres estén ordenados y no contengan cruces.

## Orden sugerido para estudiar y sustentar

1. Leer los hechos de `datos.pl` y consultar cursos y aprobaciones.
2. Seguir `puede_tomar/2` y sus casos base y recursivo.
3. Explicar la fórmula de cruce y la validación de una lista.
4. Recorrer la suma de créditos y el filtro de cursos disponibles.
5. Dibujar las dependencias de `calculo3` y de `proyecto`.
6. Seguir la planificación de Ana hacia `proyecto`, semestre por semestre.

## Transparencia sobre IA

Esta implementación, los datos de ejemplo, las pruebas y esta guía se prepararon con asistencia de OpenAI Codex a partir del enunciado. Las pruebas se ejecutaron en SWI-Prolog. Los estudiantes deben revisar y comprender el código, adaptar los datos si corresponde y declarar este uso de IA en el informe técnico solicitado por el curso. Esta guía no sustituye el informe ni el video de sustentación.
