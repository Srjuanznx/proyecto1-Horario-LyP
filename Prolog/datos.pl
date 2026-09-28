% Datos ficticios para probar los dos sistemas expertos.
% Las horas son decimales: 8.5 representa las 08:30.

curso(calculo1, 'Calculo 1', 4).
curso(algebra, 'Algebra lineal', 3).
curso(programacion1, 'Programacion 1', 4).
curso(introingenieria, 'Introduccion a la ingenieria', 2).
curso(calculo2, 'Calculo 2', 4).
curso(fisica1, 'Fisica 1', 4).
curso(programacion2, 'Programacion 2', 4).
curso(calculo3, 'Calculo 3', 4).
curso(estructuras, 'Estructuras de datos', 3).
curso(proyecto, 'Proyecto integrador', 3).

horario(calculo1, lunes, 7, 9).
horario(algebra, martes, 7, 9).
horario(programacion1, lunes, 9, 11).
horario(introingenieria, lunes, 8, 10).
horario(calculo2, miercoles, 7, 9).
horario(fisica1, miercoles, 8, 10).
horario(programacion2, jueves, 7, 9).
horario(calculo3, viernes, 7, 9).
horario(estructuras, jueves, 8, 10).
horario(proyecto, viernes, 8, 10).

% prerequisito(Curso, Requisito): Requisito debe aprobarse antes de Curso.
prerequisito(calculo2, calculo1).
prerequisito(calculo2, algebra).
prerequisito(fisica1, calculo1).
prerequisito(programacion2, programacion1).
prerequisito(calculo3, calculo2).
prerequisito(estructuras, programacion2).
prerequisito(estructuras, algebra).
prerequisito(proyecto, calculo3).
prerequisito(proyecto, estructuras).

% Registrar al estudiante permite representar historiales vacios.
estudiante(ana).
estudiante(juan).
estudiante(luisa).

% Ana comienza sin materias aprobadas.
aprobado(juan, calculo1).
aprobado(juan, algebra).
aprobado(juan, programacion1).
aprobado(luisa, calculo1).
aprobado(luisa, algebra).
aprobado(luisa, programacion1).
aprobado(luisa, calculo2).
aprobado(luisa, fisica1).
aprobado(luisa, programacion2).
