def crear_medico(especialidad)
  codigo_especialidad = especialidad.downcase[0..3]
  matricula = '123456'
  body = {
    nombre: 'Julian',
    apellido: 'Alvarez',
    matricula:,
    especialidad: codigo_especialidad
  }
  Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  matricula
end

Before do
  @fecha_de_maniana = Date.today + 1
end
Dado('la especialidad tiene una recurrencia máxima de turnos configurada como {string}') do |recurrencia|
  especialidad_body = { nombre: 'Cardiologia', duracion: 20, recurrencia_maxima: recurrencia.to_i, codigo: 'card' }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que la fecha de hoy es {string}') do |fecha|
  @fecha_de_hoy = Date.parse(fecha)
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Dado('el paciente con DNI {string} no tiene turnos asignados') do |dni_paciente|
  @username = 'carlosbianchi'
  @dni = dni_paciente
  request_body = { email: 'carlosbianchi@example.com', dni: @dni, username: @username }.to_json
  @response_paciente = Faraday.post('/pacientes', request_body, { 'Content-Type' => 'application/json' })
  expect(@response_paciente.status).to eq(201)
end

Cuando('el paciente solicita un turno para la especialidad {string}') do |especialidad|
  matricula = crear_medico(especialidad)
  body = {
    dni: @dni,
    turno: {
      fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(Date.today.to_s)),
      hora: '08:00'
    }
  }
  cuando_pido_los_feriados(@fecha_de_hoy.year, [Date.parse(@fecha_de_maniana.to_s)])
  @response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Entonces('el sistema asigna el turno exitosamente') do
  expect(@response.status).to eq(201)
end

Dado('el paciente con DNI {string} tiene un turno asignado para la especialidad {string}') do |_string, _string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('el paciente con DNI {string} tiene {int} turnos asignados para la especialidad {string}') do |_string, _int, _string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que {string} tiene una recurrencia máxima de {int} turnos') do |_string, _int|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando('el paciente solicita un turno adicional para la especialidad {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('el sistema rechaza el pedido con el mensaje {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end
