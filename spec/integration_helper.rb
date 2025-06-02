# rubocop:disable all
require 'spec_helper'
require_relative '../config/configuration'

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

    RepositorioMedicos.new(logger).delete_all
    RepositorioPacientes.new(logger).delete_all
    RepositorioEspecialidades.new(logger).delete_all
  end
end
