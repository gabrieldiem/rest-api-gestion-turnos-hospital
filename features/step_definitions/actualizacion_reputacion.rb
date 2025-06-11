Before do
  Faraday.post('/reset', {})
end

Dado('que existe el paciente con DNI {string}') do |dni|
  @request_body = { email: 'proof@test.com', dni:, username: 'proof' }
  @response = Faraday.post('/pacientes', @request_body.to_json, {})
end

def crear_especialidad_y_medico
  @codigo_especialidad = 'card'
  body_especialidades = {
    nombre: 'Cardiología',
    duracion: 1,
    recurrencia_maxima: 5,
    codigo: @codigo_especialidad
  }
  @response = Faraday.post('/especialidades', body_especialidades.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
  @matricula_medico = '123456'
  body_medico = {
    nombre: 'Julian',
    apellido: 'Alvarez',
    matricula: @matricula_medico,
    especialidad: @codigo_especialidad
  }
  @response = Faraday.post('/medicos', body_medico.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('que el paciente con DNI {string} tiene {string} turnos reservados con fecha anterior al día de hoy') do |dni, cant_turnos_reservados|
  crear_especialidad_y_medico

  fecha_de_ayer = Date.today - 1
  @id_turnos_reservados = []
  (1..cant_turnos_reservados.to_i).each do |i|
    body = {
      dni:,
      turno: {
        fecha: fecha_de_ayer,
        hora: "8:0#{2 * (i - 1)}"
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
    asistio: true
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
  @response = Faraday.get("/pacientes?username=#{@request_body[:username]}")

  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to eq(reputacion.to_f)
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
  @response = Faraday.get("/pacientes?username=#{@request_body[:username]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be > @reputacion
end

Cuando('no asisto a {string} turnos reservados') do |cant_turnos_no_asistidos|
  @response = Faraday.get("/pacientes/#{@request_body[:dni]}/turnos-reservados")
  expect(@response.status).to eq(200)

  parsed_response = JSON.parse(@response.body, symbolize_names: true)

  @id_turnos_reservados = parsed_response[:turnos].map { |turno| turno[:id] }

  i = 0

  @id_turnos_reservados.each do |id_turno|
    i >= cant_turnos_no_asistidos.to_i ? break : nil

    body = {
      dni_paciente: @request_body[:dni],
      asistio: false
    }
    @id_turno = id_turno if @id_turno.nil?
    @response = Faraday.put("/turnos/#{@id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(200)
    i += 1
  end
end

Entonces('el paciente empeora su reputacion') do
  @response = Faraday.get("/pacientes?username=#{@request_body[:username]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be < @reputacion
end
