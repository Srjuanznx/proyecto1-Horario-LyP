# Práctica 1 — Programación Funcional y Lógica

## Información académica

- **Universidad:** Universidad EAFIT
- **Programa:** Ingeniería de Sistemas
- **Asignatura:** Lenguajes y Paradigmas de Programación
- **Práctica:** Programación funcional y lógica con Haskell y Prolog, mediante un sistema de horarios acádemicos.
- **Periodo:** 2026-2
- **Profesor:** Johnny Alexander Aguirre Morales
- **Fecha de entrega:** 02/10/2026

## Integrantes

| Nombre completo | Correo institucional |
|---|---|
| Juan David Soto Garcés | jdsotog@eafit.edu.co |
| Tomas Agudelo Macias | tagudelom3@eafit.brightspace.com |

## Descripción del proyecto

Este proyecto integra e incluye los paradigmas de programación funcional y lógica mediante el analisis de un sistema acádemico de planificación y ordenamiento de cursos y horarios.

La solución está dividida en dos componentes:

1. **Haskell:** generación de combinaciones de cursos sin conflictos, validación del rango de créditos y clasificación de horarios según las preferencias del estudiante.
2. **Prolog:** sistema experto para determinar la elegibilidad de cursos y construir rutas académicas a partir de prerrequisitos y restricciones de horario.

## Entregables

### 1. Código fuente de Haskell

La implementación funcional, tanto como su información técnica y códigos fuente, se encuentran en la carpeta [`Haskell`](./Haskell/).

Archivos principales:

- [`ProyectoHorario.hs`](./Haskell/ProyectoHorario.hs): tipos de datos y funciones requeridas.
- [`Main.hs`](./Haskell/Main.hs): catálogo académico, prioridades, pruebas funcionales y ejemplos de ejecución.
- [`README.md`](./Haskell/README.md): documentación de los tipos y funciones, explicación de los algoritmos recursivos, instrucciones de ejecución y guía para la sustentación.

### 2. Código fuente de Prolog

La implementación lógica, junto con su documentación, base de conocimiento y pruebas, se encuentra en la carpeta [`Prolog`](./Prolog/).

Archivos principales:

- [`README.md`](./Prolog/README.md): documentación de los predicados, guía para la sustentación y explicación de las pruebas.
- [`datos.pl`](./Prolog/datos.pl): base de conocimiento con los hechos relacionados con cursos, horarios, prerrequisitos y estudiantes.
- [`proyectoHorario.pl`](./Prolog/proyectoHorario.pl): implementación de los sistemas expertos de matrícula y generación de rutas académicas.
- [`pruebas.pl`](./Prolog/pruebas.pl): consultas y casos de prueba utilizados para verificar el funcionamiento de los predicados.

