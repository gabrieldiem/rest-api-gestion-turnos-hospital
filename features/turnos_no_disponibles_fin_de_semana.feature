#language: es
Característica: Gestión de turnos disponibles
  Como paciente
  Quiero que el turnero no me permita reservar turnos los fines de semana
  Para evitar citas inválidas

Antecedentes:
    Dado que estoy consultando turnos disponibles

@wip
Escenario: 5.3.1 Consulta de turnos disponibles en cualquier día de la semana
    Dado que estoy consultando turnos disponibles
    Cuando consulto los turnos un día de semana, como "lunes", "martes", "miércoles" o "jueves"
    Entonces el turnero me muestra los turnos disponibles para el dia siguiente
    
@wip
Escenario: 5.3.2 Consulta de turnos disponibles en dia viernes
    Cuando consulto los turnos un "viernes"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente

@wip
Escenario: 5.3.3 Consulta de turnos disponibles en dia sabado
    Cuando consulto los turnos un "sábado"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente

@wip
Escenario: 5.3.4 Consulta de turnos disponibles en dia domingo
    Cuando consulto los turnos un "domingo"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente

@wip
Escenario: 5.3.5 Consulta de turnos disponibles un viernes antes de un feriado
    Cuando consulto los turnos un "viernes" y el "lunes" siguiente es feriado
    Entonces el turnero me muestra los turnos disponibles para el "martes" siguiente