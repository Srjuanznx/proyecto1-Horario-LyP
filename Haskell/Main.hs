module Main where

import ProyectoHorario

-- ===================================================
-- Horarios de prueba
-- Los horarios son ficticios
-- ===================================================

hCalculoIII, hProbabilidad, hEstructuraDatos, hLenguajesFormales,
    hGestionDatos, hTalentoI, hPolitica :: Horario

hCalculoIII = Horario "Lunes" 7.0 9.0
hProbabilidad = Horario "Lunes" 8.0 10.0
hEstructuraDatos = Horario "Lunes" 9.0 11.0
hLenguajesFormales = Horario "Martes" 7.0 9.0
hGestionDatos = Horario "Miercoles" 10.0 12.0
hTalentoI = Horario "Jueves" 8.0 9.0
hPolitica = Horario "Martes" 8.0 10.0

-- ===================================================
-- Cursos de prueba
-- Los nombres, codigos y creditos corresponden a los
-- cursos reales del tercer semestre de Ingenieria
-- de Sistemas en EAFIT
-- ===================================================

calculoIII, probabilidad, estructuraDatos, lenguajesFormales,
    gestionDatos, talentoI, politica :: Curso

calculoIII =
    Curso "NM2001" "Calculo III" 3 hCalculoIII []

probabilidad =
    Curso "NM2002" "Probabilidad y Estadistica" 3 hProbabilidad []

estructuraDatos =
    Curso "SI2001" "Estructura de datos y algoritmos"
        3 hEstructuraDatos []

lenguajesFormales =
    Curso "SI2002" "Lenguajes formales" 3 hLenguajesFormales []

gestionDatos =
    Curso "SI2003" "Sistemas de gestion de datos" 3 hGestionDatos []

talentoI =
    Curso "TA2003"
        "Talento I - Escuela de Ciencias Aplicadas e Ingenieria"
        0 hTalentoI []

politica =
    Curso "NFI4" "Politica" 3 hPolitica []

-- ===================================================
-- Catalogo de prueba
-- ===================================================

catalogo :: [Curso]
catalogo =
    [ calculoIII, probabilidad, estructuraDatos, lenguajesFormales
    , gestionDatos, talentoI, politica
    ]

-- ===================================================
-- Prioridades de prueba
-- Representan las preferencias del estudiante
-- ===================================================

prioridades :: [(String, Int)]
prioridades =
    [ ("NM2001", 10), ("NM2002", 8), ("SI2001", 9)
    , ("SI2002", 7), ("SI2003", 6), ("TA2003", 1)
    , ("NFI4", 4)
    ]

-- ===================================================
-- Funciones auxiliares para ejecutar las pruebas
-- ===================================================

-- Muestra si una condicion de prueba se cumple
probar :: String -> Bool -> IO ()
probar nombre condicion =
    if condicion
        then putStrLn ("OK: " ++ nombre)
        else putStrLn ("FALLO: " ++ nombre)

-- Convierte una lista de cursos en un texto compacto
-- que contiene solamente sus nombres
formatearCursos :: [Curso] -> String
formatearCursos [] = "[]"
formatearCursos (curso:resto) =
    "[" ++ nombreCurso curso ++ formatearResto resto

-- Agrega los cursos restantes y cierra la lista
formatearResto :: [Curso] -> String
formatearResto [] = "]"
formatearResto (curso:resto) =
    ", " ++ nombreCurso curso ++ formatearResto resto

-- Muestra cada opcion valida en una linea
mostrarOpcionesValidas :: [([Curso], Int)] -> IO ()
mostrarOpcionesValidas [] =
    return ()

mostrarOpcionesValidas ((cursos, total):resto) = do
    putStrLn
        ("(" ++ formatearCursos cursos
        ++ ", " ++ show total ++ ")")

    mostrarOpcionesValidas resto

-- Muestra cada posicion del ranking en una linea
mostrarRanking :: [(Int, [Curso], Int)] -> IO ()
mostrarRanking [] =
    return ()

mostrarRanking ((posicion, cursos, puntos):resto) = do
    putStrLn
        ("(" ++ show posicion
        ++ ", " ++ formatearCursos cursos
        ++ ", " ++ show puntos ++ ")")

    mostrarRanking resto

