:- ensure_loaded('datos.pl').

pertenece(X, [X|_]).
pertenece(X, [Y|Resto]) :-
    dif(X, Y),
    pertenece(X, Resto).

concatenar([], Lista, Lista).
concatenar([X|Resto], Lista, [X|Resultado]) :-
    concatenar(Resto, Lista, Resultado).

% Conserva la primera aparicion de cada elemento.
sin_repetidos(Lista, Unicos) :-
    sin_repetidos(Lista, [], Unicos).

sin_repetidos([], _, []).
sin_repetidos([X|Resto], Vistos, Unicos) :-
    ( pertenece(X, Vistos)
    -> sin_repetidos(Resto, Vistos, Unicos)
    ;  Unicos = [X|Cola],
       sin_repetidos(Resto, [X|Vistos], Cola)
    ).

% findall solo recoge hechos
prerrequisitos_directos(Curso, Requisitos) :-
    findall(Pre, prerequisito(Curso, Pre), Requisitos).

% Comprueba todos los prerrequisitos directos, incluso si ya aprobo Curso.
% La exclusion de cursos aprobados se realiza en cursos_disponibles/2.
puede_tomar(Estudiante, Curso) :-
    estudiante(Estudiante),
    curso(Curso, _, _),
    prerrequisitos_directos(Curso, Requisitos),
    requisitos_aprobados(Estudiante, Requisitos).

requisitos_aprobados(_, []).
requisitos_aprobados(Estudiante, [Pre|Resto]) :-
    aprobado(Estudiante, Pre),
    requisitos_aprobados(Estudiante, Resto).

% Intervalos [Inicio, Fin): terminar cuando otra clase inicia no es cruce.
% Primero se buscan cursos concretos; luego se comparan sus codigos.
cruce_horario(Curso1, Curso2) :-
    curso(Curso1, _, _),
    curso(Curso2, _, _),
    dif(Curso1, Curso2),
    horario(Curso1, Dia, Inicio1, Fin1),
    horario(Curso2, Dia, Inicio2, Fin2),
    Inicio1 < Fin2,
    Inicio2 < Fin1.

horario_valido([]).
horario_valido([Curso|Resto]) :-
    curso(Curso, _, _),
    horario(Curso, _, Inicio, Fin),
    Inicio < Fin,
    \+ pertenece(Curso, Resto),
    sin_cruces(Curso, Resto),
    horario_valido(Resto).

sin_cruces(_, []).
sin_cruces(Curso, [Otro|Resto]) :-
    \+ cruce_horario(Curso, Otro),
    sin_cruces(Curso, Resto).

creditos_totales([], 0).
creditos_totales([Curso|Resto], Total) :-
    curso(Curso, _, Creditos),
    creditos_totales(Resto, Subtotal),
    Total is Creditos + Subtotal.

cursos_disponibles(Estudiante, Disponibles) :-
    estudiante(Estudiante),
    findall(Curso, curso(Curso, _, _), Catalogo),
    filtrar_disponibles(Catalogo, Estudiante, Disponibles).

filtrar_disponibles([], _, []).
filtrar_disponibles([Curso|Resto], Estudiante, Disponibles) :-
    ( puede_tomar(Estudiante, Curso), \+ aprobado(Estudiante, Curso)
    -> Disponibles = [Curso|Cola]
    ;  Disponibles = Cola
    ),
    filtrar_disponibles(Resto, Estudiante, Cola).

% Recorre los prerrequisitos en profundidad y elimina duplicados al final.
% Visitados contiene la rama actual: repetir un curso indica un ciclo.
cadena_prerequisitos(Curso, Cadena) :-
    cadena_desde(Curso, [], Repetidos),
    sin_repetidos(Repetidos, Cadena).

cadena_desde(Curso, Visitados, Cadena) :-
    curso(Curso, _, _),
    \+ pertenece(Curso, Visitados),
    prerrequisitos_directos(Curso, Directos),
    expandir_requisitos(Directos, [Curso|Visitados], Cadena).

expandir_requisitos([], _, []).
expandir_requisitos([Pre|Resto], Visitados, [Pre|Cadena]) :-
    cadena_desde(Pre, Visitados, Ancestros),
    expandir_requisitos(Resto, Visitados, Otros),
    concatenar(Ancestros, Otros, Cadena).

semestre_minimo(Curso, Semestre) :-
    semestre_desde(Curso, [], Semestre).

semestre_desde(Curso, Visitados, Semestre) :-
    curso(Curso, _, _),
    \+ pertenece(Curso, Visitados),
    prerrequisitos_directos(Curso, Directos),
    maximo_semestre(Directos, [Curso|Visitados], Maximo),
    Semestre is Maximo + 1.

% El maximo de una lista vacia vale 0; asi un curso inicial queda en 1.
maximo_semestre([], _, 0).
maximo_semestre([Pre|Resto], Visitados, Maximo) :-
    semestre_desde(Pre, Visitados, SemestrePre),
    maximo_semestre(Resto, Visitados, MaximoResto),
    ( SemestrePre > MaximoResto
    -> Maximo = SemestrePre
    ;  Maximo = MaximoResto
    ).

% Ruta = [semestre(Numero, Cursos), ...].
% Agrega prerrequisitos pendientes y omite cursos ya aprobados.
% Los numeros respetan semestre_minimo/2 y no son semestres restantes.
ruta_academica(Estudiante, Cursos, Ruta) :-
    estudiante(Estudiante),
    objetivos_pendientes(Cursos, Estudiante, Necesarios),
    sin_repetidos(Necesarios, Unicos),
    quitar_aprobados(Unicos, Estudiante, Pendientes),
    validar_horarios(Pendientes),
    findall(Curso, aprobado(Estudiante, Curso), Aprobados),
    planificar(Pendientes, Aprobados, 1, Ruta).

objetivos_pendientes([], _, []).
objetivos_pendientes([Curso|Resto], Estudiante, Necesarios) :-
    curso(Curso, _, _),
    ( aprobado(Estudiante, Curso)
    -> Necesarios = Otros
    ;  cadena_prerequisitos(Curso, Cadena),
       concatenar([Curso|Cadena], Otros, Necesarios)
    ),
    objetivos_pendientes(Resto, Estudiante, Otros).

quitar_aprobados([], _, []).
quitar_aprobados([Curso|Resto], Estudiante, Pendientes) :-
    ( aprobado(Estudiante, Curso)
    -> Pendientes = Cola
    ;  Pendientes = [Curso|Cola]
    ),
    quitar_aprobados(Resto, Estudiante, Cola).

% Comprueba cada horario por separado; entre semestres puede haber cruces.
validar_horarios([]).
validar_horarios([Curso|Resto]) :-
    horario_valido([Curso]),
    validar_horarios(Resto).

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

% Se mantiene Completados fijo durante este semestre: no se permite tomar
% una materia y su prerrequisito simultaneamente. Ante cruces se favorece
% el primer curso de la lista. Es un plan valido, no un plan optimo.
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

habilitado_en(Curso, Completados, Semestre) :-
    semestre_minimo(Curso, Minimo),
    Semestre >= Minimo,
    prerrequisitos_directos(Curso, Directos),
    todos_completados(Directos, Completados).

todos_completados([], _).
todos_completados([Pre|Resto], Completados) :-
    pertenece(Pre, Completados),
    todos_completados(Resto, Completados).
