Dado('que existe la especialidad {string} con código {string}') do |especialidad, codigo|
  repo_especialidades = RepositorioEspecialidades.new(@logger)
  especialidad = Especialidad.new(especialidad, 30, 3, codigo)
  @especialidad = especialidad
  repo_especialidades.save(especialidad)
  expect(repo_especialidades.find(especialidad.id)).not_to be_nil
end

Dado('que ingreso el nombre {string}, apellido {string}, matrícula {string} y especialidad {string} para el médico') do |nombre, apellido, matricula, especialidad|
  @request_body = {
    nombre:,
    apellido:,
    matricula:,
    especialidad:
  }
end

Cuando('doy de alta al medico') do
  request_body_json = @request_body.to_json
  @response = Faraday.post('/medicos', request_body_json, { 'Content-Type' => 'application/json' })
end

Entonces('el médico se registra exitosamente') do
  parsed_response = JSON.parse(@response.body)

  expect(@response.status).to eq 201
  expect(parsed_response['nombre']).to eq @request_body[:nombre]
  expect(parsed_response['apellido']).to eq @request_body[:apellido]
  expect(parsed_response['matricula']).to eq @request_body[:matricula]
  expect(parsed_response['especialidad']).to eq @request_body[:especialidad]
  expect(parsed_response['id']).not_to be_nil
  expect(parsed_response['created_on']).not_to be_nil
end

Dado('que ingreso el nombre {string}, apellido {string}, matrícula {string} y especialidad inexistente {string} para el médico') do |nombre, apellido, matricula, especialidad|
  @request_body = {
    nombre:,
    apellido:,
    matricula:,
    especialidad:
  }
end

Entonces('recibo una respuesta de error de creación de médico') do
  parsed_response = JSON.parse(@response.body)

  expect(@response.status).to eq 400
  expect(parsed_response['mensaje_error']).to eq('Para crear un médico se requiere una especialidad existente')
end
