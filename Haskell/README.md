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

El identificador `NFI4` se utilizó para Política debido a que es una asignatura optativa, por lo cual no hay código conocido para esta.

Los horarios fueron seleccionados para incluir diferentes casos de prueba:

- Cálculo III y Probabilidad y Estadística se superponen.
- Cálculo III y Estructura de datos y algoritmos son consecutivos.
- Lenguajes formales y Política se superponen.
- Sistemas de gestión de datos y Talento I se ofrecen en días diferentes a los demás cursos.
- Talento I permite comprobar el manejo de una asignatura con cero créditos.

## 8. Documentación de funciones

### 8.1. Función `seCruzan`

```haskell
seCruzan :: Horario -> Horario -> Bool
seCruzan h1 h2 =
    (dia h1 == dia h2)
    && (horaInicio h1 < horaFin h2)
    && (horaInicio h2 < horaFin h1)
```

#### Propósito

Determinar si dos horarios ocurren el mismo día y presentan una superposición en sus intervalos de tiempo.

#### Parámetros

| Parámetro | Tipo | Descripción |
|---|---|---|
| `h1` | `Horario` | Primer horario que se desea comparar. |
| `h2` | `Horario` | Segundo horario que se desea comparar. |

#### Retorno

Devuelve un valor de tipo `Bool`:

- `True` si los horarios se superponen.
- `False` si ocurren en días diferentes o no comparten un intervalo de tiempo.

#### Funcionamiento

La función comprueba tres condiciones:

1. Los horarios deben ocurrir el mismo día.
2. El primer horario debe comenzar antes de que termine el segundo.
3. El segundo horario debe comenzar antes de que termine el primero.

Las comparaciones de horas utilizan el operador estricto `<`. Por este motivo, dos clases consecutivas no se consideran conflictivas.

Por ejemplo:

```haskell
Horario "Lunes" 7.0 9.0
Horario "Lunes" 9.0 11.0
```

Estos horarios no se cruzan porque el segundo comienza exactamente cuando termina el primero.

---

### 8.2. Función `cruzaConAlguno`

```haskell
cruzaConAlguno :: Curso -> [Curso] -> Bool
cruzaConAlguno _ [] = False

cruzaConAlguno c (x:xs) =
    seCruzan (horario c) (horario x)
    || cruzaConAlguno c xs
```

#### Propósito

Determinar si un curso presenta un conflicto de horario con al menos uno de los cursos de una lista.

#### Parámetros

| Parámetro | Tipo | Descripción |
|---|---|---|
| `c` | `Curso` | Curso cuyo horario se desea comprobar. |
| `(x:xs)` | `[Curso]` | Lista de cursos con los que será comparado. |

#### Retorno

Devuelve:

- `True` si el curso se cruza con alguno de los elementos de la lista.
- `False` si no se encuentra ningún conflicto.

#### Caso base

```haskell
cruzaConAlguno _ [] = False
```

Si la lista está vacía, no existe ningún curso con el cual pueda presentarse un conflicto.

#### Caso recursivo

La función compara el horario de `c` con el horario del primer curso `x`. Si se cruzan, el operador `||` permite devolver `True`. De lo contrario, la búsqueda continúa recursivamente con la cola `xs`.

---

### 8.3. Función `horarioValido`

```haskell
horarioValido :: [Curso] -> Bool
horarioValido [] = True

horarioValido (c:cs) =
    not (cruzaConAlguno c cs)
    && horarioValido cs
```

#### Propósito

Comprobar que una lista completa de cursos no contenga conflictos de horario.

#### Parámetro

| Parámetro | Tipo | Descripción |
|---|---|---|
| `(c:cs)` | `[Curso]` | Lista de cursos que se desea validar. |

#### Retorno

Devuelve:

- `True` cuando ninguna pareja de cursos presenta cruces.
- `False` cuando se encuentra al menos un conflicto.

#### Caso base

```haskell
horarioValido [] = True
```

Una lista vacía es válida porque no contiene cursos que puedan entrar en conflicto. Este caso también permite que una lista con un solo curso sea considerada válida.

#### Caso recursivo

La función realiza dos operaciones:

1. Comprueba que el primer curso `c` no se cruce con ninguno de los cursos restantes `cs`.
2. Valida recursivamente que los cursos de `cs` tampoco se crucen entre ellos.

Esta estrategia revisa todas las parejas necesarias sin repetir comparaciones. Si existen `n` cursos, el primero se compara con `n - 1`, el segundo con `n - 2` y así sucesivamente.

---

### 8.4. Función `totalCreditos`

```haskell
totalCreditos :: [Curso] -> Int
totalCreditos [] = 0

totalCreditos (c:cs) =
    creditos c + totalCreditos cs
```

#### Propósito

