# language: es
Característica: Consultar medicos dados de alta
Como administrador
Quiero poder consultar los médicos dados de alta
Para comprobar el estado del sistema

Antecedentes:
Dado que existe la especialidad "Traumatologia" con código "trau", duración de turno de "45" minutos y recurrencia máxima de "3" turnos
Y que existe la especialidad "Cardiología" con código "card", duración de turno de "30" minutos y recurrencia máxima de "1" turnos
Y que existe la especialidad "Pediatría" con código "pedi", duración de turno de "15" minutos y recurrencia máxima de "2" turnos

Escenario: 17.1.1 - Consultar medicos cuando hay 1 solo dado de alta
Dado que existe un medico dado de alta con nombre "María", apellido "Fernández", matricula "NAC123" y especialidad con codigo "trau"
Cuando consulto los médicos dados de alta
Entonces se obtiene una respuesta exitosa
Y se muestran "1" médicos en total
Y se observa el médico con nombre "María", apellido "Fernández", matricula "NAC123", especialista en "Traumatologia" con codigo de especialidad "trau"

Escenario: 17.1.2 - Consultar médicos cuando hay 3 dados de alta
Dado que existe un medico dado de alta con nombre "María", apellido "Fernández", matricula "NAC123" y especialidad con codigo "trau"
Dado que existe un medico dado de alta con nombre "Pedro", apellido "Sueco", matricula "NAC001" y especialidad con codigo "card"
Dado que existe un medico dado de alta con nombre "Juan", apellido "Perez", matricula "PROV001" y especialidad con codigo "pedi"
Cuando consulto los médicos dados de alta
Entonces se obtiene una respuesta exitosa
Y se muestran "3" médicos en total
Y se observa el médico con nombre "María", apellido "Fernández", matricula "NAC123", especialista en "Traumatologia" con codigo de especialidad "trau"
Y se observa el médico con nombre "Pedro", apellido "Sueco", matricula "NAC001", especialista en "Cardiología" con codigo de especialidad "card"
Y se observa el médico con nombre "Juan", apellido "Perez", matricula "PROV001", especialista en "Pediatría" con codigo de especialidad "pedi"

Escenario: 17.1.3 - Consultar médicos cuando no hay ninguno dado de alta
Dado que no existe ningún médico dado de alta
Cuando consulto los médicos dados de alta
Entonces se obtiene una respuesta exitosa
Y se muestran "0" médicos en total
Y no se observa ningún médico
