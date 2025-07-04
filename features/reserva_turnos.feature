# language: es
Característica: Reserva de turnos médicos
  Como paciente
  Quiero reservar turnos con médicos
  Para asistir a mis consultas médicas

  Antecedentes:
    Dado que existe un doctor de nombre "Ernesto" y apellido "García" registrado con matrícula "NAC123"
    Y que hoy es "19/05/2025"

  Escenario: 5.0.1 - Reserva de turno exitosa de turno disponible
    Dado que hay un paciente registrado con username "juanperez"
    Y el Dr. con matricula "NAC123" tiene un turno disponible el "20/05/2025" a las "9:00"
    Cuando reservo el turno con el médico de matrícula "NAC123" en la fecha "20/05/2025" y la hora "9:00"
    Entonces recibo el mensaje de operacion exitosa para la fecha "20/05/2025" y la hora "9:00"
    
  Escenario: 5.0.2 - No puedo reservar un turno con médico inexistente
    Dado que hay un paciente registrado con username "juanperez"
    Cuando intento reservar el turno con el médico de matrícula "ABC000" en la fecha "20/05/2025" y la hora "15:30"
    Entonces recibo el mensaje de operacion fallida
  
  Escenario: 5.0.3 - No puedo reservar un turno fuera del horario de atención
    Dado que hay un paciente registrado con username "juanperez"
    Cuando intento reservar el turno con el médico de matrícula "NAC123" en la fecha "20/05/2025" y la hora "19:00"
    Entonces recibo el mensaje "No se puede reservar en ese horario, el horario de atención es de 8:00 a 18:00"

  Escenario: 5.0.4 - No puedo reservar un turno si no estoy registrado
    Dado el Dr. con matricula "NAC123" tiene un turno disponible el "20/05/2025" a las "15:20"
    Cuando intento reservar el turno con el médico de matrícula "NAC123" en la fecha "20/05/2025" y la hora "15:20" con el username "juandiaz"
    Entonces recibo el mensaje "Para reservar un turno se debe estar registrado"

  Escenario: 5.0.5 - No puedo reservar un turno si alguien ya lo reservó
    Dado que hay un paciente registrado con username "juanperez"
    Y el Dr. con matricula "NAC123" tenía un turno disponible el "20/05/2025" a las "15:20" y alguien más lo reservó
    Cuando intento reservar el turno con el médico de matrícula "NAC123" en la fecha "20/05/2025" y la hora "15:20"
    Entonces recibo el mensaje "Este turno no está disponible"
  
  Escenario: 5.0.6 - No puedo reservar un turno que no es válido para la especialidad
    Dado que hay un paciente registrado con username "juanperez"
    Y el Dr. con matricula "NAC123" tiene un turno disponible el "20/05/2025" a las "9:00"
    Cuando intento reservar el turno con el médico de matrícula "NAC123" en la fecha "20/05/2025" y la hora "9:01"
    Entonces recibo el mensaje "No se puede reservar en este slot por superposicion con otro turno"