Calcular la suma total de créditos de una lista de cursos sin utilizar la función predefinida `sum`.

#### Parámetro

| Parámetro | Tipo | Descripción |
|---|---|---|
| `(c:cs)` | `[Curso]` | Lista de cursos cuyos créditos serán sumados. |

#### Retorno

Devuelve un valor de tipo `Int` con la cantidad total de créditos.

#### Caso base

```haskell
totalCreditos [] = 0
```

Una lista vacía tiene cero créditos.

#### Caso recursivo

La función obtiene los créditos del primer curso mediante:

```haskell
creditos c
```

Luego suma ese valor al resultado de calcular recursivamente los créditos de `cs`.

Ejemplo conceptual:

```text
totalCreditos [CalculoIII, EstructuraDatos, TalentoI]

= 3 + totalCreditos [EstructuraDatos, TalentoI]
= 3 + 3 + totalCreditos [TalentoI]
= 3 + 3 + 0 + totalCreditos []
= 6
```

Este ejemplo también demuestra que un curso con cero créditos se procesa correctamente.

## 9. Generación y filtrado de combinaciones

| Función | Firma | Descripción |
|---|---|---|
| `combinaciones` | `[Curso] -> [[Curso]]` | Genera todos los subconjuntos posibles del catálogo. |
| `agregarATodas` | `Curso -> [[Curso]] -> [[Curso]]` | Agrega un curso a cada combinación existente. |
| `esOpcionValida` | `[Curso] -> Int -> Int -> Bool` | Comprueba el horario y el rango de créditos. |
| `filtrarOpciones` | `[[Curso]] -> Int -> Int -> [([Curso], Int)]` | Conserva recursivamente las combinaciones válidas. |
| `opcionesValidas` | `[Curso] -> Int -> Int -> [([Curso], Int)]` | Genera y filtra las combinaciones del catálogo. |

El caso base de `combinaciones` es `[[]]`, porque un catálogo vacío tiene una combinación posible: la combinación vacía. Para cada curso se generan dos grupos: las combinaciones que no lo incluyen y las que sí lo incluyen. El segundo grupo se obtiene mediante `agregarATodas` y ambos se unen con `++`.

`opcionesValidas` genera las combinaciones y utiliza `filtrarOpciones` para conservar solamente aquellas que no presentan conflictos y cuyo total se encuentra entre los límites mínimo y máximo, incluidos ambos extremos.

## 10. Puntaje, ordenamiento y ranking

| Función | Firma | Descripción |
|---|---|---|
| `buscarPrioridad` | `String -> [(String, Int)] -> Int` | Busca la prioridad de un código; devuelve cero si no existe. |
| `puntaje` | `[Curso] -> [(String, Int)] -> Int` | Suma las prioridades de los cursos de una combinación. |
| `insertarPorPuntaje` | `([Curso], Int) -> [([Curso], Int)] -> [(String, Int)] -> [([Curso], Int)]` | Inserta una opción en una lista ordenada. |
| `ordenarPorPuntaje` | `[([Curso], Int)] -> [(String, Int)] -> [([Curso], Int)]` | Ordena las opciones de mayor a menor puntaje. |
| `crearRanking` | `Int -> Int -> [([Curso], Int)] -> [(String, Int)] -> [(Int, [Curso], Int)]` | Asigna posiciones y limita la cantidad de resultados. |
| `mejoresHorarios` | `[([Curso], Int)] -> [(String, Int)] -> Int -> [(Int, [Curso], Int)]` | Devuelve las mejores `n` opciones con su posición y puntaje. |

El ordenamiento se implementó mediante **insertion sort recursivo**. Primero se ordena la cola de la lista y luego se inserta la primera opción en la posición correspondiente según su puntaje. De esta manera se obtiene un orden descendente sin utilizar `sort`.

El flujo final es:

```text
Catálogo
   ↓
Combinaciones
   ↓
Opciones válidas
   ↓
Cálculo de puntajes
   ↓
Ordenamiento descendente
   ↓
Mejores n horarios
```

## 11. Ejecución y pruebas

### 11.1. Ejecución

Desde la carpeta `Haskell` se ejecuta:

```bash
runghc Main.hs
```

También puede compilarse mediante:

```bash
ghc Main.hs -o proyectoHorario
```

### 11.2. Ejemplos funcionales

