{- ===================================================
   PARTE 1: Definicion de Tipos de Datos
   Proyecto de Programacion Funcional (Haskell)
   =================================================== -}

-- Este bloque representa el espacio temporal de una asignatura
data Horario = Horario  
{ dia :: String            -- Dia de la semana (por ejem: "Martes")
, horaInicio :: Double     -- Hora de inicio en formato de decimal (por ejem: 8.0 = 8:00AM)
, horaFin :: Double        -- Hora de finalizacion en formato decimal
} deriving (Show, Eq) 

{- "Show" nos permite ver e imprimir los datos en la consola, por otro lado,
"Eq" Permite comparar si dos datos son iguales o diferentes usando == o /=. En otras palabras, 
Usamos deriving (Show, Eq) para que Haskell genere automaticamente la logica de impresion en 
pantalla y la comparacion con ==, evitandonos de este modo escribir ese codigo manualmente. -}

-- Este bloque representa la informacion completa de una materia
data Curso = Curso      
{ codigo :: String              -- Identificador del curso (por ejem: "SI1002")
, nombreCurso :: String         -- Nombre de la asignatura
, creditos :: Int               -- Numero de creditos academicos
, horario :: Horario            -- Estructura de tipo Horario asociada
, prerequisitos :: [String]     -- Lista con los prerequisitos
} deriving (Show, Eq) 

{- ===================================================
   PARTE 2: Funciones de Validacion
   =================================================== -}

-- Determina si dos horarios se sobreponen en el mismo dia y en el mismo rango de horas
seCruzan :: Horario -> Horario -> Bool        --Toma 2 parametros de tipo horario, y devuelve un tipo Bool (True o False)

--Bloque que determina mediante condicionales si una clase se cruza con otra (Si se superponen devuelve True, y sino, devuelve False)
seCruzan h1 h2 = (dia h1 == dia h2)
            && (horaInicio h1 < horaFin h2)
            && (horaInicio h2 < horaFin h1)

--Funcion auxiliar que recibe un curso y una lista de cursos, y determina si ese curso choca con alguno de la lista.
cruzaConAlguno :: Curso -> [Curso] -> Bool
cruzaConAlguno _ [] = False              --Verifica resultado con una lista vacia
cruzaConAlguno c (x:xs) = seCruzan (horario c) (horario x) || cruzaConAlguno c xs  {- Verifica si el horario del curso c se cruza con el horario del primer curso de la lista (x),
 y si no, llama recursivamente a la funcion con el resto de la lista (xs) -}

--Funcion principal que determina si una lista de cursos tiene algun choque de horarios entre ellos
horarioValido :: [Curso] -> Bool
horarioValido [] = True                                               --Caso base: una lista vacia de cursos es valida
horarioValido (c:cs) = not (cruzaConAlguno c cs) && horarioValido cs  {- Verifica si el primer curso de la lista (c) choca con alguno de los cursos restantes (cs) y si no,
 llama recursivamente a la funcion con el resto de la lista (cs) -}

-- Suma recursivamente los creditos de una lista de cursos
totalCreditos :: [Curso] -> Int
totalCreditos [] = 0
totalCreditos (c:cs) = creditos c + totalCreditos cs

{- ===================================================
   PARTE 3: Combinaciones
   =================================================== -}

--Aqui recibe una lista de cursos y entrega una lista de una lista de cursos, en donde cada lista interior representa una posible combinacion
combinaciones :: [Curso] -> [[Curso]]
combinaciones [] = [[]]

{- Genera las combinaciones que no incluyen el primer curso
y las combinaciones que si lo incluyen. -}
combinaciones (c:cs) =
    let combinacionesSinC = combinaciones cs
        combinacionesConC = agregarATodas c combinacionesSinC
    in combinacionesSinC ++ combinacionesConC

--Funcion auxiliar que agrega un curso a todas las combinaciones
agregarATodas :: Curso -> [[Curso]] -> [[Curso]]
agregarATodas _ [] = []                          -- Si no quedan combinaciones por procesar, devolvemos una lista vacia
agregarATodas c (combinacion:resto) =            -- "combinacion" es la primer combinacion de la lista, de tipo [Curso]
    (c : combinacion) : agregarATodas c resto    -- El primer ":" agrega c a la combinacion actual; el segundo ":" agrega esa combinacion modificada al resultado
