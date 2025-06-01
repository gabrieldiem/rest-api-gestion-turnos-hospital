# language: es
Característica: Registro de un paciente en el turnero
Como paciente
Quiero registrarme en el turnero usando mi username
Para gestionar mis turnos

Antecedentes:
Dado que mi username es "@juanperez"


Escenario: 3.0.1 - Registro exitoso de un paciente
Cuando me registro con DNI "12345678" y email "juan.perez@example.com"
Entonces recibo un mensaje de éxito

@wip @indev
Escenario: 3.0.2 - No puede registrarse con DNI ya registrado
Dado que existe un paciente registrado con DNI "12345678"
Cuando me registro con DNI "12345678" y email "juan.perez@example.com"
Entonces recibo un mensaje de error "El DNI ya está registrado"


Escenario: 3.0.3 - No puede registrarse con DNI vacío
Cuando me registro con DNI "" y email "juan.perez@example.com"
Entonces recibo un mensaje de error "El DNI es requerido"


Escenario: 3.0.4 - No puede registrarse con email inválido
Cuando me registro con DNI "12345678" y email "juan.perez"
Entonces recibo un mensaje de error "El formato del email es inválido"


