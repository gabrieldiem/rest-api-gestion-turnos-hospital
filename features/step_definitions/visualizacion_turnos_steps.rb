Dado('que soy un paciente registrado con el username {string}') do |username|
  @username_registrado = username
  @dni_registrado = '44765456'
  body = { email: 'juan.perez@example.com', dni: @dni_registrado, username: }
  @response = Faraday.post('/pacientes', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('que hay {int} turnos reservados para {string}') do |turnos, _username|
  @especialidad_nombre = 'Cardiología'
  @duracion = 30
  @especialidad_codigo = 'card'

  especialidad_body = { nombre: @especialidad_nombre, duracion: duracion_turno, recurrencia_maxima: 5, codigo: @especialidad_codigo }
  response = Faraday.post('/especialidades', especialidad_body.to_json, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  @medico_nombre = 'Juan'
  @medico_apellido = 'Pérez'
  @matricula = 'NAC456'

  medicos_body = { nombre: @medico_nombre, apellido: @medico_apellido, matricula:, especialidad: especialidad_codigo }.to_json
  response = Faraday.post('/medicos', medicos_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)

  @cantidad_de_turnos_esperados = turnos

  [1..turnos].each do |i|
    body = {
      dni: @dni_paciente,
      turno: {
        fecha: Date.today + i,
        hora: '8:00'
      }
    }
    respuesta = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
    expect(respuesta.status).to eq(201)
  end
end

Cuando('quiero ver mis turnos') do
  @respuesta = Faraday.get("/pacientes/#{@dni_registrado}/turnos-reservados")
  expect(@respuesta.status).to eq(200)
  @respuesta_parseada = JSON.parse(@respuesta.body, symbolize_names: true)
end

Entonces('debo ver un mensaje con la lista de mis turnos y todos sus datos deben ser correctos') do
  expect(@respuesta_parseada['turnos']).to be_a(Array)
  if @cantidad_de_turnos_esperados == 0
    expect(@respuesta_parseada['turnos']).to be_empty
  else
    @respuesta_parseada['turnos'].each do |turno|
      expect(turno).to include(:fecha, :hora, :medico)
      expect(turno['medico']['matricula']).to eq(@matricula)
      expect(turno['medico']['nombre']).to eq(@medico_nombre)
      expect(turno['medico']['apellido']).to eq(@medico_apellido)
      expect(turno['especialidad']['nombre']).to eq(@especialidad_codigo)
    end
  end
  expect(@respuesta_parseada['turnos'].size).to eq(@cantidad_de_turnos_esperados)
end
