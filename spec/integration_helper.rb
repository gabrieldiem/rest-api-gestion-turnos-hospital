# rubocop:disable all
require 'rspec/mocks'
require 'spec_helper'
require_relative '../config/configuration'
require_relative '../persistencia/repositorio_turnos'
require_relative '../persistencia/repositorio_medicos'
require_relative '../persistencia/repositorio_pacientes'
require_relative '../persistencia/repositorio_especialidades'
require_relative '../dominio/repositorios_turnero'
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }

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
