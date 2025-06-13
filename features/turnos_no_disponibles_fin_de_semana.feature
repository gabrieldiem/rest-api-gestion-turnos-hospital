#language: es
Característica: Gestión de turnos disponibles
  Como paciente
  Quiero que el turnero no me permita reservar turnos los fines de semana
  Para evitar citas inválidas

Antecedentes:
    Dado que estoy consultando turnos disponibles

Escenario: 5.3.1 Consulta de turnos disponibles en cualquier día de la semana
    Cuando consulto los turnos un "martes"
    Entonces el turnero me muestra los turnos disponibles para el "miércoles" siguiente
    

Escenario: 5.3.2 Consulta de turnos disponibles en dia viernes
    Cuando consulto los turnos un "viernes"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente


Escenario: 5.3.3 Consulta de turnos disponibles en dia sabado
    Cuando consulto los turnos un "sábado"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente


Escenario: 5.3.4 Consulta de turnos disponibles en dia domingo
    Cuando consulto los turnos un "domingo"
    Entonces el turnero me muestra los turnos disponibles para el "lunes" siguiente


Escenario: 5.3.5 Consulta de turnos disponibles un viernes antes de un feriado
    Cuando consulto los turnos un "viernes" y el "lunes" siguiente es feriado
    Entonces el turnero me muestra los turnos disponibles para el "martes" siguiente