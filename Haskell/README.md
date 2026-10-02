Parte I — Programación funcional en Haskell
1. Descripción general
La primera parte del proyecto consiste en desarrollar, mediante el paradigma de programación funcional, un sistema para generar y clasificar posibles horarios académicos. La implementación se realizó en Haskell utilizando tipos de datos propios, reconocimiento de patrones, funciones puras y recursión explícita.

El sistema recibe un catálogo de cursos que contiene la información de cada asignatura, incluyendo su código, nombre, cantidad de créditos, horario y lista de prerrequisitos. A partir de dicho catálogo, el programa genera todas las combinaciones posibles de cursos y conserva únicamente aquellas que no presentan cruces de horario y cuya cantidad total de créditos se encuentra dentro de un rango establecido.

Posteriormente, las combinaciones válidas se clasifican de acuerdo con una lista de prioridades definida por el estudiante. Cada curso recibe un valor numérico que representa el nivel de preferencia del estudiante. El programa calcula el puntaje total de cada combinación, las ordena de mayor a menor y devuelve las mejores alternativas junto con su posición y puntaje.

La implementación fue dividida en dos archivos. El archivo ProyectoHorario.hs contiene los tipos de datos y las funciones que implementan la lógica principal. El archivo Main.hs contiene el catálogo académico utilizado, las prioridades, las pruebas funcionales y los ejemplos de ejecución.

2. Objetivos
2.1. Objetivo general
Desarrollar en Haskell un sistema funcional que permita generar combinaciones de cursos sin conflictos de horario y clasificarlas según las preferencias académicas de un estudiante.

2.2. Objetivos específicos
Representar cursos y horarios mediante tipos de datos definidos por el usuario.
Determinar si dos horarios se superponen.
Verificar que una lista completa de cursos no contenga conflictos.
Calcular recursivamente la cantidad total de créditos de una combinación.
Generar todas las combinaciones posibles de un catálogo.
Filtrar las combinaciones según sus horarios y créditos.
Calcular un puntaje de preferencia para cada combinación.
Implementar un algoritmo de ordenamiento recursivo sin utilizar sort.
Obtener las mejores n combinaciones y asignarles una posición dentro del ranking.
Validar el funcionamiento mediante pruebas unitarias sencillas y una prueba de integración.
3. Restricciones de implementación
De acuerdo con los requisitos de la práctica, las funcionalidades principales fueron desarrolladas desde cero mediante recursión explícita. No se utilizaron funciones predefinidas de ordenamiento o agregación como sort, sum o maximum.

Tampoco se emplearon algoritmos combinatorios predefinidos ni funciones de orden superior como map, foldr o zip. Cuando fue necesario recorrer una lista, se utilizaron casos base, reconocimiento de patrones y llamadas recursivas.

Para ordenar las opciones válidas se implementó el algoritmo de ordenamiento por inserción. La generación de combinaciones se desarrolló mediante la estrategia recursiva de crear, para cada curso, un grupo de combinaciones que lo incluye y otro que no lo incluye.
