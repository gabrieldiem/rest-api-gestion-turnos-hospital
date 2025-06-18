# language: es
Característica: Cambiar la fecha actual para el entorno test
  Como administrador
  Quiero cambiar la fecha actual del stage de test
  Para poder realizar pruebas que esten relacionados con la fecha actual


  Antecedentes:
    Dado que hoy es "2022-06-09"


  Escenario: 28.0.1 - Se puede cambiar la fecha actual en el amiente test
    Dado que hay un medico registrado de matricula "NAC000" y una especialidad "Cardiología"
    Cuando cambio la fecha actual a "2025-06-06" y la hora "8:00"
    Y pido los turnos disponibles del medico asumiendo qu el año actual es "2025"
    Entonces me muestra los valores del dia "2025-06-09"

  @emulate_prod
  Escenario: 28.0.2 - No se puede cambiar la fecha actual en el amiente test
    Dado que hay un medico registrado de matricula "NAC000" y una especialidad "Cardiología"
    Cuando cambio la fecha actual a "2025-06-06" y la hora "8:00"
    Y recibo un error de acción prohibida
    Y pido los turnos disponibles del medico asumiendo qu el año actual es "2022"
    Entonces me muestra los valores del dia "2022-06-10"


  Escenario: 28.0.3 - Se puede resetar la fecha actual en el amiente test
    Dado que hay un medico registrado de matricula "NAC000" y una especialidad "Cardiología"
    Cuando cambio la fecha actual a "2025-06-06" y la hora "8:00"
    Y pido los turnos disponibles del medico asumiendo qu el año actual es "2025"
    Y me muestra los valores del dia "2025-06-09"
    Entonces cuando reseteo la fecha actual
    Y pido los turnos disponibles del medico asumiendo qu el año actual es "2022"
    Entonces me muestra los valores del dia "2022-06-10"



