require 'date'

Dado('que existe la especialidad {string} con código {string} y tiempo de una consulta de {string} minutos') do |nombre_especialidad, codigo_especialidad, duracion_turno|
  especialidad_body = { nombre: nombre_especialidad, duracion: duracion_turno, recurrencia_maxima: 5, codigo: codigo_especialidad }
  response = Faraday.post('/especialidades', especialidad_body.to_json, { 'Content-Type' => 'application/json' })
  @especialidad = JSON.parse(response.body, symbolize_names: true)
  expect(response.status).to eq(201)
end

Dado('que existe un paciente registrado llamado {string} con username {string}') do |nombre_paciente, username|
  @nombre_paciente = nombre_paciente
  @dni_por_nombre = { nombre_paciente => '000000000' }
  paciente_body = { username:, email: 'paciente_test@test.com', dni: @dni_por_nombre[nombre_paciente] }.to_json
  response = Faraday.post('/pacientes', paciente_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que existe un medico registrado llamado {string} con matricula {string} que atiende en {string}') do |nombre_completo_medico, matricula, especialidad_codigo|
  nombre, apellido = nombre_completo_medico.split(' ', 2)
  medicos_body = { nombre:, apellido:, matricula:, especialidad: especialidad_codigo }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que {string} reservo el turno disponible con el médico de matrícula {string} en la fecha {string} y la hora {string}') do |nombre_paciente, matricula, fecha, hora|
  hora, minutos = hora.split('.', 2)
  body = {
    dni: @dni_por_nombre[nombre_paciente],
    turno: {
      fecha: Date.parse(fecha),
      hora: "#{hora}:#{minutos}"
    }
  }
  response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Cuando('reservo el turno con el medico de matrícula {string} en la fecha {string} y la hora {string}') do |matricula, fecha, hora|
  hora, minutos = hora.split('.', 2)
  body = {
    dni: @dni_por_nombre[@nombre_paciente],
    turno: {
      fecha: Date.parse(fecha),
      hora: "#{hora}:#{minutos}"
    }
  }
  @response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
end

Entonces('recibe el mensaje de error {string}') do |mensaje|
  expect(@response.status).to eq(400)
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['mensaje_error']).to eq(mensaje)
end

Entonces('la respuesta es exitosa') do
  expect(@response.status).to eq(201)
end
