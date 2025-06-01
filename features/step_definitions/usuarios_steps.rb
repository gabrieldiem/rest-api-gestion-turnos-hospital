Dado('que mi username es {string}') do |username|
  @username = username
end

Cuando('me registro con DNI {string} y email {string}') do |dni, email|
  @request_body = { email: email, dni: dni, username: @username }.to_json
end

Entonces('recibo un mensaje de éxito') do
  @response = Faraday.post('/pacientes', @request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['dni']).to eq(@request_body[:dni])
  expect(parsed_response['email']).to eq(@request_body[:email])
  expect(parsed_response['username']).to eq(@request_body[:username])
end

Dado('que existe un paciente registrado con DNI {string}') do |string|
  registered_body = { email: "juan.perez@example.com", dni: dni, username: @username }.to_json
  @response = Faraday.post('/pacientes', registered_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Entonces('recibo un mensaje de error {string}') do |error_msg|
  @response = Faraday.post('/pacientes', registered_body, { 'Content-Type' => 'application/json' })
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['error']).to eq(error_msg)
end