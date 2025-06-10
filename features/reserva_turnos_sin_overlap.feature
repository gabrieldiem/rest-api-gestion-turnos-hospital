# language: es
Característica: No se puede pedir turnos superpuestos
  Como paciente
  Quiero que el sistema me impida reservar dos turnos en el mismo horario o con superposición
  Para evitar conflictos de agenda

  Antecedentes:
    Dado que hoy es "02/06/2025"
    Y que existe la especialidad "Traumatologia" con código "trau" y tiempo de una consulta de "45" minutos
    Y que existe un paciente registrado llamado "Juan Perez" con username "juanperez"
    Y que existe un medico registrado llamado "María Fernández" con matricula "NAC123" que atiende en "trau"
    Y que existe un medico registrado llamado "Sargento Garcia" con matricula "PROV111" que atiende en "trau"

    @wip
  Escenario: 5.1.1 - No se pueden reservar turnos superpuestos
    Dado que "Juan Perez" reservo el turno disponible con el médico de matrícula "NAC123" en la fecha "03/06/2025" y la hora "10:15"
    Cuando reservo el turno con el medico de matrícula "PROV111" en la fecha "03/06/2025" y la hora "10:25"
    Entonces recibe el mensaje de error "El turno se sobrepone con otro turno ya reservado"
  
  Escenario: 5.1.2 - Se puede reservar un turno en el límite de la superposición
    Dado que "Juan Perez" reservo el turno disponible con el médico de matrícula "NAC123" en la fecha "03/06/2025" y la hora "10:15"
    Cuando reservo el turno con el medico de matrícula "PROV111" en la fecha "03/06/2025" y la hora "11:00"
    Entonces la respuesta es exitosa
