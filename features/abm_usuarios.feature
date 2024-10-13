# language: es
Característica: ABM de usuarios

  Escenario: user-1: Alta de usuario
    Cuando creo un usuario
    Entonces se le asigna un id
    
  Escenario: user-2: Consulta de usuarios
    Dado que no existen usuario
    Cuando consulto los usuarios
    Entonces tengo un listado vacio