| Funcionalidad | Llamada | Resultado resumido |
|---|---|---|
| Cruce de horarios | `seCruzan hCalculoIII hProbabilidad` | `True` |
| Horarios consecutivos | `seCruzan hCalculoIII hEstructuraDatos` | `False` |
| Horario válido | `horarioValido [calculoIII, estructuraDatos]` | `True` |
| Horario inválido | `horarioValido [calculoIII, probabilidad]` | `False` |
| Total de créditos | `totalCreditos [calculoIII, estructuraDatos, talentoI]` | `6` |
| Combinaciones | `combinaciones [calculoIII, estructuraDatos]` | Cuatro combinaciones |
| Opción válida | `opcionesValidas [calculoIII, estructuraDatos] 6 6` | Una opción de 6 créditos |
| Puntaje | `puntaje [calculoIII, estructuraDatos, lenguajesFormales] prioridades` | `26` |
| Ordenamiento | `ordenarPorPuntaje opcionesDesordenadas prioridades` | Puntajes `19, 17, 15` |
| Mejores horarios | `mejoresHorarios opcionesCompletas prioridades 3` | Puntajes `33, 32, 30` |

### 11.3. Opciones válidas del catálogo

Llamada:

```haskell
opcionesValidas catalogo 12 18
```

Salida resumida por códigos:

```text
([NM2001, SI2001, SI2003, NFI4], 12)
([NM2001, SI2001, SI2003, TA2003, NFI4], 12)
([NM2001, SI2001, SI2002, SI2003], 12)
([NM2001, SI2001, SI2002, SI2003, TA2003], 12)
```

Cada resultado tiene la forma:

```text
(combinacion, totalCreditos)
```

### 11.4. Mejores horarios

Llamada:

```haskell
mejoresHorarios (opcionesValidas catalogo 12 18) prioridades 3
```

Salida resumida:

```text
(1, [NM2001, SI2001, SI2002, SI2003, TA2003], 33)
(2, [NM2001, SI2001, SI2002, SI2003], 32)
(3, [NM2001, SI2001, SI2003, TA2003, NFI4], 30)
```

Cada resultado contiene:

```text
(posicion, combinacion, puntaje)
```

### 11.5. Resultado de las pruebas automáticas

`Main.hs` incluye doce pruebas funcionales y una prueba completa de integración.

<details>
<summary>Ver salida de las pruebas</summary>

```text
=== PRUEBAS FUNCIONALES ===
OK: seCruzan detecta conflicto entre Calculo III y Probabilidad
OK: Calculo III y Estructura de datos son consecutivos
OK: horarioValido acepta cursos compatibles
OK: horarioValido rechaza cursos conflictivos
OK: totalCreditos maneja un curso de cero creditos
OK: combinaciones genera los subconjuntos esperados
OK: opcionesValidas acepta exactamente seis creditos
OK: buscarPrioridad y puntaje funcionan correctamente
OK: ordenarPorPuntaje ordena de mayor a menor
OK: mejoresHorarios devuelve las dos mejores opciones
OK: mejoresHorarios acepta una cantidad igual a cero
OK: flujo completo desde el catalogo hasta el ranking
```

</details>

Todas las pruebas produjeron el resultado esperado. La última prueba verifica el flujo completo desde la generación de combinaciones hasta la selección de los tres mejores horarios.

## 12. Problemas encontrados y soluciones

Durante el desarrollo se presentaron dificultades relacionadas principalmente con el sistema de tipos, las listas anidadas, la recursión y la organización modular.

| Problema encontrado | Causa | Solución aplicada |
|---|---|---|
| Error al implementar `totalCreditos`. | Se intentó sumar un valor `Int` con la cola `cs`, cuyo tipo era `[Curso]`. | Se aplicó recursivamente `totalCreditos cs` para convertir la cola en un valor numérico. |
| Dificultad para comprender `agregarATodas`. | La expresión utiliza un operador `:` para agregar un curso a una combinación y otro para agregar esa combinación al resultado. | Se diferenciaron los tipos `Curso`, `[Curso]` y `[[Curso]]` mediante ejemplos y trazas manuales. |
| Confusión entre `[]` y `[[]]`. | `[]` representa ninguna combinación, mientras que `[[]]` representa una combinación vacía. | Se utilizó `[[]]` como caso base de `combinaciones`, permitiendo construir las demás combinaciones. |
| Fallo potencial en `filtrarOpciones`. | Inicialmente solo se había definido la guarda para las opciones válidas. | Se añadió `otherwise` para descartar las opciones inválidas y continuar con el resto. |
| Restricción de no utilizar `sort`. | Las opciones debían ordenarse por puntaje mediante un algoritmo propio. | Se implementó insertion sort con `insertarPorPuntaje` y `ordenarPorPuntaje`. |
| Ciclo de importación entre módulos. | Los encabezados de `Main.hs` y `ProyectoHorario.hs` no coincidían correctamente con sus archivos. | Se definieron `module Main` y `module ProyectoHorario`, y se importó únicamente el segundo desde `Main`. |
| Variables de prueba fuera de alcance. | Las pruebas se agregaron antes de definir los horarios, cursos, catálogo y prioridades en `Main.hs`. | Los datos de prueba se declararon antes de `main`, dentro del mismo módulo. |
| Salida demasiado extensa. | `deriving Show` mostraba todos los campos de cada curso y horario. | Se crearon funciones recursivas de presentación para mostrar solamente nombres, créditos, posiciones y puntajes. |
| Necesidad de verificar todo el flujo. | Las pruebas individuales no demostraban por sí solas la integración del sistema. | Se agregó una prueba desde el catálogo hasta la generación del ranking final. |

