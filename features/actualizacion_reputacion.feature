# language: es
Característica: Actualización de la reputación
  Como centro de salud
  Quiero que se actualice la reputación cada vez que se registra una asistencia

  Antecedentes:
    Dado que hoy es "2025-06-03"
    Y que existe el paciente con DNI "12345678"
    Y que el paciente con DNI "12345678" tiene "4" turnos reservados con fecha anterior al día de hoy
    Y que el paciente con DNI "12345678" asitio a "2" turnos
    Entonces su reputacion es de "0.5"

  @wip
  Escenario: 10.1.1 Paciente mejora su reputación
    Cuando asisto a "2" turnos reservados
    Entonces el paciente mejora su reputacion
    
  @wip
  Escenario: 10.1.2 Paciente empeora su reputación
    Cuando no asisto a "2" turnos reservados
    Entonces el paciente empeora su reputacion
