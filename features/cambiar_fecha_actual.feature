# language: es
Característica: Cambiar la fecha actual para el entorno test
  Como administrador
  Quiero cambiar la fecha actual del stage de test
  Para poder realizar pruebas que esten relacionados con la fecha actual

  @wip @indev
  Escenario: 28.0.1 - Se puede cambiar la fecha actual en el amiente test
    Dado que hay 1 médico y un 1 especialidad
    Cuando cambio la fecha actual a "2025-06-06" y la hora "8:00"
    Y pido los turnos disponibles del medico
    Entonces me muestra los valores del dia "2025-09-20"


  @wip
  Escenario: 28.0.2 - No Se puede cambiar la fecha actual en el amiente test
    Dado que hay 1 médico y un 1 especialidad
    Cuando cambio la fecha actual a "viernes" "2025-06-06"
    Entonces recibo un error de acción prohibida
