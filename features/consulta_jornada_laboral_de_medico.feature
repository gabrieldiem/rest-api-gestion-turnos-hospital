#language: es
Característica: Consultar jornada de atención por nombre del profesional
  Como secretaria
  Quiero poder consultar la jornada de atención de un profesional por su nombre completo
  Para planificar eficientemente el trabajo del personal durante la jornada

@wip
Escenario: 7.0.1 - Consultar jornada con turnos asignados
  Dado que hoy es "03/06/2025"
  Y que existe un medico registrado llamado "María Fernández" con matricula "18293"
  Y que tiene un turno el día "03/06" a las "09:00" para "Ana Martínez" con DNI "40111222" con el medico "18293"
  Y tiene un turno el día "04/06" a las "10:00" para "Carlos Gómez" con DNI "35222333" con el medico "18293"
  Y tiene un turno el día "04/06" a las "11:00" para "Luisa Rodríguez" con DNI "28333444" con el medico "18293"
  Cuando consulto la jornada del profesional con matricula "18293"
  Entonces el sistema debe mostrar que hay "3" turnos asignados en total
  Y debe listar el turno del "04/06" a las "09:00" para "Ana Martínez" con DNI "40111222"
  Y debe listar el turno del "04/06" a las "10:00" para "Carlos Gómez" con DNI "35222333"
  Y debe listar el turno del "04/06" a las "11:00" para "Luisa Rodríguez" con DNI "28333444"
@wip
Escenario: 7.0.2 - Consultar jornada con turnos a fin de año
  Dado que hoy es "31/12/2025"
  Y que existe un medico registrado llamado "María Fernández" con matricula "18293"
  Y que tiene un turno el día "02/01" a las "09:00" para "Ana Martínez" con DNI "40111222" con el medico "18293"
  Y tiene un turno el día "03/01" a las "10:00" para "Carlos Gómez" con DNI "35222333" con el medico "18293"
  Y tiene un turno el día "03/01" a las "11:00" para "Luisa Rodríguez" con DNI "28333444" con el medico "18293"
  Cuando consulto la jornada del profesional con matricula "18293"
  Entonces el sistema debe mostrar que hay "3" turnos asignados en total
  Y debe listar el turno del "02/01" a las "09:00" para "Ana Martínez" con DNI "40111222"
  Y debe listar el turno del "03/01" a las "10:00" para "Carlos Gómez" con DNI "35222333"
  Y debe listar el turno del "03/01" a las "11:00" para "Luisa Rodríguez" con DNI "28333444"
@wip
Escenario: 7.0.3 - Consultar jornada con turnos asignado solo del medico solicitado
  Dado que hoy es "03/06/2025"
  Y que existe un medico registrado llamado "María Fernández" con matricula "18293"
  Y que existe un medico registrado llamado "Pedro Lopez" con matricula "42572"
  Y tiene un turno el día "03/06" a las "10:00" para "Carlos Gómez" con DNI "35222333" con el medico "18293"
  Y tiene un turno el día "04/06" a las "11:00" para "Luisa Rodríguez" con DNI "28333444" con el medico "18293"
  Y tiene un turno el día "04/06" a las "12:00" para "Jose Martinez" con DNI "43282932" con el medico "42572"
  Cuando consulto la jornada del medico con matricula "18293"
  Entonces el sistema debe mostrar que hay "2" turnos asignados en total
  Y debe listar el turno del "03/06" a las "09:00" para "Ana Martínez" con DNI "40111222"
  Y debe listar el turno del "04/06" a las "10:00" para "Carlos Gómez" con DNI "35222333"
@wip
Escenario: 7.0.4 - Consultar profesional sin turnos asignados
  Dado que hoy es "03/06/2025"
  Y que existe un medico registrado llamado "Pedro Lopez" con matricula "42572"
  Y que no tiene ningún turno asignado
  Cuando consulto la jornada del profesional con matricula "42572"
  Entonces el sistema debe indicar que hay "0" turnos asignados
  Y debe mostrar el mensaje "El profesional no tiene turnos asignados"

