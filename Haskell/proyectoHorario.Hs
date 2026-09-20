data Horario = Horario
{ dia :: String
, horaInicio :: Double
, horaFin :: Double
} deriving (Show, Eq) 

data Curso = Curso
{ codigo :: String
, nombreCurso :: String
, creditos :: Int
, horario :: Horario
, prerequisitos :: [String]
} deriving (Show, Eq) 

seCruzan :: Horario -> Horario -> Bool
