#language: es

Característica: Health check de la base de datos para tener alta disponibilidad
  Como administrador del turnero
  Quiero que la base de datos esté disponible y no se caiga
  Para evitar errores inesperados
  
  Escenario: 16.0.1 - Se hace un health check exitoso
    Dado que hay disponibilidad de la base de datos
    Cuando hago un health check del turnero
    Entonces recibo una respuesta exitosa

  @wip
  Escenario: 16.0.2 - El health check falla cuando la base no está disponible
    Dado que no hay disponibilidad de la base de datos
    Cuando hago un health check del turnero
    Entonces recibo una respuesta de error
