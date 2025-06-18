# language: es
Característica: Eliminación de todos los datos de la DB para stage de test
  Como administrador
  Quiero eliminar todos los datos del stage de test
  Para evitar conflictos con datos inválidos producidos durante el testing

  Escenario: 21.1.1 - No se pueden reservar turnos superpuestos en el stage de test
    Dado que hay 1 médico y un 1 especialidad
    Cuando reseteo los datos
    Entonces la respuesta de reset es exitosa
    Y no hay más especialidades ni médicos

  @emulate_prod
  Escenario: 21.1.2 - No se pueden reservar turnos superpuestos en el stage de prod
    Dado que hay 1 médico y un 1 especialidad
    Cuando reseteo los datos
    Entonces recibo un error de acción prohibida
    Y no se borraron los datos
