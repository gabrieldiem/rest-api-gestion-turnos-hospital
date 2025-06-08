require 'date'

Before do
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger
  @convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')

  RepositorioTurnos.new(@logger).delete_all
  RepositorioMedicos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que existe un doctor de nombre {string} y apellido {string} registrado con matrícula {string}') do |nombre, apellido, matricula|
  @matricula = matricula
  especialidad_body = { nombre: 'Cardiologia', duracion: 20, recurrencia_maxima: 5, codigo: 'card' }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  medicos_body = { nombre:, apellido:, matricula:, especialidad: 'card' }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que hay un paciente registrado con username {string}') do |username|
  @dni_paciente = '000000000'
  paciente_body = { username:, email: 'paciente_test@test.com', dni: @dni_paciente }.to_json
  response = Faraday.post('/pacientes', paciente_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('el Dr. con matricula {string} tiene un turno disponible el {string} a las {string}') do |matricula, fecha, hora|
  # Nada para hacer
end

Cuando('reservo el turno con el médico de matrícula {string} en la fecha {string} y la hora {string}') do |matricula, fecha, hora|
  body = {
    dni: @dni_paciente,
    turno: {
      fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(fecha)),
      hora:
    }
  }
  response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })

  @turno_reservado = JSON.parse(response.body, symbolize_names: true)
  expect(response.status).to eq(201)
end

Cuando('intento reservar el turno con el médico de matrícula {string} en la fecha {string} y la hora {string}') do |matricula, fecha, hora|
  body = {
    dni: @dni_paciente,
    turno: {
      fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(fecha)),
      hora:
    }
  }
  @respuesta_fallida = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })

  expect(@respuesta_fallida.status).not_to be(201)
end

Entonces('recibo el mensaje de operacion exitosa para la fecha {string} y la hora {string}') do |fecha, hora|
  expect(@turno_reservado[:dni]).to eq(@dni_paciente)
  expect(@turno_reservado[:matricula]).to eq(@matricula)
  expect(@turno_reservado[:turno][:fecha]).to eq(@convertidor_de_tiempo.presentar_fecha(Date.parse(fecha)))
  expect(@turno_reservado[:turno][:hora]).to eq(hora)
  expect(@turno_reservado[:created_at]).not_to be_nil
  expect(@turno_reservado[:id]).not_to be_nil
end

Entonces('recibo el mensaje de operacion fallida') do
  parsed_response = JSON.parse(@respuesta_fallida.body, symbolize_names: true)
  expect(parsed_response[:mensaje_error]).to include('No existe un médico con la matrícula')
end

Cuando('intento reservar el turno con el médico de matrícula {string} en la fecha {string} y la hora {string} con el username {string}') do |matricula, fecha, hora, _username|
  body = {
    dni: '66666666',
    turno: {
      fecha:,
      hora:
    }
  }

  @respuesta_fallida = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
end

Dado('el Dr. con matricula {string} tenía un turno disponible el {string} a las {string} y alguien más lo reservó') do |matricula, fecha, hora|
  medico = RepositorioMedicos.new(@logger).find_by_matricula(matricula)
  paciente = Paciente.new('test_user@email.com', '11111111', 'test_user', 1)
  RepositorioPacientes.new(@logger).save(paciente)
  fecha = Date.parse(fecha)
  hora = Hora.new(hora[0..1].to_i, hora[3..4].to_i)
  turno = Turno.new(paciente, medico, Horario.new(fecha, hora))
  RepositorioTurnos.new(@logger).save(turno)
  expect(turno.id).not_to be_nil
end

Entonces('recibo el mensaje {string}') do |msg|
  parsed_response = JSON.parse(@respuesta_fallida.body)
  expect(parsed_response['mensaje_error']).to eq(msg)
end
