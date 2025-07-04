def crear_paciente(username, dni, email)
  @username = username
  @dni = dni
  request_body = { email:, dni: @dni, username: @username }.to_json
  Faraday.post('/pacientes', request_body, { 'Content-Type' => 'application/json' })
end

Dado('que existe un paciente con DNI {string}') do |dni|
  @response = crear_paciente('juan_salchicon', dni, 'juan.salchicon@example.com')
  expect(@response.status).to eq(201)
end

def construir_especialidad
  nombre_especialidad = 'Cardiología'
  duracion_turno = 30
  @codigo_especialidad = nombre_especialidad.downcase[0..3]
  @duracion_turno = duracion_turno.to_i
  {
    nombre: nombre_especialidad,
    duracion: duracion_turno,
    recurrencia_maxima: 5,
    codigo: @codigo_especialidad
  }
end

def construir_medico
  nombre_medico = 'Julian'
  apellido_medico = 'Alvarez'
  @matricula_medico = '123456'

  {
    nombre: nombre_medico,
    apellido: apellido_medico,
    matricula: @matricula_medico,
    especialidad: @codigo_especialidad
  }
end

Dado('existe un turno con ID {string} para ese paciente') do |id_turno|
  body = construir_especialidad
  @response = Faraday.post('/especialidades', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  body = construir_medico

  @response = Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  @id_turno = id_turno
  fecha_de_maniana = Date.today + 1

  body = {
    dni: @dni,
    turno: {
      fecha: fecha_de_maniana,
      hora: '8:00'
    }
  }
  @response = Faraday.post("/medicos/#{@matricula_medico}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  @id_turno = JSON.parse(@response.body, symbolize_names: true)[:id]
  expect(@response.status).to eq(201)
end

Dado('existe un turno con ID {string} para otro paciente') do |id_turno|
  dni_otro_paciente = 123_000
  crear_paciente('juan_perez', dni_otro_paciente, 'juan_perez@example.com')

  body = construir_especialidad
  @response = Faraday.post('/especialidades', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  body = construir_medico
  @response = Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  @id_turno = id_turno
  fecha_de_maniana = Date.today + 1

  body = {
    dni: dni_otro_paciente,
    turno: {
      fecha: fecha_de_maniana,
      hora: '8:00'
    }
  }
  @response = Faraday.post("/medicos/#{@matricula_medico}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  @id_turno = JSON.parse(@response.body, symbolize_names: true)[:id]
  expect(@response.status).to eq(201)
end

Cuando('envío los datos de asistencia con DNI {string}, ID de turno {string} y asistencia {string}') do |dni, id_turno, asistencia|
  body = {
    dni_paciente: dni,
    asistio: asistencia != 'ausente'
  }
  @id_turno = id_turno if @id_turno.nil?
  @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
  @parsed_response = JSON.parse(@response.body, symbolize_names: true)
end

Cuando('envío los datos actualizados con DNI {string}, ID de turno {string} y asistencia {string}') do |dni, _id_turno, asistencia|
  body = {
    dni_paciente: dni,
    asistio: asistencia != 'ausente'
  }
  @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
  @parsed_response = JSON.parse(@response.body, symbolize_names: true)
end

Entonces('el estado del turno queda como {string}') do |estado|
  response = Faraday.get("/turnos/#{@id_turno}")
  @parsed_response = JSON.parse(response.body, symbolize_names: true)
  expect(response.status).to eq(200)
  expect(@parsed_response[:estado]).to include(estado)
end

Dado('ya está registrada la asistencia para este turno como {string}') do |estado|
  body = {
    dni_paciente: @dni,
    asistio: estado != 'ausente'
  }
  @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
  @parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(@response.status).to eq(200)
  expect(@parsed_response[:estado]).to eq(estado)
end

Entonces('el estado del turno queda actualizado como {string}') do |estado|
  @response = Faraday.get("/turnos/#{@id_turno}")
  @parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(@response.status).to eq(200)
  expect(@parsed_response[:estado]).to include(estado)
end

Dado('que no existe un paciente con DNI {string}') do |_string|
  # Hacer nada, ya que el paciente no existe
end

Entonces('recibo un mensaje de error indicando que el paciente no existe') do
  expect(@response.status).to eq(404)
  expect(@parsed_response[:mensaje_error]).to include('Paciente inexistente')
end

Dado('no existe un turno con ID {string}') do |_string|
  # Hacer nada, ya que el turno no existe
end

Entonces('recibo un mensaje de error indicando que el turno no existe') do
  expect(@response.status).to eq(404)
  expect(@parsed_response[:mensaje_error]).to include('Turno inexistente')
end

Entonces('recibo un mensaje de error indicando que el turno no pertenece a ese paciente') do
  expect(@response.status).to eq(400)
  expect(@parsed_response[:mensaje_error]).to include('El turno no pertenece a ese paciente')
end

Dado('que existe un turno con ID {string} asignado al paciente con DNI {string}') do |id_turno, dni|
  body = construir_especialidad
  @response = Faraday.post('/especialidades', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  body = construir_medico

  @response = Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  @id_turno = id_turno
  fecha_de_maniana = Date.today + 1

  body = {
    dni:,
    turno: {
      fecha: fecha_de_maniana,
      hora: '8:00'
    }
  }
  @response = Faraday.post("/medicos/#{@matricula_medico}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  @id_turno = JSON.parse(@response.body, symbolize_names: true)[:id]
  expect(@response.status).to eq(201)
end
