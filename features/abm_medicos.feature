# language: es
Característica: Alta de un médico en el sistema HMS
  Como administrador de HMS
  Quiero dar de alta un médico

  Antecedentes:
    Dado que existe la especialidad "Cardiología" con código "card" 
    Y que existe la especialidad "Pediatría" con código "pedi" 
    Y que existe la especialidad "Neurología" con código "neur"

  Escenario: 2.0.1 - Se puede dar de alta un médico correctamente
    Dado que ingreso el nombre "Juan", apellido "Pérez", matrícula "NAC123" y especialidad "card" para el médico
    Cuando doy de alta al medico
    Entonces el médico se registra exitosamente

  Escenario: 2.0.2 - No se puede crear un médico con una especialidad que no existe
    Dado que ingreso el nombre "Juan", apellido "Pérez", matrícula "NAC123" y especialidad inexistente "onco" para el médico
    Cuando doy de alta al medico
    Entonces recibo una respuesta de error de creación de médico
