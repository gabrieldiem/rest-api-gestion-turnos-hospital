# language: es
Característica: No se puede hacer reserva de turnos en días feriados
  Como paciente
  Quiero reservar turnos con médicos que no sean en días feriados
  Para asistir a mis consultas médicas

  Antecedentes:
    Dado que el día "02/04/2025" es feriado
    Y que existe la especialidad "Traumatologia" con código "trau" y tiempo de una consulta de "45" minutos
    Y que existe un paciente registrado llamado "Juan Perez" con username "juanperez"
    Y que existe un medico registrado llamado "María Fernández" con matricula "NAC123" que atiende en "trau"

  Escenario: 5.2.1 - No se muestran turnos disponibles el día feriado consultando desde un día hábil
    Dado que hoy es "01/04/2025" y no es feriado
    Y que el médico con matrícula "NAC123" no tiene turnos reservados el "03/04/2025"
    Cuando consulto los turnos disponibles para el médico con matrícula "NAC123"
    Entonces recibo los próximos 5 turnos disponibles
    Y son del "03/04/2025" a las "8:00" en adelante

  @wip @indev
  Escenario: 5.2.2 - Se muestran turnos disponibles para día hábil consultando desde un día feriado
    Dado que hoy es "02/04/2025" y es feriado
    Y que el médico con matrícula "NAC123" no tiene turnos reservados el "03/04/2025"
    Cuando consulto los turnos disponibles para el médico con matrícula "NAC123"
    Entonces recibo los próximos 5 turnos disponibles
    Y son del "03/04/2025" a las "8:00" en adelante
  @wip @indev
  Escenario: 5.2.3 - No se muestran turnos disponibles dos días feriados seguidos
    Dado que hoy es "01/04/2025" y no es feriado
    Y que el día "03/04/2025" también es feriado
    Y que el médico con matrícula "NAC123" no tiene turnos reservados el "04/04/2025"
    Cuando consulto los turnos disponibles para el médico con matrícula "NAC123"
    Entonces recibo los próximos 5 turnos disponibles
    Y son del "04/04/2025" a las "8:00" en adelante
  @wip @indev
  Escenario: 5.2.4 - No se puede hacer una reserva de turno para un día feriado
    Cuando reservo el turno con el medico de matrícula "NAC123" en la fecha "02/04/2025" y la hora "9.30"
    Entonces recibo el mensaje de error "No se puede reservar un turno para un día feriado"
