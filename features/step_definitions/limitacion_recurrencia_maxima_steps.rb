Before do
  @fecha_de_maniana = Date.today + 1
end

def crear_medico(especialidad, matricula)
  codigo_especialidad = especialidad.downcase[0..3]
  body = {
    nombre: 'Julian',
    apellido: 'Alvarez',
    matricula:,
    especialidad: codigo_especialidad
  }
  Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  matricula
end

Dado('que el paciente con DNI {string} esta registrado en el sistema') do |dni_paciente|
  @username = 'carlosbianchi'
  @dni = dni_paciente
  request_body = { email: 'carlosbianchi@example.com', dni: @dni, username: @username }.to_json
  @response_paciente = Faraday.post('/pacientes', request_body, { 'Content-Type' => 'application/json' })
  expect(@response_paciente.status).to eq(201)
end

Dado('la especialidad {string} tiene una recurrencia máxima de turnos configurada como {string}') do |especialidad, recurrencia|
  especialidad_body = { nombre: especialidad, duracion: 20, recurrencia_maxima: recurrencia.to_i, codigo: especialidad.downcase[0..3] }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(201)
end

Dado('que la fecha de hoy es {string}') do |fecha|
  @fecha_de_hoy = Date.parse(fecha)
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Dado('el paciente con DNI {string} no tiene turnos asignados') do |dni_paciente|
end

Cuando('el paciente solicita un turno para la especialidad {string}') do |especialidad|
  matricula = crear_medico(especialidad, '324123412')
  body = {
    dni: @dni,
    turno: {
      fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(Date.today.to_s)),
      hora: '09:00'
    }
  }
  cuando_pido_los_feriados(@fecha_de_hoy.year, [Date.parse(@fecha_de_maniana.to_s)])
  @response_reserva_turno = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Entonces('el sistema asigna el turno exitosamente') do
  expect(@response_reserva_turno.status).to eq(201)
end

Dado('el paciente con DNI {string} tiene {int} turnos asignados para la especialidad {string}') do |dni, cantidad_turnos, especialidad|
  matricula = crear_medico(especialidad, '222222')

  hora_base = Hora.new(10, 0)

  cantidad_turnos.times do |i|
    @hora_actual = hora_base + Hora.new(i, 0)

    body = {
      dni:, # Usar el valor de dni pasado como argumento
      turno: {
        fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(Date.today.to_s)),
        hora: @convertidor_de_tiempo.presentar_hora(@hora_actual)
      }
    }
    cuando_pido_los_feriados(@fecha_de_hoy.year, [Date.parse(@fecha_de_maniana.to_s)])
    @response_reserva_turno = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
    allow(Date).to receive(:today).and_return(@fecha_de_hoy)
  end
end

Dado('que {string} tiene una recurrencia máxima de {int} turnos') do |especialidad, recurrencia|
  especialidad = RepositorioEspecialidades.new(Configuration.logger).find_by_codigo(especialidad.downcase[0..3])
  expect(especialidad).not_to be_nil
  expect(especialidad.recurrencia_maxima).to eq(recurrencia)
end

Cuando('el paciente solicita un turno adicional para la especialidad {string}') do |especialidad|
  hora_a_pedir = @hora_actual + Hora.new(1, 0)
  matricula = crear_medico(especialidad, '33333333')

  body = {
    dni: @dni,
    turno: {
      fecha: @convertidor_de_tiempo.presentar_fecha(Date.parse(Date.today.to_s)),
      hora: @convertidor_de_tiempo.presentar_hora(hora_a_pedir)
    }
  }
  cuando_pido_los_feriados(@fecha_de_hoy.year, [Date.parse(@fecha_de_maniana.to_s)])
  @response_reserva_turno = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Entonces('el sistema rechaza el pedido con el mensaje {string}') do |mensaje|
  expect(@response_reserva_turno.status).to eq(400)
  response_body = JSON.parse(@response_reserva_turno.body, symbolize_names: true)
  expect(response_body[:mensaje_error]).to eq(mensaje)
end
