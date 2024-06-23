# language: es
Característica: Infraestructura

Escenario: version
  Cuando pido /version
  Entonces obtengo la version app

Escenario: content-type json
  Cuando pido /version
  Entonces obtengo una respuesta de tipo json
