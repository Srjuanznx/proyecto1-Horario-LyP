% Ejecutar desde la raiz: swipl -q -s Prolog/pruebas.pl -g run_tests -t halt
:- ensure_loaded('proyectoHorario.pl').
:- use_module(library(plunit)).

% Solo las pruebas agregan hechos temporales para simular datos defectuosos.
:- dynamic curso/3, horario/4, prerequisito/2, aprobado/2.

:- begin_tests(horarios_prolog).

test(sin_prerrequisitos) :- puede_tomar(ana, calculo1).
test(todos_los_prerrequisitos, [nondet]) :- puede_tomar(juan, calculo2).
test(faltan_prerrequisitos, [fail]) :- puede_tomar(ana, calculo2).
test(falta_solo_un_prerrequisito,
     [setup(assertz(user:aprobado(ana, calculo1))),
      cleanup(retractall(user:aprobado(ana, calculo1))), fail]) :-
    puede_tomar(ana, calculo2).
test(curso_desconocido, [fail]) :- puede_tomar(juan, desconocido).
test(estudiante_desconocido, [fail]) :- puede_tomar(desconocido, calculo1).
test(elegibilidad_no_excluye_aprobados) :- puede_tomar(juan, calculo1).
test(elegibilidad_con_variables, [set(C == [ana,juan,luisa])]) :-
    puede_tomar(C, calculo1).
test(disponibles_sin_historial,
     true(L == [calculo1,algebra,programacion1,introingenieria])) :-
    cursos_disponibles(ana, L).
test(disponibles_con_historial,
     true(L == [introingenieria,calculo2,fisica1,programacion2])) :-
    cursos_disponibles(juan, L).
test(disponibles_desconocido, [fail]) :- cursos_disponibles(nadie, _).

test(cruce_parcial) :- cruce_horario(calculo1, introingenieria).
test(cruce_simetrico) :- cruce_horario(introingenieria, calculo1).
test(extremos_contiguos, [fail]) :- cruce_horario(calculo1, programacion1).
test(dias_diferentes, [fail]) :- cruce_horario(calculo1, algebra).
test(mismo_curso_no_es_par, [fail]) :- cruce_horario(calculo1, calculo1).
test(cruces_con_variable, [set(C == [calculo1,programacion1])]) :-
    cruce_horario(introingenieria, C).
test(cruces_ambas_variables, true(Pares == [
    calculo1-introingenieria, programacion1-introingenieria,
    introingenieria-calculo1, introingenieria-programacion1,
    calculo2-fisica1, fisica1-calculo2, programacion2-estructuras,
    calculo3-proyecto, estructuras-programacion2, proyecto-calculo3])) :-
    findall(A-B, cruce_horario(A, B), Pares).

test(horario_vacio) :- horario_valido([]).
test(horario_sin_conflictos) :- horario_valido([calculo1,algebra,programacion1]).
test(horario_con_conflicto, [fail]) :- horario_valido([calculo1,introingenieria]).
test(conflicto_no_adyacente, [fail]) :-
    horario_valido([calculo1,algebra,introingenieria]).
test(horario_repetido, [fail]) :- horario_valido([calculo1,calculo1]).
test(horario_desconocido, [fail]) :- horario_valido([inexistente]).
test(creditos_vacios, true(T == 0)) :- creditos_totales([], T).
test(creditos_varios, true(T == 11)) :-
    creditos_totales([calculo1,algebra,programacion1], T).
test(creditos_desconocidos, [fail]) :- creditos_totales([inexistente], _).

test(cadena_vacia, true(C == [])) :- cadena_prerequisitos(calculo1, C).
test(cadena_ejemplo_pdf, true(C == [calculo2,calculo1,algebra])) :-
    cadena_prerequisitos(calculo3, C).
test(cadena_con_ancestro_compartido,
     true(C == [calculo3,calculo2,calculo1,algebra,
                estructuras,programacion2,programacion1])) :-
    cadena_prerequisitos(proyecto, C).
test(cadena_desconocida, [fail]) :- cadena_prerequisitos(inexistente, _).
test(semestre_base, true(S == 1)) :- semestre_minimo(calculo1, S).
test(semestre_ejemplo_pdf, true(S == 3)) :- semestre_minimo(calculo3, S).
test(semestre_multiples_ramas, true(S == 4)) :- semestre_minimo(proyecto, S).
test(semestre_desconocido, [fail]) :- semestre_minimo(inexistente, _).

test(ruta_vacia, true(R == [])) :- ruta_academica(ana, [], R).
test(ruta_aprobados, true(R == [])) :- ruta_academica(juan, [calculo1,algebra], R).
test(ruta_prerrequisitos_automaticos,
     true(R == [semestre(1,[calculo1,algebra]), semestre(2,[calculo2]),
                semestre(3,[calculo3])])) :-
    ruta_academica(ana, [calculo3], R).
test(ruta_respeta_minimo_aun_con_aprobados,
     true(R == [semestre(3,[calculo3])])) :-
    ruta_academica(luisa, [calculo3], R).
