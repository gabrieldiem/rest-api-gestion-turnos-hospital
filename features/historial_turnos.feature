# language: es
Característica: Hisotrial de turnos asistidos
  Como paciente, 
  quiero consultar mi historial de turnos pasados 
  para revisar mis citas anteriores y su estado

  Antecedentes:
  Dado que hoy es "2025-06-01"
  Y que existe un paciente registrado con DNI "12345678" y username "agustoSanchez"
  Y que existe la especialidad "Traumatologia" con código "trau" y tiempo de una consulta de "60" minutos
  Y que existe un medico registrado llamado "María Fernández" con matricula "NAC123" que atiende en "trau"

  @wip
  Escenario: 9.0.1 - Ver historial de turnos
    Dado que hay "3" turnos reservados para "agustoSanchez"
    Y "2" han sido asisitidos
    Cuando quiere ver su historial de turnos
    Entonces debo ver un mensaje con la lista de mis turnos pasados y todos sus datos deben ser correctos

  @wip
  Escenario: 9.0.2 - Sin turnos
    Dado que hay "3" turnos reservados para "agustoSanchez"
    Y "0" han sido asisitidos
    Cuando quiere ver su historial de turnos
    Entonces recibo un mensaje con "No tenés turnos pasados"