-- ===================================================
-- Programa principal de pruebas
-- ===================================================

main :: IO ()
main = do
    putStrLn "=== PRUEBAS FUNCIONALES ==="

    -- Prueba 1
    probar "seCruzan detecta conflicto entre Calculo III y Probabilidad"
        (seCruzan hCalculoIII hProbabilidad)

    -- Prueba 2
    probar "Calculo III y Estructura de datos son consecutivos"
        (not (seCruzan hCalculoIII hEstructuraDatos))

    -- Prueba 3
    probar "horarioValido acepta cursos compatibles"
        (horarioValido
            [ calculoIII, estructuraDatos, lenguajesFormales
            , gestionDatos, talentoI
            ])

    -- Prueba 4
    probar "horarioValido rechaza cursos conflictivos"
        (not (horarioValido [calculoIII, probabilidad]))

    -- Prueba 5
    probar "totalCreditos maneja un curso de cero creditos"
        (totalCreditos [calculoIII, estructuraDatos, talentoI] == 6)

    -- Prueba 6
    probar "combinaciones genera los subconjuntos esperados"
        (combinaciones [calculoIII, estructuraDatos]
            == [ [], [estructuraDatos], [calculoIII]
               , [calculoIII, estructuraDatos]
               ])

    -- Prueba 7
    probar "opcionesValidas acepta exactamente seis creditos"
        (opcionesValidas [calculoIII, estructuraDatos] 6 6
            == [([calculoIII, estructuraDatos], 6)])

    -- Prueba 8
    probar "buscarPrioridad y puntaje funcionan correctamente"
        (buscarPrioridad "NFI4" prioridades == 4
            && puntaje
                [calculoIII, estructuraDatos, lenguajesFormales]
                prioridades == 26)

    -- Opciones usadas para probar el ordenamiento
    let opcionesDesordenadas =
            [ ([probabilidad, lenguajesFormales], 6)
            , ([calculoIII, lenguajesFormales], 6)
            , ([calculoIII, estructuraDatos], 6)
            ]

    let opcionesOrdenadasEsperadas =
            [ ([calculoIII, estructuraDatos], 6)
            , ([calculoIII, lenguajesFormales], 6)
            , ([probabilidad, lenguajesFormales], 6)
            ]

    -- Prueba 9
    probar "ordenarPorPuntaje ordena de mayor a menor"
        (ordenarPorPuntaje opcionesDesordenadas prioridades
            == opcionesOrdenadasEsperadas)

    -- Prueba 10
    probar "mejoresHorarios devuelve las dos mejores opciones"
        (mejoresHorarios opcionesDesordenadas prioridades 2
            == [ (1, [calculoIII, estructuraDatos], 19)
               , (2, [calculoIII, lenguajesFormales], 17)
               ])

    -- Prueba 11
    probar "mejoresHorarios acepta una cantidad igual a cero"
        (mejoresHorarios opcionesDesordenadas prioridades 0 == [])

    -- Generacion de opciones para la prueba completa
    let opcionesCompletas = opcionesValidas catalogo 12 18

    let rankingEsperado =
            [ (1, [calculoIII, estructuraDatos, lenguajesFormales,
                   gestionDatos, talentoI], 33)
            , (2, [calculoIII, estructuraDatos, lenguajesFormales,
                   gestionDatos], 32)
            , (3, [calculoIII, estructuraDatos, gestionDatos,
                   talentoI, politica], 30)
            ]

    -- Prueba 12
    probar "flujo completo desde el catalogo hasta el ranking"
        (mejoresHorarios opcionesCompletas prioridades 3
            == rankingEsperado)

    -- Ejemplos de ejecucion solicitados en el enunciado
    putStrLn ""
    putStrLn "=== EJEMPLO DE OPCIONES VALIDAS ==="
    mostrarOpcionesValidas opcionesCompletas

    putStrLn ""
    putStrLn "=== TRES MEJORES HORARIOS ==="
    mostrarRanking
        (mejoresHorarios opcionesCompletas prioridades 3)
