require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
end

Dado('que hay disponibilidad de la base de datos') do
  # nada que hacer
end

Cuando('hago un health check del turnero') do
  @response = Faraday.get('/health-check')
end

Entonces('recibo una respuesta exitosa') do
  expect(@response.status).to eq 200
end

Dado('que no hay disponibilidad de la base de datos') do
  allow(DB).to receive(:[]).and_raise(Sequel::DatabaseConnectionError, 'DB is down')
end

Entonces('recibo una respuesta de error') do
  parsed_response = JSON.parse(@response.body)

  expect(@response.status).to eq 503
  expect(parsed_response['mensaje_error']).not_to be_nil
end
