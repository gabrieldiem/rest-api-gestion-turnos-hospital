# language: es
Característica: Consultar turnos disponibles por médico
  Como paciente
  Quiero consultar los turnos disponibles de un médico con una determinada matrícula

  Antecedentes:
    Dado que esta registrado el username "juanperez" y DNI "42951753"
    Y que existe un médico con nombre "Juan", apellido "Perez", matrícula "NAC123" y especialidad "Traumatología" con duración de "15" minutos

  Escenario: 4.0.1 - Se puede consultar turnos disponibles de un médico sin turnos asignados
    Dado que hoy es "20/05/2025"
    Y no hay turnos asignados para el médico con matrícula "NAC123"
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces recibo los próximos 5 turnos disponibles
    Y son del "21/05/2025" a las "8:00" en adelante

  Escenario: 4.0.2 - Se puede consultar turnos disponibles de un médico con un turno asignado
    Dado que hoy es "20/05/2025"
    Y el médico con matrícula "NAC123" tiene un turno asignado el "21/05/2025" "8:00"
    Cuando solicito los turnos disponibles con "NAC123"
    Entonces recibo los próximos 5 turnos disponibles
    Y son del "21/05/2025" a las "8:15" en adelante

  Escenario: 4.0.3 - Consultar turnos de un médico que no existe no muestra turnos
    Cuando solicito los turnos disponibles con "ABC000"
    Entonces no se muestran turnos disponibles en la respuesta erronea
    Y recibo mensaje de error "No existe un médico con la matrícula ABC000"

  Escenario: 4.0.4 - Se puede consultar turnos de un médico sin turnos disponibles en los próximos 40 días
    Dado que hoy es "20/05/2025"
    Y que existe un médico con nombre "Emilio", apellido "Joker", matrícula "PROV100" y especialidad "Cirujía" con duración de "300" minutos
    Y el médico con matrícula "PROV100" no tiene turnos disponibles en los próximos 40 días
    Cuando solicito los turnos disponibles con "PROV100"
    Entonces no se muestran turnos disponibles en la respuesta correcta
