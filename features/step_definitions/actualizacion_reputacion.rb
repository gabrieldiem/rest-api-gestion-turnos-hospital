def construir_especialidad
  nombre_especialidad = 'Cardiología'
  duracion_turno = 1
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

Dado('que existe el paciente con DNI {string}') do |dni|
  @request_body = { email: 'proof@test.com', dni:, username: 'proof_user' }
  @response = Faraday.post('/pacientes', @request_body.to_json, {})
end

Dado('que el paciente con DNI {string} tiene {string} turnos reservados con fecha anterior al día de hoy') do |dni, cant_turnos_reservados|
  body = construir_especialidad
  @response = Faraday.post('/especialidades', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  body = construir_medico

  @response = Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  @id_turno = id_turno
  fecha_de_ayer = Date.today - 1

  @id_turnos_reservados = []

  (1..cant_turnos_reservados.to_i).each do |i|
    body = {
      dni:,
      turno: {
        fecha: fecha_de_ayer,
        hora: "8:0#{i}"
      }
    }
    @response = Faraday.post("/medicos/#{@matricula_medico}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
    @parsed_response = JSON.parse(@response.body, symbolize_names: true)
    @id_turnos_reservados << @parsed_response[:id]
    expect(@response.status).to eq(201)
  end
end

Dado('que el paciente con DNI {string} asitio a {string} turnos') do |dni, cant_turnos_asistidos|
  body = {
    dni_paciente: dni,
    asistio: asistencia != 'ausente'
  }

  i = 0

  @id_turnos_reservados.each do |id_turno|
    i >= cant_turnos_asistidos.to_i ? break : nil

    @id_turno = id_turno if @id_turno.nil?
    @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
    @parsed_response = JSON.parse(@response.body, symbolize_names: true)

    i += 1
  end
end

Entonces('su reputacion es de {string}') do |reputacion|
  @response = Faraday.get("/pacientes/#{@request_body[:dni]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to eq(reputacion.to_i)
  @reputacion = parsed_response[:reputacion]
end

Cuando('asisto a {string} turnos reservados') do |cant_turnos_asistidos|
  i = 0

  @id_turnos_reservados.each do |id_turno|
    i >= cant_turnos_asistidos.to_i ? break : nil

    body = {
      dni_paciente: @request_body[:dni],
      asistio: true
    }
    @id_turno = id_turno if @id_turno.nil?
    @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(200)
    i += 1
  end
end

Entonces('el paciente mejora su reputacion') do
  @response = Faraday.get("/pacientes/#{@request_body[:dni]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be > @reputacion
end

Cuando('no asisto a {string} turnos reservados') do |_cant_turnos_no_asistidos|
  @response = Faraday.get("/pacientes/#{@request_body[:dni]}")
  expect(@response.status).to eq(200)

  parsed_response = JSON.parse(@response.body, symbolize_names: true)

  @id_turnos_reservados = parsed_response[:turnos_reservados].map { |turno| turno[:id] }

  i = 0

  @id_turnos_reservados.each do |id_turno|
    i >= cant_turnos_asistidos.to_i ? break : nil

    body = {
      dni_paciente: @request_body[:dni],
      asistio: true
    }
    @id_turno = id_turno if @id_turno.nil?
    @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(200)
    i += 1
  end
end

Entonces('el paciente empeora su reputacion') do
  @response = Faraday.get("/pacientes/#{@request_body[:dni]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be < @reputacion
end
