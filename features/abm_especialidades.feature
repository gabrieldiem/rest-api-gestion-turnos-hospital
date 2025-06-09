# language: es
Característica: Alta de especialidades en HMS
  Como administrador de HMS
  Quiero dar de alta especialidades

  Escenario: 1.0.1 - Se puede dar de alta una especialidad correctamente
    Dado que completo el nombre con "Cardiología"
    Y que completo la duración de turnos con "30" minutos
    Y que completo la recurrencia máxima con "5"
    Y que completo el código con "card"
    Cuando doy de alta la especialidad
    Entonces la especialidad se crea exitosamente

  Escenario: 1.0.2 - Se puede dar de alta otra especialidad correctamente
    Dado que completo el nombre con "Neurología"
    Y que completo la duración de turnos con "60" minutos
    Y que completo la recurrencia máxima con "3"
    Y que completo el código con "neur"
    Cuando doy de alta la especialidad
    Entonces la especialidad se crea exitosamente

  Escenario: 1.0.3 - No se puede dar de alta 2 especialidades con el mismo código
    Dado que existe la especialidad "Cardiología" con código "card", duración de turno de "30" minutos y recurrencia máxima de "2" turnos
    Y que completo el nombre con "Cardiología"
    Y que completo la duración de turnos con "35" minutos
    Y que completo la recurrencia máxima con "3"
    Y que completo el código con "card"
    Cuando doy de alta la especialidad
    Entonces recibo un mensaje de error y no se crea la especialidad
