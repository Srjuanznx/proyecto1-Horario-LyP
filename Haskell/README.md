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
```



## 6. Modelo de datos

Para representar la información académica se definieron los tipos de datos `Horario` y `Curso`.

### 6.1. Tipo `Horario`

```haskell
data Horario = Horario
    { dia        :: String
    , horaInicio :: Double
    , horaFin    :: Double
    } deriving (Show, Eq)
```

El tipo `Horario` representa el espacio temporal semanal de una asignatura.

| Campo | Tipo | Descripción |
|---|---|---|
| `dia` | `String` | Día de la semana en el que se ofrece el curso. |
| `horaInicio` | `Double` | Hora en la que comienza la clase, expresada en formato decimal. |
| `horaFin` | `Double` | Hora en la que termina la clase, expresada en formato decimal. |

Ejemplo:

```haskell
hCalculoIII = Horario "Lunes" 7.0 9.0
```

Este valor representa una clase que se ofrece el lunes desde las 7:00 hasta las 9:00.

### 6.2. Tipo `Curso`

```haskell
data Curso = Curso
    { codigo        :: String
    , nombreCurso   :: String
    , creditos      :: Int
    , horario       :: Horario
    , prerequisitos :: [String]
    } deriving (Show, Eq)
```

El tipo `Curso` representa la información académica necesaria de una asignatura.

| Campo | Tipo | Descripción |
|---|---|---|
| `codigo` | `String` | Código utilizado para identificar el curso. |
| `nombreCurso` | `String` | Nombre completo de la asignatura. |
| `creditos` | `Int` | Número de créditos académicos del curso. |
| `horario` | `Horario` | Estructura que contiene el día y las horas del curso. |
| `prerequisitos` | `[String]` | Lista de códigos de los cursos que deben aprobarse previamente. |

Ejemplo:

```haskell
calculoIII =
    Curso "NM2001" "Calculo III" 3 hCalculoIII []
```

El ejemplo representa el curso Cálculo III, identificado por el código `NM2001`, con tres créditos, un horario asociado y sin prerrequisitos registrados en los datos de prueba.

Los prerrequisitos se incluyen como parte del modelo solicitado. Sin embargo, su análisis y validación corresponden principalmente al componente lógico desarrollado en Prolog.

### 6.3. Derivación de `Show` y `Eq`

Ambos tipos utilizan:

```haskell
deriving (Show, Eq)
```

La clase `Show` permite convertir los valores en texto para mostrarlos en la terminal. Esta funcionalidad se utiliza durante las pruebas y la depuración.

La clase `Eq` permite comparar dos valores del mismo tipo mediante los operadores:

```haskell
==
/=
```

Gracias a `Eq`, las pruebas automáticas pueden comparar cursos, horarios, combinaciones y resultados completos.

## 7. Catálogo utilizado en las pruebas

Los nombres, códigos y créditos corresponden a las materias suministradas para el tercer semestre. Los horarios son ficticios y fueron definidos únicamente para comprobar la detección de conflictos.

| Código | Asignatura | Créditos | Horario de prueba |
|---|---|---:|---|
| `NM2001` | Cálculo III | 3 | Lunes, 7:00–9:00 |
| `NM2002` | Probabilidad y Estadística | 3 | Lunes, 8:00–10:00 |
| `SI2001` | Estructura de datos y algoritmos | 3 | Lunes, 9:00–11:00 |
| `SI2002` | Lenguajes formales | 3 | Martes, 7:00–9:00 |
| `SI2003` | Sistemas de gestión de datos | 3 | Miércoles, 10:00–12:00 |
| `TA2003` | Talento I | 0 | Jueves, 8:00–9:00 |
| `NFI4` | Política | 3 | Martes, 8:00–10:00 |

El identificador `NFI4` se utilizó para Política debido a que no se suministró otro código para esta asignatura.

Los horarios fueron seleccionados para incluir diferentes casos de prueba:

- Cálculo III y Probabilidad y Estadística se superponen.
- Cálculo III y Estructura de datos y algoritmos son consecutivos.
- Lenguajes formales y Política se superponen.
- Sistemas de gestión de datos y Talento I se ofrecen en días diferentes a los demás cursos.
- Talento I permite comprobar el manejo de una asignatura con cero créditos.
