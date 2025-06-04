require 'date'

Dado('que existe un doctor de nombre {string} y apellido {string} registrado con matrícula {string}') do |nombre, apellido, matricula|
  RepositorioMedicos.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all

  especialidad_body = { nombre: 'Cardiologia', duracion: 20, recurrencia_maxima: 5, codigo: 'card' }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  medicos_body = { nombre:, apellido:, matricula:, especialidad: 'card' }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que hay un paciente registrado con username {string}') do |username|
  RepositorioPacientes.new(@logger).delete_all

  @dni_paciente = '000000000'
  paciente_body = { username:, email: 'paciente_test@test.com', dni: @dni_paciente }.to_json
  response = Faraday.post('/pacientes', paciente_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('el Dr. con matricula {string} tiene un turno disponible el {string} a las {string}') do |matricula, fecha, hora|
  response = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
  parsed_response = JSON.parse(response.body)
  fecha_formateada = Date.parse(fecha).strftime('%Y-%m-%d')
  expect(response.status).to eq(200)
  expect(parsed_response['turnos']).to include('fecha' => fecha_formateada, 'hora' => hora)
end

Cuando('reservo el turno con el médico de matrícula {string} en la fecha {string} y la hora {string}') do |matricula, fecha, hora|
  body = {
    dni: @dni_paciente,
    turno: {
      fecha:,
      hora:
    }
  }
  response = Faraday.post("/medicos/#{matricula}/turnos-disponibles", body.to_json, { 'Content-Type' => 'application/json' })

  expect(response.status).to eq(201)
  @turno_reservado = JSON.parse(response.body, symbolize_names: true)
  puts @turno_reservado
  expect(@turno_reservado[:dni]).to eq(@dni_paciente)
  expect(@turno_reservado[:matricula]).to eq(matricula)
  expect(@turno_reservado[:turno][:fecha]).to eq(Date.parse(fecha).strftime('%Y-%m-%d'))
  expect(@turno_reservado[:turno][:hora]).to eq(hora)
  expect(@turno_reservado[:created_at]).not_to be_nil
  expect(@turno_reservado[:id]).not_to be_nil
end

Entonces('recibo el mensaje {string}') do |_string|
end

Cuando('reservo el turno con el médico de matrícula {string} en la fecha {string} y la hora {string} con el username {string}') do |_string, _string2, _string3, _string4|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('el Dr. con matricula {string} tenía un turno disponible el {string} a las {string} y alguien más lo reservó') do |_matricula, _fecha, _hora|
  pending # Write code here that turns the phrase above into concrete actions
end
