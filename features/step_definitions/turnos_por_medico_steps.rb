Dado('que esta registrado el username {string}') do |_string|
  @repo_pacientes = RepostiorioPacientes.new
  @repo_pacientes.delete_all
  registered_body = { email: 'juan.perez@example.com', dni: '42951753', username: }.to_json
  @response = Faraday.post('/pacientes', registered_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('que existe un médico con nombre {string}, apellido {string}, matrícula {string} y especialidad {string} con duración de {string} minutos') do |nombre, apellido, matricula, codigo, duracion|
  RepostiorioEspecialidades.new.delete_all
  RepostiorioMedicos.new.delete_all

  especialidad_body = { nombre: _codigo, duracion:, recurrencia_maxima: 5, codigo: codigo.downcase[0..3] }.to_json
  @response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  medicos_body = { nombre:, apellido:, matricula:, especialidad: especialidad.downcase[0..3] }.to_json
  @response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('que hago una consulta con el username {string}') do |_string|
end

Dado('no hay turnos asignados para el médico con matrícula {string}') do |matricula|
  expect(parsed_response['medico']['matricula']).to matricula
  expect(parsed_response['turnos']).to be_empty
end

Cuando('solicito los turnos disponibles con {string}') do |matricula|
  @response = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
  @parsed_response = JSON.parse(@response.body)
  expect(@response.status).to eq(200)
end

Entonces('recibo los próximos {string} turnos disponibles') do |string|
  @turnos_disponibles = @parsed_response['turnos']
  expect(@turnos_disponibles).not_to be_empty
  expect(@turnos_disponibles.size).to eq(string.to_i)
end

Entonces('son del {string} a las {string} en adelante') do |_fecha, _hora|
  pending
end

Dado('el médico con matrícula {string} tiene un turno asignado el {string} {string}') do |_matricula, _fecha, _hora|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('no se muestran turnos disponibles') do
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que hoy es {string}') do |fecha|
  @fecha_actual = Date.strptime(fecha, '%d/%m/%Y')
  allow(Date).to receive(:today).and_return(@fecha_actual)
end

Dado('el médico con matrícula {string} no tiene turnos disponibles en los próximos {int} días') do |_matricula, _dias|
  pending # Write code here that turns the phrase above into concrete actions
end