test(ruta_con_cruce_y_aprobados,
     true(R == [semestre(2,[calculo2]), semestre(3,[fisica1])])) :-
    ruta_academica(juan, [calculo2,fisica1], R).
test(ruta_no_toma_prerrequisito_simultaneo,
     true(R == [semestre(1,[programacion1]), semestre(2,[programacion2])])) :-
    ruta_academica(ana, [programacion2,programacion1], R).
test(ruta_duplicados,
     true(R == [semestre(1,[calculo1,algebra]), semestre(2,[calculo2])])) :-
    ruta_academica(ana, [calculo2,calculo2,calculo1], R).
test(ruta_desconocido, [fail]) :- ruta_academica(ana, [inexistente], _).
test(ruta_estudiante_desconocido, [fail]) :- ruta_academica(nadie, [], _).

% El ciclo esta fuera del catalogo normal y se elimina despues de cada caso.
crear_ciclo :-
    assertz(user:curso(ciclo_a, 'A', 1)),
    assertz(user:curso(ciclo_b, 'B', 1)),
    assertz(user:prerequisito(ciclo_a, ciclo_b)),
    assertz(user:prerequisito(ciclo_b, ciclo_a)).
borrar_ciclo :-
    retractall(user:curso(ciclo_a, _, _)),
    retractall(user:curso(ciclo_b, _, _)),
    retractall(user:prerequisito(ciclo_a, _)),
    retractall(user:prerequisito(ciclo_b, _)).

test(cadena_ciclica, [setup(crear_ciclo), cleanup(borrar_ciclo), fail]) :-
    cadena_prerequisitos(ciclo_a, _).
test(semestre_ciclico, [setup(crear_ciclo), cleanup(borrar_ciclo), fail]) :-
    semestre_minimo(ciclo_a, _).
test(ruta_ciclica, [setup(crear_ciclo), cleanup(borrar_ciclo), fail]) :-
    ruta_academica(ana, [ciclo_a], _).
test(prerrequisito_inexistente,
     [setup(assertz(user:prerequisito(calculo1, inexistente))),
      cleanup(retractall(user:prerequisito(calculo1, inexistente))), fail]) :-
    ruta_academica(ana, [calculo1], _).
test(horario_faltante,
     [setup(assertz(user:curso(sin_horario, 'Sin horario', 1))),
      cleanup(retractall(user:curso(sin_horario, _, _))), fail]) :-
    ruta_academica(ana, [sin_horario], _).
test(horario_invertido,
     [setup((assertz(user:curso(invertido, 'Invertido', 1)),
             assertz(user:horario(invertido, lunes, 10, 9)))),
      cleanup((retractall(user:curso(invertido, _, _)),
               retractall(user:horario(invertido, _, _, _)))), fail]) :-
    ruta_academica(ana, [invertido], _).

% Verificacion independiente del plan: usa las relaciones basicas y no
% los auxiliares de planificacion. Los built-ins aqui pertenecen a pruebas.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :- subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :- subconjunto(Xs, Ys).

ancestro(Curso, Pre) :- prerequisito(Curso, Pre).
ancestro(Curso, Pre) :- prerequisito(Curso, Directo), ancestro(Directo, Pre).

verificar_ruta(Estudiante, Objetivos, Ruta) :-
    findall(C, (member(semestre(_, Cs), Ruta), member(C, Cs)), Planeados),
    sort(Planeados, Unicos),
    length(Planeados, N), length(Unicos, N),
    findall(C, (member(O, Objetivos), \+ aprobado(Estudiante, O),
                (C = O ; ancestro(O, C)), \+ aprobado(Estudiante, C)), Necesarios),
    sort(Necesarios, Esperados),
    assertion(Unicos == Esperados),
    findall(S, member(semestre(S, _), Ruta), Numeros),
    sort(Numeros, Ordenados),
    assertion(Numeros == Ordenados),
    forall(member(semestre(S, Cs), Ruta),
      ( assertion(Cs \= []),
        forall(member(C, Cs),
          ( assertion(\+ aprobado(Estudiante, C)),
            semestre_minimo(C, Min), assertion(S >= Min),
            forall(prerequisito(C, P),
              assertion((aprobado(Estudiante, P) ;
                         (member(semestre(SP, CP), Ruta), SP < S, member(P, CP)))))
          )),
        forall((member(A, Cs), member(B, Cs), A \= B,
                horario(A, D, IA, FA), horario(B, D, IB, FB)),
               assertion((FA =< IB ; FB =< IA)))
      )).

test(rutas_de_todos_los_subconjuntos) :-
    findall(C, curso(C, _, _), Catalogo),
    forall((member(E, [ana,juan,luisa]), subconjunto(Catalogo, Objetivos)),
      ( findall(R, ruta_academica(E, Objetivos, R), Soluciones),
        assertion(Soluciones = [_]),
        Soluciones = [Ruta],
        verificar_ruta(E, Objetivos, Ruta)
      )).

:- end_tests(horarios_prolog).