## 13. Transparencia y uso de inteligencia artificial

Durante el desarrollo se utilizó inteligencia artificial generativa como herramienta de orientación, explicación, revisión y apoyo técnico.

### 13.1. Usos realizados

La inteligencia artificial fue utilizada para:

- Explicar conceptos de Haskell como tipos, listas, tuplas, reconocimiento de patrones y recursión.
- Dividir los requisitos del proyecto en funciones más pequeñas.
- Explicar la diferencia entre `Curso`, `[Curso]` y `[[Curso]]`.
- Proponer firmas y estructuras iniciales para algunas funciones.
- Completar fragmentos de código cuando los estudiantes lo solicitaron.
- Explicar el algoritmo recursivo para generar combinaciones.
- Orientar la implementación del ordenamiento por inserción.
- Interpretar errores generados por GHC.
- Proponer casos de prueba y datos para validar el sistema.
- Organizar la separación entre `ProyectoHorario.hs` y `Main.hs`.
- Mejorar la presentación de los resultados en la terminal.
- Apoyar la estructura y redacción inicial de la documentación técnica.

### 13.2. Participación de los estudiantes

Los integrantes del equipo fueron responsables de:

- Analizar el enunciado y sus restricciones.
- Escribir e integrar el código en los archivos del proyecto.
- Ejecutar cada prueba en el entorno local.
- Revisar los resultados obtenidos.
- Corregir problemas de nombres, módulos e indentación.
- Adaptar los datos de prueba a las asignaturas seleccionadas.
- Decidir la estructura final del programa.
- Revisar y ajustar la documentación.
- Comprender el funcionamiento de las funciones para su sustentación.

La inteligencia artificial no forma parte de la ejecución del programa. El sistema desarrollado en Haskell funciona de manera local y determinista, sin realizar solicitudes a modelos externos.

### 13.3. Resumen del apoyo recibido

| Área | Apoyo de IA | Validación realizada |
|---|---|---|
| Conceptos de Haskell | Explicaciones y ejemplos. | Revisión y aplicación por los estudiantes. |
| Recursión | Descomposición de casos base y recursivos. | Ejecución de las funciones con diferentes entradas. |
| Implementación | Sugerencias y fragmentos solicitados. | Integración y compilación local. |
| Depuración | Interpretación de mensajes de GHC. | Corrección y nueva ejecución del programa. |
| Pruebas | Propuesta de casos normales y casos límite. | Doce pruebas funcionales con resultado `OK`. |
| Documentación | Organización y borradores en Markdown. | Revisión y adaptación para el repositorio. |

Todo el código y la documentación deben ser comprendidos y sustentados por los integrantes. El contenido generado con apoyo de IA fue revisado mediante compilación, pruebas y análisis de los resultados.

## 14. Conclusiones de Haskell

1. La recursión permite procesar listas y resolver problemas de búsqueda, filtrado, acumulación y ordenamiento sin depender de ciclos o variables mutables.

2. El sistema de tipos de Haskell facilita la detección temprana de errores. Por ejemplo, permitió identificar la diferencia entre una lista de cursos y el valor entero producido por la suma de sus créditos.

3. Dividir el sistema en funciones pequeñas facilitó el desarrollo y las pruebas. La generación de combinaciones, validación de horarios, puntuación y clasificación pudieron verificarse de forma independiente.

4. El reconocimiento de patrones permitió representar de manera clara los casos base y recursivos de las listas, especialmente mediante las formas `[]` y `(x:xs)`.

5. La generación de combinaciones tiene un crecimiento exponencial de `2^n`. Aunque esto limita su aplicación con catálogos grandes, resulta adecuado para el alcance académico y los datos utilizados en la práctica.

6. El ordenamiento por inserción demostró que es posible construir un algoritmo de clasificación desde cero utilizando recursión. Aunque no es el método más eficiente para listas grandes, cumple las restricciones del proyecto y facilita la comprensión del proceso.

7. La separación entre `ProyectoHorario.hs` y `Main.hs` permitió mantener la lógica funcional independiente de los datos, las pruebas y la presentación de resultados.

8. Las pruebas automáticas y la prueba de integración permitieron comprobar que las funciones trabajan correctamente de forma individual y también como parte del flujo completo.
