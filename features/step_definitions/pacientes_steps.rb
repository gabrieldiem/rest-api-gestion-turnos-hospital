Dado('que mi username es {string}') do |username|
  @username = username
end

Cuando('me registro con DNI {string} y email {string}') do |dni, email|
  RepositorioPacientes.new.delete_all # Limpiar la base de datos antes de cada prueba
  @request_body = { email:, dni:, username: @username }
  @response = Faraday.post('/pacientes', @request_body.to_json, {})
end

Cuando('me registro nuevamente con DNI {string} y email {string}') do |dni, email|
  @request_body = { email:, dni:, username: @username }
  @response = Faraday.post('/pacientes', @request_body.to_json, {})
end

Entonces('recibo un mensaje de éxito') do
  expect(@response.status).to eq(201)
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['dni']).to eq(@request_body[:dni])
  expect(parsed_response['email']).to eq(@request_body[:email])
  expect(parsed_response['username']).to eq(@request_body[:username])
  expect(parsed_response['id']).not_to be_nil
  expect(parsed_response['created_on']).not_to be_nil
end

Dado('que existe un paciente registrado con DNI {string}') do |dni|
  RepositorioPacientes.new.delete_all # Limpiar la base de datos antes de cada prueba
  registered_body = { email: 'juan.perez@example.com', dni:, username: @username }.to_json
  @response = Faraday.post('/pacientes', registered_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Entonces('recibo un mensaje de error {string}') do |error_msg|
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['error']).to eq(error_msg)
end
