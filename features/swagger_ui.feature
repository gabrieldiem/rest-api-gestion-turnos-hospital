# language: es
Característica: Uso de API con interfaz amigable con Swagger
  Como usuario de la API
  Quiero usar la API con una interfaz amigable, como Swagger
  Para poder usar las funcionalidades proveidoas

  Escenario: 21.0.1 - Obtención de especificación de la API (OpenAPI)
    Cuando solicito la especificación de la API con estándar OpenAPI
    Entonces la recibo exitosamente

  Escenario: 21.0.2 - Visualización de forma amigable con Swagger
    Cuando solicito la interfaz Swagger
    Entonces la recibo exitosamente
