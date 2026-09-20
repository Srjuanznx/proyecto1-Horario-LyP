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
