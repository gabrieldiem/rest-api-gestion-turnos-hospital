#language: es
Característica: Limitar la asignación de turnos según la recurrencia máxima
    Como turnero, no quiero otorgar turnos más allá de la recurrencia máxima establecida.

  Antecedentes:
    Dado la especialidad "Cardiología" tiene una recurrencia máxima de turnos configurada como "3"
    Y la especialidad "Dermatología" tiene una recurrencia máxima de turnos configurada como "2"
    Y que la fecha de hoy es "2025-10-01"
    Y que el paciente con DNI "23555102" esta registrado en el sistema
  

  Escenario: 19.1 Asignar un turno cuando el paciente no tiene turnos previos
    Dado el paciente con DNI "23555102" no tiene turnos asignados
    Cuando el paciente solicita un turno para la especialidad "Cardiología"
    Entonces el sistema asigna el turno exitosamente

  Escenario: 19.2 Asignar un turno cuando el paciente no tiene turnos de una especialidad específica
    Dado el paciente con DNI "23555102" tiene 1 turnos asignados para la especialidad "Dermatología"
    Cuando el paciente solicita un turno para la especialidad "Cardiología"
    Entonces el sistema asigna el turno exitosamente
  
  Escenario: 19.3 Asignar un turno cuando el paciente tiene turnos previos de la especialidad, pero no excede la recurrencia máxima
    Dado el paciente con DNI "23555102" tiene 2 turnos asignados para la especialidad "Cardiología"
    Y que "Cardiología" tiene una recurrencia máxima de 3 turnos
    Cuando el paciente solicita un turno adicional para la especialidad "Cardiología"
    Entonces el sistema asigna el turno exitosamente
  @wip
  Escenario: 19.4 Rechazar un turno cuando el paciente excede la recurrencia máxima para la especialidad
    Dado el paciente con DNI "23555102" tiene 3 turnos asignados para la especialidad "Cardiología"
    Y que "Cardiología" tiene una recurrencia máxima de 3 turnos
    Cuando el paciente solicita un turno adicional para la especialidad "Cardiología"
    Entonces el sistema rechaza el pedido con el mensaje "No puede reservar más turnos para esta especialidad"