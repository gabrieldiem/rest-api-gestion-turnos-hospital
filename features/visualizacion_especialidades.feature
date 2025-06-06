# language: es
Característica: Consultar especialidades dadas de alta
  Como administrador
  Quiero poder consultar las especialidades dadas de alta
  Para comprobar el estado del sistema

  @wip
  Escenario: 17.0.1 - Consultar especialidades cuando hay 1 sola dada de alta
    Dado que existe la especialidad "Traumatologia" con código "trau", duración de turno de "45" minutos y recurrencia máxima de "3" turnos
    Cuando consulto las especialidades dadas de alta
    Entonces se obtiene una respuesta exitosa
    Y se muestran "1" especialidades en total
    Y se observa la especialidad "Traumatologia" con código "trau", duración de turno de "45" minutos y recurrencia máxima de "3" turnos

  @wip
  Escenario: 17.0.2 - Consultar especialidades cuando hay 3 dadas de alta
    Dado que existe la especialidad "Traumatologia" con código "trau", duración de turno de "45" minutos y recurrencia máxima de "3" turnos
    Dado que existe la especialidad "Cardiología" con código "card", duración de turno de "30" minutos y recurrencia máxima de "1" turnos
    Dado que existe la especialidad "Pediatría" con código "pedi", duración de turno de "15" minutos y recurrencia máxima de "2" turnos
    Cuando consulto las especialidades dadas de alta
    Entonces se obtiene una respuesta exitosa
    Y se muestran "3" especialidades en total
    Y se observa la especialidad "Traumatologia" con código "trau", duración de turno de "45" minutos y recurrencia máxima de "3" turnos
    Y se observa la especialidad "Cardiología" con código "card", duración de turno de "30" minutos y recurrencia máxima de "1" turnos
    Y se observa la especialidad "Pediatría" con código "pedi", duración de turno de "15" minutos y recurrencia máxima de "2" turnos

  @wip
  Escenario: 17.0.3 - Consultar especialidades cuando no hay ninguna dada de alta
    Dado que no existe ninguna especialiadad dada de alta
    Cuando consulto las especialidades dadas de alta
    Entonces se obtiene una respuesta exitosa
    Y se muestran "0" especialidades en total
    Y no se observa ninguna especialidad
