Dado('Y que existe un medico registrado con nombre {string} y apellido {string} con matricula {string}') do |nombre, apellido, matricula|
  @matricula = matricula
  especialidad_body = { nombre: 'Cardiologia', duracion: 20, recurrencia_maxima: 5, codigo: 'card' }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  medicos_body = { nombre:, apellido:, matricula:, especialidad: 'card' }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que tiene un turno el día {string} a las {string} para {string} con DNI {string} con el medico {string}') do |fecha, hora, username, dni_paciente, matricula|
  paciente_body = { username:, email: "#{username}@test.com", dni: dni_paciente }.to_json
  response = Faraday.post('/pacientes', paciente_body, { 'Content-Type' => 'application/json' })
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

Dado('tiene un turno el día {string} a las {string} para {string} con DNI {string} con el medico {string}') do |_string, _string2, _string3, _string4, _string5|
end

Cuando('consulto la jornada del profesional con matricula {string}') do |matricula|
  @response_turnos = Faraday.get("/medicos/#{matricula}/turnos-reservados")
  expect(@response_turnos.status).to eq(200)
end

Entonces('el sistema debe mostrar que hay {string} turnos asignados en total') do |cantidad_turnos|
  @response_body = JSON.parse(@response_turnos.body, symbolize_names: true)
  expect(response_body[:cantidad_turnos]).to eq(cantidad_turnos.to_i)
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

Cuando('consulto la jornada del medico con matricula {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que no tiene ningún turno asignado') do
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('el sistema debe indicar que hay {string} turnos asignados') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('debe mostrar el mensaje {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end
