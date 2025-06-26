# API REST para Gestión de Turnos en Hospitales

Este proyecto implementa un servicio de gestión de turnos para hospitales, utilizando una arquitectura sencilla y eficiente basada en tecnologías Ruby.

## Tecnologías principales

- Sinatra: Microframework web para Ruby.
- Sequel: ORM para acceso y manejo de base de datos.
- PostgreSQL: Base de datos relacional.

## Herramientas de desarrollo

- Cucumber + Gherkin: Pruebas de aceptación.
- RSpec: Pruebas unitarias y de integración.
- SimpleCov: Medición de cobertura de código.
- Rubocop: Análisis estático de código y estilo.
- Rake: Automatización de tareas comunes.

## Cómo correr

1. Instalar dependencias

```shell
bundle install
```

2. Ejecutar pruebas y chequeo de estilo. Este comando ejecuta tanto las pruebas (RSpec y Cucumber) como el linter (Rubocop).

```shell
bundle exec rake
```

3. Iniciar la aplicación. Este script aplica las migraciones necesarias y levanta el servidor web.

```shell
./start_app.sh
```
