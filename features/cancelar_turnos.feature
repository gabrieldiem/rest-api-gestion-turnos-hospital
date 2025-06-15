# language: es
Característica: Cancelar turnos reservados en el sistema HMS
  Como paciente
  Quiero cancelar un turno
  Para liberar mi espacio si no puedo asistir.

  Antecedentes:
    Dado que hoy es "2025-06-01"
    Y que existe un paciente registrado con DNI "12345678" y username "MaximoUrtea"
    Y que existe la especialidad "Traumatologia" con código "trau" y tiempo de una consulta de "60" minutos
    Y que existe un medico registrado llamado "María Fernández" con matricula "NAC123" que atiende en "trau"


  Escenario: 8.0.1 - Cancelar un turno sin repercuciones
    Dado que el paciente con DNI "12345678" saca un turno con el medico de matrícula "NAC123" para el día "2025-06-06" a las "10:00"
    Y tengo una reputacion de "1"
    Cuando cancela a la reserva "5" dias previo a la fecha del turno
    Entonces el turno se cancela exitosamente y mi reputacion se mantiene igual

  Escenario: 8.0.2 - Cancelar un turno con repercuciones
    Dado que el paciente con DNI "12345678" saca un turno con el medico de matrícula "NAC123" para el día "2025-06-01" a las "10:00"
    Y tengo una reputacion de "1"
    Cuando doy cancelar a la reserva "5" horas antes de la fecha del turno
    Entonces el turno se cancela exitosamente y mi reputacion empeora

  Escenario: 8.0.3 - Cancelar el turno antes de las 24 horas permite volver a reservarlo
    Dado que el paciente con DNI "12345678" saca un turno con el medico de matrícula "NAC123" para el día "2025-06-06" a las "10:00"
    Cuando cancela a la reserva "5" dias previo a la fecha del turno
    Entonces el turno con el medico de matricula "NAC123" se libera y puede ser reservado nuevamente

  @wip
  Escenario: 8.0.4 - Cancelar el turno dentro de las 24 horas no permite volver a reservarlo
    Dado que el paciente con DNI "12345678" saca un turno con el medico de matrícula "NAC123" para el día "2025-06-06" a las "10:00"
    Cuando doy cancelar a la reserva "5" horas antes de la fecha del turno
    Entonces el turno con el medico de matricula "NAC123" se pierde y no puede ser reservado nuevamente

  @wip
  Escenario: 8.0.5 - No se puede cancelar un turno que ya fue actualizado
    Dado que el paciente con DNI "12345678" saca un turno con el medico de matrícula "NAC123" para el día "2025-06-06" a las "10:00"
    Y el turno ya ha sido atendido
    Cuando cancela a la reserva "5" dias previo a la fecha del turno
    Entonces el turno no se cancela y se muestra un mensaje de error







