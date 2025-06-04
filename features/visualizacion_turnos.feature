# language: es
Característica: Visualizacion de turnos reservados
  Como paciente
  Quiero ver mis turnos reservados
  Para planificar mi agenda

  Antecedentes:
    Dado que soy un paciente registrado con el username "juanperez"
    Y que hoy es "10/06/2025"

  @wip @indev
  Escenario: 6.0.1-Ver turnos existentes
    Dado que hay "2" turnos reservados para "juanperez"
    Cuando quiero ver mis turnos
    Entonces debo ver un mensaje con la lista de mis turnos y todos sus datos deben ser correctos

  @wip
  Escenario: 6.0.2-Sin turnos
    Dado que hay "0" turnos reservados para "juanperez"
    Cuando quiero ver mis turnos
    Entonces recibo un mensaje con "No tenés turnos reservados"
