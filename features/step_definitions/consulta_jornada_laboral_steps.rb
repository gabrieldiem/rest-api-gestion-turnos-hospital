def crear_especialidad
  unless @especialidad_creada
    especialidad_body = { nombre: 'Cardiologia', duracion: 20, recurrencia_maxima: 5, codigo: 'card' }.to_json
    response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
    expect(response.status).to eq(201)
  end
  @especialidad_creada = true
end

Dado('que existe un medico registrado con nombre {string} y apellido {string} con matricula {string}') do |nombre, apellido, matricula|
  @matricula = matricula
  crear_especialidad

  medicos_body = { nombre:, apellido:, matricula:, especialidad: 'card' }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que tiene un turno el día {string} a las {string} para {string} con DNI {string} con el medico {string}') do |fecha, hora, username, dni_paciente, matricula|
  paciente_body = { username:, email: "#{username}@test.com", dni: dni_paciente }
  response = Faraday.post('/pacientes', paciente_body.to_json, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  body = {
    dni: dni_paciente,
    turno: {
      fecha:,
      hora:
    }
  }
  response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Entonces('el sistema debe mostrar que hay {string} turnos asignados en total') do |cantidad_turnos|
  @response_body = JSON.parse(@response_turnos.body, symbolize_names: true)
  expect(@response_body[:cantidad_turnos]).to eq(cantidad_turnos.to_i)
end

Entonces('debe listar el turno del {string} a las {string} para {string} con DNI {string}') do |fecha, hora, _username, dni|
  turno_esperado = {
    fecha:,
    hora:,
    paciente: {
      dni:
    }
  }
  expect(@response_body[:turnos]).to include(turno_esperado)
end

Cuando('consulto la jornada del medico con matricula {string}') do |matricula|
  @response_turnos = Faraday.get("/medicos/#{matricula}/turnos-reservados")
  expect(@response_turnos.status).to eq(200)
end

Entonces('el sistema debe indicar que hay {int} turnos asignados') do |cantidad_turnos|
  expect(@response_body[:cantidad_turnos]).to eq(cantidad_turnos)
end

Entonces('debe mostrar el mensaje {string}') do |mensaje|
  @respuesta_fallida_parseada = JSON.parse(@respuesta_fallida.body, symbolize_names: true)
  expect(@respuesta_fallida_parseada[:mensaje_error]).to eq(mensaje)
end

Dado('que no tiene ningún turno asignado') do
end

Cuando('intento consultar la jornada del medico con matricula {string}') do |matricula|
  @respuesta_fallida = Faraday.get("/medicos/#{matricula}/turnos-reservados")
  expect(@respuesta_fallida.status).to eq(404)
end
