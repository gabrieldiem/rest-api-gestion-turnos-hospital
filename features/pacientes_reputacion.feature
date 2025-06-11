# language: es
Característica: Gestión de reputación de pacientes
   Como centro de salud
   Quiero controlar el acceso a reserva de turnos según la reputación del paciente
   Para evitar que pacientes con mala reputacion abusen del sistema

   Antecedentes:
   Dado que mi username es "juanpi"
    Y me registro con DNI "69420" y email "juanPerez@mail.com"
    Y que hoy es "2025-06-02"
    Y que existe la especialidad "Cardiologia" con código "CARD", duración de turno de "30" minutos y recurrencia máxima de "50" turnos
    Y que existe un medico dado de alta con nombre "Franco", apellido "Finlandia", matricula "FF1426" y especialidad con codigo "CARD"

   Escenario: 10.0.1 - Paciente con buena reputación puede reservar múltiples turnos
    Cuando el paciente con DNI "69420" tiene "5" turnos asistidos y "1" turnos ausentes y "3" turnos reservado
    Y el paciente con DNI "69420" reserva "10" turnos
    Entonces el sistema permite las reservas

   Escenario: 10.0.2 - Paciente con mala reputación tiene restricciones
    Cuando el paciente con DNI "69420" tiene "2" turnos asistidos y "6" turnos ausentes y "0" turnos reservado
    Y el paciente con DNI "69420" reserva "1" turnos
    Entonces el sistema permite las reservas


   Escenario: 10.0.3 - Rechazo de reserva por mala reputación
    Cuando el paciente con DNI "69420" tiene "2" turnos asistidos y "6" turnos ausentes y "1" turnos reservado
    Y el paciente con DNI "69420" reserva "1" turnos
    Entonces el sistema bloquea las reservas
