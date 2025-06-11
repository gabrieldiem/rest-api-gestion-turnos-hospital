# language: es
Característica: Actualización de la reputación
  Como centro de salud
  Quiero que se actualice la reputación cada vez que se registra una asistencia

  Antecedentes:
    Dado que mi username es "juanpi"
    Y me registro con DNI "69420" y email "juanPerez@mail.com"
    Y que hoy es "2025-06-02"
    Y que existe la especialidad "Cardiologia" con código "CARD", duración de turno de "30" minutos y recurrencia máxima de "50" turnos
    Y que existe un medico dado de alta con nombre "Franco", apellido "Finlandia", matricula "FF1426" y especialidad con codigo "CARD"
    Y el paciente con DNI "69420" tiene "5" turnos asistidos y "5" turnos ausentes y "3" turnos reservado
    Y que mi reputacion esperada es "0.5"

  @wip
  Escenario: 10.1.1 Paciente mejora su reputación
    Cuando el paciente con DNI "69420" asiste "1" turnos
    Entonces el paciente mejora su reputacion

  @wip
  Escenario: 10.1.2 Paciente empeora su reputación
    Cuando el paciente con DNI "69420" no asiste "1" turnos
    Entonces el paciente empeora su reputacion
