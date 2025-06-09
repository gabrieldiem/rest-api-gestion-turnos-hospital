# language: es
Característica: Registrar asistencia de paciente al turno
  Como secretaria
  Quiero poder registrar la asistencia de un paciente a su turno
  Para llevar un control de los pacientes que asisten a sus citas

  Antecedentes:
    Dado que hoy es "2025-06-02"

  Escenario: 18.0.1 - Registrar asistencia exitosa (presente)
    Dado que existe un paciente con DNI "12345678"
    Y existe un turno con ID "1" para ese paciente
    Cuando envío los datos de asistencia con DNI "12345678", ID de turno "1" y asistencia "presente"
    Entonces el estado del turno queda como "presente"

  @wip
  Escenario: 18.0.2 - Registrar asistencia exitosa (ausente)
    Dado que existe un paciente con DNI "12345678"
    Y existe un turno con ID "100" para ese paciente
    Cuando envío los datos de asistencia con DNI "12345678", ID de turno "100" y asistencia "ausente"
    Entonces el estado del turno queda como "Ausente"

  @wip
  Escenario: 18.0.3 - Actualizar asistencia existente
    Dado que existe un paciente con DNI "12345678"
    Y que existe un turno con ID "100" para ese paciente
    Y ya está registrada la asistencia para este turno como "Presente"
    Cuando envío los datos actualizados con DNI "12345678", ID de turno "100" y asistencia "ausente"
    Entonces el estado del turno queda actualizado como "Ausente"
  
  @wip
  Escenario: 18.0.4 - Registrar asistencia con paciente inexistente
    Dado que no existe un paciente con DNI "99999999"
    Cuando envío los datos de asistencia con DNI "99999999", ID de turno "100" y asistencia "presente"
    Entonces recibo un mensaje de error indicando que el paciente no existe
  
  @wip
  Escenario: 18.0.5 - Registrar asistencia con turno inexistente
    Dado que existe un paciente con DNI "12345678"
    Y no existe un turno con ID "999"
    Cuando envío los datos de asistencia con DNI "12345678", ID de turno "999" y asistencia "presente"
    Entonces recibo un mensaje de error indicando que el turno no existe

  @wip
  Escenario: 18.0.6 - Registrar asistencia con turno que no pertenece al paciente
    Dado que existe un paciente con DNI "11111111"
    Y que existe un paciente con DNI "22222222"
    Y que existe un turno con ID "100" asignado al paciente con DNI "11111111"
    Cuando envío los datos de asistencia con DNI "22222222", ID de turno "100" y asistencia "presente"
    Entonces recibo un mensaje de error indicando que el turno no pertenece a ese paciente
