# rubocop:disable all
require 'rspec/mocks'
require 'spec_helper'
require_relative '../config/configuration'
require_relative '../persistencia/repositorio_turnos'
require_relative '../persistencia/repositorio_medicos'
require_relative '../persistencia/repositorio_pacientes'
require_relative '../persistencia/repositorio_especialidades'
require_relative '../dominio/exceptions/accion_prohibida_exception'
require_relative '../dominio/exceptions/medico_inexistente_exception'
require_relative '../dominio/exceptions/paciente_inexistente_exception'
require_relative '../dominio/exceptions/fuera_de_horario_exception'
require_relative '../dominio/exceptions/turno_no_disponible_exception'
require_relative '../dominio/exceptions/sin_turnos_exception'
require_relative '../dominio/exceptions/turno_inexistente_exception'
require_relative '../dominio/exceptions/paciente_invalido_exception'
require_relative '../dominio/exceptions/recurrencia_maxima_alcanzada_exception'
require_relative '../dominio/exceptions/especialidad_duplicada_exception'
require_relative '../dominio/exceptions/turno_invalido_exception'
require_relative '../dominio/exceptions/reputacion_invalida_exception'
require_relative '../dominio/exceptions/turno_feriado_no_es_reservable_exception'
require_relative '../dominio/repositorios_turnero'

RSpec.configure do |config|
  config.before :suite do
    DB = Configuration.db
    Sequel.extension :migration
    logger = Configuration.logger
    db = Configuration.db
    db.loggers << logger
    Sequel::Migrator.run(db, 'db/migrations')
  end

  config.after :each do
    ENV['LOG_LEVEL'] = 'fatal'
    logger = Configuration.logger

    RepositorioTurnos.new(logger).delete_all
    RepositorioMedicos.new(logger).delete_all
    RepositorioPacientes.new(logger).delete_all
    RepositorioEspecialidades.new(logger).delete_all
  end
end
