# Informe técnico — Programación funcional en Haskell

## 1. Descripción general

La primera parte del proyecto consiste en desarrollar, mediante el paradigma de programación funcional, un sistema para generar y clasificar posibles horarios académicos. La implementación se realizó en Haskell utilizando tipos de datos propios, reconocimiento de patrones, funciones puras y recursión explícita.

El sistema recibe un catálogo de cursos con la información de cada asignatura:

- Código.
- Nombre.
- Cantidad de créditos.
- Horario.
- Lista de prerrequisitos.

A partir del catálogo, el programa genera todas las combinaciones posibles de cursos y conserva únicamente aquellas que:

1. No presentan cruces de horario.
2. Tienen una cantidad total de créditos dentro del rango solicitado.

Posteriormente, las combinaciones válidas son clasificadas mediante una lista de prioridades definida por el estudiante. El programa calcula el puntaje de cada combinación, las ordena de mayor a menor y devuelve las mejores alternativas junto con su posición y puntaje.

## 2. Objetivos

### 2.1. Objetivo general

Desarrollar en Haskell un sistema funcional que permita generar combinaciones de cursos sin conflictos de horario y clasificarlas de acuerdo con las preferencias académicas de un estudiante.

### 2.2. Objetivos específicos

- Representar cursos y horarios mediante tipos de datos definidos por el usuario.
- Determinar si dos horarios se superponen.
- Verificar que una lista completa de cursos no contenga conflictos.
- Calcular recursivamente la cantidad total de créditos de una combinación.
- Generar todas las combinaciones posibles de un catálogo.
- Filtrar las combinaciones según sus horarios y créditos.
- Calcular un puntaje de preferencia para cada combinación.
- Implementar un algoritmo de ordenamiento recursivo sin utilizar `sort`.
- Obtener las mejores `n` combinaciones y asignarles una posición.
- Comprobar el funcionamiento mediante pruebas funcionales y una prueba de integración.

## 3. Organización del código

La implementación está dividida en los siguientes archivos:

| Archivo | Descripción |
|---|---|
| [`ProyectoHorario.hs`](./ProyectoHorario.hs) | Contiene los tipos de datos y las funciones que implementan la lógica del sistema. |
| [`Main.hs`](./Main.hs) | Contiene el catálogo académico, las prioridades, las pruebas funcionales y los ejemplos de ejecución. |

La separación entre los archivos permite mantener la lógica principal independiente de los datos utilizados para probarla.

## 4. Restricciones de implementación

Las funcionalidades principales fueron desarrolladas desde cero mediante recursión explícita, de acuerdo con las restricciones establecidas en el enunciado.

No se utilizaron las siguientes funciones predefinidas:

- `sort`
- `sum`
- `maximum`
- `map`
- `foldr`
- `zip`

Tampoco se utilizaron algoritmos combinatorios predefinidos.

Para procesar las listas se emplearon:

- Casos base.
- Reconocimiento de patrones.
- Llamadas recursivas.
- Construcción de listas mediante el operador `:`.

Para ordenar las combinaciones se implementó un algoritmo de **ordenamiento por inserción recursivo**. La generación de combinaciones se desarrolló mediante la estrategia de crear, para cada curso:

1. Las combinaciones que no incluyen el curso.
2. Las combinaciones que sí incluyen el curso.

## 5. Flujo general del programa

```text
Catálogo de cursos
        |
        v
Generación de combinaciones
        |
        v
Validación de horarios y créditos
        |
        v
Cálculo de puntajes
        |
        v
Ordenamiento por prioridad
        |
        v
Selección de los mejores horarios
