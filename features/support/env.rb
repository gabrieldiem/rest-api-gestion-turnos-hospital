# rubocop:disable all
ENV['APP_MODE'] = 'test'
require 'rack/test'
require 'rspec/expectations'
ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'

if ENV['STAGE'].nil?
  ENV['STAGE'] = 'test'
end

require_relative '../../app.rb'
require 'faraday'

require_relative '../../spec/stubs'
include FeriadosStubs
World(FeriadosStubs)

DB = Configuration.db
Sequel.extension :migration
logger = Configuration.logger
db = Configuration.db
db.loggers << logger
Sequel::Migrator.run(db, 'db/migrations')

require 'rspec/mocks'
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.teardown
end

include Rack::Test::Methods
def app
  Sinatra::Application
end

After do |_scenario|
  Faraday.post('/reset')
end
