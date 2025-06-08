Before do
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger
  RepositorioTurnos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioMedicos.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que existe un paciente con DNI {string}') do |dni|
  @username = 'juan_salchicon'
  @dni = dni
  request_body = { email: 'juan.salchicon@example.com', dni: @dni, username: @username }.to_json
  @response = Faraday.post('/pacientes', request_body, { 'Content-Type' => 'application/json' })
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

Cuando('envío los datos de asistencia con DNI {string}, ID de turno {string} y asistencia {string}') do |dni, _id_turno, asistencia|
  body = {
    dni_paciente: dni,
    asistio: asistencia
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
  response = Faraday.get("/turnos/#{@id_turno}")
  expect(response.status).to eq(200)
  expect(response.body).to include(estado)
end

Entonces('el estado del turno queda actualizado como {string}') do |estado|
  expect(@response.status).to eq(200)
  expect(@parsed_response[:asistencia]).to eq(estado)
end

Dado('que no existe un paciente con DNI {string}') do |_string|
  # Hacer nada, ya que el paciente no existe
end

Entonces('recibo un mensaje de error indicando que el paciente no existe') do
  expect(@response.status).to eq(400)
  expect(@response.body).to include('Paciente inexsitente')
end

Dado('no existe un turno con ID {string}') do |_string|
  # Hacer nada, ya que el turno no existe
end

Entonces('recibo un mensaje de error indicando que el turno no existe') do
  expect(@response.status).to eq(404)
  expect(@response.body).to include('Paciente inexsitente')
end

Entonces('recibo un mensaje de error indicando que el turno no pertenece a ese paciente') do
  expect(@response.status).to eq(400)
  expect(@response.body).to include('El turno no pertenece a ese paciente')
end
