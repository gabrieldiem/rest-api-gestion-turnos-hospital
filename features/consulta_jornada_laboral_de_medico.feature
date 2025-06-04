#language: es
Característica: Consultar jornada de atención por nombre del medico
  Como secretaria
  Quiero poder consultar la jornada de atención de un medico por su nombre completo
  Para planificar eficientemente el trabajo del personal durante la jornada


Escenario: 7.0.1 - Consultar jornada con turnos asignados
  Dado que hoy es "2025-06-03"
  Y que existe un medico registrado con nombre "María" y apellido "Fernández" con matricula "18293"
  Y que tiene un turno el día "2025-06-03" a las "9:00" para "anamartinez" con DNI "40111222" con el medico "18293"
  Y que tiene un turno el día "2025-06-04" a las "10:00" para "carlosgomez" con DNI "35222333" con el medico "18293"
  Y que tiene un turno el día "2025-06-04" a las "11:00" para "luisaodriguez" con DNI "28333444" con el medico "18293"
  Cuando consulto la jornada del medico con matricula "18293"
  Entonces el sistema debe mostrar que hay "3" turnos asignados en total
  Y debe listar el turno del "2025-06-03" a las "9:00" para "anamartinez" con DNI "40111222"
  Y debe listar el turno del "2025-06-04" a las "10:00" para "carlosgomez" con DNI "35222333"
  Y debe listar el turno del "2025-06-04" a las "11:00" para "luisaodriguez" con DNI "28333444"

Escenario: 7.0.2 - Consultar jornada con turnos a fin de año
  Dado que hoy es "2025-12-31"
  Y que existe un medico registrado con nombre "María" y apellido "Fernández" con matricula "18293"
  Y que tiene un turno el día "2025-01-02" a las "9:00" para "anamartinez" con DNI "40111222" con el medico "18293"
  Y que tiene un turno el día "2025-01-03" a las "10:00" para "carlosgomez" con DNI "35222333" con el medico "18293"
  Y que tiene un turno el día "2025-01-03" a las "11:00" para "luisarodriguez" con DNI "28333444" con el medico "18293"
  Cuando consulto la jornada del medico con matricula "18293"
  Entonces el sistema debe mostrar que hay "3" turnos asignados en total
  Y debe listar el turno del "2025-01-02" a las "9:00" para "anamartinez" con DNI "40111222"
  Y debe listar el turno del "2025-01-03" a las "10:00" para "carlosgomez" con DNI "35222333"
  Y debe listar el turno del "2025-01-03" a las "11:00" para "luisarodriguez" con DNI "28333444"

Escenario: 7.0.3 - Consultar jornada con turnos asignado solo del medico solicitado
  Dado que hoy es "2025-06-03"
  Y que existe un medico registrado con nombre "María" y apellido "Fernández" con matricula "18293"
  Y que existe un medico registrado con nombre "Pedro" y apellido "Lopez" con matricula "42572"
  Y que tiene un turno el día "2025-06-03" a las "10:00" para "carlosgomez" con DNI "35222333" con el medico "18293"
  Y que tiene un turno el día "2025-06-04" a las "11:00" para "luisarodriguez" con DNI "28333444" con el medico "18293"
  Y que tiene un turno el día "2025-06-04" a las "12:00" para "josemartinez" con DNI "43282932" con el medico "42572"
  Cuando consulto la jornada del medico con matricula "18293"
  Entonces el sistema debe mostrar que hay "2" turnos asignados en total
  Y debe listar el turno del "2025-06-03" a las "10:00" para "carlosgomez" con DNI "35222333"
  Y debe listar el turno del "2025-06-04" a las "11:00" para "luisarodriguez" con DNI "28333444"
@wip
Escenario: 7.0.4 - Consultar medico sin turnos asignados
  Dado que hoy es "2025-06-03"
  Y que existe un medico registrado con nombre "Pedro" y apellido "Lopez" con matricula "42572"
  Y que no tiene ningún turno asignado
  Cuando consulto la jornada del medico con matricula "42572"
  Entonces debe mostrar el mensaje "El medico no tiene turnos asignados"
