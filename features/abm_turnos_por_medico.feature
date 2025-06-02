# language: es
Característica: Consultar turnos disponibles por médico
  Como paciente
  Quiero consultar los turnos disponibles de un médico con una determinada matrícula

  Antecedentes:
    Dado que esta registrado el username "juanperez"
    Y que existe un médico con nombre "Juan", apellido "Perez", matrícula "NAC123" y especialidad "Traumatología" con duración de 15 minutos

  @wip
  Escenario: 4.0.1 - Se puede consultar turnos disponibles de un médico sin turnos asignados
    Dado que hago una consulta con el username "juanperez"
    Y hoy es lunes "20/05/2025"
    Y no hay turnos asignados para el médico con matrícula "NAC123"
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces recibo los próximos 5 turnos disponibles y son del martes "21/05/2025"

  @wip
  Escenario: 4.0.2 - Se puede consultar turnos disponibles de un médico con un turno asignado
    Dado que hago una consulta con el username "juanperez"
    Y hoy es lunes "20/05/2025"
    Y el médico con matrícula "NAC123" tiene un turno asignado el "martes 21/05/2025 8.00"
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces recibo los próximos 5 turnos disponibles sin contar el primer turno del día y son del martes "21/05/2025"

  @wip
  Escenario: 4.0.3 - Consultar turnos de un médico que no existe no muestra turnos
    Dado que hago una consulta con el username "juanperez"
    Cuando solicito los turnos disponibles con "ABC000"
    Entonces no se muestran turnos disponibles
    Y recibo un mensaje de error "No existe un médico con la matrícula ABC000"

  @wip
  Escenario: 4.0.4 - Se puede consultar turnos de un médico sin turnos disponibles en los próximos 40 días
    Dado que hago una consulta con el username "juanperez"
    Y que hoy es lunes "20/05/2025"
    Y el médico con matrícula "NAC123" no tiene turnos disponibles en los próximos 40 días
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces no se muestran turnos disponibles
    Y recibo un mensaje de error "No hay turnos disponibles para el médico en los próximos 40 días"

  @wip
  Escenario: 4.0.5 - No se pueden consultar turnos sin estar registrado
    Dado que hago una consulta con el username "santisev"
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces no se muestran turnos disponibles
    Y recibo un mensaje de error "Para consultar turnos tiene que estar registrado"
